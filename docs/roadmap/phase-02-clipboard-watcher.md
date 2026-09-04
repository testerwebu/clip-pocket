# Phase 02 — Clipboard Watcher

## Goal

Detect new clipboard content through NSPasteboard.

## Read before work

- docs/03-architecture.md
- docs/04-data-model.md
- docs/05-privacy.md
- docs/references/macos-clipboard-notes.md
- docs/references/clipbook-lessons.md

## Tasks

- Use `NSPasteboard.general.changeCount`.
- Poll every 0.5–1 second.
- Initialize last change count on launch to avoid importing old clipboard content.
- Ignore empty clipboard values.
- Ignore duplicates.
- Ignore ClipPocket’s own internal pasteboard marker.
- Ignore transient clipboard types.
- Ignore concealed clipboard types.
- Detect text, URLs, emails, colors and likely code snippets.
- Log detected clips first before saving to database.

## Detection scope for this phase

Detect text-based content only:

- plain text
- URLs
- email addresses
- HEX / RGB / HSL colors
- likely code snippets

Do not implement image/file/HTML persistence yet.

## Do not

- Do not build the database yet.
- Do not build search yet.
- Do not build images/files yet.
- Do not build landing page.

## Acceptance criteria

- App detects new copied text.
- App does not import clipboard content on first launch.
- App ignores duplicate copied values.
- App ignores ClipPocket’s own copied-back items.
- App ignores transient and concealed clipboard types when present.
- App builds and launches.
