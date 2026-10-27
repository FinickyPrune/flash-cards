# Review
Classic flash-card review of a folder's subtree with four ratings and day-based spaced repetition.
Status: shipped (milestone 2)

## Rules
- Review takes a list of cards and knows nothing about folders. The session builder picks the
  cards: today from a folder subtree, later also "hard words".
- Flow per card: show the front → tap to flip → show the back (the text chosen in the
  editor) → rate it.
- Review opens full screen. The front side shows the front, its context below it, then the
  screenshot if the card has one. Tapping anywhere on the card flips it: the back appears under
  the front (the front stays), and the four rating buttons appear at the bottom; before the flip
  there are none. A rating shows the next card at once: no next-interval labels, no undo. (#28)
- The top bar has Close on the left and the "3 / 20" counter; in practice it also says
  "Practice". Close leaves at once, without a confirmation. (#28)
- Ratings: **Again** (Не знаю), **Hard** (Сложно), **Good** (Хорошо), **Easy** (Легко).
- Intervals are whole days. No notifications.
- A review day starts at **04:00** local time, so a late-night session counts as the evening's
  day. A card due in N days is due at 04:00 on the N-th review day after the rating. (#25)
- Scheduling: SM-2-like, behind a replaceable scheduler (decision 0002). (#25)
  - A new card (or one after a lapse): Again → due again today; Hard or Good → 1 day;
    Easy → 4 days. Ease starts at 2.5 and doesn't change on these first ratings.
  - After that: Hard → interval × 1.2, ease −0.15; Good → 6 days on the second step, then
    interval × ease; Easy → interval × ease × 1.3, ease +0.15. Intervals round to whole days.
    From the second step on, Hard is at least the previous interval + 1 day, Good at least
    Hard + 1, Easy at least Good + 1, so a harder answer never gives a longer interval.
  - Again on a card answered right before is a **lapse**: due tomorrow (interval 1 day),
    ease −0.2, and its next ratings start over from the first step. It stays a due card, not
    a new one.
  - Ease never drops below 1.3; intervals never exceed 365 days (at the cap Hard, Good and
    Easy all give 365); no random spread.
- Session queue: due cards first, most overdue first (same due date: older card first); then
  new cards, oldest first; at most **20** cards in total (one constant). No shuffling. No daily
  limit on new cards: Play again gives the next 20. (#26)
- A card rated Again comes back after **3** other cards (at the end if fewer remain), at most
  **2** times per session; Again on its third showing just moves on. (#26)
- Only a card's **first** rating in a session changes its schedule; later ratings of it are
  only logged. (#26)
- **Practice**: only when the subtree has cards but none due and none new. Play then shows
  "All caught up" with the next due date and offers **20** random cards from the subtree
  (all of them if fewer). Practice ratings go to the review log, marked as practice, but don't
  change the schedule. (#26, #27)
- Every rating is written to the review log and saved at once, so closing review mid-session
  keeps the ratings given so far. (#27)
- Session summary: distinct cards reviewed, and how many of them were rated Good or Easy on
  their first rating. (#26) It offers **Done** and, when Play on the folder would now give a new
  session (due or new cards remain, e.g. cards rated Again), **More**, which starts that session
  in place. After practice nothing is due or new, so More doesn't show. (#28)
- The "3 / 20" counter counts distinct cards shown so far, the current one included (so it
  starts at 1); a card coming back doesn't advance it. (#26)
- A card counts as **learned** for folder progress when its forward interval is ≥ **21 days**.
  A lapse that resets the interval makes it not learned again.

## States and edge cases
- Empty subtree: Play shows "Nothing to review" and Close.
- Nothing due or new, but cards exist: "All caught up", the next due date as a relative day
  ("tomorrow", "in 3 days"), **Practice 20 random cards** and Close.
- A rating that fails to save keeps the card on screen with an error, so it can be rated again.

## Not supported
- Reverse direction (back → front) in the UI. The model and session builder allow it.
- Review by hard words; FSRS.
