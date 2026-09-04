# Codex Phase Prompt Template

Use this prompt when starting a new phase.

```txt
Read:
- AGENTS.md
- docs/00-index.md
- docs/01-product.md
- docs/02-design.md
- docs/03-architecture.md
- docs/04-data-model.md only if needed
- docs/05-privacy.md only if needed
- docs/roadmap/<CURRENT_PHASE_FILE>.md

Work only on <PHASE NAME>.

Do not start any other phase.

Do not build the landing page unless this is Phase 12.

Do not add backend, accounts, cloud sync, Electron, React Native, analytics, subscription billing or license keys.

Make the smallest useful implementation that satisfies the acceptance criteria.

After changes:
- build the app
- report files touched
- explain how to test manually
- mention risks or unfinished items
```
