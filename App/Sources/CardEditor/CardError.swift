import Foundation

enum CardError: LocalizedError, Equatable {
    case incomplete

    var errorDescription: String? {
        switch self {
        case .incomplete: String(localized: "A card needs a front and a back.")
        }
    }
}
