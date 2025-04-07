import SwiftUI
import MLXKit

@Observable
@MainActor
final class AppState {

    static let shared = AppState()

    var selectedModelID: String
    var modelProgress: [String: Double] = [:]

    var selectedModel: Model? {
        try? client.get(model: selectedModelID)
    }

    enum Error: Swift.Error, CustomStringConvertible {
        case restorationError(String)

        public var description: String {
            switch self {
            case .restorationError(let detail):
                "Restoration error: \(detail)"
            }
        }
    }

    let client: MLXKit.Client

    private init() {
        selectedModelID = Defaults.llama_3_2_1b_4bit.id
        client = .init()
        print(URL.documentsDirectory.absoluteString)
    }

    func generate(messages: [ChatRequest.Message], delta: (String) -> Void) async throws {

        // Load the model if it isn't cached
        if !client.hasModelCached(selectedModelID) {
            let _ = try await client.fetchModel(selectedModelID) { progress in
                Task {
                    await MainActor.run {
                        self.modelProgress[self.selectedModelID] = progress
                    }
                }
            }
        }

        let request = ChatRequest(
            model: selectedModelID,
            messages: messages,
            max_tokens: 2048
        )
        var offset = ""

        for try await text in try await client.chatCompletionsStream(request) {
            let content = text
            delta(content.replacingOccurrences(of: offset, with: ""))
            offset = content
        }
    }
}
