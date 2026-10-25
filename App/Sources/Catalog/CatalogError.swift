import Foundation

enum CatalogError: LocalizedError, Equatable {
    case emptyName
    case moveNotAllowed

    var errorDescription: String? {
        switch self {
        case .emptyName: String(localized: "A folder needs a name.")
        case .moveNotAllowed: String(localized: "The folder can't move there.")
        }
    }
}
