import SwiftUI

/// Creates a root folder: name and language pair, both languages defaulting to the system one.
struct NewRootFolderSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var learningLanguage = Languages.identifier(for: .current)
    @State private var backLanguage = Languages.identifier(for: .current)
    @State private var saveError: String?
    @FocusState private var isNameFocused: Bool

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .focused($isNameFocused)
                    .accessibilityIdentifier(AccessibilityID.FolderForm.name)
                Section {
                    languageLink("Learning language", selection: $learningLanguage)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.learningLanguage)
                    languageLink("Back language", selection: $backLanguage)
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
                        .disabled(trimmedName.isEmpty)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.save)
                }
            }
            .onAppear { isNameFocused = true }
            .saveErrorAlert($saveError)
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
        do {
            try CatalogService(context: context).createRootFolder(
                name: name,
                learningLanguage: learningLanguage,
                backLanguage: backLanguage
            )
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}
