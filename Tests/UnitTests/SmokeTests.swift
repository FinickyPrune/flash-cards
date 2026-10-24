import Testing
@testable import FlashCards

@Suite("Smoke")
struct SmokeTests {
    @Test("Accessibility identifiers are stable")
    func accessibilityIdentifiers() {
        #expect(AccessibilityID.rootTitle == "root.title")
    }
}
