import Observation

/// A folder's palette form: its own palette, or for a subfolder "same as parent".
@MainActor
@Observable
final class AppearanceViewModel {
    let folder: Folder
    /// Only a subfolder can follow its parent; turning it on shows the parent's palette.
    var isSameAsParent: Bool {
        didSet {
            if isSameAsParent, let parent = folder.parent {
                selection = parent.resolvedPalette
            }
        }
    }

    private(set) var selection: FolderPalette
    var saveError: String?
    private let service: any CatalogServicing

    init(folder: Folder, service: any CatalogServicing) {
        self.folder = folder
        self.service = service
        isSameAsParent = folder.parent != nil && folder.ownPalette == nil
        selection = folder.resolvedPalette
    }

    /// Picking a palette stops following the parent.
    func pick(_ palette: FolderPalette) {
        selection = palette
        isSameAsParent = false
    }

    /// Returns whether the form can close; on failure `saveError` says why.
    func save() -> Bool {
        do {
            try service.setPalette(isSameAsParent ? nil : selection, of: folder)
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }
}
