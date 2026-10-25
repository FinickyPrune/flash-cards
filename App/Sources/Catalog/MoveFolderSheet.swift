import SwiftData
import SwiftUI

/// Picks where a folder moves: the top level or any folder it may go under.
struct MoveFolderSheet: View {
    let folder: Folder
    @Query(sort: [SortDescriptor(\Folder.name, comparator: .localizedStandard)])
    private var folders: [Folder]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var warningDestination: Folder?
    @State private var saveError: String?
    @ScaledMetric private var indent = 20.0

    private struct Entry: Identifiable {
        let folder: Folder
        let depth: Int
        var id: PersistentIdentifier {
            folder.persistentModelID
        }
    }

    /// Every folder depth-first, children by name, as the catalog shows them.
    private var entries: [Entry] {
        func walk(_ folders: [Folder], depth: Int) -> [Entry] {
            folders.flatMap { folder in
                let children = (folder.children ?? [])
                    .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                return [Entry(folder: folder, depth: depth)] + walk(children, depth: depth + 1)
            }
        }
        return walk(folders.filter { $0.parent == nil }, depth: 0)
    }

    private var service: CatalogService {
        CatalogService(context: context)
    }

    var body: some View {
        NavigationStack {
            List {
                destinationButton(to: nil) {
                    Label("Top Level", systemImage: "list.bullet")
                }
                .accessibilityIdentifier(AccessibilityID.Move.topLevel)
                ForEach(entries) { entry in
                    destinationButton(to: entry.folder) {
                        Label(entry.folder.name, systemImage: "folder")
                            .padding(.leading, indent * Double(entry.depth))
                    }
                    .accessibilityIdentifier(AccessibilityID.Move.destination(entry.folder.name))
                }
            }
            .navigationTitle("Move “\(folder.name)”")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert(
                "Change Languages?",
                isPresented: Binding(
                    get: { warningDestination != nil },
                    set: {
                        if !$0 {
                            warningDestination = nil
                        }
                    }
                ),
                presenting: warningDestination
            ) { destination in
                Button("Move") { move(to: destination) }
                    .accessibilityIdentifier(AccessibilityID.Move.confirmWarning)
                Button("Cancel", role: .cancel) {}
            } message: { destination in
                Text("Cards in “\(folder.name)” will use \(pair(of: destination)) instead of \(pair(of: folder)).")
            }
            .saveErrorAlert($saveError)
        }
    }

    private func destinationButton(to destination: Folder?, label: () -> some View) -> some View {
        Button {
            switch service.moveCheck(folder, to: destination) {
            case .allowed: move(to: destination)
            case .allowedAfterWarning: warningDestination = destination
            case .notAllowed: break
            }
        } label: {
            label()
        }
        .disabled(service.moveCheck(folder, to: destination) == .notAllowed)
    }

    private func pair(of folder: Folder) -> String {
        let learning = folder.resolvedLearningLanguage.map { Languages.name(of: $0) } ?? ""
        let back = folder.resolvedBackLanguage.map { Languages.name(of: $0) } ?? ""
        return "\(learning) → \(back)"
    }

    private func move(to destination: Folder?) {
        do {
            try service.move(folder, to: destination)
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}
