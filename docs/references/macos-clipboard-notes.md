# macOS Clipboard Notes

## Clipboard API

Use `NSPasteboard.general`.

Watch changes through `changeCount`.

Recommended approach:

- store initial `changeCount` on launch
- poll every 0.5–1 second
- compare current `changeCount` to previous
- when changed, inspect pasteboard types
- extract supported content
- ignore unsupported/private content

## Important behavior

Do not import existing clipboard content on first launch.

Only save content copied after ClipPocket starts monitoring.

## Internal marker

When ClipPocket copies an old clip back to clipboard, write an internal marker type:

```txt
com.clippocket.internal
```

When the watcher sees this marker, it should ignore the event.

## Ignore types

Ignore transient clipboard content.

Ignore concealed clipboard content.

These are often used for temporary or sensitive clipboard entries.

## Supported content

V0.1 should support:

- plain text
- URLs
- emails
- colors
- code

Post-V0.1 may support:

- HTML
- rich text
- images
- files copied from Finder

## Duplicate detection

Use `contentHash`.

Avoid saving the same content repeatedly.

If a user copies the same item again, update:

- lastCopiedAt
- copyCount

instead of creating duplicate rows, unless product decision changes.

## File handling - Post-V0.1

For files copied from Finder:

- store file path/reference
- store file name
- store extension/type
- generate thumbnail if possible
- reveal in Finder action should work

Do not duplicate large files by default.

## Image handling - Post-V0.1

For images copied directly:

- save image into local ClipPocket storage
- generate thumbnail
- optionally OCR later
- allow copy back to clipboard

## Privacy

No clipboard content should leave the Mac in V0.1.
