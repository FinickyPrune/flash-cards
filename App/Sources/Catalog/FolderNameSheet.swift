import SwiftUI

/// Asks for a folder name: new subfolder or rename.
struct FolderNameSheet: View {
    @State private var model: FolderNameViewModel
    @FocusState private var isNameFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(model: FolderNameViewModel) {
        _model = State(initialValue: model)
    }

    private var title: LocalizedStringKey {
        switch model.mode {
        case .newSubfolder: "New Subfolder"
        case .rename: "Rename Folder"
        }
    }

    /// The folder's colours: the renamed folder's, or the parent's for a new subfolder.
    private var palette: FolderPalette {
        switch model.mode {
        case let .newSubfolder(parent): parent.resolvedPalette
        case let .rename(folder): folder.resolvedPalette
        }
    }

    private var saveTitle: LocalizedStringKey {
        switch model.mode {
        case .newSubfolder: "Create"
        case .rename: "Save"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $model.name)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                        .onSubmit(save)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.name)
                } header: {
                    SectionLabel("Name")
                }
            }
            .formSheetStyle(accent: palette.accent)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SheetToolbar(
                    confirmTitle: saveTitle,
                    accent: palette.accent,
                    canConfirm: model.canSave,
                    cancelID: AccessibilityID.FolderForm.cancel,
                    confirmID: AccessibilityID.FolderForm.save,
                    cancel: { dismiss() },
                    confirm: save
                )
            }
            .onAppear { isNameFocused = true }
            .saveErrorAlert($model.saveError)
        }
        .presentationDetents([.medium])
    }

    private func save() {
        if model.save() {
            dismiss()
        }
    }
}
