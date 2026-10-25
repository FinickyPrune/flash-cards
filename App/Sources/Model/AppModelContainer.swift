import SwiftData

/// Builds the app's SwiftData container: local only, CloudKit-compatible schema (decision 0001).
enum AppModelContainer {
    static let schema = Schema([Folder.self, Card.self, ReviewState.self, ReviewLog.self])

    /// `inMemory` is for tests and previews.
    static func make(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
