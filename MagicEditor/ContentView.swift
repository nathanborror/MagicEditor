import SwiftUI

struct ContentView: View {

    @State private var viewModel = MagicEditorViewModel()
    @State private var contextManager = MagicContextMenuManager()

    var body: some View {
        ZStack(alignment: .topLeading) {
            MagicEditor(viewModel: $viewModel)
            if viewModel.showingContextMenu {
                MagicContextMenu(manager: contextManager)
                    .frame(width: 150)
                    .offset(x: viewModel.contextMenuPosition.x, y: viewModel.contextMenuPosition.y)
            }
        }
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
                    viewModel.bold()
                } label: {
                    Label("Bold", systemImage: "bold")
                }
            }
            ToolbarItem {
                Button {
                    handleSubmit()
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
            }
        }
        .onChange(of: viewModel.contextMenuNotification) { _, newValue in
            switch newValue?.kind {
            case .submit:
                handleSubmit()
            case .up:
                contextManager.handleSelectionMoveUp()
            case .down:
                contextManager.handleSelectionMoveDown()
            case .select:
                contextManager.handleSelection()
            case .none:
                break
            }
        }
        .onAppear {
            handleLoad()
        }
    }

    func handleLoad() {
        viewModel.read(
            document: .init(
                """
                ￼
                You are a helpful assistant.
                
                ￼
                Write an article about entropy
                
                 
                Here you go!
                
                 
                
                """,
                attributes: [
                    .init(key: "Attachment.Role", value: "system", location: 0, length: 1),
                    .init(key: "Font.Bold", value: "", location: 12, length: 7),
                    .init(key: "Attachment.Role", value: "user", location: 32, length: 1),
                    .init(key: "Attachment.Role", value: "assistant", location: 66, length: 1),
                    .init(
                        key: "Attachment.Article",
                        value: """
                            Entropy is fundamentally a measure of disorder or randomness in a system. It originally \
                            comes from thermodynamics, but has implications in fields like information theory, \
                            physics, chemistry, and computing.
                            """,
                        location: 82,
                        length: 1
                    ),
                ]
            )
        )

        contextManager.options = [
            .init(label: "User") {
                viewModel.backspace()
                handleInsert(role: "user")
            },
            .init(label: "Assistant") {
                viewModel.backspace()
                handleInsert(role: "assistant")
            },
            .init(label: "System") {
                viewModel.backspace()
                handleInsert(role: "system")
            }
        ]
    }

    func handleInsert(role: String) {
        let attachment = RoleAttachment(role: role)
        viewModel.insert(attachment: attachment)
        viewModel.insert(text: "\n")
        viewModel.showingContextMenu = false
    }

    func handleSubmit() {
        if let doc = viewModel.encode() {
            //print(doc)
            print(handleConvert(doc))
        } else {
            print("Failed to serialize output")
        }
    }

    func handleConvert(_ document: MagicDocument) -> [(String, String)] {
        var out: [(String, String)] = []

        // Filter out roles and sort them by location
        let roles = document.attributes
            .filter { $0.key == "Attachment.Role" }
            .sorted { $0.location < $1.location}

        // Determine message ranges
        for (i, role) in roles.enumerated() {
            if (i+1) < roles.count {
                let location = role.location+role.length
                let length = roles[i+1].location
                let message = extract(from: document.text, location: location, length: length)
                out.append((role.value, message))
            } else {
                let location = role.location+role.length
                let length = document.text.count
                let message = extract(from: document.text, location: location, length: length)
                out.append((role.value, message))
            }
        }

        return out
    }

    private func extract(from text: String, location: Int, length: Int, trimWhitespace: Bool = true) -> String {
        let startIndex = text.index(text.startIndex, offsetBy: location)
        let endIndex = text.index(text.startIndex, offsetBy: length)
        let out = String(text[startIndex..<endIndex])
        if trimWhitespace {
            return out.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return out
    }
}
