# Screenshot import
Turn one or many screenshots into cards: OCR the text, tap a word or phrase, confirm the card.
Status: planned (milestone 4 in-app; milestone 5 share extension)

## Entry points
Both feed the same inbox and the same flow; the flow only sees images.
1. **Share extension** from Photos or any app, one or many images.
2. **In-app button** with the system photo picker, multiple selection.

## Share extension
- Copies the image files as-is into the inbox (App Group), without decoding them (extension
  memory limit). Shows "Added N screenshots".
- Doesn't try to open the app (no official way). The app shows a banner "N screenshots in
  inbox". (assumption)
- No folder choice in the extension; it is made when processing starts.

## Processing a batch
1. Start: pick a folder for the whole batch, or create one. Its root's language pair applies.
2. For the current screenshot: OCR on the original image (not the compressed copy) with the
   folder's learning language, or automatic detection when OCR doesn't support it (decision
   0005); then tokenise the recognised lines.
3. Word picker: the screenshot, and below it the recognised lines as tappable tokens. Lines
   that look like the subtitle come first: horizontally centred, lowest on the screen, and
   joined into one sentence when they are stacked. All other text (player controls,
   notifications, clock) follows in a separate "Other text" section. Tokens without letters
   (times, counters) are dropped. Words joined by a hyphen (`well-known`) are one token; contractions
   (`I'm`, `mother's`) stay whole (decision 0007). Tap a token to pick a word, or a run of adjacent tokens on
   one line as a phrase. (assumption: subtitle heuristic)
4. The card editor opens in add mode (`card-editor.md`): front = the pick (with the lemma toggle
   when it differs), context = the line (sentence when possible), screenshot attached, tiles
   prefilled with hints.
5. Duplicate check by front key within the root folder; warn and ask "Create anyway?".
6. Save returns to the word picker of the same screenshot; words already made into cards are
   marked. Pick another word or go to **Next screenshot**.
7. Always available: **Skip screenshot**, **Back**, editing the
   front by hand.
8. OCR found nothing → a message and **Create card manually** with this screenshot.
9. End of batch: "Created N cards" and an offer to play.

## Storage
- On save the card stores a compressed copy of the screenshot: long side ~1280 px, JPEG
  quality ~0.7, at most ~300 KB. No reference to the photo library; the card survives deletion
  of the original. The original in Photos is never touched.
- The inbox file is deleted when the user leaves the screenshot: **Next screenshot**, **Skip
  screenshot**, or the end of the batch. Until then it stays in the inbox, so after an app
  restart the screenshot is still there and words already made into cards are marked.

## States and edge cases
- OCR is near-perfect on English subtitles. Languages Apple's OCR doesn't support (e.g.
  Serbian: ć and đ are often misread) are not a screenshot use case in the MVP; editing the
  front by hand always works.
- The inbox is shared by all entry points and survives app restarts.

## Not supported
- Highlighting the picked word on the screenshot; folder choice inside the extension.
- Cards from a website, document or query.
