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
- Scheduling: SM-2-like, behind a replaceable scheduler (decision 0002). Exact parameters are
  set when the scheduler is built.
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
