import FlashCore
import Foundation
import Mockable
import SwiftData
import Testing
@testable import FlashCards

@MainActor
@Suite("ReviewViewModel")
struct ReviewViewModelTests {
    private let container: ModelContainer
    private let service = MockReviewServicing()
    private let folder: Folder

    init() throws {
        container = try AppModelContainer.make(inMemory: true)
        folder = Folder(name: "English", learningLanguage: "en", backLanguage: "ru")
        container.mainContext.insert(folder)
    }

    private func card(_ front: String) -> Card {
        let card = Card(front: front, back: "x", backSource: "custom", folder: folder)
        container.mainContext.insert(card)
        return card
    }

    // Catches: rating before the flip (a double tap rating the next card unseen), the first/repeat
    // flag not taken from the session, the card not advancing, or the summary not shown at the end.
    @Test("Each rating after the flip is recorded with the session's flags and advances to the summary")
    func ratingFlow() {
        let first = card("reckon")
        let second = card("cook")
        given(service).build(for: .any)
            .willReturn(.session([first.id, second.id]))
            .build(for: .any).willReturn(.empty)
        given(service).record(.any, for: .any, isFirstRating: .any, isPractice: .any).willReturn()
        let model = ReviewViewModel(folder: folder, service: service)
        model.start()

        model.rate(.good)
        verify(service).record(.any, for: .any, isFirstRating: .any, isPractice: .any).called(.never)

        model.flip()
        // Again brings `first` back after `second` (fewer than 3 cards remain).
        model.rate(.again)
        #expect(model.currentCard === second)
        #expect(model.isFlipped == false)
        model.flip()
        model.rate(.good)
        model.flip()
        model.rate(.easy)

        verify(service).record(
            .value(.again),
            for: .value(first),
            isFirstRating: .value(true),
            isPractice: .value(false)
        )
        .called(.once)
        verify(service).record(
            .value(.good),
            for: .value(second),
            isFirstRating: .value(true),
            isPractice: .value(false)
        )
        .called(.once)
        verify(service).record(
            .value(.easy),
            for: .value(first),
            isFirstRating: .value(false),
            isPractice: .value(false)
        )
        .called(.once)
        // Two distinct cards; only `second` was Good or Easy on its first rating.
        #expect(model.phase == .summary(ReviewSession.Summary(reviewed: 2, goodOrEasy: 1)))
    }

    // Catches: practice ratings recorded as regular reviews, which would change the schedule.
    @Test("Practice ratings are recorded as practice")
    func practice() {
        let reckon = card("reckon")
        let nextDue = Date(timeIntervalSince1970: 1_800_000_000)
        given(service).build(for: .any).willReturn(.allCaughtUp(nextDue: nextDue))
        given(service).practice(for: .any).willReturn([reckon.id])
        given(service).record(.any, for: .any, isFirstRating: .any, isPractice: .any).willReturn()
        let model = ReviewViewModel(folder: folder, service: service)
        model.start()
        #expect(model.phase == .allCaughtUp(nextDue: nextDue))

        model.startPractice()
        model.flip()
        model.rate(.good)

        verify(service).record(
            .value(.good),
            for: .value(reckon),
            isFirstRating: .value(true),
            isPractice: .value(true)
        )
        .called(.once)
        #expect(model.phase == .summary(ReviewSession.Summary(reviewed: 1, goodOrEasy: 1)))
        #expect(model.nextSession == nil)
    }

    // Catches: More shown when building again gives nothing (it would open an empty session), or
    // More not starting the session the service built.
    @Test(
        "More is offered only when building again gives a session",
        arguments: [true, false]
    )
    func more(hasNextSession: Bool) {
        let reckon = card("reckon")
        let cook = card("cook")
        let again: SessionBuilder.Outcome = hasNextSession
            ? .session([cook.id])
            : .allCaughtUp(nextDue: Date(timeIntervalSince1970: 1_800_000_000))
        given(service).build(for: .any)
            .willReturn(.session([reckon.id]))
            .build(for: .any).willReturn(again)
        given(service).record(.any, for: .any, isFirstRating: .any, isPractice: .any).willReturn()
        let model = ReviewViewModel(folder: folder, service: service)
        model.start()
        model.flip()
        model.rate(.good)

        #expect((model.nextSession != nil) == hasNextSession)
        model.continueReviewing()
        if hasNextSession {
            #expect(model.phase == .card)
            #expect(model.currentCard === cook)
        } else {
            #expect(model.phase == .summary(ReviewSession.Summary(reviewed: 1, goodOrEasy: 1)))
        }
    }

    // Catches: a failed save moving on anyway, so the user thinks a rating was kept that wasn't.
    @Test("A failed save keeps the card and shows an error")
    func failedSave() {
        let reckon = card("reckon")
        given(service).build(for: .any).willReturn(.session([reckon.id]))
        given(service).record(.any, for: .any, isFirstRating: .any, isPractice: .any)
            .willThrow(CocoaError(.fileWriteOutOfSpace))
        let model = ReviewViewModel(folder: folder, service: service)
        model.start()
        model.flip()
        model.rate(.good)

        #expect(model.phase == .card)
        #expect(model.currentCard === reckon)
        #expect(model.isFlipped)
        #expect(model.saveError != nil)
    }
}
