# DirtyMixerApp

Native SwiftUI control app for a 9-channel analog dirty video mixer board.

## Current Status

- Phase: `UI skeleton` (mock board state, no hardware connection yet)
- Platform target: macOS first, iOS/iPadOS later
- Control transport (planned): USB serial first, Ethernet later

## What's Included In This Initial Draft

- SwiftUI app shell
- 9-channel board model with mock state
- Channel strip UI (A/B toggles, mix slider/value, active indicator)
- Main board grid view
- Preset bar with 12 slots (mock save/recall)
- Toolbar actions (connect/disconnect, load/save project placeholders)

## Run

```bash
swift run
```

## Repo Workflow

Use small commits so growth is easy to track over time.

Suggested commit style:

- `feat(ui): add channel strip skeleton`
- `feat(serial): add USB port discovery`
- `feat(preset): add .jbt preset save/load`
- `fix(protocol): handle ERR responses`

## Core Rules

1. Board is dumb (execution only).
2. DirtyMixerApp is the only board-protocol speaker.
3. Standalone mode always works.
4. Preserve dirty behavior (no over-smoothing).
5. Swift-native architecture.

See full context in [DirtyMixerApp_BuildGuide.md](./DirtyMixerApp_BuildGuide.md).
