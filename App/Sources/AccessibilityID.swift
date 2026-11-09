import FlashCore

/// Identifiers UI tests find elements by.
enum AccessibilityID {
    enum Home {
        static let newFolder = "home.newFolder"
        static let emptyNewFolder = "home.emptyNewFolder"
    }

    enum FolderScreen {
        static let newCard = "folder.newCard"
        static let emptyNewCard = "folder.emptyNewCard"
        static let newSubfolder = "folder.newSubfolder"
        static let empty = "folder.empty"
        static let emptyNewSubfolder = "folder.emptyNewSubfolder"
        static let play = "folder.play"
        static let more = "folder.more"
        static let title = "folder.title"
        static let importCSV = "folder.importCSV"
    }

    enum CSVImport {
        static let folder = "csvImport.folder"
        static let count = "csvImport.count"
        static let duplicates = "csvImport.duplicates"
        static let skipped = "csvImport.skipped"
        static let skipDuplicates = "csvImport.skipDuplicates"
        static let header = "csvImport.header"
        static let error = "csvImport.error"
        static let cancel = "csvImport.cancel"
        static let confirm = "csvImport.confirm"
    }

    enum Row {
        static func folder(_ name: String) -> String {
            "row.folder.\(name)"
        }

        static func card(_ front: String) -> String {
            "row.card.\(front)"
        }
    }

    enum FolderAction {
        static let play = "folderAction.play"
        static let rename = "folderAction.rename"
        static let move = "folderAction.move"
        static let appearance = "folderAction.appearance"
        static let delete = "folderAction.delete"
        static let confirmDelete = "folderAction.confirmDelete"
    }

    enum Review {
        static let close = "review.close"
        static let position = "review.position"
        static let card = "review.card"
        static let back = "review.back"
        static let showAnswer = "review.showAnswer"
        static let empty = "review.empty"
        static let allCaughtUp = "review.allCaughtUp"
        static let practice = "review.practice"
        static let reviewed = "review.reviewed"
        static let goodOrEasy = "review.goodOrEasy"
        static let done = "review.done"
        static let more = "review.more"

        static func rating(_ rating: Rating) -> String {
            "review.rating.\(rating)"
        }
    }

    enum FolderForm {
        static let name = "folderForm.name"
        static let save = "folderForm.save"
        static let cancel = "folderForm.cancel"
        static let previewName = "folderForm.previewName"
        static let learningLanguage = "folderForm.learningLanguage"
        static let backLanguage = "folderForm.backLanguage"
    }

    enum Appearance {
        static let sameAsParent = "appearance.sameAsParent"
        static let done = "appearance.done"
        static let cancel = "appearance.cancel"
    }

    enum Palette {
        static func swatch(_ name: String) -> String {
            "palette.\(name)"
        }
    }

    enum CardEditor {
        static let front = "cardEditor.front"
        static let context = "cardEditor.context"
        static let backText = "cardEditor.backText"
        static let folder = "cardEditor.folder"
        static let save = "cardEditor.save"
        static let cancel = "cardEditor.cancel"
        static let keyboardDone = "cardEditor.keyboardDone"
        static let saveAnyway = "cardEditor.saveAnyway"
        static let delete = "cardEditor.delete"
        static let confirmDelete = "cardEditor.confirmDelete"

        static func tile(_ source: String) -> String {
            "cardEditor.tile.\(source)"
        }

        static func folderOption(_ name: String) -> String {
            "cardEditor.folderOption.\(name)"
        }
    }

    enum LanguagePicker {
        static func option(_ id: String) -> String {
            "language.\(id)"
        }
    }

    enum Move {
        static let topLevel = "move.topLevel"
        static let confirmWarning = "move.confirmWarning"

        static func destination(_ name: String) -> String {
            "move.destination.\(name)"
        }
    }
}
