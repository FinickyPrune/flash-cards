import Foundation
import Testing
@testable import FlashCore

@Suite("SM2Scheduler")
struct SM2SchedulerTests {
    /// Belgrade switches from summer time on 2026-10-25 at 03:00, so day arithmetic in seconds would drift.
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Belgrade") ?? .gmt
        return calendar
    }()

    private static func date(_ month: Int, _ day: Int, _ hour: Int, _ minute: Int = 0, year: Int = 2026) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? .distantPast
    }

    private static let now = date(11, 1, 12)
    private let scheduler = SM2Scheduler(calendar: calendar)

    // Catches: a wrong first-step table, or ease changing before the card was ever answered right.
    @Test(
        "A new card is due today on Again, in 1 day on Hard or Good, in 4 days on Easy; ease stays 2.5",
        arguments: [
            (Rating.again, SchedulingState(dueDate: now)),
            (.hard, SchedulingState(repetitions: 1, intervalDays: 1, dueDate: date(11, 2, 4))),
            (.good, SchedulingState(repetitions: 1, intervalDays: 1, dueDate: date(11, 2, 4))),
            (.easy, SchedulingState(repetitions: 1, intervalDays: 4, dueDate: date(11, 5, 4))),
        ]
    )
    func newCard(rating: Rating, expected: SchedulingState) {
        #expect(scheduler.schedule(SchedulingState(), rating: rating, at: Self.now) == expected)
    }

    // Catches: skipping the fixed 6-day second step, or multiplying by something other than ease.
    @Test("Good, Good, Good on a new card gives 1, 6, then 6 × 2.5 = 15 days")
    func goodProgression() {
        var state = SchedulingState()
        var intervals: [Int] = []
        for _ in 0 ..< 3 {
            state = scheduler.schedule(state, rating: .good, at: Self.now)
            intervals.append(state.intervalDays)
        }
        #expect(intervals == [1, 6, 15])
    }

    // Catches: wrong multipliers or ease steps, Hard stalling at 1 day, Easy shorter than Good,
    // a lapse that keeps the interval, and missing ease floor or interval cap.
    @Test(
        "A card answered right before follows the SM-2 formulas within the bounds",
        arguments: [
            // 10 × 1.2 = 12, ease −0.15.
            (
                SchedulingState(repetitions: 3, intervalDays: 10),
                Rating.hard,
                SchedulingState(repetitions: 4, intervalDays: 12, ease: 2.35, dueDate: date(11, 13, 4))
            ),
            // 10 × 2.5 = 25, ease unchanged.
            (
                SchedulingState(repetitions: 3, intervalDays: 10),
                .good,
                SchedulingState(repetitions: 4, intervalDays: 25, dueDate: date(11, 26, 4))
            ),
            // 10 × 2.5 × 1.3 = 32.5 → 33, ease +0.15.
            (
                SchedulingState(repetitions: 3, intervalDays: 10),
                .easy,
                SchedulingState(repetitions: 4, intervalDays: 33, ease: 2.65, dueDate: date(12, 4, 4))
            ),
            // Lapse: back to 1 day, ease −0.2.
            (
                SchedulingState(repetitions: 3, intervalDays: 30),
                .again,
                SchedulingState(repetitions: 0, intervalDays: 1, ease: 2.3, lapses: 1, dueDate: date(11, 2, 4))
            ),
            // 1 × 1.2 rounds to 1; Hard still moves on by a day.
            (
                SchedulingState(repetitions: 1, intervalDays: 1),
                .hard,
                SchedulingState(repetitions: 2, intervalDays: 2, ease: 2.35, dueDate: date(11, 3, 4))
            ),
            // 1 × 2.5 × 1.3 = 3, but Good gives 6 at this step, so Easy gives 7.
            (
                SchedulingState(repetitions: 1, intervalDays: 1),
                .easy,
                SchedulingState(repetitions: 2, intervalDays: 7, ease: 2.65, dueDate: date(11, 8, 4))
            ),
            // Ease never drops below 1.3.
            (
                SchedulingState(repetitions: 3, intervalDays: 10, ease: 1.4),
                .hard,
                SchedulingState(repetitions: 4, intervalDays: 12, ease: 1.3, dueDate: date(11, 13, 4))
            ),
            (
                SchedulingState(repetitions: 3, intervalDays: 10, ease: 1.4),
                .again,
                SchedulingState(repetitions: 0, intervalDays: 1, ease: 1.3, lapses: 1, dueDate: date(11, 2, 4))
            ),
            // 200 × 2.5 = 500, capped at a year.
            (
                SchedulingState(repetitions: 5, intervalDays: 200),
                .good,
                SchedulingState(repetitions: 6, intervalDays: 365, dueDate: date(11, 1, 4, year: 2027))
            ),
        ]
    )
    func answeredBefore(state: SchedulingState, rating: Rating, expected: SchedulingState) {
        #expect(scheduler.schedule(state, rating: rating, at: Self.now) == expected)
    }

    // Catches: a midnight day boundary, or adding days as 24-hour periods across a DST change.
    @Test(
        "Due dates fall on 04:00 local of the review day, which starts at 04:00",
        arguments: [
            (date(11, 2, 3, 59), date(11, 2, 4)),
            (date(11, 2, 4, 1), date(11, 3, 4)),
            // The night of Oct 24–25 is an hour longer.
            (date(10, 24, 12), date(10, 25, 4)),
        ]
    )
    func dayBoundary(ratedAt: Date, expectedDue: Date) {
        let state = scheduler.schedule(SchedulingState(), rating: .good, at: ratedAt)
        #expect(state.dueDate == expectedDue)
    }

    // Catches: an off-by-one in the 21-day rule, or a lapse that keeps the card learned.
    @Test("A card is learned from a 21-day interval until it lapses")
    func learned() {
        #expect(!SchedulingState(repetitions: 3, intervalDays: 20).isLearned)
        let learned = SchedulingState(repetitions: 3, intervalDays: 21)
        #expect(learned.isLearned)
        #expect(!scheduler.schedule(learned, rating: .again, at: Self.now).isLearned)
    }
}
