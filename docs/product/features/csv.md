# CSV import and export
Import cards from a CSV file into a folder, and export a folder to CSV as a simple backup.
CSV is the main way Serbian cards enter the app (vision).
Status: planned (milestone 3)

## Import
- The system file importer opens a file; then the user picks the destination folder.
- Format: UTF-8 with or without a BOM; any other encoding is an error. Line endings `\n`,
  `\r\n` or `\r`. Quoting per RFC 4180 (a quoted field may hold the delimiter, line breaks and
  `""`). Fields are trimmed. (#54)
- Delimiter: the one of tab, `;` and `,` that splits the most of the first 50 non-blank rows
  into two or more fields; ties go tab, then `;`, then `,`. (#54)
- Columns: 1 → front, 2 → back (back source = custom), 3 (optional) → context; further columns
  are ignored. (#54)
- Header row: guessed when the first field is `front`, `word`, `term`, `question`, `phrase`,
  `лицо`, `слово`, `термин`, `вопрос`, `фраза`, `reč` or `pojam` (ignoring case and
  diacritics); the preview can override the guess. (#54)
- Preview before importing: number of rows and number of duplicates (front key within the root
  folder), then **Import**.

## Export
- Exports one folder to CSV in the same column format, without screenshots: UTF-8 with a BOM,
  comma delimiter, CRLF line endings, a `front,back,context` header; a field is quoted only when
  it holds a comma, a quote or a line break. Reading an exported file gives back the same
  rows. (#54)

## States and edge cases
- Blank rows are ignored. A row with an empty front or back is skipped and counted. (#54)
- A file with no cards reads as empty, not as an error. (#54)
- Duplicates (planned, #55): a **Skip duplicates** toggle in the preview, on by default; a
  duplicate is a front key already in the root folder or on an earlier row of the file.

## Not supported
- Full backup with screenshots (after MVP).
- Encodings other than UTF-8 (e.g. Windows-1251 exports from older Excel).
- Escaping spreadsheet formulas (`=`, `+`, `-`, `@` at a field start): it would break the round
  trip (`-ing`).
