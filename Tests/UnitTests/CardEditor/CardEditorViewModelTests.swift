import Mockable
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("CardEditorViewModel")
struct CardEditorViewModelTests {
    private let container: ModelContainer
    private let service = MockCardServicing()
    private let serbian: Folder

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
        serbian = Folder(name: "Serbian", learningLanguage: "sr-Latn", backLanguage: "ru")
        container.mainContext.insert(serbian)
    }

    private func card(_ front: String) -> Card {
        let card = Card(front: front, back: "дом", backSource: "translation", folder: serbian)
        container.mainContext.insert(card)
        return card
    }

    // Catches: creating on the first tap despite a duplicate, skipping "Create anyway?".
    @Test("A duplicate front waits for Create anyway")
    func duplicateWaits() {
        let existing = card("kuća")
        given(service).duplicate(of: .any, in: .any, excluding: .any).willReturn(existing)
        given(service).create(.any).willReturn(existing)
        let model = CardEditorViewModel(adding: serbian, service: service)
        model.front = "Kuca "
        model.back = "дом"

        #expect(model.save() == false)
        #expect(model.duplicate === existing)
        verify(service).create(.any).called(.never)

        #expect(model.saveAnyway() == true)
        verify(service).create(.any).called(.once)
    }

    // Catches: saving the text of a tile other than the selected one, or the wrong source.
    @Test("The selected tile's text is saved as the back with its source")
    func selectedTileIsTheBack() {
        given(service).duplicate(of: .any, in: .any, excluding: .any).willReturn(nil)
        given(service).create(.any).willReturn(card("hvala"))
        let model = CardEditorViewModel(adding: serbian, service: service)
        model.front = "hvala"
        model.back = "спасибо"
        model.selectedSource = .synonyms
        model.back = "thanks, thank you"

        #expect(model.save() == true)
        verify(service)
            .create(.matching { $0.back == "thanks, thank you" && $0.backSource == .synonyms && $0.front == "hvala" })
            .called(.once)
    }

    // Catches: re-asking on every edit about a duplicate the user already accepted, or never
    // checking again when the edit gives the card another front key.
    @Test(
        "An edit asks about duplicates only when the front key changes",
        arguments: [("kuća", "house", true), ("kuca ", "дом", true), ("hvala", "дом", false)]
    )
    func editDuplicateCheck(front: String, back: String, saves: Bool) {
        let kuca = card("kuća")
        let other = card("Kuca")
        given(service).duplicate(of: .any, in: .any, excluding: .any).willReturn(other)
        given(service).update(.any, with: .any).willReturn()
        let model = CardEditorViewModel(editing: kuca, fallbackFolder: serbian, service: service)
        model.front = front
        model.back = back

        #expect(model.save() == saves)
        #expect(model.duplicate == (saves ? nil : other))
    }

    // Catches: blocking swipe-to-dismiss and asking "Discard changes?" for a form with nothing in it.
    @Test("Only real content counts as unsaved changes")
    func hasChanges() {
        let model = CardEditorViewModel(adding: serbian, service: service)
        model.back = "a"
        model.back = ""
        model.selectedSource = .synonyms
        model.front = "  "
        #expect(model.hasChanges == false)

        model.back = "thanks"
        #expect(model.hasChanges == true)
    }
}
