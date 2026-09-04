# Phase 08 — Basic Search

## Goal

Implement fast local search across V0.1 text-based clips.

## Read before work

- docs/04-data-model.md
- docs/03-architecture.md
- docs/05-privacy.md

## Tasks

- Implement SQLite FTS5 search.
- Index `searchText`.
- Include:
  - plain text
  - normalized text
  - URL
  - email
  - color value
  - code text
  - source app
  - tags
- Connect search input in menu bar popover.
- Show results instantly.
- Show empty search state.

## Search placeholder

Search clips, links, emails, colors or code...

## Empty state

No clips found.

Try another word, link, email or color.

## Do not

- Do not add cloud search.
- Do not add AI semantic search in V0.1.
- Do not add external search services.
- Do not index file names in V0.1.
- Do not index OCR text in V0.1.

## Acceptance criteria

- Search works offline.
- Search returns relevant clips.
- Search covers text, links, emails, colors and code snippets.
- Search is fast.
- App builds and launches.
