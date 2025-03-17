import SwiftUI

struct ContentView: View {

    @State private var viewModel = MagicEditorViewModel(
        attributedString: AttributedString("Hello, world!", attributes: .init([
            .font: NSFont.systemFont(ofSize: 17),
        ]))
    )

    var body: some View {
        MagicEditor(viewModel: $viewModel)
            .padding()
            .toolbar {
                ToolbarItem {
                    Button {
                        let role = RoleAttachment()
                        role.role = "user"
                        viewModel.insert(attachment: role)
                    } label: {
                        Label("Insert", systemImage: "arrow.down")
                    }
                }
                ToolbarItem {
                    Button {
                        print(viewModel.toRichText())
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                }
            }
    }
}
