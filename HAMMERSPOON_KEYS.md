# Hammerspoon Key Reference

This document provides a complete reference for all Hammerspoon keyboard shortcuts configured for use with the Voyager keyboard.

## Key Modifiers

- **Hyper**: `Cmd + Alt + Ctrl + Shift`
- **Mash**: `Shift + Ctrl + Alt`

## Application Launchers (Hyper + Letter)

### Communication
- `Hyper + S` → Slack
- `Hyper + I` → Messages  
- `Hyper + Q` → Discord
- `Hyper + E` → Superhuman

### Development Tools
- `Hyper + P` → PhpStorm
- `Hyper + V` → Visual Studio Code
- `Hyper + T` → iTerm
- `Hyper + ;` → Linear *(Changed from 'O')*
- `Hyper + G` → OpenLens
- `Hyper + R` → Postman
- `Hyper + M` → DataGrip

### Productivity & Browser
- `Hyper + C` → Google Chrome
- `Hyper + N` → Obsidian
- `Hyper + W` → Claude
- `Hyper + F` → Fantastical
- `Hyper + D` → Reminders
- `Hyper + X` → Microsoft Excel
- `Hyper + B` → Miro
- `Hyper + A` → ChatGPT

### Media & Utilities
- `Hyper + Y` → Spotify
- `Hyper + U` → Granola
- `Hyper + Z` → Keymapp

### Available Keys
- `Hyper + O` → (Available - freed from Linear)

## Window Management

### Basic Window Controls (Hyper + Direction)
- `Hyper + H` → Left half of screen
- `Hyper + L` → Right half of screen
- `Hyper + J` → Maximize window
- `Hyper + K` → Move to next screen
- `Hyper + 1` → Center window (big)

### Advanced Window Positioning (Mash + Key)
- `Mash + H` → Left 70%
- `Mash + L` → Right 30%
- `Mash + K` → Top 50%
- `Mash + J` → Bottom 50%
- `Mash + [` → Upper left 70%
- `Mash + ]` → Upper right 30%
- `Mash + ;` → Bottom left 70%
- `Mash + '` → Bottom right 30%
- `Mash + M` → Maximize
- `Mash + I` → Center (small)
- `Mash + O` → Center (medium)
- `Mash + P` → Center (big)
- `Mash + Y` → Center on screen

## Portrait Monitor Features

### Portrait Layouts (Hyper + Number)
- `Hyper + 9` → Quick position Spotify on portrait monitor (top 20%)
- `Hyper + 6` → Productivity layout
  - Spotify (top 20%)
  - Linear (middle third)
  - Slack (bottom 50%)
- `Hyper + 5` → Monitoring layout
  - Activity Monitor (top 30%)
  - Console (bottom 70%)
- `Hyper + 4` → Communication layout
  - Slack (top third)
  - Messages (middle third)
  - Discord (bottom third)

## Spotify Controls
- `Hyper + \` → Display current track
- `Hyper + PageUp` → Volume up
- `Hyper + PageDown` → Volume down

## System Controls
- `Hyper + 0` → Reload Hammerspoon config

## Notes

1. **Portrait Monitor Detection**: The config automatically detects portrait monitors (height > width) and applies layouts accordingly
2. **Auto-Spotify**: Spotify automatically positions to the portrait monitor when launched
3. **USB Device Detection**: Automatically switches Karabiner profiles when Razer keyboard is connected/disconnected
4. **Modular Configuration**: The config is split into focused modules for easier maintenance:
   - `init.lua` - Main loader
   - `window-management.lua` - Window positioning
   - `app-launcher.lua` - Application hotkeys
   - `portrait-layouts.lua` - Portrait monitor support
   - `spotify-controls.lua` - Media controls
   - `deep-work.lua` - Focus timer (currently no hotkeys bound)
   - `device-watchers.lua` - USB monitoring