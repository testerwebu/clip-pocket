# ClipBook Lessons

ClipBook is reference only.

Do not copy:

- source code
- UI
- icons
- assets
- layout
- branding
- exact implementation

Useful lessons:

- watch NSPasteboard `changeCount`
- initialize last `changeCount` on app launch
- use internal pasteboard marker to avoid self-capturing
- ignore transient and concealed clipboard types
- support multiple clip types over time
- keep clipboard history searchable
- local-first privacy matters

ClipPocket is built natively with Swift, SwiftUI and AppKit.

ClipPocket should not use ClipBook’s stack.

ClipPocket should not use a web wrapper.

ClipPocket should not become a clone.

## Product decisions learned from ClipBook

ClipPocket V0.1 should support:

- text
- links
- emails
- colors
- code

Post-V0.1 may support:

- HTML / rich text
- images
- files

Post-V0.1 lessons:

- images and files need local preview/thumbnail strategy
- OCR for copied images can be useful
- rich clipboard managers can grow beyond text/link/code after the slim core works

ClipPocket can use ClipBook as a checklist for edge cases, not as source code.

## Scope boundary

ClipPocket may be functionally inspired by proven clipboard-manager patterns, but it must be visually and technically independent.

Do not recreate ClipBook’s pricing structure, UI, icon, layout or stack by default.
