import SwiftUI
import MLXKit

struct ContentView: View {
    @Environment(AppState.self) var state
    @Environment(MagicEditorViewModel.self) var viewModel

    @State private var contextManager = MagicContextMenuManager()

    @AppStorage("showing.inspector")
    private var showingInspector = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MagicEditor(viewModel: viewModel)

            if viewModel.showingContextMenu {
                MagicContextMenu(manager: contextManager)
                    .frame(width: 150)
                    .offset(x: viewModel.contextMenuPosition.x, y: viewModel.contextMenuPosition.y)
            }
        }
        .inspector(isPresented: $showingInspector) {
            InspectorView()
        }
        .toolbar {
            ToolbarItem {
                Button("Info", systemImage: "sidebar.right") {
                    showingInspector.toggle()
                }
                .keyboardShortcut("i", modifiers: [.command, .shift])
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
                
                Entropy is fundamentally a measure of disorder or randomness in a system. It originally comes from thermodynamics, but has implications in fields like information theory, physics, chemistry, and computing.
                
                """,
                attributes: [
                    .init(key: "Attachment.Role", value: "system", location: 0, length: 1),
                    .init(key: "Font.Bold", value: "", location: 12, length: 7),
                    .init(key: "Attachment.Role", value: "user", location: 32, length: 1),
                    .init(key: "Attachment.Role", value: "assistant", location: 66, length: 1),
                    .init(
                        key: "Attachment.Article",
                        value: "",
                        location: 82,
                        length: 205
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
    }

    func handleSubmit() {
        guard let doc = viewModel.encode() else { return }

        let messages = doc.messages

        viewModel.insert(text: "\n\n")
        handleInsert(role: "assistant")

        Task {
            do {
                try await state.generate(messages: messages) { delta in
                    viewModel.insert(text: delta)
                }
                viewModel.insert(text: "\n\n")
                handleInsert(role: "user")
            } catch {
                print(error)
            }
        }
    }
}

struct InspectorView: View {
    @Environment(AppState.self) var state

    var body: some View {
        @Bindable var state = state
        Form {
            Picker("Available Models", selection: $state.selectedModelID) {
                ForEach(state.client.models) { model in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(model.name)
                        ProgressView(value: model.loaded)
                    }
                    .tag(model.id)
                }
            }
            .pickerStyle(.inline)
        }
    }
}
