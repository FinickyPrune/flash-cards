import SwiftUI

/// A folder screen's title block: for a subfolder its parent's name in the accent above, then the
/// name and the language pair.
struct FolderHeader: View {
    let folder: Folder

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let parent = folder.parent {
                Text(parent.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(folder.resolvedPalette.accent)
            }
            Text(folder.name)
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier(AccessibilityID.FolderScreen.title)
            if let learning = folder.resolvedLearningLanguage, let back = folder.resolvedBackLanguage {
                Text("\(Languages.name(of: learning)) → \(Languages.name(of: back))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
