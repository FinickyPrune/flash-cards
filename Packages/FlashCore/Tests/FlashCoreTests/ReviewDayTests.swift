import Foundation
import Testing
@testable import FlashCore

@Suite("ReviewDay")
struct ReviewDayTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Belgrade") ?? .gmt
        return calendar
    }()

    private static func date(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        let components = DateComponents(year: 2026, month: 11, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? .distantPast
    }

    // Catches: counting calendar days from midnight, which is one day off between 00:00 and 04:00,
    // when the user is still in the previous review day.
    @Test(
        "Review days are counted from 04:00, not midnight",
        arguments: [
            (date(1, 12), date(2, 4), 1),
            (date(2, 1, 30), date(2, 4), 1),
            (date(2, 1, 30), date(3, 4), 2),
            (date(2, 4), date(2, 4), 0),
            (date(2, 3, 59), date(2, 4), 1),
        ]
    )
    func count(now: Date, due: Date, expected: Int) {
        #expect(ReviewDay.count(from: now, to: due, calendar: Self.calendar) == expected)
    }
}
