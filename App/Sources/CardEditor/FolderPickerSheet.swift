import SwiftData
import SwiftUI

/// Picks a folder at any depth: where a card goes, or where a CSV import goes. With `makeNewFolder`
/// it also offers New Folder…, and a root folder created there is picked.
struct FolderPickerSheet: View {
    @Binding var selection: Folder?
    var makeNewFolder: (() -> NewRootFolderViewModel)?
    @Query(sort: [SortDescriptor(\Folder.name, comparator: .localizedStandard)])
    private var folders: [Folder]
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric private var indent = 20.0
    @State private var newFolder: NewRootFolderViewModel?
    /// A folder was created and picked: the picker closes once the New Folder sheet has.
    @State private var closesAfterNewFolder = false

    var body: some View {
        NavigationStack {
            List {
                if let makeNewFolder {
                    Button {
                        let model = makeNewFolder()
                        model.onCreate = { folder in
                            selection = folder
                            closesAfterNewFolder = true
                        }
                        newFolder = model
                    } label: {
                        Label("New Folder…", systemImage: "folder.badge.plus")
                    }
                    .accessibilityIdentifier(AccessibilityID.FolderPicker.newFolder)
                }
                ForEach(FolderTree.entries(folders)) { entry in
                    Button {
                        selection = entry.folder
                        dismiss()
                    } label: {
                        HStack {
                            Label(entry.folder.name, systemImage: "folder")
                                .padding(.leading, indent * Double(entry.depth))
                                .foregroundStyle(Color.primary)
                            Spacer()
                            if entry.folder === selection {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.tint)
                            }
                        }
                    }
                    .accessibilityAddTraits(entry.folder === selection ? .isSelected : [])
                    .accessibilityIdentifier(AccessibilityID.CardEditor.folderOption(entry.folder.name))
                }
            }
            .navigationTitle("Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier(AccessibilityID.FolderPicker.cancel)
                }
            }
            .sheet(item: $newFolder, onDismiss: closeIfFolderCreated) { NewRootFolderSheet(model: $0) }
        }
    }

    private func closeIfFolderCreated() {
        if closesAfterNewFolder {
            dismiss()
        }
    }
}
