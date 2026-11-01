/// Learned cards / all cards in a folder's subtree (`catalog.md`).
struct FolderProgress: Equatable {
    let learned: Int
    let total: Int

    /// Learned share, 0 for no cards.
    var fraction: Double {
        total == 0 ? 0 : Double(learned) / Double(total)
    }

    /// Whole percent, rounded down so an unfinished folder never shows 100%.
    var percent: Int {
        total == 0 ? 0 : learned * 100 / total
    }
}
