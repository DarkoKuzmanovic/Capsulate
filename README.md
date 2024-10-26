# Capsulate

Capsulate 0.5.0 is an AutoHotkey script that enhances the functionality of the Caps Lock key on Windows systems. It allows users to repurpose the Caps Lock key for various custom actions while still maintaining the ability to toggle caps lock.

## Overview

Capsulate transforms the Caps Lock key into a powerful modifier key, enabling quick access to volume controls, window management, text expansion, a Pomodoro timer, and custom actions. The script is designed to be user-friendly and customizable through a configuration file and GUI. Additionally, Capsulate now includes an auto-update feature to keep your script up-to-date effortlessly.

## Features

- **Repurpose Caps Lock for Custom Actions**

  - Use Caps Lock as a modifier key for various shortcuts.

- **Double-Click Caps Lock for Configurable Actions**

  - Perform a specific action (e.g., `Win+F5`) when Caps Lock is double-clicked.

- **Use Caps Lock + Arrow Keys for Volume and Window Management**

  - `Caps Lock + Up/Down`: Controls volume.
  - `Caps Lock + Left/Right`: Window management (default: `Win + Ctrl + Left/Right`).
  - `Caps Lock + Delete`: Mutes volume.

- **Text Expansion**

  - Expand predefined abbreviations into full text snippets.
  - Easily add, update, or delete text expansions via the configuration GUI.

- **Pomodoro Timer**

  - Toggle a 25-minute Pomodoro timer using a hotkey.
  - Visual countdown displayed via a tooltip.

- **Auto-Update from GitHub**

  - Automatically checks for updates and notifies you when a new version is available.
  - Seamlessly downloads and installs updates without losing your configuration.

- **Customization**

  - Fully customizable timeout and action settings.
  - Add custom shortcuts to launch applications or perform actions.

- **Automatic Light/Dark Mode Icon Switching**

  - Tray icon adapts to your Windows theme (light or dark mode).

- **Configuration GUI**
  - User-friendly interface to customize settings and manage shortcuts.
  - Multiple tabs for General settings, Text Expander, and Shortcuts.

## Key Functions

### Main Script (`Capsulate.ahk`)

1. **`LoadConfiguration()`**

   - Loads user settings from the `config.ini` file.

2. **`SetTrayIcon()`**

   - Sets the appropriate tray icon based on the Windows theme.

3. **`ShowUnifiedConfigGUI()`**

   - Displays the configuration GUI for easy customization of settings, text expansions, and shortcuts.

4. **`CheckLatestVersion()`**

   - Checks GitHub for the latest release version of Capsulate.

5. **`CheckForUpdates(*)`**

   - Handles the update flow, prompting the user and initiating the update process if a new version is available.

6. **`UpdateScript()`**

   - Downloads the latest version from GitHub and replaces the current script.

7. **`ExpandText()`**

   - Expands selected text based on predefined abbreviations.

8. **`TogglePomodoro()` & `PomodoroTick()`**

   - Manages the Pomodoro timer functionality.

9. **`GeneratePassword()`**

   - Generates a secure password and copies it to the clipboard.

10. **`RestartXMouseButtonControl()`**
    - Restarts the `XMouseButtonControl` application.

### Hotkeys

- **Basic Hotkeys**

  - `Caps Lock`: Acts as a modifier key when held down.
  - `Caps Lock` (double-click): Performs a custom action (default: `Win+F5`).
  - `Ctrl + Caps Lock`: Toggles the traditional Caps Lock functionality.

- **Modifier + Other Keys**

  - `Caps Lock + Up/Down`: Controls volume.
  - `Caps Lock + Delete`: Mutes volume.
  - `Caps Lock + Left/Right`: Window management (`Win + Ctrl + Left/Right`).

- **Text Expansion and Variables**

  - `[`: Copies selected text to `trackingCode`.
  - `]`: Copies selected text to `orderNumber`.

- **Configuration and Toggles**

  - `!c`: Opens the configuration GUI.
  - `Esc`: Toggles the Pomodoro timer.

- **Media Controls**

  - `Up`: Sends `{Volume_Up}`.
  - `Down`: Sends `{Volume_Down}`.
  - `Delete`: Sends `{Volume_Mute}`.

