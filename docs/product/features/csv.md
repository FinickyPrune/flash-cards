# CSV import and export
Import cards from a CSV file into a folder, and export a folder to CSV as a simple backup.
Status: planned (milestone 5)

## Import
- The system file importer opens a file; then the user picks the destination folder.
- Format (assumption): UTF-8; delimiter detected among `;`, `,` and tab; quoted fields allowed;
  header row optional.
- Columns: 1 → front, 2 → back (back source = custom), 3 (optional) → context.
- Preview before importing: number of rows and number of duplicates (front key within the root
  folder), then **Import**.

## Export
- Exports one folder to CSV in the same column format, without screenshots. (assumption: in MVP)

## States and edge cases
- (to be defined) Rows with an empty front or back; what happens to duplicates on import
  (skip or create).

## Not supported
- Full backup with screenshots (after MVP).
