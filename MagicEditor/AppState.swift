import SwiftUI
import MLXKit

@Observable
@MainActor
final class AppState {

    static let shared = AppState()

    var selectedModelID: String

    var selectedModel: Model? {
        try? client.getModel(selectedModelID)
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

    let client: Client

    private init() {
        selectedModelID = Defaults.llama_3_2_1b_4bit.id
        client = .shared
    }

    func generate(messages: [ChatRequest.Message], delta: (String) -> Void) async throws {
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
