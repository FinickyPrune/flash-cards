import SwiftData
import SwiftUI

/// Root of the app: the root folders and what is due today, over a fixed wash (`catalog.md`).
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
            // Re-read every minute so cards turn due at 04:00 while home is open.
            TimelineView(.everyMinute) { context in
                folderList(now: context.date)
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

    private func folderList(now: Date) -> some View {
        List(roots) { folder in
            NavigationLink(value: folder) {
                FolderRow(folder: folder, now: now)
            }
            .folderRowActions(for: folder, model.rowActions)
            .listRowBackground(CatalogStyle.surface)
            .accessibilityIdentifier(AccessibilityID.Row.folder(folder.name))
        }
        .scrollContentBackground(.hidden)
        .background {
            ScreenWash(light: CatalogStyle.homeHues, dark: CatalogStyle.homeHuesDark, strength: 0.8)
        }
        .navigationSubtitle(subtitle(due: HomeViewModel.dueToday(in: roots, at: now)))
    }
}

private func subtitle(due: Int) -> Text {
    due == 0 ? Text("Nothing due today") : Text("^[\(due) card](inflect: true) due today")
}

#Preview {
    let container = ModelContainer.preview
    HomeView(model: HomeViewModel(dependencies: .live(context: container.mainContext)))
        .modelContainer(container)
}
