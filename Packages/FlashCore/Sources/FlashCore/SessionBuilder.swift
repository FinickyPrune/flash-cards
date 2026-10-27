import Foundation

/// Picks the cards for one review session from any list of cards (`review.md` → Session).
public enum SessionBuilder {
    public static let sessionSize = 20

    public enum Result: Sendable, Equatable {
        /// Due cards, most overdue first, then new cards, oldest first; at most `sessionSize`.
        case session([UUID])
        /// There are cards, but none is due or new; `nextDue` is the earliest due date.
        case allCaughtUp(nextDue: Date)
        case empty
    }

    public static func build(from cards: [SessionCard], at now: Date) -> Result {
        let due = cards
            .filter { $0.isDue(at: now) }
            .sorted { ($0.state.dueDate ?? now, $0.createdAt) < ($1.state.dueDate ?? now, $1.createdAt) }
        let new = cards
            .filter(\.isNew)
            .sorted { $0.createdAt < $1.createdAt }
        let picked = (due + new).prefix(sessionSize).map(\.id)
        if !picked.isEmpty {
            return .session(picked)
        }
        guard let nextDue = cards.compactMap(\.state.dueDate).min() else {
            return .empty
        }
        return .allCaughtUp(nextDue: nextDue)
    }

    /// Up to `count` cards in random order, for when nothing is due or new.
    public static func practice(
        from cards: [SessionCard],
        count: Int = sessionSize,
        using generator: inout some RandomNumberGenerator
    ) -> [UUID] {
        Array(cards.shuffled(using: &generator).prefix(count).map(\.id))
    }
}
