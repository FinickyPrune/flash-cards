import FlashCore
import Foundation
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("ReviewService")
struct ReviewServiceTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Belgrade") ?? .gmt
        return calendar
    }()

    private static func date(_ day: Int, _ hour: Int) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: hour)) ?? .distantPast
    }

    private static let now = date(1, 12)

    private let container: ModelContainer
    private let service: ReviewService
    private let root: Folder

    private var context: ModelContext {
        container.mainContext
    }

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
        service = ReviewService(
            context: container.mainContext,
            scheduler: SM2Scheduler(calendar: Self.calendar),
            clock: { Self.now }
        )
        root = Folder(name: "English", learningLanguage: "en", backLanguage: "ru")
        container.mainContext.insert(root)
    }

    private func card(
        _ front: String,
        in folder: Folder,
        createdDay: Int = 1,
        state: SchedulingState? = nil
    ) -> Card {
        let card = Card(
            front: front,
            back: "x",
            backSource: "custom",
            folder: folder,
            createdAt: Self.date(createdDay, 0)
        )
        context.insert(card)
        if let state {
            let reviewState = ReviewState(card: card)
            reviewState.apply(state)
            context.insert(reviewState)
        }
        return card
    }

    /// Every log row as "rating kind direction @ time".
    private func logs() throws -> [String] {
        try context.fetch(FetchDescriptor<ReviewLog>()).map {
            "\($0.rating) \($0.kind) \($0.direction) @ \($0.reviewedAt == Self.now ? "now" : "\($0.reviewedAt)")"
        }
    }

    // Catches: no ReviewState created for a new card, the scheduler's result not stored, or the
    // log missing or written with the wrong kind.
    @Test("The first rating of a new card stores the schedule and one review log row")
    func firstRating() throws {
        let card = card("run", in: root)

        try service.record(.good, for: card, isFirstRating: true, isPractice: false)

        // Good on a new card: 1 day, due 04:00 the next review day.
        let expected = SchedulingState(repetitions: 1, intervalDays: 1, dueDate: Self.date(2, 4))
        #expect(card.reviewStates?.count == 1)
        #expect(card.forwardReviewState?.schedulingState == expected)
        #expect(try logs() == ["2 review forward @ now"])
    }

    // Catches: a repeat rating rescheduling the card a second time in one session, or practice
    // changing the schedule (both would turn this 10-day card into a lapse on Again).
    @Test(
        "A repeat or practice rating is only logged",
        arguments: [
            (false, false, "review"),
            (true, true, "practice"),
        ]
    )
    func onlyLogged(isFirstRating: Bool, isPractice: Bool, expectedKind: String) throws {
        let learned = SchedulingState(repetitions: 3, intervalDays: 10, dueDate: Self.date(1, 4))
        let card = card("run", in: root, state: learned)

        try service.record(.again, for: card, isFirstRating: isFirstRating, isPractice: isPractice)

        #expect(card.forwardReviewState?.schedulingState == learned)
        #expect(try logs() == ["0 \(expectedKind) forward @ now"])
    }

    // Catches: reviewing only the folder's own cards, including a sibling's, ignoring stored
    // schedules (a card due next week would then count as new), or passing the wrong creation
    // date (new cards go oldest first). Practice takes the same subtree, due or not.
    @Test("Build and practice use the whole subtree with each card's schedule")
    func buildSubtree() throws {
        let child = Folder(name: "Show", parent: root)
        let grandchild = Folder(name: "Season", parent: child)
        let sibling = Folder(name: "Other", parent: root)
        let own = card("one", in: child, createdDay: 2)
        let deep = card("two", in: grandchild, createdDay: 1)
        let overdue = card(
            "three",
            in: grandchild,
            state: SchedulingState(repetitions: 1, intervalDays: 1, dueDate: Self.date(1, 4))
        )
        let later = card(
            "later",
            in: grandchild,
            state: SchedulingState(repetitions: 1, intervalDays: 6, dueDate: Self.date(7, 4))
        )
        _ = card("elsewhere", in: sibling)
        try context.save()

        // Due first, then new cards oldest first; the card due next week waits.
        #expect(service.build(for: child) == .session([overdue.id, deep.id, own.id]))
        #expect(Set(service.practice(for: child)) == [own.id, deep.id, overdue.id, later.id])
    }
}
