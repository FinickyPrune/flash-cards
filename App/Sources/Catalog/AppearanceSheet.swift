import SwiftUI

/// Changes a folder's palette (`catalog.md`); a subfolder can follow its parent instead.
struct AppearanceSheet: View {
    @State private var model: AppearanceViewModel
    @Environment(\.dismiss) private var dismiss

    init(model: AppearanceViewModel) {
        _model = State(initialValue: model)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    FolderPreviewRow(
                        palette: model.selection,
                        name: model.folder.name,
                        learningLanguage: model.folder.resolvedLearningLanguage,
                        backLanguage: model.folder.resolvedBackLanguage
                    )
                }
                if let parent = model.folder.parent {
                    Section {
                        Toggle(isOn: $model.isSameAsParent) {
                            Text("Same as “\(parent.name)”")
                            Text("Follows the parent folder's colours")
                        }
                        .accessibilityIdentifier(AccessibilityID.Appearance.sameAsParent)
                    }
                }
                Section {
                    PalettePicker(selection: Binding(get: { model.selection }, set: { model.pick($0) }))
                } header: {
                    SectionLabel("Gradient")
                }
            }
            .formSheetStyle(accent: model.selection.accent)
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SheetToolbar(
                    confirmTitle: "Done",
                    accent: model.selection.accent,
                    cancelID: AccessibilityID.Appearance.cancel,
                    confirmID: AccessibilityID.Appearance.done,
                    cancel: { dismiss() },
                    confirm: {
                        if model.save() {
                            dismiss()
                        }
                    }
                )
            }
            .saveErrorAlert($model.saveError)
        }
    }
}
