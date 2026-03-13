# DirtyMixerApp — Build Guide & Briefing Document

## What This Project Is

DirtyMixerApp is a native Mac/iOS Swift application that controls a custom-built 9-channel analog dirty video mixer board. It acts as the translation and intelligence layer between higher-level show control software (Atlas server) and the dumb analog hardware board.

This document covers hardware context, software architecture, short term build priorities, and longer term roadmap.

## Hardware Context

### The Board (Physical Device)

- 9 independent dirty mixer channels
- Each channel has 2 composite video inputs (A and B) and 1 composite video output
- Signals are mixed in a crude/intentionally dirty analog way: sync fights, brightness wars, unstable hybrids
- This is not a clean broadcast mixer. Dirty behavior is the point.
- One central microcontroller (RP2350-based board with USB-C) manages all 9 channels
- Each channel has a digipot (MCP4151 or similar, 8-10 bit) that controls the mix parameter
- Controller communicates via SPI to digipots, CS lines per channel for addressing
- USB-C connection to host computer (V1)
- Ethernet planned for later versions

### Per-Channel Control Model (V1)

Each channel exposes:

- `input_a_enabled` (bool)
- `input_b_enabled` (bool)
- `mix` (0-255 for V1, potentially 0-1023 for 10-bit)

### Board Communication Protocol (V1, USB Serial)

Simple ASCII command format over USB serial:

```text
CH1 MIX 128
CH3 A ON
CH7 B OFF
CH1 MIX 255
```

Board acknowledges with `OK` or `ERR`. DirtyMixerApp handles all protocol details.

## System Architecture

```text
[ Atlas / Server / Other Apps ]
           ↓ high-level intent
      [ DirtyMixerApp ]
           ↓ board protocol
       [ Hardware Board ]
```

### Role Boundaries

- Atlas/server layer sends high-level intent (recall preset, run ramp, random mode, etc.)
- DirtyMixerApp translates intent to low-level board commands, owns automation/presets/state
- Hardware board applies state updates only

## Operating Modes

### Standalone Mode

- Manual channel control UI
- Preset load/save/recall
- Timeline playback
- Automation execution
- No server required

### Managed Mode

- Controlled by Atlas/other apps
- Accepts high-level commands over network/IPC
- Translates to board actions and reports state
- UI reflects externally-driven state

## .jbt Format

JSON-based with a typed root:

```json
{
  "jbt_type": "dirtymixer_preset",
  "version": "1.0",
  "name": "Preset 12 — Chaos Mode",
  "channels": [
    { "id": 1, "a": true, "b": true, "mix": 128 },
    { "id": 2, "a": true, "b": false, "mix": 255 }
  ]
}
```

Supported concepts:

- `dirtymixer_preset`
- `dirtymixer_timeline`
- `dirtymixer_clip`
- `dirtymixer_project`

## Tech Stack

- UI: SwiftUI
- Targets: macOS first, iOS/iPadOS later
- USB Serial: Swift + IOKit or serialport library
- Networking (later): Swift Network framework
- File format: JSON (`.jbt`)
- State: `ObservableObject` + `@Published`

## Short-Term Priorities

### Phase 1 (Current): UI Skeleton

- Channel Strip View (x9)
- Main Board View + connection status
- Preset Bar (>=12 slots)
- Toolbar controls (connect, load/save project, mode indicator)
- Mock data (no hardware yet)

### Phase 2: USB Serial Connection

- Port discovery and connect UI
- Command send + ACK/ERR handling
- Reconnection logic

### Phase 3: Presets

- Save/recall named presets
- Interpolated recall over duration
- `.jbt` preset load/save

### Phase 4: Automation + Timeline

- Envelope shapes (linear, triangle, stepped)
- Group automation
- Transport controls
- `.jbt` timeline load/save

## Naming & Conventions

- App: `DirtyMixerApp`
- Protocol channel prefix: `CH` with 1-based IDs
- Extension: `.jbt`
- Mix range: `0-255` (V1), possible `0-1023` later
- Channel IDs are always 1-indexed

## Design Rules

1. Board is dumb.
2. DirtyMixerApp is the only protocol speaker.
3. Standalone mode must always work.
4. Do not sanitize dirty behavior out of existence.
5. Swift native all the way.
