import Foundation
import SwiftData

/// Folder tree changes (`catalog.md` → Rules). Every change is saved right away; a failed save
/// rolls the context back, so the UI never shows a change that isn't stored.
@MainActor
struct CatalogService: CatalogServicing {
    let context: ModelContext

    @discardableResult
    func createRootFolder(name: String, learningLanguage: String, backLanguage: String) throws -> Folder {
        let folder = try Folder(
            name: validName(name),
            learningLanguage: learningLanguage,
            backLanguage: backLanguage
        )
        context.insert(folder)
        try save()
        return folder
    }

    @discardableResult
    func createSubfolder(name: String, in parent: Folder) throws -> Folder {
        let folder = try Folder(name: validName(name), parent: parent)
        context.insert(folder)
        try save()
        return folder
    }

    func rename(_ folder: Folder, to name: String) throws {
        folder.name = try validName(name)
        try save()
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

    /// A folder that becomes a root keeps the pair it had; one that goes under another
    /// folder drops its own and inherits the new root's.
    func move(_ folder: Folder, to destination: Folder?) throws {
        guard moveCheck(folder, to: destination) != .notAllowed else { throw CatalogError.moveNotAllowed }
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
        try save()
    }

    /// Deletes the folder with its subfolders and cards.
    func delete(_ folder: Folder) throws {
        context.delete(folder)
        try save()
    }

    private func save() throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func validName(_ name: String) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw CatalogError.emptyName }
        return trimmed
    }
}
