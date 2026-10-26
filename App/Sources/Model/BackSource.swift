/// Which tile a card's back came from (`card-editor.md`). Stored as its raw value.
enum BackSource: String, CaseIterable {
    case definition
    case synonyms
    case translation
    case custom
}
