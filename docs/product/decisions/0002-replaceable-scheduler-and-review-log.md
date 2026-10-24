# 0002. SM-2-like scheduler behind a protocol, full review log, direction in the model
Status: accepted (2026-10-24)

## Context
The final spaced-repetition algorithm (SM-2 variants vs. FSRS) needs its own research, but
review must ship in milestone 2. A reverse direction (back → front) is wanted later.

## Decision
- Review depends on a `Scheduler` protocol; the MVP implementation is SM-2-like with day intervals.
- Every rating is stored in `ReviewLog`, so a later algorithm can recompute schedules from history.
- Review state is a separate entity keyed by card **and** direction; MVP uses only `forward`.

## Alternatives
- Scheduling fields on `Card` — simpler, but blocks reverse direction and loses history.
- FSRS from the start — delays review; parameters need history we don't have yet.

## Consequences
Swapping the algorithm is a new `Scheduler` plus a recompute from the log. Reverse direction
needs only UI and session-builder changes.
