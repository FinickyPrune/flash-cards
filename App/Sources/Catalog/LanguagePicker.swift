import SwiftUI

/// Searchable list of every system language; picking one goes back.
struct LanguagePicker: View {
    let title: LocalizedStringKey
    @Binding var selection: String
    @State private var options: [Languages.Option] = []
    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    private var filtered: [Languages.Option] {
        query.isEmpty ? options : options.filter { $0.name.localizedStandardContains(query) }
    }

    var body: some View {
        ScrollViewReader { proxy in
            List(filtered) { option in
                Button {
                    selection = option.id
                    dismiss()
                } label: {
                    HStack {
                        Text(option.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if option.id == selection {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .accessibilityAddTraits(option.id == selection ? .isSelected : [])
                .accessibilityIdentifier(AccessibilityID.LanguagePicker.option(option.id))
            }
            .searchable(text: $query)
            .navigationTitle(title)
            .onAppear {
                options = Languages.all()
                proxy.scrollTo(selection, anchor: .center)
            }
        }
    }
}
