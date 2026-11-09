import Foundation

/// Why a CSV file can't be previewed (`csv.md` → States and edge cases).
enum CSVImportError: LocalizedError, Equatable {
    case unreadable
    case notUTF8
    case tooLarge
    case noCards

    var errorDescription: String? {
        switch self {
        case .unreadable: String(localized: "The file can't be read.")
        case .notUTF8: String(localized: "The file isn't UTF-8 text. Save it as “CSV UTF-8” and try again.")
        case .tooLarge: String(localized: "The file is too large to import. Split it into files under 10 MB.")
        case .noCards: String(localized: "No cards found in this file. Each row needs a front and a back.")
        }
    }
}
