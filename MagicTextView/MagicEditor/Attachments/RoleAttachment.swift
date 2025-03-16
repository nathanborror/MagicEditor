import AppKit

class RoleAttachmentView: NSView {

    var attachment: RoleAttachment? {
        didSet { updateView() }
    }

    private lazy var label: NSTextField = {
        let label = NSTextField(labelWithString: "Label")
        label.font = .systemFont(ofSize: attachmentFontSize)
        label.isEditable = false
        label.isSelectable = false
        label.isBordered = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = attachmentTextColor
        label.drawsBackground = false
        return label
    }()

    private let attachmentInsets = NSEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
    private let attachmentFontSize: CGFloat = 11
    private let attachmentHorizontalPadding: CGFloat = 8
    private let attachmentVerticalPadding: CGFloat = 3
    private let attachmentCornerRadius: CGFloat = 10
    private var attachmentTextColor: NSColor {
        switch attachment?.role {
        case "assistant": .systemBlue
        case "system": .systemPink
        case "user": .systemGreen
        default: .labelColor
        }
    }
    private var attachmentBackgroundColor: NSColor {
        switch attachment?.role {
        case "assistant": .systemBlue.withAlphaComponent(0.2)
        case "system": .systemPink.withAlphaComponent(0.2)
        case "user": .systemGreen.withAlphaComponent(0.2)
        default: .labelColor.withAlphaComponent(0.2)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = .clear
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: attachmentHorizontalPadding + attachmentInsets.left),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -(attachmentHorizontalPadding + attachmentInsets.right)),
            label.topAnchor.constraint(equalTo: topAnchor, constant: attachmentVerticalPadding + attachmentInsets.top),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(attachmentVerticalPadding + attachmentInsets.bottom))
        ])
    }

    private func updateView() {
        let role = attachment?.role ?? "Unknown"
        if role == "user" {
            label.stringValue = "You"
        } else {
            label.stringValue = role.capitalized
        }
        label.textColor = attachmentTextColor

        // Force layout update
        label.invalidateIntrinsicContentSize()
        invalidateIntrinsicContentSize()
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect) {
        let contentRect = bounds.insetBy(dx: attachmentInsets.left, dy: attachmentInsets.top)
        let path = NSBezierPath(roundedRect: contentRect, xRadius: attachmentCornerRadius, yRadius: attachmentCornerRadius)
        attachmentBackgroundColor.setFill()
        path.fill()
    }

    override var intrinsicContentSize: NSSize {
        let size = label.intrinsicContentSize
        return NSSize(
            width: size.width + (attachmentHorizontalPadding * 2) + (attachmentInsets.left + attachmentInsets.right),
            height: size.height + (attachmentVerticalPadding * 2) + (attachmentInsets.top + attachmentInsets.bottom)
        )
    }
}

class RoleAttachmentViewProvider: NSTextAttachmentViewProvider {

    override func loadView() {
        let attachmentView = RoleAttachmentView()
        attachmentView.attachment = textAttachment as? RoleAttachment
        view = attachmentView
    }
}

class RoleAttachment: NSTextAttachment, @unchecked Sendable {
    var role: String = "user"

    override func viewProvider(for parentView: NSView?, location: NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        let provider = RoleAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        provider.tracksTextAttachmentViewBounds = true
        return provider
    }
}
