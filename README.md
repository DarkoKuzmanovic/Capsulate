# Capsulate

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0+-green.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

Capsulate 1.0.0 is a powerful AutoHotkey v2 script that transforms the Caps Lock key into a productivity powerhouse on Windows systems. It repurposes the underutilized Caps Lock key for custom actions while maintaining the ability to toggle caps lock when needed.

## 🌟 Overview

Capsulate transforms your Caps Lock key into a versatile modifier key, providing instant access to:
- 🔊 Volume and system controls
- 🪟 Advanced window management
- 📝 Smart text expansion and case conversion
- ⚡ Custom application shortcuts
- 🔧 System utilities and tools

The script features enterprise-grade reliability with comprehensive error handling, automatic updates, and a user-friendly configuration interface.

## ✨ Features

### 🎮 **Smart Caps Lock Control**
- **Modifier Key**: Use Caps Lock as a powerful modifier for shortcuts
- **Double-Click Actions**: Configurable double-click behavior (default: Esc key)
- **Traditional Toggle**: Ctrl+Caps Lock for normal caps lock functionality
- **Intelligent State Management**: Prevents conflicts and ensures reliable operation

### 🎵 **Media & System Controls**
- `Caps Lock + Up/Down`: Volume control
- `Caps Lock + BackSpace`: Volume mute
- `Caps Lock + T`: Task Manager
- `Caps Lock + W`: Windows Update settings
- `Caps Lock + Delete`: Disk Cleanup (with admin privileges)

### 🪟 **Window Management**
- `Caps Lock + Left/Right`: Virtual desktop switching
- `Caps Lock + Shift + Left/Right`: Move window between monitors
- `Caps Lock + Space`: PowerToys Run (if installed)
- `Caps Lock + C`: Color picker

### 📝 **Advanced Text Processing**
- **Text Expansion**: Convert abbreviations to full text
- **Case Conversion Chord**: `Caps Lock + K` then:
  - `L`: lowercase
  - `U`: UPPERCASE  
  - `C`: camelCase
  - `T`: Title Case
  - `Space`: Trim whitespace
- **Smart Clipboard Management**: Race condition prevention and throttling

### ⚡ **Quick Shortcuts**
- `Caps Lock + 0-9`: Launch custom applications/paths
- `Caps Lock + P`: Generate secure 16-character password
- `Caps Lock + E`: Expand text abbreviations
- `Caps Lock + X`: Restart XMouseButtonControl
- `Caps Lock + Alt + C`: Configuration GUI
- `Caps Lock + Alt + R`: Reload script

### 🎨 **User Experience**
- **Adaptive Theme**: Tray icon automatically switches between light/dark themes
- **Smart Tooltips**: Contextual feedback with configurable positioning
- **Configuration GUI**: Intuitive tabbed interface for settings management
- **Auto-Update**: Seamless updates from GitHub releases

## 🚀 What's New in v1.0.0

### 🛡️ **Enterprise-Grade Reliability**
- **Comprehensive Error Handling**: Bulletproof error management throughout
- **Advanced Logging**: Detailed logging with automatic file rotation
- **Configuration Validation**: Automatic validation and correction of settings
- **Security Enhancements**: Dangerous command detection for shortcuts

### ⚡ **Performance Optimizations**
- **Centralized Clipboard Manager**: Eliminates race conditions and conflicts
- **Throttled Operations**: Prevents rapid successive clipboard operations
- **Cached Theme Detection**: Reduced registry reads with 30-second caching
- **Optimized Update Intervals**: Better resource management

### 🏗️ **Modular Architecture**
- **Class-Based Design**: Clean, maintainable code structure
- **Constants Management**: Centralized configuration values
- **Theme Manager**: Intelligent theme detection and caching
- **Config Validator**: Robust input validation and sanitization

### 🔧 **Enhanced Configuration**
- **Semantic Version Comparison**: Proper version checking for updates
- **Input Validation**: All settings validated with safe fallbacks
- **Security Checks**: Prevents execution of dangerous commands
- **Backup & Recovery**: Configuration corruption protection

## 📋 **Complete Hotkey Reference**

### Core Controls
| Hotkey | Action |
|--------|--------|
| `Double-Click Caps Lock` | Configurable action (default: Esc) |
| `Ctrl + Caps Lock` | Toggle Caps Lock state |

### Media & Volume
| Hotkey | Action |
|--------|--------|
| `Caps Lock + Up` | Volume Up |
| `Caps Lock + Down` | Volume Down |
| `Caps Lock + BackSpace` | Volume Mute |

