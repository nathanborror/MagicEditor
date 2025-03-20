import SwiftUI

@MainActor
@Observable
final class MagicEditorViewModel {

    private weak var controller: MagicEditorViewController? = nil

    private var textStorage: NSTextStorage? {
        controller?.textView.textStorage
    }

    private var selectedRange: NSRange? {
        #if os(macOS)
        controller?.textView.selectedRange()
        #else
        controller?.textView.selectedRange
        #endif
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
        guard let textStorage, let selectedRange else { return }
        let attachmentString = NSAttributedString(attachment: attachment)
        textStorage.insert(attachmentString, at: selectedRange.location)
    }

    func encode() -> MagicDocument? {
        guard let textStorage else { return nil }
        var out = MagicDocument("")
        let range = NSRange(location: 0, length: textStorage.length)
        textStorage.enumerateAttributes(in: range) { attributes, range, stop in
            let str = textStorage.attributedSubstring(from: range).string

            // Attachment attributes
            if let attachment = attributes[NSAttributedString.Key.attachment] as? RoleAttachment {
                let attr = MagicDocument.Attribute(key: "Attachment.Role", value: attachment.role, location: range.location, length: range.length)
                out.attributes.append(attr)
            }
            if let attachment = attributes[NSAttributedString.Key.attachment] as? ArticleAttachment {
                let attr = MagicDocument.Attribute(key: "Attachment.Article", value: attachment.content, location: range.location, length: range.length)
                out.attributes.append(attr)
            }

            // Font attributes
            if MagicFunction.hasFontBold(attributes) {
                let attr = MagicDocument.Attribute(key: "Font.Bold", value: "", location: range.location, length: range.length)
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
            let range = NSMakeRange(attribute.location, attribute.length)
            switch attribute.key {
            case "Attachment.Role":
                let attachment = RoleAttachment(role: attribute.value)
                let attachmentString = NSAttributedString(attachment: attachment)
                out.replaceCharacters(in: range, with: attachmentString)
            case "Attachment.Article":
                let attachment = ArticleAttachment(content: attribute.value)
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
        guard let textStorage, let selectedRange else { return }
        guard selectedRange.location != textStorage.length else { return }

        var effectiveRange = NSRange(location: 0, length: 0)
        for attribute in textStorage.attributes(at: selectedRange.location, effectiveRange: &effectiveRange) {

            // Ignore attachments, they cannot have text styles applied to them
            if MagicFunction.isAttachment(attribute) {
                return
            }

            if MagicFunction.isFontBold(attribute) {
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

struct MagicDocument: Codable {
    var text: String
    var attributes: [Attribute]

    struct Attribute: Codable {
        var key: String
        var value: String
        var location: Int
        var length: Int

        init(key: String, value: String, location: Int, length: Int) {
            self.key = key
            self.value = value
            self.location = location
            self.length = length
        }
    }

    init(_ text: String, attributes: [Attribute] = []) {
        self.text = text
        self.attributes = attributes
    }
}
