# ResurrectionAnnounce

Plugin for **WoW 1.12.1** that listens to **HealComm** and announces who you are resurrecting.
Tested with **HealComm** + **pfUI** and **LunaUnitFrames** (Turtle WoW compatible).

## Features
- Announces res target to RAID / PARTY / SAY
- “Dynamic” mode auto-picks RAID → PARTY → SAY
- Simple slash commands + status readout

## Requirements
- HealComm (or LunaUnitFrames with compatible HealComm messaging)

## Installation
1) Copy the folder to `Interface/AddOns/ResurrectionAnnounce/`  
2) Enable at character select → **AddOns** (tick **Load out of date** if needed)

## Usage
`/sayres {chat|help|status}` or `/sr {chat|help|status}`

- `chat {number}` sets the output channel:
  - `0` – Dynamic (RAID > PARTY > SAY)
  - `1` – RAID only
  - `2` – SAY only
- Shorthand:
  - `/sr dynamic` → `chat 0`
  - `/sr raid` → `chat 1`
  - `/sr say` → `chat 2`
- `status` shows the current mode
- `help` shows usage

### Examples
