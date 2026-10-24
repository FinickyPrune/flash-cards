# Card editor
One screen to add or edit a card: front, screenshot, context, the back chosen from three tiles, and the folder.
Status: planned (milestone 1; hints in milestone 4)

## Rules
- Modes: **add** and **edit**, same screen.
- Top to bottom: front (editable text field), screenshot if present, context (editable),
  three tiles, folder chip.
- Tiles: **Definition**, **Translation**, **Custom text** (a text field). The user selects
  exactly one; its text is saved as the back and stays editable. Review shows that text.
- Definition and Translation tiles are prefilled with hints when a source has one (see `hints.md`).
  An empty hint leaves the tile empty and editable.
- The selected tile by default is the back source last used in this root folder; for a new
  root folder it is Translation. (assumption)
- The back source can be changed only here, never during review.
- Folder chip: tap opens a folder picker. Default: the folder chosen for the batch, or the
  folder the editor was opened from.
- In edit mode both sides and the folder can change.
- In add mode inside the import flow the primary action is **Save and next**.
- Duplicate check on save: another card with the same front key in the same root folder →
  warn and ask "Create anyway?". The front key ignores case, diacritics and surrounding
  spaces, so `kuća` = `Kuca `.
- When the front came from a token whose lemma differs (`running` → `run`), a toggle switches
  the front between the form in the text and the lemma. (spike: lemma quality per language)

## States and edge cases
- Front empty → can't save.
- Back empty → can't save. (assumption)
- No screenshot (manual card or CSV) → the screenshot area is hidden.

## Not supported
- Several back variants per card; synonyms as a fourth tile.
