import Foundation

/// The queue of one review run: Again brings a card back a few cards later (`review.md` → Session).
public struct ReviewSession: Sendable, Equatable {
    /// Other cards shown before a card rated Again comes back.
    public static let againGap = 3
    /// How many times one card can come back in a session.
    public static let maxReturns = 2

    public struct Rated: Sendable, Equatable {
        public var cardID: UUID
        /// Only the first rating of a card in a session changes its schedule.
        public var isFirstRating: Bool
    }

    public struct Summary: Sendable, Equatable {
        /// Distinct cards rated.
        public var reviewed: Int
        /// Distinct cards whose first rating was Good or Easy.
        public var goodOrEasy: Int
    }

    /// Practice never changes the schedule.
    public let isPractice: Bool
    /// Distinct cards in the session, for the "3 / 20" counter.
    public let cardCount: Int
    private var queue: [UUID]
    private var returns: [UUID: Int] = [:]
    private var firstRatings: [UUID: Rating] = [:]

    public init(cards: [UUID], isPractice: Bool = false) {
        queue = cards
        cardCount = Set(cards).count
        self.isPractice = isPractice
    }

    public var current: UUID? {
        queue.first
    }

    public var isFinished: Bool {
        queue.isEmpty
    }

    /// Distinct cards shown so far, the current one included; a returning card doesn't advance it.
    public var position: Int {
        guard let current, firstRatings[current] == nil else {
            return firstRatings.count
        }
        return firstRatings.count + 1
    }

    public var summary: Summary {
        Summary(
            reviewed: firstRatings.count,
            goodOrEasy: firstRatings.values.count { $0 == .good || $0 == .easy }
        )
    }

    /// Rates the current card and moves on; `nil` when the session is already finished.
    @discardableResult
    public mutating func rate(_ rating: Rating) -> Rated? {
        guard !queue.isEmpty else {
            return nil
        }
        let card = queue.removeFirst()
        let isFirstRating = firstRatings[card] == nil
        if isFirstRating {
            firstRatings[card] = rating
        }
        if rating == .again, returns[card, default: 0] < Self.maxReturns {
            returns[card, default: 0] += 1
            queue.insert(card, at: min(Self.againGap, queue.count))
        }
        return Rated(cardID: card, isFirstRating: isFirstRating)
    }
}
