import Foundation
import Observation

/// A folder name form: a new subfolder or a rename.
@MainActor
@Observable
final class FolderNameViewModel {
    enum Mode {
        case newSubfolder(in: Folder)
        case rename(Folder)
    }

    let mode: Mode
    var name: String
    var saveError: String?
    private let service: any CatalogServicing

    init(mode: Mode, service: any CatalogServicing) {
        self.mode = mode
        self.service = service
        switch mode {
        case .newSubfolder: name = ""
        case let .rename(folder): name = folder.name
        }
    }

    var canSave: Bool {
        FolderName.normalized(name) != nil
    }

    /// Returns whether the form can close; on failure `saveError` says why.
    func save() -> Bool {
        guard canSave else { return false }
        do {
            switch mode {
            case let .newSubfolder(parent): try service.createSubfolder(name: name, in: parent)
            case let .rename(folder): try service.rename(folder, to: name)
            }
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }
}
