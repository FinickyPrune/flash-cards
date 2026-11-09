import FlashCore
import SwiftUI

/// Preview before a CSV import (`csv.md` → Import): the destination folder, what the file holds,
/// and its first cards, so wrong columns or a wrong delimiter show before anything is created.
struct CSVImportSheet: View {
    @State private var model: CSVImportViewModel
    @State private var isPickingFolder = false
    @Environment(\.dismiss) private var dismiss

    init(model: CSVImportViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        let accent = model.folder.resolvedPalette.accent
        NavigationStack {
            Form {
                Section {
                    folderRow
                }
                switch model.phase {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                case let .failed(message):
                    failure(message)
                case .ready:
                    CSVImportSummary(model: model)
                }
            }
            .formSheetStyle(accent: accent)
            .navigationTitle("Import CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SheetToolbar(
                    confirmTitle: "Import",
                    accent: accent,
                    canConfirm: model.canImport,
                    cancelID: AccessibilityID.CSVImport.cancel,
                    confirmID: AccessibilityID.CSVImport.confirm,
                    cancel: { dismiss() },
                    confirm: {
                        if model.importCards() {
                            dismiss()
                        }
                    }
                )
            }
            .sheet(isPresented: $isPickingFolder) { FolderPickerSheet(selection: $model.folder) }
            .saveErrorAlert($model.saveError)
            .task { await model.load() }
        }
    }

    private var folderRow: some View {
        FolderPathRow(folder: model.folder) { isPickingFolder = true }
            .accessibilityIdentifier(AccessibilityID.CSVImport.folder)
    }

    private func failure(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Can't Import This File", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityID.CSVImport.error)
        .listRowBackground(Color.clear)
    }
}
