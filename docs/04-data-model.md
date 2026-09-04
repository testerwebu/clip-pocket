# Data Model

## Clip types

V0.1 clip types:

- text
- link
- email
- color
- code

Future clip types:

- html
- image
- file

## Clip fields

Recommended V0.1 `Clip` fields:

- id
- type
- title
- plainText
- normalizedText
- searchText
- sourceAppName
- sourceBundleIdentifier
- url
- email
- colorValue
- createdAt
- updatedAt
- lastCopiedAt
- copyCount
- isPinned
- isFavorite
- isDeleted
- tags
- characterCount
- contentHash

Future-ready optional fields:

- htmlDataPath
- richTextDataPath
- imagePath
- filePaths
- thumbnailPath
- ocrText
- ocrStatus

## Rules

- Store searchable text in `searchText`.
- Use `contentHash` for duplicate detection.
- For V0.1, store all supported clips as plain text. A code clip is stored as plain text and displayed with a monospaced system font. Do not implement rich text, HTML preservation, image storage, file storage, thumbnails or OCR in V0.1.
- Keep all data local.
- Use SQLite as source of truth.
- Use FTS5 for local full-text search.
- The schema may include future-ready optional fields, but implementation must stay inside the current phase and V0.1 scope.

## Duplicate behavior

If the same content is copied repeatedly:

- do not create unnecessary duplicate rows
- update `lastCopiedAt`
- increment `copyCount`

This can change later if product decision changes.

## File behavior - Post-V0.1

For files copied from Finder:

- store file path/reference
- store file name
- store extension/type
- generate thumbnail if possible
- allow reveal in Finder

Do not duplicate large files by default.

Do not implement file storage in V0.1.

## Image behavior - Post-V0.1

For images copied directly:

- save image into local ClipPocket storage
- generate thumbnail
- run OCR later when Phase 07 is reached
- allow copy back to clipboard

Do not implement image storage or thumbnails in V0.1.

## HTML and rich text behavior - Post-V0.1

For HTML / rich text:

- store original representation locally when available
- generate plain text fallback
- include plain text fallback in `searchText`
- allow copy original
- allow copy as plain text

Do not implement HTML preservation or rich text preservation in V0.1.

## OCR status - Post-V0.1

Possible `ocrStatus` values:

- none
- pending
- processing
- completed
- failed

Do not implement OCR in V0.1.
