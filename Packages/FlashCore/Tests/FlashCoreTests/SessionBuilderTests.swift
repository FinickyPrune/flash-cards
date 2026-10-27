import Foundation
import Testing
@testable import FlashCore

@Suite("SessionBuilder")
struct SessionBuilderTests {
    private static let now = Date(timeIntervalSinceReferenceDate: 1_000_000_000)

    private static func daysFromNow(_ days: Double) -> Date {
        now.addingTimeInterval(days * 86400)
    }

    /// A new card created `age` days ago.
    private static func newCard(age: Double) -> SessionCard {
        SessionCard(id: UUID(), createdAt: daysFromNow(-age))
    }

    /// A card created long ago, due `days` from now (negative = overdue).
    private static func scheduledCard(dueIn days: Double) -> SessionCard {
        SessionCard(
            id: UUID(),
            createdAt: daysFromNow(-1000),
            state: SchedulingState(repetitions: 1, intervalDays: 1, dueDate: daysFromNow(days))
        )
    }

    // Catches: new cards before due ones, wrong sort direction, a missing limit,
    // or a card due tomorrow counted as due.
    @Test("Due cards come first, most overdue first, then the oldest new cards, 20 in all")
    func dueThenNew() {
        let due = (1 ... 5).map { Self.scheduledCard(dueIn: -Double($0)) } // overdue by 1…5 days
        let new = (1 ... 30).map { Self.newCard(age: Double($0)) } // created 1…30 days ago
        let later = Self.scheduledCard(dueIn: 1)
        let cards = (due + new + [later]).shuffled()

        let expected = due.reversed().map(\.id) + new.reversed().prefix(15).map(\.id)
        #expect(SessionBuilder.build(from: cards, at: Self.now) == .session(expected))
    }

    // Catches: new cards squeezed in even when due cards fill the session.
    @Test("With 25 due cards the session is the 20 most overdue, with no new cards")
    func dueFillsSession() {
        let due = (1 ... 25).map { Self.scheduledCard(dueIn: -Double($0)) }
        let cards = (due + [Self.newCard(age: 1)]).shuffled()

        let expected = due.reversed().prefix(20).map(\.id)
        #expect(SessionBuilder.build(from: cards, at: Self.now) == .session(expected))
    }

    // Catches: an empty session instead of "all caught up", or the latest due date instead of the earliest.
    @Test("Nothing due or new gives the earliest next due date; no cards gives empty")
    func nothingToReview() {
        let cards = [Self.scheduledCard(dueIn: 3), Self.scheduledCard(dueIn: 1), Self.scheduledCard(dueIn: 7)]
        #expect(SessionBuilder.build(from: cards, at: Self.now) == .allCaughtUp(nextDue: Self.daysFromNow(1)))
        #expect(SessionBuilder.build(from: [], at: Self.now) == .empty)
    }

    // Catches: ignoring the generator, repeating cards, or no limit.
    @Test("Practice takes up to 20 distinct cards in an order set by the generator")
    func practice() {
        let cards = (1 ... 30).map { Self.scheduledCard(dueIn: Double($0)) }
        var first = SeededGenerator(seed: 7)
        var second = SeededGenerator(seed: 7)
        let picked = SessionBuilder.practice(from: cards, using: &first)

        #expect(picked.count == 20)
        #expect(Set(picked).count == 20)
        #expect(Set(picked).isSubset(of: cards.map(\.id)))
        #expect(picked == SessionBuilder.practice(from: cards, using: &second))
        #expect(picked != cards.prefix(20).map(\.id))

        var third = SeededGenerator(seed: 7)
        #expect(SessionBuilder.practice(from: Array(cards.prefix(3)), using: &third).count == 3)
    }
}

/// SplitMix64, so practice order is the same on every run.
private struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
