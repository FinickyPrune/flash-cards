# Review
Classic flash-card review of a folder's subtree with four ratings and day-based spaced repetition.
Status: planned (milestone 2)

## Rules
- Review takes a list of cards and knows nothing about folders. The session builder picks the
  cards: today from a folder subtree, later also "hard words".
- Flow per card: show the front → tap to flip → show the back (the text chosen in the
  editor) → rate it.
- Ratings: **Again** (Не знаю), **Hard** (Сложно), **Good** (Хорошо), **Easy** (Легко).
- Intervals are whole days. No notifications.
- A review day starts at **04:00** local time, so a late-night session counts as the evening's
  day. A card due in N days is due at 04:00 on the N-th review day after the rating. (#25)
- Scheduling: SM-2-like, behind a replaceable scheduler (decision 0002). (#25)
  - A new card (or one after a lapse): Again → due again today; Hard or Good → 1 day;
    Easy → 4 days. Ease starts at 2.5 and doesn't change on these first ratings.
  - After that: Hard → interval × 1.2, ease −0.15; Good → 6 days on the second step, then
    interval × ease; Easy → interval × ease × 1.3, ease +0.15. Intervals round to whole days.
  - Hard is at least the previous interval + 1 day, Good at least Hard + 1, Easy at least
    Good + 1, so a harder answer never gives a longer interval.
  - Again on a card answered right before is a **lapse**: due tomorrow (interval 1 day),
    ease −0.2, it starts over as a new card.
  - Ease never drops below 1.3; intervals never exceed 365 days; no random spread.
- Session queue: due cards first, then new cards; at most **20** cards in total (one constant).
- A card rated Again comes back later in the same session, after a few other cards (exact gap set
  when the session builder is built).
- No due cards → the user can still play: **20** random cards from the subtree. These
  ratings go to the review log but don't change the schedule.
- Every rating is written to the review log.
- Session summary: number of cards reviewed, and how many were rated Good or Easy.
- A card counts as **learned** for folder progress when its forward interval is ≥ **21 days**.
  A lapse that resets the interval makes it not learned again.

## States and edge cases
- Empty subtree: Play shows that there is nothing to review.
- A card rated Again several times in one session: (to be defined, e.g. at most N returns)

## Not supported
- Reverse direction (back → front) in the UI. The model and session builder allow it.
- Review by hard words; FSRS.
