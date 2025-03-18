import SwiftUI

#if os(macOS)
typealias PlatformFont = NSFont
#else
typealias PlatformFont = UIFont
#endif

@MainActor
@Observable
final class MagicEditorViewModel {

    private weak var controller: MagicEditorViewController? = nil

    private var textContentStorage: NSTextContentStorage? {
        controller?.textView.textContentStorage
    }

    private var textStorage: NSTextStorage? {
        textContentStorage?.textStorage
    }

    private var selectedRange: NSRange? {
        controller?.textView.selectedRange()
    }

    func connect(to controller: MagicEditorViewController) {
        self.controller = controller
    }

    func read(document: MagicDocument) {
        let attributedString = decode(document: document)
        controller?.setAttributedString(attributedString)
    }

    func read(string: String) {
        let attributedString = NSAttributedString(
            string: string,
            attributes: [.font: PlatformFont.systemFont(ofSize: 16)]
        )
        controller?.setAttributedString(attributedString)
    }

    func insert(attachment: NSTextAttachment) {
        guard let textContentStorage, let textStorage, let selectedRange else { return }
        let attachmentString = NSAttributedString(attachment: attachment)
        textContentStorage.performEditingTransaction {
            textStorage.insert(attachmentString, at: selectedRange.location)
        }
    }

    func encode() -> MagicDocument? {
        guard let textStorage else { return nil }
        var out = MagicDocument("")
        let range = NSRange(location: 0, length: textStorage.length)
        textStorage.enumerateAttributes(in: range) { attributes, range, stop in
            let str = textStorage.attributedSubstring(from: range).string

            // Attachment attributes
            if let attachment = attributes[NSAttributedString.Key.attachment] as? RoleAttachment {
                let attr = MagicDocument.Attribute(key: "Attachment.Role", value: attachment.role, start: range.location, end: range.length)
                out.attributes.append(attr)
            }

            // Font attributes
            if hasFont(attributes, with: .bold) {
                let attr = MagicDocument.Attribute(key: "Font.Bold", value: "", start: range.location, end: range.length)
                out.attributes.append(attr)
            }

            out.text += str
        }
        return out
    }

    func decode(document: MagicDocument) -> NSAttributedString {
        let out = NSMutableAttributedString(
            string: document.text,
            attributes: [.font: PlatformFont.systemFont(ofSize: 16)]
        )
        for attribute in document.attributes {
            let range = NSMakeRange(attribute.start, attribute.end)
            switch attribute.key {
            case "Attachment.Role":
                let attachment = RoleAttachment(role: attribute.value)
                let attachmentString = NSAttributedString(attachment: attachment)
                out.replaceCharacters(in: range, with: attachmentString)
            case "Font.Bold":
                out.addAttribute(.font, value: PlatformFont.systemFont(ofSize: 16, weight: .bold), range: range)
            default:
                continue
            }
        }
        return out
    }
}

extension MagicEditorViewModel {

    func bold() {
        guard let textContentStorage, let textStorage, let selectedRange else { return }
        guard selectedRange.location != textStorage.length else { return }

        var effectiveRange = NSRange(location: 0, length: 0)
        for attribute in textStorage.attributes(at: selectedRange.location, effectiveRange: &effectiveRange) {

            // Ignore attachments, they cannot have text styles applied to them
            if isAttachment(attribute) {
                return
            }

            textContentStorage.performEditingTransaction {
                if isFont(attribute, with: .bold) {
                    textStorage.addAttributes([
                        .font: PlatformFont.systemFont(ofSize: 16)
                    ], range: effectiveRange)
                } else {
                    textStorage.addAttributes([
                        .font: PlatformFont.systemFont(ofSize: 16, weight: .bold)
                    ], range: selectedRange)
                }
            }
        }
    }
}

struct MagicDocument: Codable {
    var text: String
    var attributes: [Attribute]

    struct Attribute: Codable {
        var key: String
        var value: String
        var start: Int
        var end: Int

        init(key: String, value: String, start: Int, end: Int) {
            self.key = key
            self.value = value
            self.start = start
            self.end = end
        }
    }

    init(_ text: String, attributes: [Attribute] = []) {
        self.text = text
        self.attributes = attributes
    }
}

// MARK: Convenience

fileprivate func isAttachment(_ attribute: (NSAttributedString.Key, Any)) -> Bool {
    return attribute.1 is NSTextAttachment
}

fileprivate func hasFont(_ attributes: [NSAttributedString.Key: Any], with trait: NSFontDescriptor.SymbolicTraits? = nil) -> Bool {
    guard let font = attributes[NSAttributedString.Key.font] as? NSFont else {
        return false
    }
    guard let trait else {
        return true
    }
    return font.fontDescriptor.symbolicTraits.contains(trait)
}

fileprivate func isFont(_ attribute: (NSAttributedString.Key, Any), with trait: NSFontDescriptor.SymbolicTraits? = nil) -> Bool {
    guard let font = attribute.1 as? NSFont else {
        return false
    }
    guard let trait else {
        return true
    }
    return font.fontDescriptor.symbolicTraits.contains(trait)
}
