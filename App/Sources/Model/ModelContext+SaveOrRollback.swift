import SwiftData

extension ModelContext {
    /// Saves, or rolls every pending change back and rethrows, so the UI never shows a change
    /// that isn't stored.
    func saveOrRollback() throws {
        do {
            try save()
        } catch {
            rollback()
            throw error
        }
    }
}
