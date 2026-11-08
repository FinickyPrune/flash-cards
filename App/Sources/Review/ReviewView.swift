import FlashCore
import SwiftData
import SwiftUI

/// Review of a folder's subtree, shown full screen over the folder's wash (`review.md` → Flow).
/// Close dismisses at once; ratings given so far are already saved.
struct ReviewView: View {
    @State private var model: ReviewViewModel
    @Environment(\.dismiss) private var dismiss

    init(model: ReviewViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        let palette = model.folder.resolvedPalette
        content(palette)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background { ScreenWash(palette: palette) }
            .tint(palette.accent)
            // Play starts the session before presenting; this covers a model built without it.
            .task { model.start() }
            .saveErrorAlert($model.saveError)
    }

    @ViewBuilder
    private func content(_ palette: FolderPalette) -> some View {
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
            .reviewCardStyle(palette)
            .padding(16)
        case let .allCaughtUp(nextDue):
            ContentUnavailableView {
                Label("All Caught Up", systemImage: "checkmark.circle")
                    .accessibilityIdentifier(AccessibilityID.Review.allCaughtUp)
            } description: {
                Text("Next card: \(Self.relativeDay(of: nextDue))")
            } actions: {
                Button { model.startPractice() } label: {
                    Text("Practice 20 Random Cards")
                        .foregroundStyle(CatalogStyle.onAccent)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier(AccessibilityID.Review.practice)
                Button("Close") { dismiss() }
            }
            .reviewCardStyle(palette)
            .padding(16)
        case .card:
            if let card = model.currentCard {
                cardFlow(card, palette: palette)
                    .safeAreaInset(edge: .top, spacing: 0) { topBar(palette) }
            }
        case let .summary(summary):
            ReviewSummaryView(
                summary: summary,
                folderName: model.folder.name,
                palette: palette,
                canContinue: model.nextSession != nil,
                onDone: { dismiss() },
                onMore: { model.continueReviewing() }
            )
            .safeAreaInset(edge: .top, spacing: 0) { topBar(palette) }
        }
    }

    private func cardFlow(_ card: Card, palette: FolderPalette) -> some View {
        FillingScrollView {
            // Tapping anywhere on the card flips it; a button so VoiceOver can flip it too.
            Button { model.flip() } label: {
                ReviewCardView(card: card, palette: palette, isFlipped: model.isFlipped)
                    .reviewCardStyle(palette)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityHint(model.isFlipped ? Text(verbatim: "") : Text("Shows the back"))
            // Flipped, it is only the card's content; VoiceOver moves on to the ratings.
            .accessibilityRemoveTraits(model.isFlipped ? .isButton : [])
            .accessibilityIdentifier(AccessibilityID.Review.card)
            .padding(16)
        }
        // A new card starts at the top, not at the previous card's scroll offset.
        .id(card.id)
        .safeAreaInset(edge: .bottom) {
            Group {
                if model.isFlipped {
                    RatingButtons { model.rate($0) }
                } else {
                    Button { model.flip() } label: {
                        Text("Show answer")
                            .font(.headline)
                            .foregroundStyle(palette.accent)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                    .controlSize(.large)
                    .accessibilityIdentifier(AccessibilityID.Review.showAnswer)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    private func topBar(_ palette: FolderPalette) -> some View {
        ReviewTopBar(
            folderName: model.folder.name,
            isPractice: model.session.isPractice,
            position: model.session.position,
            cardCount: model.session.cardCount,
            accent: palette.accent,
            close: { dismiss() }
        )
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
