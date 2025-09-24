# Repository Guidelines

## Project Structure & Module Organization
Capsulate ships as a single AutoHotkey v2 application with supporting assets:
- `Capsulate.ahk` hosts hotkey handlers, GUI widgets, logging, and configuration validation. Keep new modules in this file unless they justify breaking out into a separate include.
- `config.ini` stores user-adjustable settings. Default values are regenerated if the file is missing.
- `expansions.ini` maintains shorthand expansions shown in the configuration GUI.
- `capsulate-dark.png` and `capsulate-light.png` provide the tray icon variants; update both when changing artwork.
- `capsulate.log` records structured diagnostics and rotates automatically; review it when debugging.

## Build, Run, and Development Commands
Target AutoHotkey v2.0+. From the repo root:
- `"%ProgramFiles%\AutoHotkey\AutoHotkey64.exe" Capsulate.ahk` launches the script with live configuration.
- `"%ProgramFiles%\AutoHotkey\AutoHotkey64.exe" /ErrorStdOut Capsulate.ahk` surfaces runtime errors in the console; use while iterating.
- `Get-Content -Wait capsulate.log` tails the rotating log for background issues.
Avoid moving the script or assets while debugging; many paths rely on `A_ScriptDir`.

## Coding Style & Naming Conventions
Use four spaces for indentation and align inline blocks for readability. Prefer PascalCase for public functions, methods, and class names, and SCREAMING_SNAKE_CASE for constants (mirroring `Constants` and global defaults). Scope variables tightly and initialise them near first use. Use `;` comments to describe intent rather than mechanics, and keep GUI definitions and timer callbacks grouped logically.

## Testing Guidelines
There is no automated harness yet; perform focused manual checks before opening a PR. Validate double-click detection, modifier chords, GUI updates, and theme-aware tray icons on both light and dark Windows modes. Run with `/ErrorStdOut` and watch `capsulate.log` to confirm no warnings. When editing configuration logic, back up `config.ini`, trigger validation failures, and confirm corrected defaults are applied without crashes.

## Commit & Pull Request Guidelines
Recent history mixes ad-hoc subjects with conventional commits; please standardise on `type: summary` (e.g. `feat: add clipboard throttling toggle`). Keep bodies wrapped at 72 characters and reference GitHub issues where applicable. PRs should include a concise summary, testing notes, and screenshots for GUI tweaks. Call out any config or shortcut migrations and highlight manual steps reviewers must run.
