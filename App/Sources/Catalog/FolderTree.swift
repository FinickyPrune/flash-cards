import SwiftData

/// The folder tree flattened depth-first, children by name, as the catalog shows it.
enum FolderTree {
    struct Entry: Identifiable {
        let folder: Folder
        let depth: Int
        var id: PersistentIdentifier {
            folder.persistentModelID
        }
    }

    /// `folders` is every folder sorted by name; the roots among them start the walk.
    static func entries(_ folders: [Folder]) -> [Entry] {
        func walk(_ folders: [Folder], depth: Int) -> [Entry] {
            folders.flatMap { [Entry(folder: $0, depth: depth)] + walk($0.sortedChildren, depth: depth + 1) }
        }
        return walk(folders.filter { $0.parent == nil }, depth: 0)
    }

    /// `English › Breaking Bad › Season 1`.
    static func path(of folder: Folder) -> String {
        var names = [folder.name]
        var node = folder.parent
        while let current = node {
            names.insert(current.name, at: 0)
            node = current.parent
        }
        return names.joined(separator: " › ")
    }
}
