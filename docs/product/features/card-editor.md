# Card editor
One screen to add or edit a card: front, screenshot, context, the back chosen from four tiles, and the folder.
Status: partial (manual cards shipped in milestone 1; screenshot, hints, lemma toggle and import in milestone 4)

## Rules
- Modes: **add** and **edit**, same screen, shown as a full-height sheet with Cancel and Save,
  from a folder and (later) from the import flow. (assumption)
- Top to bottom: front (editable text field), screenshot if present, context (editable),
  four tiles, folder chip.
- Tiles: **Definition**, **Synonyms**, **Translation**, **Custom text** (a text field). The user selects
  exactly one; its text is saved as the back. Only the selected tile is editable: tapping another
  tile selects it and puts the cursor in it; the other tiles keep their text. Review shows the
  selected tile's text. (#15)
- Definition, Synonyms and Translation tiles are prefilled with hints when a source has one (see `hints.md`).
  An empty hint leaves the tile empty and editable.
- The selected tile by default is the back source last used in this root folder; for a new
  root folder it is Translation. (assumption) Creating a card sets it; an edit sets it only when
  it picks another tile or moves the card to another root folder. (assumption)
- The back source can be changed only here, never during review.
- Folder chip: tap opens a folder picker. Default: the folder chosen for the batch, or the
  folder the editor was opened from.
- In edit mode both sides and the folder can change.
- In add mode inside the import flow the primary action is **Save and next**.
- Duplicate check on save: another card with the same front key in the same root folder →
  warn and ask "Create anyway?". The front key ignores case, diacritics and surrounding
  spaces, and treats any run of spaces inside as one, so `kuća` = `Kuca ` and
  `ice  cream` = `ice cream`. Letters with a stroke are letters, not diacritics: `đak` ≠ `dak`.
- When the front came from a token whose lemma differs (`running` → `run`, `saw` → `see`), a
  toggle switches the front between the lemma and the form in the text. The front starts as
  the lemma. Lemma rules: decision 0007. The toggle changes only the front: tiles keep their
  hints and the user's edits.

## States and edge cases
- Editing a card that keeps its front key and root folder doesn't ask about a duplicate again;
  changing the front or moving it to another root folder does. (assumption)
- A card is deleted from edit mode with a confirmation, or by swiping its row in the folder
  list (no confirmation there: assumption). Its review history goes with it. (#15)
- Unsaved changes: the sheet can't be swiped away, and Cancel asks "Discard changes?". (assumption)
- Front empty → can't save.
- Back empty → can't save. (assumption)
- No screenshot (manual card or CSV) → the screenshot area is hidden.

## Not supported
- Several back variants per card.
