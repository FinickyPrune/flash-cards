# 0004. Share extension only drops files into a shared inbox
Status: accepted (2026-10-24)

## Context
Share extensions have a tight memory limit, can't officially open their host app, and decoding
or OCR'ing several screenshots there risks being killed.

## Decision
The extension copies the shared image files as-is into `inbox/` in the App Group container,
shows "Added N screenshots" and exits. All processing (OCR, card creation, SwiftData) happens in
the app. The in-app photo picker feeds the same inbox and flow.

## Alternatives
- Process in the extension — instant cards, but memory kills and a second SwiftData writer.
- Open the app from the extension — no supported API.

## Consequences
One import flow for all entry points. The user must open the app to finish; the app shows an
inbox banner. Files in the inbox must survive app restarts and be cleaned up after processing.
