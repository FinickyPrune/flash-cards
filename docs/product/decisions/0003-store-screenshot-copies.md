# 0003. Cards store a compressed copy of the screenshot
Status: accepted (2026-10-24)

## Context
Users delete screenshots from Photos after making cards. A reference to the library would
break those cards and needs photo-library permission.

## Decision
Store a compressed JPEG copy (long side ~1280 px, quality ~0.7, ≤ ~300 KB) in SwiftData
with external storage. OCR runs on the original before compression. Never modify Photos.

## Alternatives
- Photo library reference (`PHAsset` id) — no storage cost, but cards break and permission is needed.
- Full-size copy — sharper, but the database grows several times larger and sync later gets expensive.

## Consequences
The database grows ~300 KB per screenshot card. Full backup must include images (post-MVP).
