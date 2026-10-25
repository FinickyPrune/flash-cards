import SwiftData
import SwiftUI

/// Root of the app: the root folders (`catalog.md`).
struct HomeView: View {
    @Query(
        filter: #Predicate<Folder> { $0.parent == nil },
        sort: [SortDescriptor(\Folder.name, comparator: .localizedStandard)]
    )
    private var roots: [Folder]
    @State private var actions = FolderActions()
    @State private var isCreatingFolder = false

    var body: some View {
        NavigationStack {
            List(roots) { folder in
                NavigationLink(value: folder) {
                    FolderRow(folder: folder)
                }
                .folderRowActions(for: folder, actions)
                .accessibilityIdentifier(AccessibilityID.Row.folder(folder.name))
            }
            .overlay {
                if roots.isEmpty {
                    ContentUnavailableView {
                        Label("No Folders", systemImage: "folder")
                    } description: {
                        Text("Create a folder to start collecting cards.")
                    } actions: {
                        Button("New Folder") { isCreatingFolder = true }
                    }
                }
            }
            .navigationTitle("Folders")
            .navigationDestination(for: Folder.self) { FolderView(folder: $0) }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Folder", systemImage: "folder.badge.plus") { isCreatingFolder = true }
                        .accessibilityIdentifier(AccessibilityID.Home.newFolder)
                }
            }
            .sheet(isPresented: $isCreatingFolder) { NewRootFolderSheet() }
            .folderActionsPresentation(actions)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(.preview)
}
