import Foundation
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("CardService")
struct CardServiceTests {
    private let container: ModelContainer
    private let service: CardService
    private let serbian: Folder
    private let words: Folder
    private let english: Folder

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
        service = CardService(context: container.mainContext)
        serbian = Folder(name: "Serbian", learningLanguage: "sr-Latn", backLanguage: "ru")
        words = Folder(name: "Words", parent: serbian)
        english = Folder(name: "English", learningLanguage: "en", backLanguage: "ru")
        for folder in [serbian, words, english] {
            container.mainContext.insert(folder)
        }
    }

    private func draft(_ front: String, back: String = "дом", source: BackSource = .translation, in folder: Folder)
        -> CardDraft
    {
        CardDraft(front: front, context: "", back: back, backSource: source, folder: folder)
    }

    // Catches: comparing raw fronts instead of keys, checking only the same folder rather than the
    // root, or matching across roots.
    @Test("A duplicate is the same front key anywhere in the same root folder")
    func duplicate() throws {
        let kuca = try service.create(draft("kuća", in: words))

        #expect(try service.duplicate(of: "Kuca ", in: serbian, excluding: nil) === kuca)
        #expect(try service.duplicate(of: "Kuca ", in: english, excluding: nil) == nil)
        #expect(try service.duplicate(of: "Kuca ", in: words, excluding: kuca) == nil)
    }

    // Catches: saving with a blank side (the UI disables Save, but the service is the last line).
    @Test(
        "Saving is refused without a front or a back",
        arguments: [("  ", "дом"), ("kuća", " ")]
    )
    func incomplete(front: String, back: String) {
        #expect(throws: CardError.incomplete) { try service.create(draft(front, back: back, in: words)) }
        #expect(throws: CardError.incomplete) {
            let card = try service.create(draft("kuća", in: words))
            try service.update(card, with: draft(front, back: back, in: words))
        }
    }

    // Catches: remembering the source on the subfolder (or not at all) instead of on its root.
    @Test("The next card in a root folder starts with the back source last saved there")
    func rememberedBackSource() throws {
        try service.create(draft("hvala", back: "thanks, thank you", source: .synonyms, in: words))

        #expect(words.defaultBackSource == .synonyms)
        #expect(serbian.defaultBackSource == .synonyms)
        #expect(english.defaultBackSource == .translation)
    }

    // Catches: an edit that updates the front but leaves a stale front key, or ignores the folder.
    @Test("Editing a card can change its front, back and folder")
    func edit() throws {
        let card = try service.create(draft("kuca", in: words))

        try service.update(card, with: draft(" Kuća ", back: "house", source: .custom, in: english))

        #expect(card.front == "Kuća")
        #expect(card.frontKey == "kuca")
        #expect(card.back == "house")
        #expect(card.source == .custom)
        #expect(card.folder === english)
    }
}
