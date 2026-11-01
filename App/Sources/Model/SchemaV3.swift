import SwiftData

/// Current schema: `Folder.palette` holds the folder's colours. When the model changes, freeze
/// copies of these types here (as in `SchemaV2`) and add `SchemaV4` plus a stage in
/// `AppMigrationPlan`.
enum SchemaV3: VersionedSchema {
    static let versionIdentifier = Schema.Version(3, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Folder.self, Card.self, ReviewState.self, ReviewLog.self]
    }
}
