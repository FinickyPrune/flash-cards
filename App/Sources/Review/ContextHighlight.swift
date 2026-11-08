import Foundation

/// Where a card's front appears in its context, so review can highlight it (`review.md`).
enum ContextHighlight {
    /// The first occurrence of `front` in `context` as a whole word, else the first occurrence at
    /// all, ignoring case and diacritics; nil when absent.
    static func range(of front: String, in context: String) -> Range<String.Index>? {
        guard !front.isEmpty else {
            return nil
        }
        let options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]
        let first = context.range(of: front, options: options)
        var match = first
        while let found = match {
            if isWord(found, in: context) {
                return found
            }
            match = context.range(
                of: front,
                options: options,
                range: context.index(after: found.lowerBound) ..< context.endIndex
            )
        }
        return first
    }

    /// No letter or digit right before or right after the range.
    private static func isWord(_ range: Range<String.Index>, in text: String) -> Bool {
        let before = range.lowerBound > text.startIndex ? text[text.index(before: range.lowerBound)] : nil
        let after = range.upperBound < text.endIndex ? text[range.upperBound] : nil
        return [before, after].allSatisfy { !($0?.isLetter ?? false) && !($0?.isNumber ?? false) }
    }
}
