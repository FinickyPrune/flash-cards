import SwiftUI

/// "Folder" and the chosen folder's path in the tint, or Choose Folder while there is none,
/// opening a folder picker on tap; in the card editor and the CSV import preview.
struct FolderPathRow: View {
    let folder: Folder?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("Folder")
                    .foregroundStyle(Color.primary)
                Spacer(minLength: 8)
                Label(
                    folder.map(FolderTree.path(of:)) ?? String(localized: "Choose Folder"),
                    systemImage: "folder.fill"
                )
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.tint)
                .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}
