import Testing
@testable import FlashCards

@Suite("ContextHighlight")
struct ContextHighlightTests {
    // Catches: a case- or diacritic-sensitive search (no highlight for "Cook" or "café"), a later
    // occurrence picked over the first, the front highlighted inside a longer word when it also
    // stands alone, no fallback when it only appears inside one, or an empty front matching.
    @Test(arguments: [
        ("cook", "He says he can Cook it, cook it well.", "Cook" as String?, 15),
        ("cafe", "Un café noir", "café", 3),
        ("Café", "a cafe", "cafe", 2),
        ("cook", "Cookies? I can cook.", "cook", 15),
        ("cook", "Cookies, please.", "Cook", 0),
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
