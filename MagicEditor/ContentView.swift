import SwiftUI

struct ContentView: View {

    @State private var viewModel = MagicEditorViewModel()

    var body: some View {
        MagicEditor(viewModel: $viewModel)
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
                        handleSubmit()
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
    }

    func handleInsert(role: String) {
        let attachment = RoleAttachment(role: role)
        viewModel.insert(attachment: attachment)
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
