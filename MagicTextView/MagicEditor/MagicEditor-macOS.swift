import AppKit

class MagicEditorViewController: NSViewController {

    private var textView: MagicTextView

    init() {
        self.textView = MagicTextView()
        super.init(nibName: nil, bundle: nil)

        textView.delegate = self
        textView.textContentStorage?.delegate = self
        textView.textLayoutManager?.delegate = textView
        textView.allowsUndo = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = NSView()
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
        let marker = NSMutableAttributedString(string: "User\n")
        marker.addAttribute(.magicRoleMarker, value: NSNumber(value: 1), range: NSRange(location: 0, length: 4))

        // Attachment Example
        let attachment = RoleAttachment()
        attachment.role = "User"
        let attachmentString = NSAttributedString(attachment: attachment)

        textView.textContentStorage?.performEditingTransaction {
            textView.textContentStorage?.textStorage?.insert(marker, at: 0)
            textView.textContentStorage?.textStorage?.append(attachmentString)
        }

//        example_serialize()
//        example_print_document()

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

    func example_serialize() {
        let str = textView.attributedString()
        let range = NSRange(location: 0, length: str.length)
        str.enumerateAttributes(in: range) { attributes, range, stop in
            print(attributes, range)
            print("---")
        }
    }

    func example_print_document() {
        let str = textView.attributedString()
        let range = NSRange(location: 0, length: str.length)
        let doc = try? str.data(from: range, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        print(String(data: doc!, encoding: .utf8)!)
    }
}

extension MagicEditorViewController: NSTextContentManagerDelegate {

    func textContentManager(_ textContentManager: NSTextContentManager, shouldEnumerate textElement: NSTextElement, options: NSTextContentManager.EnumerationOptions = []) -> Bool {
        return true // This is where you can decide to show or hide text elements
    }
}

extension MagicEditorViewController: NSTextContentStorageDelegate {

    func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        let originalText = textContentStorage.textStorage!.attributedSubstring(from: range)
        if originalText.attribute(.magicRoleMarker, at: 0, effectiveRange: nil) != nil {

            // Create attributes and apply them to original string
            let attributes: [NSAttributedString.Key: AnyObject] = [.foregroundColor: NSColor.systemRed]
            let attributedString = NSMutableAttributedString(attributedString: originalText)
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttributes(attributes, range: range)

            return NSTextParagraph(attributedString: attributedString)
        } else {
            return nil
        }
    }
}

extension MagicEditorViewController: NSTextViewDelegate {

    func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }

        let selectedRange = textView.selectedRange()
        if selectedRange.length == 0 {
            if selectedRange.location > 0 && selectedRange.location < textView.string.count {
                let attributes = textView.textStorage?.attributes(at: selectedRange.location - 1, effectiveRange: nil)
                textView.typingAttributes = attributes ?? [:]
            }
        }
    }
}

// MARK: TextView

class MagicTextView: NSTextView {
}

extension MagicTextView: NSTextLayoutManagerDelegate {

    func textLayoutManager(_ textLayoutManager: NSTextLayoutManager, textLayoutFragmentFor location: any NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment {
        let ignore = NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
        let location = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)

        // Throws exception if the location is outside the bounds of the length, also when location and length are 0.
        guard let length = textStorage?.length, location < length else {
            return ignore
        }

        // Get attribute of interest and return a special fragment with additional visual treatments.
        guard let textStorage = textContentStorage?.textStorage else {
            return ignore
        }
        guard textStorage.attribute(.magicRoleMarker, at: location, effectiveRange: nil) as? NSNumber != nil else {
            return ignore
        }
        return MagicRoleFragment(textElement: textElement, range: textElement.elementRange)
    }
}
