import SwiftUI

class RoleAttachment: NSTextAttachment, @unchecked Sendable {
    var role: String = "user"

    override func viewProvider(for parentView: NSView?, location: NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        let provider = MagicAttachmentViewProvider(
            content: RoleAttachmentView(role: role),
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        provider.tracksTextAttachmentViewBounds = true
        return provider
    }
}

struct RoleAttachmentView: View {
    var role: String

    private let attachmentFontSize: CGFloat = 11
    private let attachmentHorizontalPadding: CGFloat = 8
    private let attachmentVerticalPadding: CGFloat = 3
    private let attachmentCornerRadius: CGFloat = 10

    private var attachmentTextColor: Color {
        switch role {
        case "assistant": .blue
        case "system": .pink
        case "user": .green
        default: .primary
        }
    }

    private var attachmentBackgroundColor: Color {
        switch role {
        case "assistant": .blue.opacity(0.2)
        case "system": .pink.opacity(0.2)
        case "user": .green.opacity(0.2)
        default: .primary.opacity(0.2)
        }
    }

    var body: some View {
        Text(role)
            .font(.system(size: attachmentFontSize))
            .foregroundColor(attachmentTextColor)
            .padding(.horizontal, attachmentHorizontalPadding)
            .padding(.vertical, attachmentVerticalPadding)
            .background(
                RoundedRectangle(cornerRadius: attachmentCornerRadius)
                    .fill(attachmentBackgroundColor)
            )
    }
}
