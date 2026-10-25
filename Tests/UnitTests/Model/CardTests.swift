import Testing
@testable import FlashCards

@Suite("Card")
struct CardTests {
    // Normalisation rules themselves are tested in FlashCoreTests/FrontKeyTests.
    // Catches: setFront updating the front but leaving a stale frontKey.
    @Test("The front key follows the front")
    func frontKeyFollowsFront() {
        let card = Card(front: "Kuća ", back: "дом", backSource: "translation", folder: nil)
        #expect(card.frontKey == "kuca")

        card.setFront("ice  cream")
        #expect(card.frontKey == "ice cream")
    }
}
