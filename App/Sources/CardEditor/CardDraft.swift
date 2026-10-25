import Foundation

/// What the card editor saves: both sides, the context and the folder.
struct CardDraft {
    var front: String
    var context: String
    var back: String
    var backSource: BackSource
    var folder: Folder

    /// Front and back must have text (`card-editor.md` → States).
    var isComplete: Bool {
        !front.trimmed.isEmpty && !back.trimmed.isEmpty
    }
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
