import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("Card")
struct CardTests {
    // Normalisation rules themselves are tested in FlashCoreTests/FrontKeyTests.
    // Catches: setFront updating the front but leaving a stale frontKey.
    @Test("The front key follows the front")
    func frontKeyFollowsFront() throws {
        let container = try AppModelContainer.make(inMemory: true)
        let card = Card(front: "Kuća ", back: "дом", backSource: "translation", folder: nil)
        container.mainContext.insert(card)
        #expect(card.frontKey == "kuca")

        card.setFront("ice  cream")
        #expect(card.frontKey == "ice cream")
    }
}
