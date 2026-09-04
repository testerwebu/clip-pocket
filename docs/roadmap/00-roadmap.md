# Roadmap

## V0.1 build order

Do not start with the landing page.

Build order for the first usable text-based V0.1:

1. Phase 00 — Project setup
2. Phase 01 — Menu bar shell
3. Phase 02 — Clipboard watcher
4. Phase 03 — Local store
5. Phase 04 — Text-based clip types
6. Phase 08 — Basic search
7. Phase 09 — Settings
8. Phase 10 — Polish
9. Phase 11 — Packaging

Post-V0.1:

- Phase 05 — HTML / rich text
- Phase 06 — Images / files
- Phase 07 — OCR for images
- Phase 12 — Landing page

Do not start the landing page before the native macOS V0.1 works.

When working on a phase, read only that phase file and the documents referenced inside it.

## Hard rules

- Do not implement more than one phase at a time.
- If working on Phase 02, do not start Phase 03.
- If working on Phase 03, do not start Phase 04.
- The app must build and launch after every phase.
- Do not add backend, accounts, cloud sync, analytics, subscriptions or license keys in V0.1.
- Do not create fake `.xcodeproj` files manually.
- The real Xcode project must be created during Phase 00.
- V0.1 is text-based only: text, links, emails, colors and code snippets stored as plain text.
- Do not implement HTML/rich text, images, files, thumbnails or OCR in V0.1.

## Current expected pre-Phase-00 structure

Before Phase 00, it is okay for these folders to contain only `.gitkeep`:

- apps/mac/ClipPocket/
- apps/web/app/
- apps/web/components/
- apps/web/public/

During Phase 00, Codex should create the real native macOS project in `apps/mac/`.

During Post-V0.1 Phase 12, Codex should create the real Next.js landing in `apps/web/`.
