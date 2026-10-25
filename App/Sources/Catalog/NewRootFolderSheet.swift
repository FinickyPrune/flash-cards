import SwiftUI

/// Creates a root folder: name and language pair, both languages defaulting to the system one.
struct NewRootFolderSheet: View {
    @State private var model: NewRootFolderViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isNameFocused: Bool

    init(model: NewRootFolderViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $model.name)
                    .focused($isNameFocused)
                    .accessibilityIdentifier(AccessibilityID.FolderForm.name)
                Section {
                    languageLink("Learning language", selection: $model.learningLanguage)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.learningLanguage)
                    languageLink("Back language", selection: $model.backLanguage)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.backLanguage)
                } footer: {
                    Text("Subfolders use the same languages. They can't be changed later.")
                }
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", action: create)
                        .disabled(!model.canCreate)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.save)
                }
            }
            .onAppear { isNameFocused = true }
            .saveErrorAlert($model.saveError)
        }
    }

    private func languageLink(_ title: LocalizedStringKey, selection: Binding<String>) -> some View {
        NavigationLink {
            LanguagePicker(title: title, selection: selection)
        } label: {
            LabeledContent(title, value: Languages.name(of: selection.wrappedValue))
        }
    }

    private func create() {
        if model.create() {
            dismiss()
        }
    }
}
