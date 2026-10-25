import SwiftData
import SwiftUI

/// Picks where a folder moves: the top level or any folder it may go under.
struct MoveFolderSheet: View {
    @State private var model: MoveFolderViewModel
    @Query(sort: [SortDescriptor(\Folder.name, comparator: .localizedStandard)])
    private var folders: [Folder]
    @Environment(\.dismiss) private var dismiss
    @ScaledMetric private var indent = 20.0

    init(model: MoveFolderViewModel) {
        _model = State(initialValue: model)
    }

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
            folders.flatMap { [Entry(folder: $0, depth: depth)] + walk($0.sortedChildren, depth: depth + 1) }
        }
        return walk(folders.filter { $0.parent == nil }, depth: 0)
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
            .navigationTitle("Move “\(model.folder.name)”")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert(
                "Change Languages?",
                isPresented: Binding(isPresent: $model.warningDestination),
                presenting: model.warningDestination
            ) { _ in
                Button("Move") {
                    if model.confirmWarning() {
                        dismiss()
                    }
                }
                .accessibilityIdentifier(AccessibilityID.Move.confirmWarning)
                Button("Cancel", role: .cancel) {}
            } message: { destination in
                Text(
                    "Cards in “\(model.folder.name)” will use \(model.pairDescription(of: destination)) instead of \(model.pairDescription(of: model.folder))."
                )
            }
            .saveErrorAlert($model.saveError)
        }
    }

    private func destinationButton(to destination: Folder?, label: () -> some View) -> some View {
        let isAllowed = model.isAllowed(destination)
        return Button {
            if model.choose(destination) {
                dismiss()
            }
        } label: {
            // Rows read as a list of places, not links; unavailable ones are dimmed.
            label()
                .foregroundStyle(isAllowed ? Color.primary : Color.secondary)
        }
        .disabled(!isAllowed)
    }
}
