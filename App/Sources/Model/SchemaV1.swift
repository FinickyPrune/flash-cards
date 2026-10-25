import SwiftData

/// First shipped schema. When the model changes, freeze copies of these types here and add
/// `SchemaV2` plus a stage in `AppMigrationPlan`.
enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Folder.self, Card.self, ReviewState.self, ReviewLog.self]
    }
}
