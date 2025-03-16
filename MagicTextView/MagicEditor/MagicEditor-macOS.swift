import AppKit

class MagicEditorViewController: NSViewController {

    private var textView: NSTextView

    init() {
        self.textView = NSTextView()
        super.init(nibName: nil, bundle: nil)

        textView.delegate = self
        textView.textContentStorage?.delegate = self
        textView.textLayoutManager?.delegate = self
        textView.allowsUndo = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let url = Bundle.main.url(forResource: "README", withExtension: "md")!
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .defaultAttributes: [
                    NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15),
                ],
            ]
            try textView.textStorage?.read(from: url, options: options, documentAttributes: nil, error: ())
        } catch {
            print(error)
        }

        // Marker Example
        let role = NSMutableAttributedString(string: "User\n")
        role.addAttribute(.roleAttribute, value: NSNumber(value: 1), range: NSRange(location: 0, length: 4))

        // Attachment Example
        let attachment = RoleAttachment()
        attachment.role = "user"
        let attachmentString = NSAttributedString(attachment: attachment)

        textView.textContentStorage?.performEditingTransaction {
            textView.textContentStorage?.textStorage?.insert(role, at: 0)
            textView.textContentStorage?.textStorage?.append(attachmentString)
        }

//        debug_serialize()
//        debug_print_document()

        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func showPopover(_ fragment: NSTextLayoutFragment) {
        print("Fragment:", fragment)
    }

    func debug_serialize() {
        let str = textView.attributedString()
        let range = NSRange(location: 0, length: str.length)
        str.enumerateAttributes(in: range) { attributes, range, stop in
            print(attributes, range)
            print("---")
        }
    }

    func debug_print_document() {
        let str = textView.attributedString()
        let range = NSRange(location: 0, length: str.length)
        let doc = try? str.data(from: range, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        print(String(data: doc!, encoding: .utf8)!)
    }
}

extension MagicEditorViewController: NSTextContentManagerDelegate {

    // This is where attributes can be shown or hidden. They are all shown by default.
    func textContentManager(_ textContentManager: NSTextContentManager, shouldEnumerate textElement: NSTextElement, options: NSTextContentManager.EnumerationOptions = []) -> Bool {
        return true
    }
}

extension MagicEditorViewController: NSTextContentStorageDelegate {

    // This is where attributes can be located and modified. This will only affect the attributed string
    // attributes for the attributes (e.g. font, foreground color, etc)
    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        let original = textContentStorage.textStorage!.attributedSubstring(from: range)

        // Decorate custom attributes
        if original.attribute(.roleAttribute, at: 0, effectiveRange: nil) != nil {
            let attributes: [NSAttributedString.Key: AnyObject] = [.foregroundColor: NSColor.systemRed]
            let attributedString = NSMutableAttributedString(attributedString: original)
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttributes(attributes, range: range)
            return NSTextParagraph(attributedString: attributedString)
        }

        return nil
    }
}

extension MagicEditorViewController: NSTextLayoutManagerDelegate {

    // This is where attributes can receive a custom layout (e.g. custom view) — I think this view is just
    // applied as a background to the attributed string. Throws an exception if the location is outside the bounds
    // of the length, also when location and length are 0.
    func textLayoutManager(_ textLayoutManager: NSTextLayoutManager, textLayoutFragmentFor location: any NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment {
        let ignore = NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
        let location = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)

        guard let length = textView.textStorage?.length, location < length else {
            return ignore
        }
        guard let textStorage = textView.textContentStorage?.textStorage else {
            return ignore
        }

        // Decorate layout of custom attributes
        if textStorage.attribute(.roleAttribute, at: location, effectiveRange: nil) as? NSNumber != nil {
            return RoleFragment(textElement: textElement, range: textElement.elementRange)
        }

        return ignore
    }
}

extension MagicEditorViewController: NSTextViewDelegate {
}
