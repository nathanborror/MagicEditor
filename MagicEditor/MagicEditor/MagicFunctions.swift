import SwiftUI

struct MagicFunction {

    static func isAttachment(_ attribute: (NSAttributedString.Key, Any)) -> Bool {
        return attribute.1 is NSTextAttachment
    }

    static func hasFont(_ attributes: [NSAttributedString.Key: Any], with trait: NSFontDescriptor.SymbolicTraits? = nil) -> Bool {
        guard let font = attributes[NSAttributedString.Key.font] as? NSFont else {
            return false
        }
        guard let trait else {
            return true
        }
        return font.fontDescriptor.symbolicTraits.contains(trait)
    }

    static func isFont(_ attribute: (NSAttributedString.Key, Any), with trait: NSFontDescriptor.SymbolicTraits? = nil) -> Bool {
        guard let font = attribute.1 as? NSFont else {
            return false
        }
        guard let trait else {
            return true
        }
        return font.fontDescriptor.symbolicTraits.contains(trait)
    }
}
