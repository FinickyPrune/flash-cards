# CSV import and export
Import cards from a CSV file into a folder, and export a folder to CSV as a simple backup.
CSV is the main way Serbian cards enter the app (vision).
Status: partial (import shipped; export #57 planned)

## Import
- **Import CSV…** on a folder screen's **More** menu opens the system file importer (CSV, TSV or
  plain text), then the preview with that folder as the destination. (#55)
- **Import CSV** on Home (toolbar, and the empty state) opens the same flow with no destination
  yet: the Folder row reads **Choose Folder** and Import stays disabled until one is picked;
  until then only repeats within the file count as duplicates. (#56)
- The import's folder picker starts with **New Folder…**: the New Folder sheet, and the root
  folder created there becomes the destination. With no folders it is the only row. (#56)
- Format: UTF-8 with or without a BOM; any other encoding is an error. Line endings `\n`,
  `\r\n` or `\r`. Quoting per RFC 4180 (a quoted field may hold the delimiter, line breaks and
  `""`). A quote that never closes is read as text. Fields are trimmed. (#54)
- Delimiter: the one of tab, `;` and `,` that splits the most of the first 50 non-blank rows
  into two or more fields without leaving a quote inside an unquoted field (that means it split a
  quoted field, as `;` in `pas,"собака; пёс"`); then the most rows split at all; ties go tab,
  then `;`, then `,`. (#54)
- Columns: 1 → front, 2 → back (back source = custom), 3 (optional) → context; further columns
  are ignored. (#54)
- Header row: guessed when the first field is `front`, `word`, `term`, `question`, `phrase`,
  `лицо`, `слово`, `термин`, `вопрос`, `фраза`, `reč` or `pojam` (ignoring case and
  diacritics); the preview can override the guess. (#54)
- Preview before importing, while the file is read off the main thread (#55):
  - **Folder** row with the destination's path; tapping it picks another folder at any depth,
    or creates a root folder.
  - Cards to import; Duplicates (hidden at 0); Rows skipped for an empty front or back (hidden
    at 0).
  - **Skip duplicates**, on by default, shown while there are duplicates; off imports every row.
  - **First row is a header**, starting at the guess; changing it, or the folder, recounts.
  - The first 3 cards that would be created: front, back and context.
  - **Import** is disabled while there is nothing to import.
- A duplicate is a front key already in the destination's root folder, or on an earlier row of
  the file; the first occurrence in the file is the one kept. (#55)
- Import creates the cards in the destination folder, new, back source custom, no screenshot,
  in one save, in file order (the file's last row is the newest; none is dated in the future). The root folder's last back
  source doesn't change. A failed save creates nothing and shows the error. (#55)

## Export
- Exports one folder to CSV in the same column format, without screenshots: UTF-8 with a BOM,
  comma delimiter, CRLF line endings, a `front,back,context` header; a field is quoted only when
  it holds a comma, a quote or a line break. Reading an exported file gives back the same
  rows. (#54)

## States and edge cases
- Blank rows are ignored. A row with an empty front or back is skipped and counted. (#54)
- The file can't be read (including a failed pick), isn't UTF-8, is over 10 MB, or has no row
  with both a front and a back once the guessed header is left out (an empty folder's export):
  the preview says so and only Cancel works. (#55)

## Not supported
- Full backup with screenshots (after MVP).
- Encodings other than UTF-8 (e.g. Windows-1251 exports from older Excel).
- Escaping spreadsheet formulas (`=`, `+`, `-`, `@` at a field start): it would break the round
  trip (`-ing`).
