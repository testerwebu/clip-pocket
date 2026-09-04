# ClipPocket

ClipPocket is a tiny native macOS clipboard utility that keeps useful copied text in one local, searchable pocket.

It is built as a native Mac app, lives in the menu bar, and is designed around a simple promise: your clips stay on your Mac.

## Status

ClipPocket is an early public codebase for a local-first macOS clipboard app. The current app target is a text-based first version, not a finished production release.

The project is suitable to share on GitHub as a work-in-progress native Mac utility. It should not yet be presented as a fully QA-tested commercial app.

## Current Scope

The first usable version is focused on text-based clipboard history:

- plain text
- links and URLs
- email addresses
- color values such as HEX, RGB, and HSL
- code snippets stored as plain text

ClipPocket intentionally does not include accounts, cloud sync, analytics, a backend, or Electron.

## Not In The Current Version

These are future features and are not part of the current text-first app scope:

- HTML or rich text preservation
- copied images
- files copied from Finder
- thumbnails
- OCR
- cloud sync
- accounts

## Repository Structure

```text
apps/mac/        Native macOS app
apps/web/        Future landing page placeholder
docs/            Product, design, architecture, privacy, and roadmap notes
agents/          Role notes for product, engineering, design, privacy, and release review
```

## macOS App

The app is in `apps/mac`.

Core stack:

- Swift
- SwiftUI
- AppKit where needed
- NSPasteboard
- SQLite with FTS5
- UserDefaults / AppStorage

## Build

Requirements:

- macOS
- Xcode

Build the app from the repository root:

```sh
xcodebuild -project apps/mac/ClipPocket.xcodeproj -scheme ClipPocket -configuration Debug build
```

For a release build:

```sh
xcodebuild -project apps/mac/ClipPocket.xcodeproj -scheme ClipPocket -configuration Release build
```

## Run

Open `apps/mac/ClipPocket.xcodeproj` in Xcode and run the `ClipPocket` scheme.

The app should appear in the macOS menu bar as Clip Pocket.

## Privacy

ClipPocket is local-first. In the current app scope, copied content is stored locally on the user's Mac and is not uploaded to a server.

See `docs/05-privacy.md` for the privacy rules and local data notes.

## Distribution

Installer files such as `.dmg` builds should not be committed to the repository. They belong in GitHub Releases once a release build has been tested.

## Roadmap

See `docs/roadmap/00-roadmap.md`.

## License

No open-source license has been granted yet. The source is visible for review, but all rights are reserved unless a license is added later.
