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
                    ForEach(cards) { CardRow(card: $0) }
                }
            }
        }
        .overlay {
            if subfolders.isEmpty, cards.isEmpty {
                ContentUnavailableView {
                    Label("Empty Folder", systemImage: "folder")
                } description: {
                    Text("This folder has no subfolders or cards yet.")
                } actions: {
                    Button("New Subfolder") { model.isCreatingSubfolder = true }
                        .accessibilityIdentifier(AccessibilityID.FolderScreen.emptyNewSubfolder)
                }
                .accessibilityIdentifier(AccessibilityID.FolderScreen.empty)
            }
        }
        .navigationTitle(model.folder.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Subfolder", systemImage: "folder.badge.plus") { model.isCreatingSubfolder = true }
                    .accessibilityIdentifier(AccessibilityID.FolderScreen.newSubfolder)
            }
        }
        .sheet(isPresented: $model.isCreatingSubfolder) { FolderNameSheet(model: model.newSubfolderModel()) }
        .folderActionsPresentation(model.rowActions)
    }
}
