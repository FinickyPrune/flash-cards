import Foundation

/// Review days start at 04:00 local time, so a late-night session still counts as the evening's day.
public enum ReviewDay {
    static let startHour = 4

    /// 04:00 on the review day that is `days` after the review day containing `date`.
    static func start(_ days: Int, after date: Date, calendar: Calendar) -> Date {
        let shift = calendar.component(.hour, from: date) < startHour ? days - 1 : days
        let day = calendar.date(byAdding: .day, value: shift, to: calendar.startOfDay(for: date)) ?? date
        return calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: day) ?? day
    }

    /// Review days from the one containing `now` to the one containing `date`: 0 today, 1 tomorrow.
    public static func count(from now: Date, to date: Date, calendar: Calendar) -> Int {
        calendar.dateComponents(
            [.day],
            from: start(0, after: now, calendar: calendar),
            to: start(0, after: date, calendar: calendar)
        ).day ?? 0
    }
}
