import Foundation
import Observation

/// The new root folder form: name and language pair, both languages defaulting to the device's.
@MainActor
@Observable
final class NewRootFolderViewModel {
    var name = ""
    var learningLanguage = Languages.systemLanguage
    var backLanguage = Languages.systemLanguage
    var saveError: String?
    private let service: any CatalogServicing

    init(service: any CatalogServicing) {
        self.service = service
    }

    var canCreate: Bool {
        FolderName.normalized(name) != nil
    }

    /// Returns whether the form can close; on failure `saveError` says why.
    func create() -> Bool {
        guard canCreate else { return false }
        do {
            try service.createRootFolder(name: name, learningLanguage: learningLanguage, backLanguage: backLanguage)
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }
}
