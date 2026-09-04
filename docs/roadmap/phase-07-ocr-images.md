# Phase 07 — OCR for Images

Status: Post-V0.1. Do not implement before the slim core is working.

## Goal

Make copied images searchable by recognized text.

## Read before work

- docs/04-data-model.md
- docs/05-privacy.md
- docs/03-architecture.md

## Tasks

- Create `OCRProcessor`.
- Use Apple Vision for local OCR.
- Queue OCR for copied images.
- Run OCR in background.
- Store OCR status:
  - pending
  - processing
  - completed
  - failed
- Store recognized text in `ocrText`.
- Add `ocrText` to searchable content.

## Privacy rule

OCR must run locally.

Do not upload images.

Do not use remote AI/OCR APIs.

## Do not

- Do not OCR all files automatically.
- Do not OCR video.
- Do not add ScreenPocket-specific screenshot logic here.
- Do not add cloud processing.

## Acceptance criteria

- Copied image gets processed locally.
- Recognized text is stored.
- OCR does not block UI.
- Search can later use OCR text.
- App builds and launches.
