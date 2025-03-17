import SwiftUI

/// A generic attachment view provider that should be used with custom `NSTextAttachment` instances.
class MagicAttachmentViewProvider<Content: View>: NSTextAttachmentViewProvider {
    let content: Content

    init(content: Content, textAttachment: NSTextAttachment, parentView: NSView?, textLayoutManager: NSTextLayoutManager?, location: any NSTextLocation) {
        self.content = content
        super.init(textAttachment: textAttachment, parentView: parentView, textLayoutManager: textLayoutManager, location: location)
    }

    override func loadView() {
        let attachmentView = MagicAttachmentView(content: content)
        attachmentView.attachment = textAttachment
        view = attachmentView
    }
}

/// A generic attachment view that should only be used by `MagicAttachmentViewProvider` when loading custom `NSTextAttachment` views.
fileprivate class MagicAttachmentView<Content: View>: NSView {

    var attachment: NSTextAttachment? {
        didSet { updateHostingView() }
    }

    private var content: Content
    private var hostingController: NSHostingController<Content>?

    init(content: Content) {
        self.content = content
        super.init(frame: .zero)

        wantsLayer = true
        layer?.backgroundColor = .clear
        updateHostingView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateHostingView() {

        // Clear previous hosting view and create a fresh one
        hostingController?.view.removeFromSuperview()
        hostingController = NSHostingController(rootView: content)

        if let hostingView = hostingController?.view {
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(hostingView)

            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: NSSize {
        return hostingController?.view.intrinsicContentSize ?? .zero
    }
}
