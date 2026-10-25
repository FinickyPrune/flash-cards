import SwiftData
import SwiftUI

/// Picks the folder a card goes into; any folder at any depth.
struct FolderPickerSheet: View {
    @Binding var selection: Folder
    @Query(sort: [SortDescriptor(\Folder.name, comparator: .localizedStandard)])
    private var folders: [Folder]
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric private var indent = 20.0

    var body: some View {
        NavigationStack {
            List(FolderTree.entries(folders)) { entry in
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
            .navigationTitle("Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
