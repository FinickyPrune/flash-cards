import FlashCore
import SwiftData
import SwiftUI

/// Review of a folder's subtree, shown full screen (`review.md` → Flow). Close dismisses at once;
/// ratings given so far are already saved.
struct ReviewView: View {
    @State private var model: ReviewViewModel
    @Environment(\.dismiss) private var dismiss

    init(model: ReviewViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbar }
        }
        // Play starts the session before presenting; this covers a model built without it.
        .task { model.start() }
        .saveErrorAlert($model.saveError)
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .loading:
            Color.clear
        case .empty:
            ContentUnavailableView {
                // On the label: an identifier on the whole view would replace the buttons' own.
                Label("Nothing to Review", systemImage: "rectangle.stack")
                    .accessibilityIdentifier(AccessibilityID.Review.empty)
            } description: {
                Text("This folder has no cards yet.")
            } actions: {
                Button("Close") { dismiss() }
            }
        case let .allCaughtUp(nextDue):
            ContentUnavailableView {
                Label("All Caught Up", systemImage: "checkmark.circle")
                    .accessibilityIdentifier(AccessibilityID.Review.allCaughtUp)
            } description: {
                Text("Next card: \(Self.relativeDay(of: nextDue))")
            } actions: {
                Button("Practice 20 Random Cards") { model.startPractice() }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier(AccessibilityID.Review.practice)
                Button("Close") { dismiss() }
            }
        case .card:
            if let card = model.currentCard {
                cardFlow(card)
            }
        case let .summary(summary):
            ReviewSummaryView(
                summary: summary,
                canContinue: model.nextSession != nil,
                onDone: { dismiss() },
                onMore: { model.continueReviewing() }
            )
        }
    }

    private func cardFlow(_ card: Card) -> some View {
        ScrollView {
            // Tapping anywhere on the card flips it; a button so VoiceOver can flip it too.
            Button { model.flip() } label: {
                ReviewCardView(card: card, isFlipped: model.isFlipped)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint(model.isFlipped ? Text(verbatim: "") : Text("Shows the back"))
            // Flipped, it is only the card's content; VoiceOver moves on to the ratings.
            .accessibilityRemoveTraits(model.isFlipped ? .isButton : [])
            .accessibilityIdentifier(AccessibilityID.Review.card)
        }
        // A new card starts at the top, not at the previous card's scroll offset.
        .id(card.id)
        .safeAreaInset(edge: .bottom) {
            if model.isFlipped {
                ratingButtons
            }
        }
    }

    private var ratingButtons: some View {
        HStack(spacing: 8) {
            ForEach(Rating.allCases, id: \.self) { rating in
                Button { model.rate(rating) } label: {
                    Text(rating.title)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(rating.tint)
                .accessibilityIdentifier(AccessibilityID.Review.rating(rating))
            }
        }
        .padding()
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        // The other states have their own Close or Done.
        if model.phase == .card {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark") { dismiss() }
                    .accessibilityIdentifier(AccessibilityID.Review.close)
            }
            ToolbarItem(placement: .principal) {
                VStack {
                    if model.session.isPractice {
                        Text("Practice")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("\(model.session.position) / \(model.session.cardCount)")
                        .font(.headline)
                        .monospacedDigit()
                        .accessibilityIdentifier(AccessibilityID.Review.position)
                }
            }
        }
    }

    /// "today", "tomorrow", "in 3 days": whole review days, since cards are due at the start of one.
    private static func relativeDay(of date: Date) -> String {
        let days = ReviewDay.count(from: .now, to: date, calendar: .current)
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .full
        return formatter.localizedString(from: DateComponents(day: max(days, 0)))
    }
}

#Preview {
    let container = ModelContainer.preview
    let folder = (try? container.mainContext.fetch(FetchDescriptor<Folder>()))?.first { $0.name == "Season 1" }
    if let folder {
        ReviewView(model: ReviewViewModel(
            folder: folder,
            service: AppDependencies.live(context: container.mainContext).reviewService
        ))
        .modelContainer(container)
    }
}
