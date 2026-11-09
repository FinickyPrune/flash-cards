import SwiftUI
import UniformTypeIdentifiers

extension View {
    /// Import CSV's file importer and preview sheet, on Home and on a folder screen. `open` gets
    /// nil when the pick failed, which the preview shows as "can't be read".
    func csvImportPresentation(
        isPickingFile: Binding<Bool>,
        preview: Binding<CSVImportViewModel?>,
        open: @escaping (URL?) -> Void
    ) -> some View {
        fileImporter(
            isPresented: isPickingFile,
            allowedContentTypes: [.commaSeparatedText, .tabSeparatedText, .plainText]
        ) { open(try? $0.get()) }
            .sheet(item: preview) { CSVImportSheet(model: $0) }
    }
}
