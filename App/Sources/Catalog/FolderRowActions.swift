import SwiftUI

extension View {
    /// Play, rename, appearance, move and delete on a folder row's context menu; rename, move and
    /// delete also as swipe actions.
    func folderRowActions(for folder: Folder, _ actions: FolderRowActionsModel) -> some View {
        contextMenu { FolderActionButtons(folder: folder, actions: actions) }
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

    /// Asks before deleting `deleting` and its subtree; `confirm` deletes it.
    func folderDeleteConfirmation(
        _ deleting: Binding<Folder?>,
        confirm: @escaping (Folder) -> Void
    ) -> some View {
        confirmationDialog(
            Text("Delete “\(deleting.wrappedValue?.name ?? "")”?"),
            isPresented: Binding(isPresent: deleting),
            titleVisibility: .visible,
            presenting: deleting.wrappedValue
        ) { folder in
            Button("Delete Folder", role: .destructive) { confirm(folder) }
                .accessibilityIdentifier(AccessibilityID.FolderAction.confirmDelete)
        } message: { _ in
            Text("Its subfolders and cards will be deleted too. This can't be undone.")
        }
    }

    /// The review, the sheets and the delete confirmation the row actions open.
    func folderActionsPresentation(_ actions: FolderRowActionsModel) -> some View {
        modifier(FolderActionsPresentation(actions: actions))
    }
}

/// Play, rename, appearance, move and delete for one folder, as menu items.
struct FolderActionButtons: View {
    let folder: Folder
    let actions: FolderRowActionsModel
    /// Off on the folder's own screen, where Play is on the summary card.
    var includesPlay = true
    /// Asks before deleting; by default through `actions`.
    var delete: (() -> Void)?

    var body: some View {
        if includesPlay {
            Button("Play", systemImage: "play") { actions.play(folder) }
                .accessibilityIdentifier(AccessibilityID.FolderAction.play)
        }
        Button("Rename", systemImage: "pencil") { actions.renaming = folder }
            .accessibilityIdentifier(AccessibilityID.FolderAction.rename)
        Button("Appearance", systemImage: "paintpalette") { actions.styling = folder }
            .accessibilityIdentifier(AccessibilityID.FolderAction.appearance)
        Button("Move", systemImage: "folder") { actions.moving = folder }
            .accessibilityIdentifier(AccessibilityID.FolderAction.move)
        Button("Delete", systemImage: "trash", role: .destructive) {
            if let delete {
                delete()
            } else {
                actions.deleting = folder
            }
        }
        .accessibilityIdentifier(AccessibilityID.FolderAction.delete)
    }
}

private struct FolderActionsPresentation: ViewModifier {
    @Bindable var actions: FolderRowActionsModel

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $actions.review) { ReviewView(model: $0) }
            .sheet(item: $actions.renaming) { FolderNameSheet(model: actions.renameModel(for: $0)) }
            .sheet(item: $actions.styling) { AppearanceSheet(model: actions.appearanceModel(for: $0)) }
            .sheet(item: $actions.moving) { MoveFolderSheet(model: actions.moveModel(for: $0)) }
            .folderDeleteConfirmation($actions.deleting) { actions.confirmDelete($0) }
            .saveErrorAlert($actions.saveError)
    }
}
