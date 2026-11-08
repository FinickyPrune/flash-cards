import Foundation

/// Where a card's front appears in its context, so review can highlight it (`review.md`).
enum ContextHighlight {
    /// The first occurrence of `front` in `context`, ignoring case and diacritics; nil when absent.
    static func range(of front: String, in context: String) -> Range<String.Index>? {
        guard !front.isEmpty else {
            return nil
        }
        return context.range(of: front, options: [.caseInsensitive, .diacriticInsensitive])
    }
}
