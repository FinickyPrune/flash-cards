import FlashCore
import SwiftUI

/// The preview's counts, its two toggles and the first cards an import would create.
struct CSVImportSummary: View {
    @Bindable var model: CSVImportViewModel

    var body: some View {
        let rows = model.rowsToImport
        let duplicates = model.plan.duplicateCount
        Section {
            count("Cards to import", rows.count, id: AccessibilityID.CSVImport.count)
            if duplicates > 0 {
                count("Duplicates", duplicates, id: AccessibilityID.CSVImport.duplicates)
                Toggle("Skip duplicates", isOn: $model.skipsDuplicates)
                    .accessibilityIdentifier(AccessibilityID.CSVImport.skipDuplicates)
            }
            if model.skippedCount > 0 {
                count("Rows skipped", model.skippedCount, id: AccessibilityID.CSVImport.skipped)
            }
            Toggle("First row is a header", isOn: $model.firstRowIsHeader)
                .accessibilityIdentifier(AccessibilityID.CSVImport.header)
        } header: {
            SectionLabel("File")
        } footer: {
            if model.skippedCount > 0 {
                Text("Rows with an empty front or back are skipped.")
            }
        }
        if !rows.isEmpty {
            Section {
                ForEach(Array(rows.prefix(3).enumerated()), id: \.offset) { _, row in
                    CSVPreviewRow(row: row)
                }
            } header: {
                SectionLabel("First Cards")
            }
        }
    }

    private func count(_ title: LocalizedStringKey, _ value: Int, id: String) -> some View {
        LabeledContent {
            Text(value, format: .number)
                .monospacedDigit()
                .accessibilityIdentifier(id)
        } label: {
            Text(title)
        }
    }
}

/// A card an import would create, as a folder lists it, with the context below.
private struct CSVPreviewRow: View {
    let row: CSVRow

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(row.front)
                .font(.headline)
            Text(row.back)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            if let context = row.context {
                Text(context)
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
