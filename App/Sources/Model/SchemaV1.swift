import Foundation
import SwiftData

/// First shipped schema, frozen: these copies must keep matching stores written by version 1.
/// Never change them; change the live models and add a new schema version instead.
enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Folder.self, Card.self, ReviewState.self, ReviewLog.self]
    }

    @Model
    final class Folder {
        var id = UUID()
        var name = ""
        var parent: Folder?
        @Relationship(deleteRule: .cascade, inverse: \Folder.parent)
        var children: [Folder]?
        @Relationship(deleteRule: .cascade, inverse: \Card.folder)
        var cards: [Card]?
        var learningLanguage: String?
        var backLanguage: String?
        var lastBackSource: String?
        var createdAt = Date.now

        init() {}
    }

    @Model
    final class Card {
        var id = UUID()
        var folder: Folder?
        var front = ""
        var frontKey = ""
        var context: String?
        @Attribute(.externalStorage) var screenshot: Data?
        var back = ""
        var backSource = "custom"
        var createdAt = Date.now
        var updatedAt = Date.now
        @Relationship(deleteRule: .cascade, inverse: \ReviewState.card)
        var reviewStates: [ReviewState]?
        @Relationship(deleteRule: .cascade, inverse: \ReviewLog.card)
        var reviewLogs: [ReviewLog]?

        init() {}
    }

    @Model
    final class ReviewState {
        var card: Card?
        var direction = "forward"
        var dueDate: Date?
        var intervalDays = 0.0
        var ease = 2.5
        var repetitions = 0
        var lapses = 0

        init() {}
    }

    @Model
    final class ReviewLog {
        var card: Card?
        var direction = "forward"
        var rating = 0
        var reviewedAt = Date.now

        init() {}
    }
}
