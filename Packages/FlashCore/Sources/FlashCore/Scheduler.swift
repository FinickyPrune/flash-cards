import Foundation

/// Spaced-repetition algorithm; review depends on this, not on a concrete one (decision 0002).
public protocol Scheduler: Sendable {
    func schedule(_ state: SchedulingState, rating: Rating, at now: Date) -> SchedulingState
}
