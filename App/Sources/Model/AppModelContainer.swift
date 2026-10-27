import Foundation
import SwiftData

/// Builds the app's SwiftData container: local only, CloudKit-compatible schema (decision 0001).
///
/// `groupContainer: .none` keeps the store in the app's own container: with `.automatic`, adding
/// the App Group for the share extension would silently move it to a new, empty store there.
enum AppModelContainer {
    static let schema = Schema(versionedSchema: SchemaV2.self)

    /// `inMemory` is for tests and previews; `url` lets migration tests open a store file of
    /// their own (default: the app's store). A `url` wins over `inMemory`.
    static func make(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let configuration = if let url {
            ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        } else {
            ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: inMemory,
                groupContainer: .none,
                cloudKitDatabase: .none
            )
        }
        return try ModelContainer(
            for: schema,
            migrationPlan: AppMigrationPlan.self,
            configurations: configuration
        )
    }
}
