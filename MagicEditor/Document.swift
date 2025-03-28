import Foundation

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
