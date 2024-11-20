# Capsulate

Capsulate 0.7.0 is an AutoHotkey script that enhances the functionality of the Caps Lock key on Windows systems. It allows users to repurpose the Caps Lock key for various custom actions while still maintaining the ability to toggle caps lock.

## Overview

Capsulate transforms the Caps Lock key into a powerful modifier key, enabling quick access to volume controls, window management, text expansion, and custom actions. The script is designed to be user-friendly and customizable through a configuration file and GUI. Additionally, Capsulate includes an auto-update feature to keep your script up-to-date effortlessly.

## Features

- **Repurpose Caps Lock for Custom Actions**
  - Use Caps Lock as a modifier key for various shortcuts
  - Improved performance and reliability with better state management

- **Double-Click Caps Lock for Configurable Actions**
  - Perform a specific action when Caps Lock is double-clicked
  - Default action is now `{Esc}` for quick escape key access

- **Use Caps Lock + Arrow Keys for Volume and Window Management**
  - `Caps Lock + Up/Down`: Controls volume
  - `Caps Lock + Left/Right`: Window management (default: `Win + Ctrl + Left/Right`)
  - `Caps Lock + Delete`: Mutes volume

- **Text Expansion**
  - Expand predefined abbreviations into full text snippets
  - Enhanced clipboard handling with performance optimizations
  - Improved error handling for more reliable text expansion

- **Auto-Update from GitHub**
  - Automatically checks for updates and notifies you when a new version is available
  - Seamlessly downloads and installs updates without losing your configuration
  - Added error handling for network-related issues

- **Customization**
  - Fully customizable timeout and action settings
  - Add custom shortcuts to launch applications or perform actions
  - Enhanced configuration system with better state management

- **Automatic Light/Dark Mode Icon Switching**
  - Tray icon adapts to your Windows theme (light or dark mode)

- **Configuration GUI**
  - User-friendly interface to customize settings and manage shortcuts
  - Multiple tabs for General settings and Text Expander
  - Improved reliability with better error handling

## Technical Improvements in v0.7.0

- **Enhanced Configuration Management**
  - Implemented global `CACHED_CONFIG` for better state management
  - Improved configuration loading with proper error handling
  - Fixed initialization issues with configuration values

- **Performance Optimizations**
  - Added clipboard operation throttling to prevent rapid successive operations
  - Improved text expansion performance
  - Better memory management with proper variable scoping

- **Error Handling**
  - Added comprehensive error handling for configuration loading
  - Improved error messages for better troubleshooting
  - Added safeguards against common failure points

## Key Functions

### Main Script (`Capsulate.ahk`)

1. **`LoadConfiguration()`**
   - Loads user settings from the `config.ini` file
   - Returns a Map of configuration values
   - Includes error handling for file operations

2. **`SetTrayIcon()`**
   - Sets the appropriate tray icon based on the Windows theme
   - Automatically updates when theme changes

3. **`ShowUnifiedConfigGUI()`**
   - Displays the configuration GUI for easy customization
   - Uses cached configuration for better performance

4. **`GetSelectedText()`**
   - Enhanced clipboard handling with throttling
   - Improved error handling for clipboard operations

5. **`CheckLatestVersion()`**
   - Checks GitHub for the latest release version
   - Added error handling for network issues

### Configuration

The configuration system has been improved with the following settings:

- **`CapsLockTimeout`**: Delay in milliseconds for Caps Lock actions (default: 300)
- **`DoubleClickCount`**: Number of clicks needed for double-click action (default: 2)
- **`ToolTipPosition`**: Position of tooltips (0: Near Tray, 1: Near Mouse)
- **`DoubleClickAction`**: Action performed on Caps Lock double-click (default: `{Esc}`)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
