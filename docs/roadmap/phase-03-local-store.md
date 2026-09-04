# Phase 03 — Local Store

## Goal

Create local persistence for clips.

V0.1 persists text-based clips only:

- text
- link
- email
- color
- code

## Read before work

- docs/04-data-model.md
- docs/05-privacy.md
- docs/03-architecture.md

## Tasks

- Create `Clip` model.
- Create `ClipType`.
- Create `ClipStore` or `ClipRepository`.
- Set up SQLite database.
- Store V0.1 text-based clips.
- Add `contentHash` for duplicate detection.
- Add timestamps.
- Add pinned/favorite/delete state.
- Load clips on app launch.
- Handle corrupted/missing data gracefully.

## Important

The schema may include future-ready optional fields, but V0.1 storage supports only:

- text
- link
- email
- color
- code

This phase must not implement storage for HTML, rich text, images, files, thumbnails or OCR.

## Do not

- Do not build search yet.
- Do not build OCR yet.
- Do not build HTML/rich text storage yet.
- Do not build image storage yet.
- Do not build file storage yet.
- Do not build thumbnails yet.
- Do not build landing page.
- Do not add cloud storage.

## Acceptance criteria

- Clips can be saved locally.
- Clips persist between app launches.
- Duplicate detection works through `contentHash`.
- App builds and launches.
