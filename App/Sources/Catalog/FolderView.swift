import SwiftData
import SwiftUI

/// One folder: its subfolders by name, then its cards newest first (`catalog.md`).
struct FolderView: View {
    let folder: Folder
    @Environment(\.modelContext) private var context
    @State private var actions = FolderActions()
    @State private var isCreatingSubfolder = false

    var body: some View {
        let subfolders = folder.sortedChildren
        let cards = (folder.cards ?? []).sorted { $0.createdAt > $1.createdAt }
        List {
            if !subfolders.isEmpty {
                Section("Folders") {
                    ForEach(subfolders) { subfolder in
                        NavigationLink(value: subfolder) {
                            FolderRow(folder: subfolder)
                        }
                        .folderRowActions(for: subfolder, actions)
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
                    Button("New Subfolder") { isCreatingSubfolder = true }
                        .accessibilityIdentifier(AccessibilityID.FolderScreen.emptyNewSubfolder)
                }
                .accessibilityIdentifier(AccessibilityID.FolderScreen.empty)
            }
        }
        .navigationTitle(folder.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("New Subfolder", systemImage: "folder.badge.plus") { isCreatingSubfolder = true }
                    .accessibilityIdentifier(AccessibilityID.FolderScreen.newSubfolder)
            }
        }
        .sheet(isPresented: $isCreatingSubfolder) {
            FolderNameSheet(title: "New Subfolder", saveTitle: "Create", initialName: "") { name in
                try CatalogService(context: context).createSubfolder(name: name, in: folder)
            }
        }
        .folderActionsPresentation(actions)
    }
}
