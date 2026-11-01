import SwiftUI

/// One folder (`catalog.md`): a header, a summary card with Play, its subfolders as tiles, then its
/// cards newest first, over a wash in the folder's palette.
struct FolderView: View {
    @State private var model: FolderViewModel
    /// The header has scrolled under the bar, so the bar shows the name instead.
    @State private var showsBarTitle = false
    @State private var openedSubfolder: Folder?
    @Environment(\.dismiss) private var dismiss

    init(model: FolderViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        if model.isDeleted {
            Color.clear
        } else {
            content
        }
    }

    private var content: some View {
        let folder = model.folder
        let palette = folder.resolvedPalette
        let subfolders = folder.sortedChildren
        let cards = (folder.cards ?? []).sorted { $0.createdAt > $1.createdAt }
        let progress = folder.progress
        // One section: everything above the cards is its header, which the list neither clips to
        // the section's rounded corners nor treats as a row, so the tiles stay separate links.
        return List {
            Section {
                ForEach(cards) { card in
                    Button { model.edit(card) } label: {
                        CardRow(card: card)
                    }
                    .foregroundStyle(Color.primary)
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) { model.deleteCard(card) }
                    }
                    .accessibilityIdentifier(AccessibilityID.Row.card(card.front))
                }
                .listRowBackground(CatalogStyle.surface)
                if subfolders.isEmpty, cards.isEmpty {
                    ContentUnavailableView {
                        Label("Empty Folder", systemImage: "folder")
                    } description: {
                        Text("Add a card or a subfolder.")
                    } actions: {
                        Button("New Card") { model.addCard() }
                            .accessibilityIdentifier(AccessibilityID.FolderScreen.emptyNewCard)
                        Button("New Subfolder") { model.isCreatingSubfolder = true }
                            .accessibilityIdentifier(AccessibilityID.FolderScreen.emptyNewSubfolder)
                    }
                    // Contain: the buttons keep their own identifiers.
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier(AccessibilityID.FolderScreen.empty)
                    // Borderless: in a list row, default buttons all fire on a tap anywhere in it.
                    .buttonStyle(.borderless)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } header: {
                VStack(alignment: .leading, spacing: 16) {
                    FolderHeader(folder: folder)
                    if progress.total > 0 {
                        // Re-read every minute so cards turn due at 04:00 while the screen is open.
                        TimelineView(.everyMinute) { context in
                            FolderSummaryCard(
                                palette: palette,
                                due: folder.dueCount(at: context.date),
                                progress: progress
                            ) { model.rowActions.play(folder) }
                        }
                    }
                    if !subfolders.isEmpty {
                        SectionTitle("Folders")
                        SubfolderGrid(subfolders: subfolders, actions: model.rowActions) { openedSubfolder = $0 }
                    }
                    if !cards.isEmpty {
                        SectionTitle("Cards")
                    }
                }
                .font(.body)
                .foregroundStyle(.primary)
                .textCase(nil)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
        }
        .scrollContentBackground(.hidden)
        .background { ScreenWash(palette: palette) }
        .onScrollGeometryChange(for: Bool.self) { $0.contentOffset.y + $0.contentInsets.top > 60 } action: {
            showsBarTitle = $1
        }
        .navigationTitle(folder.name)
        .navigationBarTitleDisplayMode(.inline)
        .tint(palette.accent)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(folder.name)
                    .font(.headline)
                    .opacity(showsBarTitle ? 1 : 0)
                    .accessibilityHidden(!showsBarTitle)
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button("New Subfolder", systemImage: "folder.badge.plus") { model.isCreatingSubfolder = true }
                    .accessibilityIdentifier(AccessibilityID.FolderScreen.newSubfolder)
                Button("New Card", systemImage: "plus") { model.addCard() }
                    .accessibilityIdentifier(AccessibilityID.FolderScreen.newCard)
                moreMenu(for: folder)
            }
        }
        .navigationDestination(item: $openedSubfolder) { FolderView(model: model.subfolderModel(for: $0)) }
        .sheet(isPresented: $model.isCreatingSubfolder) { FolderNameSheet(model: model.newSubfolderModel()) }
        .sheet(item: $model.editor) { CardEditorSheet(model: $0) }
        .folderDeleteConfirmation($model.deleting) { _ in
            if model.confirmDelete() {
                dismiss()
            }
        }
        .saveErrorAlert($model.saveError)
        .folderActionsPresentation(model.rowActions)
    }

    /// The folder's own actions, as on its context menu but without Play (on the summary card);
    /// deleting it also leaves the screen.
    private func moreMenu(for folder: Folder) -> some View {
        Menu("More", systemImage: "ellipsis") {
            FolderActionButtons(folder: folder, actions: model.rowActions, includesPlay: false) {
                model.deleting = folder
            }
        }
        .accessibilityIdentifier(AccessibilityID.FolderScreen.more)
    }
}

/// Subfolders two to a row (one at accessibility text sizes), each opening its screen.
private struct SubfolderGrid: View {
    let subfolders: [Folder]
    let actions: FolderRowActionsModel
    let open: (Folder) -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let columns = Array(
            repeating: GridItem(.flexible(), spacing: 12, alignment: .top),
            count: dynamicTypeSize.isAccessibilitySize ? 1 : 2
        )
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(subfolders) { subfolder in
                // A menu, not a link with a context menu: a list only gives whole rows context
                // menus, and the tiles live in the section header. Tap opens, long press shows the
                // folder's actions.
                Menu {
                    FolderActionButtons(folder: subfolder, actions: actions)
                } label: {
                    SubfolderTile(folder: subfolder)
                } primaryAction: {
                    open(subfolder)
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
                .accessibilityActions { FolderActionButtons(folder: subfolder, actions: actions) }
                .accessibilityIdentifier(AccessibilityID.Row.folder(subfolder.name))
            }
        }
    }
}

private struct SectionTitle: View {
    let title: LocalizedStringKey

    init(_ title: LocalizedStringKey) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
            .padding(.top, 4)
    }
}
