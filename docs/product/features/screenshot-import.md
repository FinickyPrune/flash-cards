# Screenshot import
Turn one or many screenshots into cards: OCR the text, tap a word or phrase, confirm the card.
Status: planned (milestone 3 in-app; milestone 4 share extension)

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
2. For the current screenshot: OCR on the original image (not the compressed copy), languages
   from the folder's learning language; then tokenise the recognised lines.
3. Word picker: the screenshot, and below it the tokens in reading order. Tap a token to pick a
   word, or pick a run of adjacent tokens on one line as a phrase.
4. The card editor opens in add mode (`card-editor.md`): front = the pick (with the lemma toggle
   when it differs), context = the line (sentence when possible), screenshot attached, tiles
   prefilled with hints.
5. Duplicate check by front key within the root folder; warn and ask "Create anyway?".
6. Save returns to the word picker of the same screenshot; words already made into cards are
   marked. Pick another word or go to **Next screenshot**.
7. Always available: **Skip screenshot** (removes it from the inbox), **Back**, editing the
   front by hand.
8. OCR found nothing → a message and **Create card manually** with this screenshot.
9. End of batch: "Created N cards" and an offer to play.

## Storage
- On save the card stores a compressed copy of the screenshot: long side ~1280 px, JPEG
  quality ~0.7, at most ~300 KB. No reference to the photo library; the card survives deletion
  of the original. The original in Photos is never touched.
- The inbox file is deleted once a card from it is saved, or when it is skipped.
  (to be defined: delete after the first saved card, or when leaving the screenshot, so more
  words can still be picked after an app restart)

## States and edge cases
- Serbian Latin diacritics (č ć š ž đ) are expected to be misread; manual editing of the
  front is mandatory. (spike: OCR quality for sr and en)
- The inbox is shared by all entry points and survives app restarts.

## Not supported
- Highlighting the picked word on the screenshot; folder choice inside the extension.
- Cards from a website, document or query.
