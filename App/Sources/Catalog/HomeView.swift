import SwiftData
import SwiftUI

/// Root of the app: the root folders (`catalog.md`).
struct HomeView: View {
    @Query(
        filter: #Predicate<Folder> { $0.parent == nil },
        sort: [SortDescriptor(\Folder.name, comparator: .localizedStandard)]
    )
    private var roots: [Folder]
    @State private var model: HomeViewModel

    init(model: HomeViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack {
            List(roots) { folder in
                NavigationLink(value: folder) {
                    FolderRow(folder: folder)
                }
                .folderRowActions(for: folder, model.rowActions)
                .accessibilityIdentifier(AccessibilityID.Row.folder(folder.name))
            }
            .overlay {
                if roots.isEmpty {
                    ContentUnavailableView {
                        Label("No Folders", systemImage: "folder")
                    } description: {
                        Text("Create a folder to start collecting cards.")
                    } actions: {
                        Button("New Folder") { model.isCreatingFolder = true }
                            .accessibilityIdentifier(AccessibilityID.Home.emptyNewFolder)
                    }
                }
            }
            .navigationTitle("Folders")
            .navigationDestination(for: Folder.self) { FolderView(model: model.folderModel(for: $0)) }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Folder", systemImage: "folder.badge.plus") { model.isCreatingFolder = true }
                        .accessibilityIdentifier(AccessibilityID.Home.newFolder)
                }
            }
            .sheet(isPresented: $model.isCreatingFolder) { NewRootFolderSheet(model: model.newRootFolderModel()) }
            .folderActionsPresentation(model.rowActions)
        }
    }
}

#Preview {
    let container = ModelContainer.preview
    HomeView(model: HomeViewModel(
        service: CatalogService(context: container.mainContext),
        cardService: CardService(context: container.mainContext),
        reviewService: ReviewService(context: container.mainContext)
    ))
    .modelContainer(container)
}
