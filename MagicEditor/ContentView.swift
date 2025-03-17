import SwiftUI

struct ContentView: View {

    @State private var viewModel = MagicEditorViewModel()

    var body: some View {
        MagicEditor(viewModel: $viewModel)
            .padding()
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button("User") {
                            handleInsert(role: "user")
                        }
                        Button("Assistant") {
                            handleInsert(role: "assistant")
                        }
                        Button("System") {
                            handleInsert(role: "system")
                        }
                    } label: {
                        Label("Insert", systemImage: "paperclip")
                    }
                    .menuIndicator(.hidden)
                }
                ToolbarItem {
                    Button {
                        if let (output, attachments) = viewModel.serialize() {
                            print(output)
                            print(attachments)
                        } else {
                            print("Failed to serialize output")
                        }
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .onAppear {
                viewModel.read(string: "Hello, world!")
            }
    }

    func handleInsert(role: String) {
        let attachment = RoleAttachment()
        attachment.role = role
        viewModel.insert(attachment: attachment)
    }
}
