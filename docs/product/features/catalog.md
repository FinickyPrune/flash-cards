# Catalog
A tree of folders holding cards; every folder shows progress and can start a review of its subtree.
Status: partial (folder tree shipped in milestone 1; progress and Play in milestone 2)

## Rules
- Folders nest to any depth. Design and test the UI at 2–3 levels.
- Folders can be created, renamed, moved and deleted. Rename, move and delete are on a folder
  row's context menu (long press) and swipe actions. (#14)
- Deleting a folder deletes its whole subtree (subfolders and cards) after a confirmation.
- Creating a root folder asks for the learning language and the back language; both default
  to the system language. Any language the system knows can be picked, from a searchable list.
  Subfolders inherit the pair from their root folder and don't store one. (#14)
- A root folder's language pair can't be changed after it is created. (#14)
- Home lists the root folders by name, each with its language pair.
- A folder screen lists its subfolders by name, then its cards newest first; a card row shows
  the front and the back. (#14)
- Each folder row shows progress: learned cards / all cards in its subtree. (planned)
- **Play** is available on every folder and reviews the folder's subtree (see `review.md`). (planned)
- **New card** on a folder screen opens the card editor in add mode with that folder chosen. (planned, #15)

## States and edge cases
- Empty folder: no subfolders and no cards; offers New subfolder, later New card (#15) and
  screenshot import (milestone 4).
- Moving a folder under itself or one of its own descendants is not allowed.
- Moving a folder to another root folder is allowed; its cards take on the new root's language
  pair. If the pairs differ, a warning is shown before the move.
- Moving a subfolder to the top level makes it a root folder that keeps the pair it had.

## Not supported
- Tags.