### Window Management
| Hotkey | Action |
|--------|--------|
| `Caps Lock + Left` | Switch to left virtual desktop |
| `Caps Lock + Right` | Switch to right virtual desktop |
| `Caps Lock + Shift + Left` | Move window to left monitor |
| `Caps Lock + Shift + Right` | Move window to right monitor |

### Text Processing
| Hotkey | Action |
|--------|--------|
| `Caps Lock + E` | Expand text abbreviation |
| `Caps Lock + K, L` | Convert selected text to lowercase |
| `Caps Lock + K, U` | Convert selected text to UPPERCASE |
| `Caps Lock + K, C` | Convert selected text to camelCase |
| `Caps Lock + K, T` | Convert selected text to Title Case |
| `Caps Lock + K, Space` | Trim whitespace from selected text |

### Utilities
| Hotkey | Action |
|--------|--------|
| `Caps Lock + P` | Generate secure password |
| `Caps Lock + T` | Open Task Manager |
| `Caps Lock + W` | Open Windows Update |
| `Caps Lock + C` | Color picker |
| `Caps Lock + Delete` | Disk Cleanup (admin) |
| `Caps Lock + X` | Restart XMouseButtonControl |

### Configuration & Management
| Hotkey | Action |
|--------|--------|
| `Caps Lock + Alt + C` | Open Configuration GUI |
| `Caps Lock + Alt + R` | Reload Script |

### Custom Shortcuts
| Hotkey | Action |
|--------|--------|
| `Caps Lock + 0-9` | Launch custom application/path |

## ⚙️ Configuration

### Settings File (`config.ini`)
```ini
[General]
CapsLockTimeout=300           # Double-click timeout (50-5000ms)
DoubleClickCount=2           # Clicks needed for double-click (1-5)
ToolTipPosition=1            # 0: Near tray, 1: Near mouse
DoubleClickAction={Esc}      # Action on double-click

[Shortcuts]
1=C:\                        # Caps Lock + 1 launches C:\
2=D:\                        # Caps Lock + 2 launches D:\
0=D:\source\repos           # Caps Lock + 0 launches repos folder
```

### Text Expansions (`expansions.ini`)
```ini
[Expansions]
btw=by the way
omg=oh my god
email=your.email@example.com
sig=Best regards,\nYour Name
```

### Configuration GUI
Access the intuitive configuration interface with `Caps Lock + Alt + C`:
- **General Tab**: Core settings and timeout configuration
- **Text Expander Tab**: Manage abbreviations and expansions
- Real-time validation and error checking

## 📥 Installation

1. **Download** the latest `Capsulate.ahk` from [Releases](https://github.com/DarkoKuzmanovic/Capsulate/releases)
2. **Install** [AutoHotkey v2.0+](https://www.autohotkey.com/download/)
3. **Run** `Capsulate.ahk` (double-click or run from command line)
4. **Configure** using the tray menu or `Caps Lock + Alt + C`

### Auto-Start (Optional)
Enable "Run at Startup" from the tray menu to launch Capsulate automatically when Windows starts.

## 🔧 Requirements

- **Windows 10/11** (any edition)
- **AutoHotkey v2.0+** (required)
- **Administrator privileges** (for some features like Disk Cleanup)

## 📊 Advanced Features

### Logging & Debugging
- Comprehensive logging to `capsulate.log`
- Automatic log rotation at 1MB
- Error tracking and performance monitoring
- Debug information for troubleshooting

### Security
- Input validation for all configuration values
- Dangerous command detection for custom shortcuts
- Secure password generation with cryptographic randomness
- Protected update mechanism with file verification

### Performance
- Optimized clipboard operations with mutex protection
- Cached theme detection (30-second intervals)
- Throttled system calls to prevent conflicts
- Memory-efficient string operations

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

For major changes, please open an issue first to discuss your ideas.

### Development Guidelines
- Follow AutoHotkey v2 best practices
- Add comprehensive error handling
- Include logging for debugging
- Test thoroughly on different Windows versions
- Update documentation for new features

## 🐛 Troubleshooting

### Common Issues
- **Script won't start**: Ensure AutoHotkey v2.0+ is installed
- **Shortcuts not working**: Check for conflicting software
- **Update failures**: Verify internet connection and GitHub access
- **Configuration errors**: Use the GUI to reset to defaults

### Debug Information
Check `capsulate.log` for detailed error information and performance metrics.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

## 🙏 Acknowledgments

- AutoHotkey community for the amazing scripting language
- Contributors and beta testers
- Users providing feedback and feature requests

---

**Made with ❤️ by [Darko Kuzmanovic](https://github.com/DarkoKuzmanovic)**

*Transform your productivity with Capsulate - because your Caps Lock key deserves better!*