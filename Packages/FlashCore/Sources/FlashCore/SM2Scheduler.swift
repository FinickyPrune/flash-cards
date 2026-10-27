import Foundation

/// SM-2-like scheduler with whole-day intervals and no fuzz (`review.md` → Scheduling).
public struct SM2Scheduler: Scheduler {
    static let minimumEase = 1.3
    static let maximumIntervalDays = 365

    private let calendar: Calendar

    /// `autoupdatingCurrent` follows a time-zone change while the app runs.
    public init(calendar: Calendar = .autoupdatingCurrent) {
        self.calendar = calendar
    }

    public func schedule(_ state: SchedulingState, rating: Rating, at now: Date) -> SchedulingState {
        var next = state
        switch rating {
        case .again where state.repetitions == 0:
            // Not learned yet: no penalty, just due again today.
            next.intervalDays = 0
            next.dueDate = now
            return next
        case .again:
            next.intervalDays = 1
            next.repetitions = 0
            next.lapses += 1
            next.ease = Self.clampedEase(state.ease - 0.2)
        case .hard, .good, .easy:
            next.intervalDays = Self.interval(after: state, rating: rating)
            next.repetitions += 1
            if state.repetitions > 0 {
                next.ease = Self.clampedEase(state.ease + Self.easeChange(for: rating))
            }
        }
        next.dueDate = ReviewDay.start(next.intervalDays, after: now, calendar: calendar)
        return next
    }

    /// Interval for Hard, Good or Easy; `schedule` handles Again before calling this.
    private static func interval(after state: SchedulingState, rating: Rating) -> Int {
        guard state.repetitions > 0 else {
            return rating == .easy ? 4 : 1
        }
        // Integer percentages: halves like 5 × 2.3 = 11.5 must round up, which Double can miss.
        let previous = state.intervalDays
        let easePercent = Int((state.ease * 100).rounded())
        // A harder answer never gives a longer interval, and Hard never stalls on the same one.
        let hard = max(previous + 1, roundedDivision(previous * 120, by: 100))
        let good = max(hard + 1, state.repetitions == 1 ? 6 : roundedDivision(previous * easePercent, by: 100))
        let easy = max(good + 1, roundedDivision(previous * easePercent * 130, by: 10000))
        let days = switch rating {
        case .again, .hard: hard
        case .good: good
        case .easy: easy
        }
        return min(days, maximumIntervalDays)
    }

    /// Rounds half up; both operands are non-negative here.
    private static func roundedDivision(_ dividend: Int, by divisor: Int) -> Int {
        (dividend + divisor / 2) / divisor
    }

    private static func easeChange(for rating: Rating) -> Double {
        switch rating {
        case .hard: -0.15
        case .easy: 0.15
        case .again, .good: 0
        }
    }

    /// Rounded to hundredths so repeated steps don't drift (2.5 − 0.15 equals the literal 2.35).
    private static func clampedEase(_ ease: Double) -> Double {
        max(minimumEase, (ease * 100).rounded() / 100)
    }
}
