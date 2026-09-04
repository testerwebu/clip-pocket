# Phase 05 — HTML / Rich Text

Status: Post-V0.1. Do not implement before the slim core is working.

## Goal

Support HTML and rich text clipboard content.

## Read before work

- docs/04-data-model.md
- docs/03-architecture.md
- docs/05-privacy.md

## Tasks

- Read HTML from NSPasteboard when available.
- Read rich text/RTF when available.
- Store original data locally as files if needed.
- Generate plain text fallback.
- Add preview for simplified HTML/rich text.
- Add actions:
  - copy original
  - copy as plain text

## Storage rule

Store larger rich content as local files.

Database stores metadata and paths.

## Do not

- Do not build a full HTML renderer.
- Do not build an editor.
- Do not add cloud processing.
- Do not add landing page.

## Acceptance criteria

- Copied rich text is saved.
- Copied HTML has plain text fallback.
- User can copy original or plain text.
- Search text can include fallback text.
- App builds and launches.
