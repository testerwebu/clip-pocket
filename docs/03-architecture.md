# Architecture

## Goal

Build ClipPocket as a native macOS app.

The architecture should stay simple, modular and local-first.

## Stack

Use in V0.1:

- Swift
- SwiftUI
- AppKit where needed
- NSPasteboard
- SQLite + FTS5
- UserDefaults / AppStorage for simple settings

Post-V0.1 stack:

- Apple Vision for OCR
- Quick Look thumbnails
- image storage
- file previews
- OCR

Do not use:

- Electron
- React Native
- backend in V0.1
- cloud sync
- accounts
- remote OCR
- analytics in the app
- web dashboard

## App shape

ClipPocket should primarily be a menu bar app.

Main surfaces:

- menu bar popover
- settings window
- optional preview/detail window
- optional pinned/floating window later

## Suggested V0.1 modules

```txt
App/
  ClipPocketApp.swift
  AppState.swift
  SettingsStore.swift

Clipboard/
  ClipboardMonitor.swift
  PasteboardReader.swift
  PasteboardWriter.swift
  PasteboardTypes.swift

Clips/
  Clip.swift
  ClipType.swift
  ClipClassifier.swift
  ClipStore.swift
  ClipRepository.swift

Storage/
  SQLiteDatabase.swift
  SearchIndex.swift

UI/
  MenuBar/
    MenuBarView.swift
    ClipListView.swift
    ClipRowView.swift
    ClipSearchView.swift
    ClipFiltersView.swift

  Settings/
    SettingsView.swift

Services/
  LaunchAtLoginService.swift
  SourceAppDetector.swift
```

Post-V0.1 modules may add file storage, previews, thumbnails and OCR services.

## Clipboard monitoring

Use `NSPasteboard.general.changeCount`.

Poll every 0.5–1 second.

On change:

1. Check pasteboard types.
2. Ignore internal ClipPocket marker.
3. Ignore transient clipboard types.
4. Ignore concealed clipboard types.
5. Extract supported content.
6. Classify content type.
7. Generate content hash.
8. Avoid duplicates.
9. Store clip locally.
10. Update UI.

## Internal pasteboard marker

When ClipPocket copies an old clip back to clipboard, it should add an internal marker.

Example marker:

```txt
com.clippocket.internal
```

The monitor must ignore clipboard changes created by ClipPocket itself.

## Clip classification

The classifier should detect:

- URL
- email address
- color value
- likely code
- plain text fallback

Do not classify HTML/rich text, images or files in V0.1.

## Local storage

Use SQLite as the source of truth.

Use FTS5 for search.

For V0.1, store supported clips as plain text and metadata in SQLite.

Post-V0.1 large data should be stored as files, not directly in the main database:

- images
- HTML data
- rich text data
- thumbnails

The database may include future-ready optional paths and metadata, but V0.1 must not implement storage for HTML, rich text, images, files, thumbnails or OCR.

## Search

Search should include:

- plain text
- normalized text
- URL
- email
- color value
- code text
- source app
- tags

Post-V0.1 search may include file names and OCR text.

Search must be local and fast.

## OCR - Post-V0.1

OCR is for copied images.

Use Apple Vision.

OCR should run in the background.

OCR result goes into `ocrText`.

`ocrText` should be indexed for search.

No image should be uploaded.

Do not implement OCR in V0.1.

## UI architecture

Keep UI separate from services.

Views should not directly read `NSPasteboard`.

Views should communicate through `AppState`, repositories or services.

## Build principle

Each phase must build and launch before moving on.

Do not implement multiple phases at once.
