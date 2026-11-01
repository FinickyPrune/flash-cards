# Catalog
A tree of folders holding cards; every folder shows progress and can start a review of its subtree.
Status: shipped (folder tree in milestone 1, progress and Play in milestone 2)

## Rules
- Folders nest to any depth. Design and test the UI at 2–3 levels.
- Folders can be created, renamed, moved and deleted. Rename, move and delete are on a folder
  row's context menu (long press) and swipe actions, and on a folder screen's **More** menu (⋯)
  for the folder itself. A subfolder tile on its parent's screen has the same actions on long
  press, without swipe actions. Deleting the open folder returns to the screen before. (#14, #43)
- Deleting a folder deletes its whole subtree (subfolders and cards) after a confirmation.
- Creating a root folder asks for the learning language and the back language; both default
  to the system language. Any language the system knows can be picked, from a searchable list.
  Subfolders inherit the pair from their root folder and don't store one. (#14)
- A root folder's language pair can't be changed after it is created. (#14)
- Every folder has a **palette**: two gradient hues and an accent, one of 8 cool sets (Lagoon,
  Indigo, Mint, Arctic, Glacier, Aurora, Lilac, Rose), each with a light and a dark variant.
  There is no separate accent choice. (#42)
  - Creating a root folder picks one; the default is the first palette no root folder uses yet,
    then they repeat in order.
  - A subfolder follows its parent's palette ("Same as …") unless given its own.
  - **Appearance** on a folder's context menu or its screen's More menu changes it later; for a
    subfolder it can go back to following the parent.
  - A root folder from before palettes gets one derived from its id, stable across launches.
  - A folder moved to the top level, or a root folder moved under another folder, keeps the
    palette it showed; a following subfolder moved elsewhere follows its new parent.
  - Root folder rows show a tile in the palette's gradient; a folder screen has a wash and
    accent in its palette, and each subfolder tile glows in its own.
- **Due count**: the cards in a folder's subtree that Play would take today, without the
  20-card cap: due now or new. A card due tomorrow becomes due at the 04:00 review-day start,
  not at midnight (`review.md`). (#43)
- **Home** lists the root folders by name over a fixed two-hue wash. The subtitle is the sum of
  their due counts, `N cards due today`, or `Nothing due today`. A row shows the gradient tile,
  name, language pair, `N due` in the folder's accent (hidden at 0) and a ring of learned / all
  cards with the percentage (hidden while the subtree has no cards). (#43)
- A **folder screen** shows, over a wash in the folder's palette: for a subfolder its parent's
  name, the folder's name and language pair; a summary card with `N due today`,
  `learned / all learned`, a bar and a **Play** button (hidden while the subtree has no cards);
  its subfolders as a two-column grid of tiles by name, each with `learned / all learned`; then
  its cards newest first, a row showing the front in bold and the back. (#14, #43)
- Progress is learned cards / all cards in the subtree. A learned card is defined in
  `review.md`. (#29)
- **Play** is available on every folder and reviews the folder's subtree (see `review.md`): on
  the folder screen's summary card, and first on a folder's context menu (home and folder
  screens). (#28, #43)
- **New card** on a folder screen opens the card editor in add mode with that folder chosen;
  tapping a card opens it in edit mode. (#15)

## States and edge cases
- No folders yet: home offers New folder.
- Empty folder: no subfolders and no cards; offers New card and New subfolder, later screenshot
  import (milestone 4).
- Moving a folder under itself or one of its own descendants, or to where it already is, is not
  allowed; those destinations are shown dimmed.
- Moving a folder to another root folder is allowed; its cards take on the new root's language
  pair. If the pairs differ, a warning is shown before the move.
- Moving a subfolder to the top level makes it a root folder that keeps the pair it had.
- A root folder moved under another folder becomes a subfolder: it drops its own pair and last
  back source and takes the new root's.

## Not supported
- Tags.
