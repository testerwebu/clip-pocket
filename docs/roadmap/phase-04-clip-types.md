# Phase 04 — Clip Types

## Goal

Classify text-based clipboard content into useful types.

## Read before work

- docs/04-data-model.md
- docs/03-architecture.md
- docs/roadmap/phase-02-clipboard-watcher.md

## Tasks

Detect and classify:

- plain text
- URLs / links
- email addresses
- color values: HEX, RGB, HSL
- likely code snippets

Create `ClipClassifier`.

Add type filters in the UI:

- All
- Text
- Links
- Emails
- Colors
- Code
- Pinned

## Type detection rules

Use simple, reliable heuristics.

Avoid overengineering.

Examples:

- URL if valid URL pattern.
- Email if valid email pattern.
- Color if HEX/RGB/HSL pattern.
- Code if multiline, contains syntax symbols, or common language patterns.
- Otherwise text.

## Do not

- Do not implement images/files yet.
- Do not implement OCR yet.
- Do not add AI classification.
- Do not add cloud logic.

## Acceptance criteria

- Copied URLs show as links.
- Copied emails show as emails.
- Copied colors show as colors.
- Copied code shows as code.
- Filters work.
- App builds and launches.
