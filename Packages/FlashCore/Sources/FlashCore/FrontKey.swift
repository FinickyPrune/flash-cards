import Foundation

/// Normalised card front used to detect duplicates (`card-editor.md` → duplicate check).
///
/// Ignores case, diacritics, surrounding whitespace and the length of whitespace runs inside,
/// so `kuća` = `Kuca ` and `ice  cream` = `ice cream`.
public enum FrontKey {
    public static func make(from front: String) -> String {
        front
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
