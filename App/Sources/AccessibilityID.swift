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
        static let rename = "folderAction.rename"
        static let move = "folderAction.move"
        static let delete = "folderAction.delete"
        static let confirmDelete = "folderAction.confirmDelete"
    }

    enum FolderForm {
        static let name = "folderForm.name"
        static let save = "folderForm.save"
        static let learningLanguage = "folderForm.learningLanguage"
        static let backLanguage = "folderForm.backLanguage"
    }

    enum CardEditor {
        static let front = "cardEditor.front"
        static let context = "cardEditor.context"
        static let backText = "cardEditor.backText"
        static let folder = "cardEditor.folder"
        static let save = "cardEditor.save"
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
