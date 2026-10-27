import SwiftUI

/// A folder in a list; root folders also show their language pair. Trailing: learned / all
/// cards in the subtree, hidden while the subtree has no cards.
struct FolderRow: View {
    let folder: Folder

    var body: some View {
        let progress = folder.progress
        LabeledContent {
            if progress.total > 0 {
                Text("\(progress.learned) / \(progress.total)")
                    .monospacedDigit()
            }
        } label: {
            Label {
                VStack(alignment: .leading) {
                    Text(folder.name)
                    if folder.parent == nil,
                       let learning = folder.learningLanguage,
                       let back = folder.backLanguage
                    {
                        Text("\(Languages.name(of: learning)) → \(Languages.name(of: back))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } icon: {
                Image(systemName: "folder")
            }
        }
    }
}
