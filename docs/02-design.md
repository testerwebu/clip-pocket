# Design

## Visual direction

ClipPocket should feel like a tiny premium macOS utility.

It should feel:

- native
- clean
- white
- calm
- lightweight
- fast
- focused
- trustworthy

It should not feel:

- SaaS-like
- heavy
- loud
- dashboard-like
- colorful everywhere
- childish
- generic AI-tool-like

## Apple-like design principles

Use native macOS patterns wherever possible.

Use:

- system font
- SF Symbols
- native controls
- native menu bar behavior
- native spacing
- native shadows
- native materials only if they help

Do not bundle Apple font files.

Use SwiftUI/AppKit system font APIs.

## Typography

Use system fonts.

SwiftUI:

```swift
.font(.system(size: 15, weight: .regular, design: .default))
```

For code snippets:

```swift
.font(.system(.body, design: .monospaced))
```

AppKit:

```swift
NSFont.systemFont(ofSize: 15, weight: .regular)
```

## Color palette

Base:

- White: #FFFFFF
- Soft White: #FAFAFB
- Ink: #111827
- Muted Text: #6B7280
- Border: #E5E7EB
- Hairline: #EEF0F3

Accent:

- Apple Blue: #007AFF
- Baby Blue: #5AC8FA
- Pocket Orange: #FF9F0A
- Soft Pink: #FF6B8A
- Deep Blue: #0A4DFF

Use ratio:

- 90% white / off-white
- 7% black, grey, border, shadow
- 3% accent color

## UI style

The app should use:

- white surfaces
- subtle borders
- small shadows only when needed
- rounded corners
- compact controls
- clear hierarchy
- minimal icons
- restrained accent colors

Avoid:

- huge grey panels
- colorful dashboard blocks
- heavy gradients
- large sidebars
- complex settings pages
- visual noise

## Menu bar popover

The menu bar popover is the core product UI.

It should include:

- search input
- pinned clips when available
- recent clips list
- type filters
- settings button
- compact quick actions

The popover should feel like a small Mac utility, not a full app dashboard.

## Clip rows

Each clip row should show:

- type icon
- short preview/title
- source app if available
- time or relative age
- pinned state
- quick action on hover or selection

Rows should be compact but readable.

## Type indicators

Use small visual indicators for clip types:

- Text
- Link
- Email
- Color
- Code

Post-V0.1 indicators:

- HTML
- Image
- File

Use SF Symbols where possible.

## App icon direction

The icon should be distinct from ClipBook and ScreenPocket.

Concept:

- rounded macOS app icon
- small pocket shape
- clipped notes/cards inside
- subtle orange/blue/pink accents
- clean and premium
- no clipboard cliché if possible

Do not copy ClipBook’s icon.

## Copy tone

Use short, direct copy.

Good:

- Copy. Forget. Find it later.
- Keep every clip in one tiny pocket.
- Search your clipboard history.
- Your clips stay on your Mac.
- No account. No cloud. No subscription.

Avoid:

- Revolutionize your productivity.
- Unlock your workflow potential.
- AI-powered clipboard intelligence.
- Cross-platform productivity ecosystem.

## Landing later

The landing page should only be built after the native V0.1 works.

Landing style:

- white
- centered
- large Apple-like typography
- minimal sections
- strong hero
- product demo
- lifetime pricing
- privacy message

Do not design landing before the app has a real UI.
