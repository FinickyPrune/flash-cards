import Foundation
import Observation

/// Moving one folder: which destinations are allowed, and the warning before a pair change.
@MainActor
@Observable
final class MoveFolderViewModel {
    let folder: Folder
    /// A destination whose root has another pair, waiting for the user to confirm.
    var warningDestination: Folder?
    var saveError: String?
    private let service: any CatalogServicing

    init(folder: Folder, service: any CatalogServicing) {
        self.folder = folder
        self.service = service
    }

    func isAllowed(_ destination: Folder?) -> Bool {
        service.moveCheck(folder, to: destination) != .notAllowed
    }

    /// Moves right away, or asks first when the pair would change. Returns whether the sheet can close.
    func choose(_ destination: Folder?) -> Bool {
        switch service.moveCheck(folder, to: destination) {
        case .allowed:
            return move(to: destination)
        case .allowedAfterWarning:
            warningDestination = destination
            return false
        case .notAllowed:
            return false
        }
    }

    /// Moves after the user confirmed the warning for `destination`. Returns whether the sheet can close.
    func confirmWarning(for destination: Folder) -> Bool {
        warningDestination = nil
        return move(to: destination)
    }

    func pairDescription(of folder: Folder) -> String {
        let learning = folder.resolvedLearningLanguage.map { Languages.name(of: $0) } ?? ""
        let back = folder.resolvedBackLanguage.map { Languages.name(of: $0) } ?? ""
        return "\(learning) → \(back)"
    }

    private func move(to destination: Folder?) -> Bool {
        do {
            try service.move(folder, to: destination)
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }
}
