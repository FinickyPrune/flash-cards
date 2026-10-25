import SwiftUI

/// A folder in a list; root folders also show their language pair.
struct FolderRow: View {
    let folder: Folder

    var body: some View {
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
