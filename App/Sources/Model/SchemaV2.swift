import SwiftData

/// Current schema: `ReviewLog.kind` marks practice ratings. When the model changes, freeze copies
/// of these types here (as in `SchemaV1`) and add `SchemaV3` plus a stage in `AppMigrationPlan`.
enum SchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Folder.self, Card.self, ReviewState.self, ReviewLog.self]
    }
}
