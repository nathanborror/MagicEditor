# Magic Editor

This is a demonstration how to use TextKit 2 through creating an editor that allows you add basic styling to text and insert attachments.

## TextKit 2

### Models

- NSTextContainer
- NSTextContentManager
- NSTextContentStorage
- NSTextElement
- NSTextParagraph
- NSTextSelection
- NSTextLocation
- NSTextRange

### Controllers

- NSTextLayoutManager
- NSTextLayoutFragment
- NSTextLineFragment
- NSTextViewportLayoutControl
- NSTextSelectionNavigation

### NSTextContainer

An NSLayoutManager uses NSTextContainer to determine where to break lines, lay out portions of text, and so on. An NSTextContainer object typically defines rectangular regions, but you can define exclusion paths inside the text container to create regions where text doesn’t flow. You can also subclass to create text containers with nonrectangular regions, such as circular regions, regions with holes in them, or regions that flow alongside graphics.
You can access instances of the NSTextContainer, NSLayoutManager, and NSTextStorage classes from threads other than the main thread as long as the app guarantees access from only one thread at a time.

### NSTextContentManager

An abstract class that defines the interface and a default implementation for managing the text document contents. Inherited by NSTextContentStorage.

### NSTextContentStorage

An NSTextContentStorage object provides the backing store for a view that contains text. This object stores the text in an attributed string object, and defaults to using an NSTextStorage object. It also maps portions of the text to NSTextElement objects to organize the text into paragraphs, lists, and other common element types found in text content. During layout, TextKit uses these elements to lay out and render the text in your view.

The standard system views use an NSTextContentStorage object to manage their text content. When building a custom text view, use this type to store the text for your view. NSTextContentStorage works with an associated NSTextLayoutManager to lay out your view’s text. When someone inserts new text or edits the existing text, call the performEditingTransaction(_:) method and use a block to modify the contents of the attributedString property. Wrapping your edits in an edit transaction lets the rest of the text system respond to those changes.

TextKit uses the abstract NSTextLocation protocol to identify locations within text. NSTextContentStorage manager provides its own implementation of this protocol to represent locations within its storage object. To get the start and end locations, access the object’s documentRange property and use them to create new location objects. If you provide your own implementation of the NSTextLocation protocol to manage locations in your content, subclass NSTextContentManager and implement your own storage object to support those locations.

### NSTextElement

An abstract base class that represents the smallest units of text layout such as paragraphs or attachments. Inherited by NSTextParagraph.

### NSTextParagraph

A class that represents a single paragraph backed by an attributed string as the contents.
