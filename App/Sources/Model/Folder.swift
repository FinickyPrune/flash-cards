import Foundation
import SwiftData

/// Catalog node holding cards and subfolders (`catalog.md`).
///
/// The language pair and the last back source are stored on the root folder only;
/// subfolders resolve them from their root.
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
    /// Raw value of the back source last used in this root folder, see `Card.backSource`.
    var lastBackSource: String?
    var createdAt = Date.now

    /// A root folder, which owns the language pair.
    init(name: String, learningLanguage: String, backLanguage: String, createdAt: Date = .now) {
        self.name = name
        self.learningLanguage = learningLanguage
        self.backLanguage = backLanguage
        self.createdAt = createdAt
    }

    /// A subfolder, which inherits the language pair from its root.
    init(name: String, parent: Folder, createdAt: Date = .now) {
        self.name = name
        self.parent = parent
        self.createdAt = createdAt
    }

    var root: Folder {
        var folder = self
        while let parent = folder.parent {
            folder = parent
        }
        return folder
    }

    /// Subfolders by name, as the catalog lists them.
    var sortedChildren: [Folder] {
        (children ?? []).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    var resolvedLearningLanguage: String? {
        root.learningLanguage
    }

    var resolvedBackLanguage: String? {
        root.backLanguage
    }
}
