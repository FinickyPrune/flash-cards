import SwiftUI

extension View {
    /// Play, rename, move and delete on a folder row: context menu and swipe actions.
    func folderRowActions(for folder: Folder, _ actions: FolderRowActionsModel) -> some View {
        contextMenu {
            Button("Play", systemImage: "play") { actions.play(folder) }
                .accessibilityIdentifier(AccessibilityID.FolderAction.play)
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

    /// The review, the sheets and the delete confirmation the row actions open.
    func folderActionsPresentation(_ actions: FolderRowActionsModel) -> some View {
        modifier(FolderActionsPresentation(actions: actions))
    }
}

private struct FolderActionsPresentation: ViewModifier {
    @Bindable var actions: FolderRowActionsModel

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $actions.review) { ReviewView(model: $0) }
            .sheet(item: $actions.renaming) { FolderNameSheet(model: actions.renameModel(for: $0)) }
            .sheet(item: $actions.moving) { MoveFolderSheet(model: actions.moveModel(for: $0)) }
            .confirmationDialog(
                Text("Delete “\(actions.deleting?.name ?? "")”?"),
                isPresented: Binding(isPresent: $actions.deleting),
                titleVisibility: .visible,
                presenting: actions.deleting
            ) { folder in
                Button("Delete Folder", role: .destructive) { actions.confirmDelete(folder) }
                    .accessibilityIdentifier(AccessibilityID.FolderAction.confirmDelete)
            } message: { _ in
                Text("Its subfolders and cards will be deleted too. This can't be undone.")
            }
            .saveErrorAlert($actions.saveError)
    }
}
