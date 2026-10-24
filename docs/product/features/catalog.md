# Catalog
A tree of folders holding cards; every folder shows progress and can start a review of its subtree.
Status: planned (milestone 1; progress and Play in milestone 2)

## Rules
- Folders nest to any depth. Design and test the UI at 2–3 levels.
- Folders can be created, renamed, moved and deleted.
- Deleting a folder deletes its whole subtree (subfolders and cards) after a confirmation. (assumption)
- Creating a root folder asks for the learning language and the back language; both default
  to the system language. Subfolders inherit the pair from their root folder and don't store one.
- A folder screen lists its subfolders, then its cards.
- Each folder row shows progress: learned cards / all cards in its subtree.
- **Play** is available on every folder and reviews the folder's subtree (see `review.md`).
- **New card** on a folder screen opens the card editor in add mode with that folder chosen.

## States and edge cases
- Empty folder: no subfolders and no cards; offer New card and screenshot import. (assumption)
- Moving a folder under one of its own descendants is not allowed.
- Moving a folder to another root folder: (to be defined) its cards take on the new root's language pair, or the move is limited to the same pair.

## Not supported
- Tags.
