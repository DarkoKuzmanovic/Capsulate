# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Capsulate is an AutoHotkey v2 script that enhances the functionality of the Caps Lock key on Windows systems. The script repurposes Caps Lock as a powerful modifier key for various shortcuts while maintaining caps lock toggle functionality.

## Key Architecture

### Core Components

- **Main Script (`Capsulate.ahk`)**: Single-file AutoHotkey v2 script containing all functionality
- **Configuration System**: INI-based configuration with `config.ini` for settings and `expansions.ini` for text expansions
- **Global State Management**: Uses `CACHED_CONFIG` global variable for configuration caching
- **Tray Integration**: System tray icon with context menu for management

### Key Functions and Structure

1. **Configuration Management**
   - `LoadConfiguration()`: Loads settings from config.ini with error handling
   - `CreateDefaultConfig()`: Creates default configuration file if missing
   - Configuration cached in global `CACHED_CONFIG` Map object

2. **Caps Lock State Machine**
   - Uses global variables: `capsLockPressed`, `waitingForChord`, `capsLockTimer`, `capsLockCount`
   - Implements double-click detection with configurable timeout
   - Chord mode for multi-key combinations (CapsLock+K then second key)

3. **GUI System**
   - `ShowUnifiedConfigGUI()`: Tabbed configuration interface
   - Dynamic expansion list management
   - Real-time configuration updates

4. **Text Processing**
   - `GetSelectedText()`: Clipboard-based text selection with throttling
   - `ExpandText()`: Text expansion system using word-at-cursor detection
   - Case conversion utilities (camel, title, upper, lower, trim)

## Development Commands

Since this is an AutoHotkey script, there are no traditional build commands. Development workflow:

- **Run Script**: Double-click `Capsulate.ahk` or run via AutoHotkey
- **Reload Script**: Use tray menu "Restart Script" or CapsLock+Alt+R
- **Configuration**: Use tray menu "Configuration" or CapsLock+Alt+C
- **Testing**: Manual testing through the configured hotkeys

## Configuration Files

### config.ini Structure
```ini
[General]
CapsLockTimeout=300          # Milliseconds for double-click detection
DoubleClickCount=2          # Number of clicks for double-click action
ToolTipPosition=0           # 0=Near Tray, 1=Near Mouse
DoubleClickAction={Esc}     # Action on double-click

[Shortcuts]
1=C:\                      # CapsLock+1 launches this path
2=D:\                      # CapsLock+2 launches this path
# ... numbered shortcuts 0-9
```

### expansions.ini Structure
```ini
[Expansions]
abbreviation=expansion text
```

## Key Hotkey Mappings

### Primary Hotkeys (CapsLock + Key)
- **Arrow Keys**: Volume (Up/Down), Window management (Left/Right)
- **Numbers 0-9**: Launch custom shortcuts from config
- **Letters**: Various utilities (E=Expand, P=Password, T=TaskMgr, etc.)
- **Special**: Alt+C (Config), Alt+R (Reload), K (Chord mode)

### Chord Mode (CapsLock+K then...)
- L: Convert to lowercase
- U: Convert to uppercase  
- C: Convert to camelCase
- T: Convert to Title Case
- Space: Trim whitespace

## Error Handling Patterns

The script implements comprehensive error handling:
- Try-catch blocks for file operations
- Clipboard operation throttling to prevent conflicts
- Network error handling for update checks
- Configuration validation with fallbacks

## Update System

- Auto-update functionality via GitHub API
- Version checking against GitHub releases
- Batch file-based update mechanism
- Preserves user configuration during updates

## Development Notes

- Requires AutoHotkey v2.0+ (`#Requires AutoHotkey v2.0`)
- Single instance enforcement (`#SingleInstance Force`)
- Uses modern AutoHotkey v2 syntax (Map objects, arrow functions)
- No external dependencies beyond AutoHotkey runtime