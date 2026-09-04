# Clip Pocket macOS App

Native macOS app for Clip Pocket.

## Stack

V0.1:

- Swift
- SwiftUI
- AppKit where needed
- NSPasteboard
- SQLite + FTS5
- UserDefaults / AppStorage

Post-V0.1:

- Apple Vision
- Quick Look thumbnails
- image/file storage and previews

## V0.1 features

- menu bar app
- clipboard watcher
- local text-based clip history
- text/link/email/color/code detection
- basic local search
- copy back to clipboard
- pin/favorite/delete
- settings
- local-first privacy

## Post-V0.1 features

- HTML/rich text support
- image/file support
- thumbnails
- local OCR for images

## Phase 00

This folder contains the native macOS SwiftUI project foundation.

Created in this phase:

- `ClipPocket.xcodeproj`
- `ClipPocket/App/ClipPocketApp.swift`
- `ClipPocket/App/AppState.swift`
- `ClipPocket/App/SettingsStore.swift`
- basic menu bar shell
- basic settings shell
- clean module folders

## Build

```sh
xcodebuild -project ClipPocket.xcodeproj -scheme ClipPocket -configuration Debug build
```

## Run

Open `ClipPocket.xcodeproj` in Xcode and run the `ClipPocket` scheme.

The app should appear as a menu bar item named Clip Pocket.

## Hard rules

- no Electron
- no backend
- no account
- no cloud sync
- no remote OCR
- no analytics in V0.1
- follow `docs/roadmap/00-roadmap.md`
