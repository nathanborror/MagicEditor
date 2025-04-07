import Foundation
import MLXKit

struct MagicDocument: Codable {
    var text: String
    var attributes: [Attribute]

    struct Attribute: Codable {
        var key: String
        var value: String
        var location: Int
        var length: Int

        init(key: String, value: String, location: Int, length: Int) {
            self.key = key
            self.value = value
            self.location = location
            self.length = length
        }
    }

    init(_ text: String, attributes: [Attribute] = []) {
        self.text = text
        self.attributes = attributes
    }
}

extension MagicDocument {

    var messages: [ChatRequest.Message] {
        var messages: [ChatRequest.Message] = []

        // Filter out roles and sort them by location
        let roles = attributes
            .filter { $0.key == "Attachment.Role" }
            .sorted { $0.location < $1.location}

        // Determine message ranges
        for (i, role) in roles.enumerated() {
            if (i+1) < roles.count {
                let location = role.location+role.length
                let length = roles[i+1].location
                let content = extract(from: text, location: location, length: length)
                messages.append(.init(role: .init(rawValue: role.value)!, content: content))
            } else {
                let location = role.location+role.length
                let length = text.count
                let content = extract(from: text, location: location, length: length)
                messages.append(.init(role: .init(rawValue: role.value)!, content: content))
            }
        }

        return messages
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
