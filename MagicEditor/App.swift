import SwiftUI

@main
struct MainApp: App {

    @State var state = AppState.shared
    @State var viewModel = MagicEditorViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .containerBackground(.background, for: .window)
        }
        .environment(state)
        .environment(viewModel)
        .commands {
            CommandMenu("Format") {
                Button("Bold", systemImage: "bold") {
                    viewModel.bold()
                }
                .keyboardShortcut("b", modifiers: .command)

                Button("Italic", systemImage: "italic") {
                    print("not implemented")
                }
                .keyboardShortcut("i", modifiers: .command)

                Button("Underline", systemImage: "underline") {
                    print("not implemented")
                }
                .keyboardShortcut("u", modifiers: .command)
            }
        }
    }
}
