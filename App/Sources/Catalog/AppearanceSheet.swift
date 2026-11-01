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
                    Label {
                        Text(model.folder.name)
                    } icon: {
                        FolderTile(palette: model.selection)
                    }
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
                Section("Gradient") {
                    PalettePicker(selection: Binding(get: { model.selection }, set: { model.pick($0) }))
                }
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if model.save() {
                            dismiss()
                        }
                    }
                    .accessibilityIdentifier(AccessibilityID.Appearance.done)
                }
            }
            .tint(model.selection.accent)
            .saveErrorAlert($model.saveError)
        }
    }
}
