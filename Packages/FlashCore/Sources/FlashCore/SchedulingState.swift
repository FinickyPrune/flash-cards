import Foundation

/// Scheduling state of one card in one direction, without persistence (decision 0002).
public struct SchedulingState: Sendable, Equatable {
    /// A card counts as learned for folder progress from this interval on (`review.md`).
    public static let learnedIntervalDays = 21

    /// Successful reviews in a row; 0 for a new card and after a lapse.
    public var repetitions: Int
    public var intervalDays: Int
    public var ease: Double
    public var lapses: Int
    /// `nil` for a card that was never reviewed.
    public var dueDate: Date?

    public init(
        repetitions: Int = 0,
        intervalDays: Int = 0,
        ease: Double = 2.5,
        lapses: Int = 0,
        dueDate: Date? = nil
    ) {
        self.repetitions = repetitions
        self.intervalDays = intervalDays
        self.ease = ease
        self.lapses = lapses
        self.dueDate = dueDate
    }

    public var isLearned: Bool {
        intervalDays >= Self.learnedIntervalDays
    }
}
