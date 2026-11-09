import Foundation
import Observation

/// The new root folder form: name, language pair (both defaulting to the device's language) and
/// palette (defaulting to one no root folder uses yet).
@MainActor
@Observable
final class NewRootFolderViewModel: Identifiable {
    var name = ""
    var learningLanguage = Languages.systemLanguage
    var backLanguage = Languages.systemLanguage
    var palette: FolderPalette
    var saveError: String?
    /// Called with the created folder; the CSV import's folder picker picks it.
    var onCreate: ((Folder) -> Void)?
    private let service: any CatalogServicing

    init(service: any CatalogServicing) {
        self.service = service
        palette = service.paletteForNewRoot()
    }

    var canCreate: Bool {
        FolderName.normalized(name) != nil
    }

    /// Returns whether the form can close; on failure `saveError` says why.
    func create() -> Bool {
        guard canCreate else { return false }
        do {
            let folder = try service.createRootFolder(
                name: name,
                learningLanguage: learningLanguage,
                backLanguage: backLanguage,
                palette: palette
            )
            onCreate?(folder)
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }
}
