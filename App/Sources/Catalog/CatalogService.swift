import Foundation
import SwiftData

/// Folder tree changes (`catalog.md` → Rules). Every change is saved right away; a failed save
/// rolls the context back, so the UI never shows a change that isn't stored.
@MainActor
struct CatalogService: CatalogServicing {
    let context: ModelContext

    @discardableResult
    func createRootFolder(
        name: String,
        learningLanguage: String,
        backLanguage: String,
        palette: FolderPalette
    ) throws -> Folder {
        let folder = try Folder(
            name: validName(name),
            learningLanguage: learningLanguage,
            backLanguage: backLanguage,
            palette: palette
        )
        context.insert(folder)
        try context.saveOrRollback()
        return folder
    }

    @discardableResult
    func createSubfolder(name: String, in parent: Folder) throws -> Folder {
        let folder = try Folder(name: validName(name), parent: parent)
        context.insert(folder)
        try context.saveOrRollback()
        return folder
    }

    func paletteForNewRoot() -> FolderPalette {
        // Only a default the user sees and can change: if the fetch fails, offer the first palette.
        let roots = (try? context.fetch(FetchDescriptor<Folder>(predicate: #Predicate { $0.parent == nil }))) ?? []
        return .forNewRoot(used: roots.map(\.resolvedPalette))
    }

    func rename(_ folder: Folder, to name: String) throws {
        folder.name = try validName(name)
        try context.saveOrRollback()
    }

    func setPalette(_ palette: FolderPalette?, of folder: Folder) throws {
        folder.ownPalette = palette
        try context.saveOrRollback()
    }

    /// `destination == nil` means the top level: the folder becomes a root folder.
    func moveCheck(_ folder: Folder, to destination: Folder?) -> MoveCheck {
        guard destination !== folder.parent else { return .notAllowed }
        guard let destination else { return .allowed }
        var node: Folder? = destination
        while let current = node {
            if current === folder {
                return .notAllowed
            }
            node = current.parent
        }
        let samePair = folder.resolvedLearningLanguage == destination.resolvedLearningLanguage
            && folder.resolvedBackLanguage == destination.resolvedBackLanguage
        return samePair ? .allowed : .allowedAfterWarning
    }

    /// A folder that becomes a root keeps the pair and the palette it had; one that goes under
    /// another folder drops its own pair and inherits the new root's. A root keeps its palette
    /// either way, even one derived from its id.
    func move(_ folder: Folder, to destination: Folder?) throws {
        guard moveCheck(folder, to: destination) != .notAllowed else { throw CatalogError.moveNotAllowed }
        if folder.parent == nil || destination == nil {
            folder.ownPalette = folder.resolvedPalette
        }
        if let destination {
            folder.learningLanguage = nil
            folder.backLanguage = nil
            folder.lastBackSource = nil
            folder.parent = destination
        } else {
            let root = folder.root
            folder.learningLanguage = root.learningLanguage
            folder.backLanguage = root.backLanguage
            folder.lastBackSource = root.lastBackSource
            folder.parent = nil
        }
        try context.saveOrRollback()
    }

    /// Deletes the folder with its subfolders and cards.
    func delete(_ folder: Folder) throws {
        context.delete(folder)
        try context.saveOrRollback()
    }

    private func validName(_ name: String) throws -> String {
        guard let name = FolderName.normalized(name) else { throw CatalogError.emptyName }
        return name
    }
}
