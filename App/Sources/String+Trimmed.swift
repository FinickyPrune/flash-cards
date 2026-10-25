import Foundation

extension String {
    /// Without surrounding whitespace and newlines.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
