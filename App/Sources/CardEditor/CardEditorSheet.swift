import SwiftUI

/// Add or edit a card: front, context, the back sources as a list, folder (`card-editor.md`).
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
        let palette = model.folder.resolvedPalette
        NavigationStack {
            Form {
                Section {
                    TextField("Word or phrase", text: $model.front)
                        .font(.title2.bold())
                        .focused($focus, equals: .front)
                        .accessibilityIdentifier(AccessibilityID.CardEditor.front)
                } header: {
                    SectionLabel("Front")
                }
                Section {
                    TextField("The line where it appeared", text: $model.context, axis: .vertical)
                        .lineLimit(1 ... 4)
                        .accessibilityIdentifier(AccessibilityID.CardEditor.context)
                } header: {
                    SectionLabel("Context")
                }
                Section {
                    ForEach(BackSource.tileOrder, id: \.self) { row($0, palette: palette) }
                } header: {
                    // The note goes under the label when both don't fit on one line.
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .firstTextBaseline) {
                            SectionLabel("Back")
                            Spacer(minLength: 8)
                            backNote
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            SectionLabel("Back")
                            backNote
                        }
                    }
                }
                Section {
                    folderRow
                }
                if isEditing {
                    deleteSection
                }
            }
            .formSheetStyle(accent: palette.accent)
            // On short screens the keyboard pushes the navigation bar (Cancel, Save) off screen;
            // dragging the form or Done gets it back.
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(isEditing ? "Edit Card" : "New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                SheetToolbar(
                    confirmTitle: "Save",
                    accent: palette.accent,
                    canConfirm: model.canSave,
                    cancelID: AccessibilityID.CardEditor.cancel,
                    confirmID: AccessibilityID.CardEditor.save,
                    cancel: cancel,
                    confirm: { close(if: model.save()) }
                )
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focus = nil }
                        .accessibilityIdentifier(AccessibilityID.CardEditor.keyboardDone)
                }
            }
            .confirmationDialog("Discard Changes?", isPresented: $model.isConfirmingDiscard) {
                Button("Discard Changes", role: .destructive) { dismiss() }
            }
            .onAppear {
                if !isEditing {
                    focus = .front
                }
            }
            // The selected row's field is inserted by this very update; focusing it in the same
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

    /// One back source. Only the selected row is editable; another one is a button that selects it.
    @ViewBuilder
    private func row(_ source: BackSource, palette: FolderPalette) -> some View {
        if source == model.selectedSource {
            BackSourceRow(source: source, isSelected: true, accent: palette.accent) {
                TextField("Back text", text: $model.back, axis: .vertical)
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                    .lineLimit(1 ... 6)
                    .focused($focus, equals: .back)
                    .accessibilityIdentifier(AccessibilityID.CardEditor.backText)
            }
            .listRowBackground(SelectedRowBackground(palette: palette))
            .listRowSeparator(.hidden)
            .accessibilityElement(children: .contain)
            .accessibilityAddTraits(.isSelected)
            .accessibilityIdentifier(AccessibilityID.CardEditor.tile(source.rawValue))
        } else {
            Button {
                model.selectedSource = source
            } label: {
                BackSourceRow(source: source, isSelected: false, accent: palette.accent) {
                    let text = model.text(of: source)
                    Text(text.isEmpty ? String(localized: "Empty") : text)
                        .lineLimit(1)
                }
                .contentShape(Rectangle())
            }
            .accessibilityIdentifier(AccessibilityID.CardEditor.tile(source.rawValue))
        }
    }

    private var backNote: some View {
        Text("Pick one; it's shown in review")
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    private var folderRow: some View {
        Button { isPickingFolder = true } label: {
            HStack(spacing: 8) {
                Text("Folder")
                    .foregroundStyle(Color.primary)
                Spacer(minLength: 8)
                Label(FolderTree.path(of: model.folder), systemImage: "folder.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.tint)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityIdentifier(AccessibilityID.CardEditor.folder)
    }

    private var deleteSection: some View {
        Section {
            Button("Delete Card", role: .destructive) { model.isConfirmingDelete = true }
                .frame(maxWidth: .infinity)
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
        // A plain red text button under the form, not a row.
        .listRowBackground(Color.clear)
    }

    private func cancel() {
        if model.hasChanges {
            model.isConfirmingDiscard = true
        } else {
            dismiss()
        }
    }

    private func close(if done: Bool) {
        if done {
            dismiss()
        }
    }
}
