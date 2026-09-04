# Privacy

## Core promise

Your clips stay on your Mac.

ClipPocket is local-first.

## V0.1 privacy rules

Do not upload copied content.

Do not send clipboard content to a server.

Do not use remote OCR.

Do not require an account.

Do not add analytics inside the native app.

Do not add cloud sync in V0.1.

## V0.1 local data

ClipPocket may store locally:

- copied text
- copied links
- copied email addresses
- copied color values
- copied code snippets
- source app metadata if available
- timestamps
- pinned/favorite states
- tags

## Post-V0.1 local data

These may be added later, but must not be implemented in V0.1:

- HTML/rich text data
- copied images
- file references
- thumbnails
- OCR text from copied images

## Sensitive clipboard types

The clipboard monitor should ignore:

- transient clipboard content
- concealed clipboard content
- ClipPocket’s own internal pasteboard marker

The app should avoid saving password-manager/private clipboard entries when marked as concealed.

## User controls

Settings should include:

- pause clipboard monitoring
- clear history
- maximum history size
- delete individual clip
- delete all clips
- optionally exclude apps later

## Privacy copy

Use this in product UI:

ClipPocket is local-first. Your clips stay on your Mac. No account, no cloud sync, no tracking.

Short version:

Your clips stay on your Mac.

## Future privacy considerations

If cloud sync is ever added, it must be optional.

If analytics are ever added, they must never include clipboard content.

If license keys are ever added, they must not require uploading clipboard content.

## Non-negotiable

No copied content leaves the device in V0.1.
