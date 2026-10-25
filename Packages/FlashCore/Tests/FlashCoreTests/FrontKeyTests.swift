import Testing
@testable import FlashCore

@Suite("FrontKey")
struct FrontKeyTests {
    // Catches: dropping one of the folding options, trimming only one end, or not collapsing inner runs.
    @Test(
        "Fronts that differ only in case, diacritics or whitespace share a key",
        arguments: [
            ("kuća", "Kuca "),
            ("kuća", "KUCA"),
            ("ice cream", "ice  cream"),
            ("ice cream", "\tIce\u{00A0}cream\n"),
        ]
    )
    func sameKey(lhs: String, rhs: String) {
        #expect(FrontKey.make(from: lhs) == FrontKey.make(from: rhs))
    }

    // Catches: a normalisation so aggressive it merges different words (e.g. dropping letters or all spaces).
    @Test(
        "Different words keep different keys",
        arguments: [
            ("kuća", "kuna"),
            ("ice cream", "icecream"),
        ]
    )
    func differentKey(lhs: String, rhs: String) {
        #expect(FrontKey.make(from: lhs) != FrontKey.make(from: rhs))
    }
}
