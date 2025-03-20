import UIKit

class MagicEditorViewController: UIViewController {

    lazy var textView: UITextView = {
        let textLayoutManager = NSTextLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: view.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        textLayoutManager.textContainer = textContainer

        let textContentStorage = NSTextContentStorage()
        textContentStorage.delegate = self
        textContentStorage.addTextLayoutManager(textLayoutManager)

        let textView = UITextView(frame: view.bounds, textContainer: textContainer)
        textView.delegate = self
        textView.textLayoutManager?.delegate = self
        textView.textStorage.delegate = self
        textView.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        return textView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    func setAttributedString(_ attributedString: NSAttributedString) {
        if textView.textStorage.isEqual(to: attributedString) == false {
            textView.textStorage.setAttributedString(attributedString)
        }
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
            let attributes: [NSAttributedString.Key: AnyObject] = [.foregroundColor: UIColor.systemRed]
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

        let length = textView.textStorage.length
        guard location < length else {
            return ignore
        }

        // Decorate layout of custom attributes
        if textView.textStorage.attribute(.roleAttribute, at: location, effectiveRange: nil) as? NSNumber != nil {
            return RoleFragment(textElement: textElement, range: textElement.elementRange)
        }

        return ignore
    }
}

extension MagicEditorViewController: NSTextStorageDelegate {
}

extension MagicEditorViewController: UITextViewDelegate {
}
