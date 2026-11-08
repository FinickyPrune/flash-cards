import Testing
@testable import FlashCards

@Suite("ContextHighlight")
struct ContextHighlightTests {
    // Catches: a case- or diacritic-sensitive search (no highlight for "Cook" or "café"), a later
    // occurrence picked over the first, or an empty front matching at the start.
    @Test(arguments: [
        ("cook", "He says he can Cook it, cook it well.", "Cook" as String?, 15),
        ("cafe", "Un café noir", "café", 3),
        ("Café", "a cafe", "cafe", 2),
        ("reckon", "I guess so.", nil, 0),
        ("", "Anything", nil, 0),
    ])
    func firstOccurrence(front: String, context: String, match: String?, offset: Int) {
        let range = ContextHighlight.range(of: front, in: context)
        #expect(range.map { String(context[$0]) } == match)
        if let range {
            #expect(context.distance(from: context.startIndex, to: range.lowerBound) == offset)
        }
    }
}
