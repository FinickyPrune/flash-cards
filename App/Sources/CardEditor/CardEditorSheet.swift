import SwiftUI

/// Add or edit a card: front, context, four tiles, folder (`card-editor.md`).
struct CardEditorSheet: View {
    @State private var model: CardEditorViewModel
    @State private var isPickingFolder = false
    @FocusState private var focus: Field?
    @Environment(\.dismiss) private var dismiss

    private enum Field {
        case front
        case back
    }

    init(model: CardEditorViewModel) {
        _model = State(initialValue: model)
    }

    private var isEditing: Bool {
        if case .edit = model.mode {
            true
        } else {
            false
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Front") {
                    TextField("Word or phrase", text: $model.front)
                        .focused($focus, equals: .front)
                        .accessibilityIdentifier(AccessibilityID.CardEditor.front)
                }
                Section("Context") {
                    TextField("The line where it appeared", text: $model.context, axis: .vertical)
                        .lineLimit(1 ... 4)
                        .accessibilityIdentifier(AccessibilityID.CardEditor.context)
                }
                Section {
                    ForEach(BackSource.tileOrder, id: \.self) { tile($0) }
                } header: {
                    Text("Back")
                } footer: {
                    Text("Pick one tile; its text is shown in review.")
                }
                Section {
                    Button { isPickingFolder = true } label: {
                        LabeledContent("Folder") {
                            Text(FolderTree.path(of: model.folder))
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .foregroundStyle(Color.primary)
                    .accessibilityIdentifier(AccessibilityID.CardEditor.folder)
                }
                if isEditing {
                    Section {
                        Button("Delete Card", role: .destructive) { model.isConfirmingDelete = true }
                            .accessibilityIdentifier(AccessibilityID.CardEditor.delete)
                            .confirmationDialog(
                                "Delete This Card?",
                                isPresented: $model.isConfirmingDelete,
                                titleVisibility: .visible
                            ) {
                                Button("Delete Card", role: .destructive) { close(if: model.delete()) }
                                    .accessibilityIdentifier(AccessibilityID.CardEditor.confirmDelete)
                            } message: {
                                Text("Its review history will be deleted too. This can't be undone.")
                            }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Card" : "New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .onAppear {
                if !isEditing {
                    focus = .front
                }
            }
            // The selected tile's field is inserted by this very update; focusing it in the same
            // pass is ignored, so focus it on the next main-actor turn.
            .onChange(of: model.selectedSource) {
                Task { focus = .back }
            }
            .sheet(isPresented: $isPickingFolder) { FolderPickerSheet(selection: $model.folder) }
            .alert(
                "Duplicate Card",
                isPresented: Binding(isPresent: $model.duplicate),
                presenting: model.duplicate
            ) { _ in
                Button(isEditing ? "Save Anyway" : "Create Anyway") { close(if: model.saveAnyway()) }
                    .accessibilityIdentifier(AccessibilityID.CardEditor.saveAnyway)
                Button("Cancel", role: .cancel) {}
            } message: { existing in
                Text("“\(existing.front)” is already a card in “\(existing.folder?.root.name ?? "")”.")
            }
            .saveErrorAlert($model.saveError)
        }
        .interactiveDismissDisabled(model.hasChanges)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                if model.hasChanges {
                    model.isConfirmingDiscard = true
                } else {
                    dismiss()
                }
            }
            .confirmationDialog("Discard Changes?", isPresented: $model.isConfirmingDiscard) {
                Button("Discard Changes", role: .destructive) { dismiss() }
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save") { close(if: model.save()) }
                .disabled(!model.canSave)
                .accessibilityIdentifier(AccessibilityID.CardEditor.save)
        }
    }

    /// One back option. Only the selected tile is editable; another one is a button that selects it.
    @ViewBuilder
    private func tile(_ source: BackSource) -> some View {
        if source == model.selectedSource {
            VStack(alignment: .leading, spacing: 6) {
                tileTitle(source, isSelected: true)
                TextField("Back text", text: $model.back, axis: .vertical)
                    .lineLimit(1 ... 6)
                    .focused($focus, equals: .back)
                    .accessibilityIdentifier(AccessibilityID.CardEditor.backText)
            }
            .padding(.vertical, 4)
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(.isSelected)
            .accessibilityIdentifier(AccessibilityID.CardEditor.tile(source.rawValue))
        } else {
            Button {
                model.selectedSource = source
            } label: {
                VStack(alignment: .leading, spacing: 6) {
                    tileTitle(source, isSelected: false)
                    let text = model.text(of: source)
                    // Explicit colours: inside a button `.secondary` would take the tint.
                    Text(text.isEmpty ? String(localized: "Empty") : text)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .accessibilityIdentifier(AccessibilityID.CardEditor.tile(source.rawValue))
        }
    }

    private func tileTitle(_ source: BackSource, isSelected: Bool) -> some View {
        Label(source.title, systemImage: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(Color.secondary))
    }

    private func close(if done: Bool) {
        if done {
            dismiss()
        }
    }
}
