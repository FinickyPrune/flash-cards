import Foundation
import Testing
@testable import FlashCore

@Suite("ReviewSession")
struct ReviewSessionTests {
    private static let ids = Dictionary(uniqueKeysWithValues: "ABCDEFGH".map { (String($0), UUID()) })
    private static let names = Dictionary(uniqueKeysWithValues: ids.map { ($1, $0) })

    private static func session(_ cards: String) -> ReviewSession {
        ReviewSession(cards: cards.compactMap { ids[String($0)] })
    }

    /// Rates each shown card with the next rating and returns the cards in the order shown.
    private static func play(_ session: inout ReviewSession, _ ratings: [Rating]) -> String {
        var shown = ""
        for rating in ratings {
            guard let current = session.current else { break }
            shown += names[current] ?? "?"
            _ = session.rate(rating)
        }
        return shown
    }

    // Catches: a card coming back at once or only at the very end, or an off-by-one in the gap.
    @Test(
        "A card rated Again comes back after 3 other cards, or at the end if fewer remain",
        arguments: [
            ("ABCDE", "ABCDAE"),
            ("AB", "ABA"),
        ]
    )
    func againComesBack(cards: String, expectedOrder: String) {
        var session = Self.session(cards)
        var ratings = Array(repeating: Rating.good, count: expectedOrder.count)
        ratings[0] = .again
        #expect(Self.play(&session, ratings) == expectedOrder)
        #expect(session.isFinished)
    }

    // Catches: a card that comes back forever, or only once.
    @Test("A card rated Again every time is shown 3 times, then the session moves on")
    func returnsAreLimited() {
        var session = Self.session("A")
        #expect(Self.play(&session, [.again, .again, .again, .again]) == "AAA")
        #expect(session.isFinished)
    }

    // Catches: a repeat rating treated as first (it would change the schedule twice), a summary
    // counting showings or the last rating, or a counter that advances on a returning card.
    @Test("Only the first rating counts for the schedule, the summary and the counter")
    func firstRatingCounts() throws {
        var session = Self.session("AB")
        let cardA = try #require(Self.ids["A"])
        let cardB = try #require(Self.ids["B"])
        var positions = [session.position]

        var rated = [session.rate(.again)]
        positions.append(session.position)
        rated.append(session.rate(.good))
        positions.append(session.position)
        rated.append(session.rate(.good))

        #expect(rated == [
            ReviewSession.Rated(cardID: cardA, isFirstRating: true),
            ReviewSession.Rated(cardID: cardB, isFirstRating: true),
            ReviewSession.Rated(cardID: cardA, isFirstRating: false),
        ])
        #expect(positions == [1, 2, 2])
        #expect(session.cardCount == 2)
        // A: Again then Good → reviewed, not Good/Easy. B: Good.
        #expect(session.summary == ReviewSession.Summary(reviewed: 2, goodOrEasy: 1))
        #expect(session.rate(.good) == nil)
    }
}
