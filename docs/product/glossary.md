# Glossary
Domain terms, used with exactly these names in docs, issues, code and UI.

| Term | Meaning | Code name | UI (ru) |
|---|---|---|---|
| Folder | Catalog node holding cards and/or subfolders, any depth. "Pack" in early notes = folder. | `Folder` | Папка |
| Root folder | Top-level folder. Owns the language pair and last back source; subfolders inherit. | `Folder` with `parent == nil` | — |
| Subtree | A folder with all its descendants. Progress and Play work on the subtree. | — | — |
| Language pair | Learning language → back language, e.g. `sr → ru`, `en → en` (definitions in English). | `learningLanguage`, `backLanguage` | — |
| Card | One item to learn: front and back. | `Card` | Карточка |
| Front | Word or phrase on top, screenshot below it if present. | `front` | Лицо |
| Back | One text the user picked from the four tiles when creating the card. Shown in review. | `back` | Оборот |
| Back source | Which tile the back came from: definition, synonyms, translation or custom. | `backSource`: `definition` / `synonyms` / `translation` / `custom` | Определение / Синонимы / Перевод / Свой текст |
| Tile | One of the four back options on the card editor, prefilled with a hint where available. | — | Плитка |
| Hint | Text the app suggests for a tile (definition, synonyms, translation) or the front (lemma). | `DefinitionProvider`, `SynonymProvider`, `TranslationProvider`, `Lemmatizer` | — |
| Context | The subtitle line (ideally sentence) where the word appeared. | `context` | Контекст |
| Screenshot | Compressed copy of the source image stored with the card. | `screenshot` | Скриншот |
| Front key | Normalised front used to detect duplicates: trimmed, case- and diacritics-insensitive. | `frontKey` | — |
| Duplicate | A card with the same front key in the same root folder. | — | Дубликат |
| Inbox | Queue of unprocessed screenshots shared by all entry points. | `InboxStore`, `inbox/` in the App Group | Inbox |
| Batch | The screenshots processed in one run of the import flow, all into one folder. | — | Пачка |
| Token | A word from OCR'd text after tokenisation; a phrase is a run of tokens on one line. | — | — |
| Lemma | Dictionary form of a token (`running` → `run`). | `Lemmatizer` | Начальная форма |
| Sense | One meaning of a dictionary entry; the Definition tile shows one sense. | — | Значение |
| Review | Playing cards and rating each answer. "Game" in early notes = review. | — | Игра |
| Play | The action that starts a review session for a folder's subtree. | — | Играть |
| Session | One review run: a queue of at most 20 cards. | `SessionBuilder` builds it | Сессия |
| Rating | Answer grade: again 0, hard 1, good 2, easy 3. | `rating` | Не знаю / Сложно / Хорошо / Легко |
| Due card | A card whose review state's due date has passed. | `dueDate` | — |
| New card | A card never reviewed. | — | — |
| Direction | Forward = front → back (MVP). Reverse = back → front (later). | `direction`: `forward` / `reverse` | — |
| Review state | Scheduling state of one card in one direction. | `ReviewState` | — |
| Review log | Every rating ever given, kept to recompute schedules (e.g. for FSRS). | `ReviewLog` | — |
| Scheduler | The spaced-repetition algorithm, behind a protocol. | `Scheduler` | — |
