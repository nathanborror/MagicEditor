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
                        if let doc = viewModel.encode() {
                            print(doc)
                        } else {
                            print("Failed to serialize output")
                        }
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }
                }
                ToolbarItem {
                    Button {
                        viewModel.bold()
                    } label: {
                        Label("Bold", systemImage: "bold")
                    }
                }
            }
            .onAppear {
                viewModel.read(document: .init("Hello, world!\n\n￼", attributes: [
                    .init(key: "Font.Bold", value: "", start: 0, end: 5),
                    .init(key: "Attachment.Role", value: "user", start: 15, end: 1)
                ]))
            }
    }

    func handleInsert(role: String) {
        let attachment = RoleAttachment(role: role)
        viewModel.insert(attachment: attachment)
    }
}
