import SwiftUI

/// Asks for a folder name: new subfolder or rename.
struct FolderNameSheet: View {
    let title: LocalizedStringKey
    let saveTitle: LocalizedStringKey
    let onSave: (String) throws -> Void
    @State private var name: String
    @State private var saveError: String?
    @FocusState private var isNameFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(
        title: LocalizedStringKey,
        saveTitle: LocalizedStringKey,
        initialName: String,
        onSave: @escaping (String) throws -> Void
    ) {
        self.title = title
        self.saveTitle = saveTitle
        self.onSave = onSave
        _name = State(initialValue: initialName)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
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
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier(AccessibilityID.FolderForm.save)
                }
            }
            .onAppear { isNameFocused = true }
            .saveErrorAlert($saveError)
        }
        .presentationDetents([.medium])
    }

    private func save() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        do {
            try onSave(name)
            dismiss()
        } catch {
            saveError = error.localizedDescription
        }
    }
}
