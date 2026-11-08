import SwiftUI

/// The redesigned sheets' toolbar: Cancel as an × on the left, the confirm action as a ✓ filled
/// with the folder's accent on the right.
struct SheetToolbar: ToolbarContent {
    let confirmTitle: LocalizedStringKey
    let accent: Color
    var canConfirm = true
    let cancelID: String
    let confirmID: String
    let cancel: () -> Void
    let confirm: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", action: cancel)
                .accessibilityIdentifier(cancelID)
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(action: confirm) {
                Label(confirmTitle, systemImage: "checkmark")
                    .foregroundStyle(CatalogStyle.onAccent)
            }
            .buttonStyle(.glassProminent)
            .tint(accent)
            .disabled(!canConfirm)
            .accessibilityIdentifier(confirmID)
        }
    }
}
