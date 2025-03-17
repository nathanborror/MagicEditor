import SwiftUI

#if os(macOS)
typealias ViewControllerRepresentable = NSViewControllerRepresentable
#else
typealias ViewControllerRepresentable = UIViewControllerRepresentable
#endif

struct MagicEditor: ViewControllerRepresentable {
    @Binding var viewModel: MagicEditorViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeViewController(context: Context) -> MagicEditorViewController {
        let controller = MagicEditorViewController()
        controller.setAttributedString(.init(viewModel.attributedString))
        viewModel.connect(to: controller)
        return controller
    }

    func updateViewController(_ controller: MagicEditorViewController, context: Context) {
        controller.setAttributedString(.init(viewModel.attributedString))
    }

    #if os(macOS)
    func makeNSViewController(context: Context) -> MagicEditorViewController {
        makeViewController(context: context)
    }
    func updateNSViewController(_ controller: MagicEditorViewController, context: Context) {
        updateViewController(controller, context: context)
    }
    #else
    func makeUIViewController(context: Context) -> MagicEditorViewController {
        makeViewController(context: context)
    }
    func updateUIViewController(_ controller: MagicEditorViewController, context: Context) {
        updateViewController(controller, context: context)
    }
    #endif

    class Coordinator {
        var parent: MagicEditor

        init(_ parent: MagicEditor) {
            self.parent = parent
        }
    }
}
