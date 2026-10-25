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

    private var saveTitle: LocalizedStringKey {
        switch model.mode {
        case .newSubfolder: "Create"
        case .rename: "Save"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $model.name)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .onSubmit(save)
                    .accessibilityIdentifier(AccessibilityID.FolderForm.name)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveTitle, action: save)
                        .disabled(!model.canSave)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.save)
                }
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
