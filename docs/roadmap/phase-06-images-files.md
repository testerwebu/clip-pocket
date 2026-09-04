# Phase 06 — Images / Files

Status: Post-V0.1. Do not implement before the slim core is working.

## Goal

Support copied images and files.

## Read before work

- docs/04-data-model.md
- docs/03-architecture.md
- docs/05-privacy.md
- docs/references/macos-clipboard-notes.md

## Tasks

Images:

- Detect image clipboard content.
- Save image locally.
- Generate thumbnail.
- Show image preview.
- Allow copy back to clipboard.

Files:

- Detect files copied from Finder.
- Store file references and metadata.
- Store file names for search.
- Generate thumbnails where possible.
- Allow reveal in Finder.
- Allow copy file reference back to clipboard.

## Storage rules

Images may be copied into ClipPocket local storage.

Files should be stored as references by default, not duplicated.

## Do not

- Do not run OCR yet.
- Do not copy entire large file trees.
- Do not build file management UI.
- Do not add cloud sync.

## Acceptance criteria

- Copied image appears in ClipPocket.
- Copied file from Finder appears in ClipPocket.
- Thumbnails appear where possible.
- Reveal in Finder works for files.
- App builds and launches.
