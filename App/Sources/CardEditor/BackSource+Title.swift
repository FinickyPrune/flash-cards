import SwiftUI

extension BackSource {
    /// The tile's name in the card editor (glossary → Back source).
    var title: LocalizedStringKey {
        switch self {
        case .definition: "Definition"
        case .synonyms: "Synonyms"
        case .translation: "Translation"
        case .custom: "Custom text"
        }
    }

    /// Tiles top to bottom, as `card-editor.md` lists them.
    static let tileOrder: [BackSource] = [.definition, .synonyms, .translation, .custom]
}
