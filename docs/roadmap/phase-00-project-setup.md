# Phase 00 — Project Setup

## Goal

Create the native macOS project foundation.

## Read before work

- AGENTS.md
- docs/00-index.md
- docs/01-product.md
- docs/02-design.md
- docs/03-architecture.md

## Tasks

- Create native macOS SwiftUI project in `apps/mac`.
- Set app name to ClipPocket.
- Configure bundle identifier.
- Configure minimum supported macOS version.
- Create basic app shell.
- Create `AppState`.
- Create `SettingsStore`.
- Add folder structure for app modules.
- Add basic build/run script if useful.

## Do not

- Do not implement clipboard monitoring yet.
- Do not implement database yet.
- Do not implement search yet.
- Do not implement OCR yet.
- Do not build the landing page.
- Do not add payments.
- Do not add accounts.

## Acceptance criteria

- Project exists in `apps/mac`.
- App builds.
- App launches.
- App has clean module structure.
- No unnecessary dependencies are added.
