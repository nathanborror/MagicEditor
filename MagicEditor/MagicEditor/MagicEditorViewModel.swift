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

    func connect(to controller: MagicEditorViewController) {
        self.controller = controller
    }

    func read(string: String) {
        let attributedString = NSAttributedString(
            string: string,
            attributes: [
                .font: PlatformFont.systemFont(ofSize: 16)
            ]
        )
        controller?.setAttributedString(attributedString)
    }

    func insert(attachment: NSTextAttachment) {
        guard let textView = controller?.textView else { return }
        let selectionRange = textView.selectedRange()

        let attachmentString = NSAttributedString(attachment: attachment)
        textView.textContentStorage?.performEditingTransaction {
            textView.textContentStorage?.textStorage?.insert(attachmentString, at: selectionRange.location)
        }
    }

    func serialize() -> (String, [AttachmentRef])? {
        guard let textView = controller?.textView else { return nil }

        var output = ""
        var attachments: [AttachmentRef] = []

        let attributedString = textView.attributedString()
        let range = NSRange(location: 0, length: attributedString.length)

        attributedString.enumerateAttributes(in: range) { attributes, range, stop in
            let str = attributedString.attributedSubstring(from: range).string
            output += str

            // Serialize Attachments
            if let attachment = attributes[NSAttributedString.Key.attachment] as? RoleAttachment {
                let ref = AttachmentRef(
                    type: "RoleAttachment",
                    value: attachment.role,
                    location: range.location,
                    length: range.length
                )
                attachments.append(ref)
            }

            // Look for additional attachment types here

        }

        return (output, attachments)
    }
}

struct AttachmentRef {
    let type: String
    let value: String
    let location: Int
    let length: Int
}
