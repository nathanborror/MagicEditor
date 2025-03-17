import SwiftUI

#if os(macOS)
typealias PlatformFont = NSFont
#else
typealias PlatformFont = UIFont
#endif

@MainActor
@Observable
final class MagicEditorViewModel {

    var attributedString: NSAttributedString

    private weak var controller: MagicEditorViewController? = nil

    init(string: String) {
        self.attributedString = .init(
            string: string,
            attributes: [
                .font: PlatformFont.systemFont(ofSize: 16)
            ]
        )
    }

    func connect(to controller: MagicEditorViewController) {
        self.controller = controller
    }

    func insert(attachment: NSTextAttachment) {
        guard let textView = controller?.textView else { return }
        let selectionRange = textView.selectedRange()

        let attachmentString = NSAttributedString(attachment: attachment)
        textView.textContentStorage?.performEditingTransaction {
            textView.textContentStorage?.textStorage?.insert(attachmentString, at: selectionRange.location)
        }
    }

    func toRichText() -> String? {
        guard let textView = controller?.textView else { return nil }
        let str = textView.attributedString()
        let range = NSRange(location: 0, length: str.length)
        let doc = try? str.data(from: range, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        return String(data: doc!, encoding: .utf8)
    }

//    func debug_serialize() {
//        guard let textView = controller?.textView else { return }
//
//        let str = textView.attributedString()
//        let range = NSRange(location: 0, length: str.length)
//        str.enumerateAttributes(in: range) { attributes, range, stop in
//            print(attributes, range)
//            print("---")
//        }
//    }
}
