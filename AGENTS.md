# AGENTS.md

You are working on ClipPocket.

ClipPocket is a tiny native macOS clipboard utility. Build the macOS app first. Do not start the landing page until the app V0.1 is real.

Before working, read only the files relevant to the current task.

Always read:
- docs/00-index.md
- docs/01-product.md
- docs/02-design.md
- docs/roadmap/00-roadmap.md

Then read the specific phase file from docs/roadmap/.

Do not read all roadmap phase files unless explicitly asked.

Hard rules:
- Do not use Electron.
- Do not add backend.
- Do not add accounts.
- Do not add cloud sync.
- Do not start the landing page before Phase 12.
- Do not implement more than one phase at once.
- After every phase, the app must build and launch.

V0.1 scope:
- V0.1 is text-based only.
- Supported V0.1 clip types are plain text, links / URLs, email addresses, color values and code snippets stored as plain text.
- In V0.1, code means plain text that looks like code.
- Do not implement HTML preservation in V0.1.
- Do not implement rich text preservation in V0.1.
- Do not implement images in V0.1.
- Do not implement files copied from Finder in V0.1.
- Do not implement thumbnails in V0.1.
- Do not implement OCR in V0.1.

Tech stack:
- Swift
- SwiftUI
- AppKit where necessary
- NSPasteboard
- SQLite + FTS5
- UserDefaults / AppStorage
- Local-first storage

Post-V0.1 stack:
- Apple Vision for OCR
- Quick Look thumbnails
- image storage
- file previews

Important structure note:
- apps/mac/ClipPocket.xcodeproj should be created during Phase 00.
- Do not expect apps/mac/ClipPocket.xcodeproj to exist before Phase 00.
- Do not create a fake Xcode project file manually.

Output after work:
- What changed
- Files touched
- How to test
- Risks / next steps
