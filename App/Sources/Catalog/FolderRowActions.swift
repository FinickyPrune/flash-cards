import SwiftData
import SwiftUI

extension View {
    /// Rename, move and delete on a folder row: context menu and swipe actions.
    func folderRowActions(for folder: Folder, _ actions: FolderActions) -> some View {
        contextMenu {
            Button("Rename", systemImage: "pencil") { actions.renaming = folder }
                .accessibilityIdentifier(AccessibilityID.FolderAction.rename)
            Button("Move", systemImage: "folder") { actions.moving = folder }
                .accessibilityIdentifier(AccessibilityID.FolderAction.move)
            Button("Delete", systemImage: "trash", role: .destructive) { actions.deleting = folder }
                .accessibilityIdentifier(AccessibilityID.FolderAction.delete)
        }
        .swipeActions(edge: .trailing) {
            // Not `.destructive`: that role animates the row away before the user confirms.
            Button("Delete", systemImage: "trash") { actions.deleting = folder }
                .tint(.red)
            Button("Move", systemImage: "folder") { actions.moving = folder }
        }
        .swipeActions(edge: .leading) {
            Button("Rename", systemImage: "pencil") { actions.renaming = folder }
                .tint(.accentColor)
        }
    }

    /// The sheets and the delete confirmation the row actions open.
    func folderActionsPresentation(_ actions: FolderActions) -> some View {
        modifier(FolderActionsPresentation(actions: actions))
    }
}

private struct FolderActionsPresentation: ViewModifier {
    @Bindable var actions: FolderActions
    @Environment(\.modelContext) private var context
    @State private var saveError: String?

    func body(content: Content) -> some View {
        content
            .sheet(item: $actions.renaming) { folder in
                FolderNameSheet(title: "Rename Folder", saveTitle: "Save", initialName: folder.name) { name in
                    try CatalogService(context: context).rename(folder, to: name)
                }
            }
            .sheet(item: $actions.moving) { MoveFolderSheet(folder: $0) }
            .confirmationDialog(
                deleteTitle,
                isPresented: Binding(
                    get: { actions.deleting != nil },
                    set: {
                        if !$0 {
                            actions.deleting = nil
                        }
                    }
                ),
                titleVisibility: .visible,
                presenting: actions.deleting
            ) { folder in
                Button("Delete Folder", role: .destructive) {
                    // Close the dialog first so it never reads the deleted model.
                    actions.deleting = nil
                    delete(folder)
                }
                .accessibilityIdentifier(AccessibilityID.FolderAction.confirmDelete)
            } message: { _ in
                Text("Its subfolders and cards will be deleted too. This can't be undone.")
            }
            .saveErrorAlert($saveError)
    }

    private var deleteTitle: Text {
        Text("Delete “\(actions.deleting?.name ?? "")”?")
    }

    private func delete(_ folder: Folder) {
        do {
            try CatalogService(context: context).delete(folder)
        } catch {
            saveError = error.localizedDescription
        }
    }
}
