import SwiftUI

#if os(macOS)
typealias PlatformViewControllerRepresentable = NSViewControllerRepresentable
typealias PlatformFontDescriptor = NSFontDescriptor
typealias PlatformFont = NSFont
typealias PlatformView = NSView
typealias PlatformHostingController = NSHostingController
typealias PlatformSize = NSSize
#else
typealias PlatformViewControllerRepresentable = UIViewControllerRepresentable
typealias PlatformFontDescriptor = UIFontDescriptor
typealias PlatformFont = UIFont
typealias PlatformView = UIView
typealias PlatformHostingController = UIHostingController
typealias PlatformSize = CGSize
#endif

struct MagicFunction {

    static func isAttachment(_ attribute: (NSAttributedString.Key, Any)) -> Bool {
        return attribute.1 is NSTextAttachment
    }

    static func hasFontBold(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
        #if os(macOS)
        hasFont(attributes, with: .bold)
        #else
        hasFont(attributes, with: .traitBold)
        #endif
    }

    static func hasFontItalic(_ attributes: [NSAttributedString.Key: Any]) -> Bool {
        #if os(macOS)
        hasFont(attributes, with: .italic)
        #else
        hasFont(attributes, with: .traitItalic)
        #endif
    }

    static func hasFont(_ attributes: [NSAttributedString.Key: Any], with trait: PlatformFontDescriptor.SymbolicTraits? = nil) -> Bool {
        guard let font = attributes[NSAttributedString.Key.font] as? PlatformFont else {
            return false
        }
        guard let trait else {
            return true
        }
        return font.fontDescriptor.symbolicTraits.contains(trait)
    }

    static func isFontBold(_ attribute: (NSAttributedString.Key, Any)) -> Bool {
        #if os(macOS)
        isFont(attribute, with: .bold)
        #else
        isFont(attribute, with: .traitBold)
        #endif
    }

    static func isFontItalic(_ attribute: (NSAttributedString.Key, Any)) -> Bool {
        #if os(macOS)
        isFont(attribute, with: .italic)
        #else
        isFont(attribute, with: .traitItalic)
        #endif
    }

    static func isFont(_ attribute: (NSAttributedString.Key, Any), with trait: PlatformFontDescriptor.SymbolicTraits? = nil) -> Bool {
        guard let font = attribute.1 as? PlatformFont else {
            return false
        }
        guard let trait else {
            return true
        }
        return font.fontDescriptor.symbolicTraits.contains(trait)
    }
}
