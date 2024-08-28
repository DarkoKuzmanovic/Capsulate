# Capsulate

Capsulate 0.3.0 is an AutoHotkey script that enhances the functionality of the Caps Lock key on Windows systems. It allows users to repurpose the Caps Lock key for various custom actions while still maintaining the ability to toggle caps lock.

## Overview

Capsulate transforms the Caps Lock key into a powerful modifier key, enabling quick access to volume controls, window management, and custom actions. The script is designed to be user-friendly and customizable through a configuration file and GUI.

## Features

- Repurpose Caps Lock for custom actions
- Double-click Caps Lock for a configurable action
- Use Caps Lock + arrow keys for volume and window management
- Customizable timeout and action settings
- Automatic light/dark mode icon switching
- Configuration GUI for easy customization

## Files

- `Capsulate.ahk`: The main AutoHotkey script
- `config.ini`: Configuration file for user settings
- `expansions.ini`: Configuration file for text expander
- `capsulate-light.png`: Tray icon for light mode
- `capsulate-dark.png`: Tray icon for dark mode

## Key Functions

### Main Script (Capsulate.ahk)

1. `LoadConfiguration()`: Loads user settings from the config.ini file
2. `SetTrayIcon()`: Sets the appropriate tray icon based on Windows theme
3. `ShowConfigGUI()`: Displays the configuration GUI for easy customization
4. `SaveConfig()`: Saves user configuration changes

### Hotkeys

- `Caps Lock`: Acts as a modifier key when held down
- `Caps Lock` (double-click): Performs a custom action (default: Win+F5)
- `Ctrl + Caps Lock`: Toggles the traditional Caps Lock functionality
- `Caps Lock + Up/Down`: Controls volume
- `Caps Lock + Delete`: Mutes volume
- `Caps Lock + Left/Right`: Window management (default: Win+Ctrl+Left/Right)

## Configuration

Users can customize Capsulate's behavior through the `config.ini` file or the configuration GUI. The following settings are available:

- `CapsLockTimeout`: Time threshold for double-click detection (in milliseconds)
- `DoubleClickCount`: Number of clicks required for double-click action
- `DoubleClickAction`: Action performed on Caps Lock double-click
- Various key combination actions (Up, Down, Delete, Left, Right)

## Usage

1. Ensure AutoHotkey v2.0 or later is installed on your system
2. Run the `Capsulate.ahk` script
3. Use Caps Lock as a modifier key for quick actions
4. Access the configuration GUI through the tray icon or by pressing Ctrl+Alt+C

## Customization

To customize Capsulate:

1. Right-click the tray icon and select "Configuration"
2. Modify settings in the GUI
3. Click "Save" to apply changes

Alternatively, you can directly edit the `config.ini` file in the script directory.

## TODO

- Add more useful shortcuts
- Implement autoexpander functionality to expand selected text
- EXE file that runs without AutoHotkey installed

## Notes

Capsulate requires AutoHotkey v2.0 or later to function properly. Make sure you have the correct version installed before running the script.

## License

Capsulate is released under the MIT License. See the [LICENSE](LICENSE.md) file for details.
