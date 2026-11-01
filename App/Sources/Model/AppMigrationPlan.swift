import SwiftData

/// Migrations between shipped schemas, oldest first.
enum AppMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self, SchemaV2.self, SchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [
            // V2 adds `ReviewLog.kind` with a default, so existing rows read as `review`.
            .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self),
            // V3 adds the optional `Folder.palette`; existing folders read as nil.
            .lightweight(fromVersion: SchemaV2.self, toVersion: SchemaV3.self),
        ]
    }
}