- **Window and System Controls**
  - `Left`: Sends `Win + Ctrl + Left`.
  - `Right`: Sends `Win + Ctrl + Right`.
  - `T`: Runs Task Manager.
  - `W`: Opens Windows Update settings.
  - `C`: Runs Disk Cleanup as administrator.
  - `X`: Restarts `XMouseButtonControl`.
  - `E`: Expands selected text.
  - `P`: Generates a secure password.
  - `K`: Initiates a chord-based action.

## Configuration

Users can customize Capsulate's behavior through the `config.ini` file or the configuration GUI. The following settings are available:

### General Settings

- **`CapsLockTimeout`**: Time threshold for double-click detection (in milliseconds).
- **`DoubleClickCount`**: Number of clicks required for the double-click action.
- **`ToolTipPosition`**: Position of tooltips (`1` for Near Mouse, `0` for Near Tray).
- **`DoubleClickAction`**: Action performed on Caps Lock double-click (e.g., `{LWin down}{F5}{LWin up}`).

### Text Expander

- **Abbreviations and Expansions**: Define custom abbreviations and their corresponding expanded text in `expansions.ini` or through the GUI.

### Shortcuts

- **Custom Shortcuts**: Assign number keys (`0-9`) to launch specific executables or folders via the `config.ini` or the GUI.

## Usage

1. **Prerequisites**

   - Ensure AutoHotkey v2.0 or later is installed on your system.

2. **Running the Script**

   - Double-click `Capsulate.ahk` to run the script.
   - An icon will appear in the system tray indicating Capsulate is active.

3. **Using Caps Lock as a Modifier**

   - Hold down the Caps Lock key and press other keys to perform custom actions (e.g., `Caps Lock + Up` to increase volume).

4. **Accessing the Configuration GUI**

   - Press `Ctrl + Alt + C` or right-click the tray icon and select "Configuration" to open the GUI for customization.

5. **Managing Text Expansions**

   - Open the configuration GUI and navigate to the "Text Expander" tab to add, update, or delete abbreviations.

6. **Using the Pomodoro Timer**

   - Press `Esc` to toggle the Pomodoro timer. A 25-minute countdown will start, displayed via a tooltip.

7. **Auto-Updates**
   - Capsulate will automatically check for updates upon startup and notify you if a new version is available.
   - Alternatively, select "Check for Updates" from the tray menu to manually initiate an update check.

## Customization

To customize Capsulate:

1. **Using the Configuration GUI**

   - Right-click the tray icon and select "Configuration" or press `Ctrl + Alt + C`.
   - Modify settings across the "General," "Text Expander," and "Shortcuts" tabs.
   - Click "Save" to apply changes or "Cancel" to discard.

2. **Editing Configuration Files**
   - **`config.ini`**: Directly edit general settings and shortcuts.
   - **`expansions.ini`**: Define text expansions by adding lines in the format `abbreviation=expansion`.

## Changelog

### v0.5.0

- **Added Auto-Update Feature**

  - Automatically checks GitHub for the latest release.
  - Downloads and installs updates seamlessly while preserving user configurations.

- **Implemented Text Expander**

  - Allows users to define abbreviations that expand into full text snippets.
  - Manage abbreviations via the configuration GUI or `expansions.ini`.

- **Introduced Pomodoro Timer**

  - Toggle a 25-minute Pomodoro timer to enhance productivity.
  - Visual countdown displayed through tooltips.

- **Enhanced Configuration GUI**

  - Added multiple tabs for better organization of settings.
  - Improved user interface with Segoe UI font and enhanced layout.

- **Additional Shortcuts and Actions**

  - Added hotkeys for launching Task Manager, Windows Update settings, and Disk Cleanup.
  - Enhanced window management shortcuts.

- **Bug Fixes and Performance Improvements**
  - Resolved issues with JSON parsing for the auto-update feature.
  - Improved stability and responsiveness of the script.

### v0.3.0

- **Initial Release**
  - Repurposed Caps Lock for custom actions.
  - Double-click Caps Lock for configurable actions.
  - Volume and window management via Caps Lock + arrow keys.
  - Configuration GUI for general settings.
  - Automatic light/dark mode icon switching.
  - Text expansion capabilities (planned for future releases).

## TODO

- Add more useful shortcuts.
- Implement an EXE file that runs without AutoHotkey installed.
- Enhance auto-update security and reliability.
- Expand text expander functionality with more advanced features.

## Notes

Capsulate requires AutoHotkey v2.0 or later to function properly. Make sure you have the correct version installed before running the script.

## License

Capsulate is released under the MIT License. See the [LICENSE](LICENSE.md) file for details.
