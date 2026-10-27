import SwiftUI

/// One folder: its subfolders by name, then its cards newest first (`catalog.md`).
struct FolderView: View {
    @State private var model: FolderViewModel

    init(model: FolderViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        let subfolders = model.folder.sortedChildren
        let cards = (model.folder.cards ?? []).sorted { $0.createdAt > $1.createdAt }
        List {
            if !subfolders.isEmpty {
                Section("Folders") {
                    ForEach(subfolders) { subfolder in
                        NavigationLink(value: subfolder) {
                            FolderRow(folder: subfolder)
                        }
                        .folderRowActions(for: subfolder, model.rowActions)
                        .accessibilityIdentifier(AccessibilityID.Row.folder(subfolder.name))
                    }
                }
            }
            if !cards.isEmpty {
                Section("Cards") {
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
                }
            }
        }
        .overlay {
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
                .accessibilityIdentifier(AccessibilityID.FolderScreen.empty)
            }
        }
        .navigationTitle(model.folder.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Play", systemImage: "play.fill") { model.rowActions.play(model.folder) }
                    .accessibilityIdentifier(AccessibilityID.FolderScreen.play)
            }
            ToolbarItemGroup(placement: .primaryAction) {
                Button("New Subfolder", systemImage: "folder.badge.plus") { model.isCreatingSubfolder = true }
                    .accessibilityIdentifier(AccessibilityID.FolderScreen.newSubfolder)
                Button("New Card", systemImage: "plus") { model.addCard() }
                    .accessibilityIdentifier(AccessibilityID.FolderScreen.newCard)
            }
        }
        .sheet(isPresented: $model.isCreatingSubfolder) { FolderNameSheet(model: model.newSubfolderModel()) }
        .sheet(item: $model.editor) { CardEditorSheet(model: $0) }
        .saveErrorAlert($model.saveError)
        .folderActionsPresentation(model.rowActions)
    }
}
