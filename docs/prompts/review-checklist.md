# Review Checklist

Use after each phase.

## Scope

- Did the agent only work on the requested phase?
- Did it avoid unrelated features?
- Did it avoid landing work before Phase 12?

## Build

- Does the app build?
- Does the app launch?
- Are there obvious runtime errors?

## Product

- Does the change support the core promise?
- Does it keep ClipPocket small?
- Does it avoid SaaS/dashboard patterns?

## Privacy

- Does clipboard content stay local?
- Did the agent avoid analytics?
- Did the agent avoid cloud processing?
- Are sensitive clipboard types ignored where relevant?

## Design

- Does the UI feel native?
- Is it mostly white/clean?
- Does it use system fonts?
- Does it avoid visual clutter?

## Architecture

- Is the code modular?
- Are services separated from UI?
- Is persistence separated from views?
- Are large files stored outside the main database?

## Next step

- Is the next phase clear?
- Are risks documented?
