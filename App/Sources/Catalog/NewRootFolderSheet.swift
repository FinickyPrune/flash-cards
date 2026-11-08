import SwiftUI

/// Creates a root folder: a preview of its catalog row, name, language pair (both defaulting to
/// the system language) and palette.
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
                Section {
                    FolderPreviewRow(
                        palette: model.palette,
                        name: model.name,
                        learningLanguage: model.learningLanguage,
                        backLanguage: model.backLanguage
                    )
                }
                Section {
                    TextField("Name", text: $model.name)
                        .focused($isNameFocused)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.name)
                } header: {
                    SectionLabel("Name")
                }
                Section {
                    languageLink("Learning language", selection: $model.learningLanguage)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.learningLanguage)
                    languageLink("Back language", selection: $model.backLanguage)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.backLanguage)
                } header: {
                    SectionLabel("Languages")
                } footer: {
                    Text("Subfolders use the same languages. They can't be changed later.")
                }
                Section {
                    PalettePicker(selection: $model.palette)
                } header: {
                    SectionLabel("Gradient")
                }
            }
            .formSheetStyle(accent: model.palette.accent)
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SheetToolbar(
                    confirmTitle: "Create",
                    accent: model.palette.accent,
                    canConfirm: model.canCreate,
                    cancelID: AccessibilityID.FolderForm.cancel,
                    confirmID: AccessibilityID.FolderForm.save,
                    cancel: { dismiss() },
                    confirm: create
                )
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
