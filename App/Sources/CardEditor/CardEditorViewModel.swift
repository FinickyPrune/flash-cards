import FlashCore
import Foundation
import Observation

/// The card editor in add or edit mode (`card-editor.md`). Only the selected tile is edited;
/// its text is the back.
@MainActor
@Observable
final class CardEditorViewModel {
    enum Mode {
        case add
        case edit(Card)
    }

    let mode: Mode
    var front: String
    var context: String
    var folder: Folder
    var selectedSource: BackSource
    private(set) var tileTexts: [BackSource: String]
    /// An existing card with the same front key, waiting for "Create anyway".
    var duplicate: Card?
    var isConfirmingDelete = false
    var isConfirmingDiscard = false
    var saveError: String?
    private let initial: Snapshot
    private let service: any CardServicing

    private struct Snapshot: Equatable {
        let front: String
        let context: String
        let folder: Folder
        let selectedSource: BackSource
        let tileTexts: [BackSource: String]
    }

    /// A new card in `folder`, starting on the back source last used in its root.
    init(adding folder: Folder, service: any CardServicing) {
        let source = folder.defaultBackSource
        mode = .add
        front = ""
        context = ""
        self.folder = folder
        selectedSource = source
        tileTexts = [:]
        self.service = service
        initial = Snapshot(front: "", context: "", folder: folder, selectedSource: source, tileTexts: [:])
    }

    /// An existing card; `fallbackFolder` is used only if the card has lost its folder.
    init(editing card: Card, fallbackFolder: Folder, service: any CardServicing) {
        let snapshot = Snapshot(
            front: card.front,
            context: card.context ?? "",
            folder: card.folder ?? fallbackFolder,
            selectedSource: card.source,
            tileTexts: [card.source: card.back]
        )
        mode = .edit(card)
        front = snapshot.front
        context = snapshot.context
        folder = snapshot.folder
        selectedSource = snapshot.selectedSource
        tileTexts = snapshot.tileTexts
        self.service = service
        initial = snapshot
    }

    /// The text of the selected tile: the back.
    var back: String {
        get { tileTexts[selectedSource] ?? "" }
        set { tileTexts[selectedSource] = newValue }
    }

    func text(of source: BackSource) -> String {
        tileTexts[source] ?? ""
    }

    var canSave: Bool {
        draft.isComplete
    }

    var hasChanges: Bool {
        snapshot != initial
    }

    /// Saves unless another card in the root folder has the same front; then `duplicate` asks first.
    /// Returns whether the editor can close.
    func save() -> Bool {
        guard canSave else { return false }
        do {
            if needsDuplicateCheck, let existing = try service.duplicate(of: front, in: folder, excluding: card) {
                duplicate = existing
                return false
            }
        } catch {
            saveError = error.localizedDescription
            return false
        }
        return commit()
    }

    /// Saves after the user chose "Create anyway". Returns whether the editor can close.
    func saveAnyway() -> Bool {
        duplicate = nil
        return commit()
    }

    /// Deletes the edited card. Returns whether the editor can close.
    func delete() -> Bool {
        guard let card else { return false }
        do {
            try service.delete(card)
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }

    private var card: Card? {
        if case let .edit(card) = mode {
            card
        } else {
            nil
        }
    }

    private var draft: CardDraft {
        CardDraft(front: front, context: context, back: back, backSource: selectedSource, folder: folder)
    }

    private var snapshot: Snapshot {
        Snapshot(front: front, context: context, folder: folder, selectedSource: selectedSource, tileTexts: tileTexts)
    }

    /// An edit that keeps the front key and the root folder doesn't ask again about a duplicate
    /// the user already accepted.
    private var needsDuplicateCheck: Bool {
        guard let card else { return true }
        return FrontKey.make(from: front) != card.frontKey || folder.root !== card.folder?.root
    }

    private func commit() -> Bool {
        do {
            if let card {
                try service.update(card, with: draft)
            } else {
                try service.create(draft)
            }
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }
}
