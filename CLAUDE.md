# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Capsulate v1.0.0 is an enterprise-grade AutoHotkey v2 script that transforms the Caps Lock key into a productivity powerhouse on Windows systems. The script features a modular class-based architecture with comprehensive error handling, security validation, and performance optimizations.

## Key Architecture (v1.0.0)

### Core Components

- **Main Script (`Capsulate.ahk`)**: Single-file AutoHotkey v2 script with modular class-based architecture
- **Configuration System**: INI-based configuration with validation and security checks
- **Centralized Clipboard Manager**: Race condition prevention and operation throttling
- **Logging System**: Comprehensive logging with automatic file rotation
- **Theme Management**: Cached theme detection with performance optimization
- **Update System**: Secure auto-update with file verification

### Class Architecture

#### **ClipboardManager Class**
- **Purpose**: Centralized clipboard operations with mutex protection
- **Key Methods**: 
  - `SafeClipboardOperation()`: Thread-safe clipboard wrapper
  - `GetSelectedText()`, `GetWordAtCursor()`: Text retrieval
  - `ConvertSelectedText()`: Case conversion operations
- **Features**: Throttling (100ms), race condition prevention, error handling

#### **Logger Class**
- **Purpose**: Enterprise-grade logging with rotation
- **Key Methods**: `Info()`, `Error()`, `Warning()`, `Debug()`
- **Features**: 1MB log rotation, timestamp formatting, silent failure protection
- **File**: `capsulate.log` (auto-rotated to `.old`)

#### **ConfigValidator Class**
- **Purpose**: Input validation and security checks
- **Key Methods**: 
  - `Validate()`: Comprehensive config validation
  - `ValidateShortcutPath()`: Security validation for shortcuts
- **Features**: Range validation, dangerous command detection, auto-correction

#### **ThemeManager Class**
- **Purpose**: Cached Windows theme detection
- **Key Methods**: `IsDarkTheme()`, `GetIconPath()`
- **Features**: 30-second caching, registry optimization, fallback handling

#### **Constants Class**
- **Purpose**: Centralized configuration values
- **Features**: GitHub URLs, default values, timeout constants
- **Methods**: `GetGitHubApiUrl()`, `GetDownloadUrl()`

### Global State Management

```autohotkey
global CACHED_CONFIG := LoadConfiguration()
global capsLockPressed := false
global waitingForChord := false
global capsLockTimer := 0
global capsLockCount := 0
```

## Development Commands

Since this is an AutoHotkey script, there are no traditional build commands. Development workflow:

- **Run Script**: Double-click `Capsulate.ahk` or run via AutoHotkey
- **Reload Script**: Use tray menu "Restart Script" or CapsLock+Alt+R
- **Configuration**: Use tray menu "Configuration" or CapsLock+Alt+C
- **Testing**: Manual testing through the configured hotkeys
- **Debugging**: Check `capsulate.log` for detailed error information

## Configuration Files

### config.ini Structure
```ini
[General]
CapsLockTimeout=300          # Milliseconds for double-click detection (50-5000)
DoubleClickCount=2          # Number of clicks for double-click action (1-5)
ToolTipPosition=0           # 0=Near Tray, 1=Near Mouse
DoubleClickAction={Esc}     # Action on double-click (max 100 chars)

[Shortcuts]
1=C:\                      # CapsLock+1 launches this path
2=D:\                      # CapsLock+2 launches this path
0=D:\source\repos          # CapsLock+0 launches repos folder
# ... numbered shortcuts 0-9 (security validated)
```

### expansions.ini Structure
```ini
[Expansions]
btw=by the way
omg=oh my god
email=your.email@example.com
sig=Best regards,\nYour Name
```

## Complete Hotkey Reference

### Core Controls
- **Double-Click Caps Lock**: Configurable action (default: Esc)
- **Ctrl + Caps Lock**: Toggle Caps Lock state

### Media & Volume
- **CapsLock + Up/Down**: Volume control
- **CapsLock + BackSpace**: Volume mute

### Window Management
- **CapsLock + Left/Right**: Virtual desktop switching
- **CapsLock + Shift + Left/Right**: Move window between monitors
- **CapsLock + Space**: PowerToys Run (if installed)

### Text Processing
- **CapsLock + E**: Expand text abbreviation
- **CapsLock + K, L**: Convert selected text to lowercase
- **CapsLock + K, U**: Convert selected text to UPPERCASE
- **CapsLock + K, C**: Convert selected text to camelCase
- **CapsLock + K, T**: Convert selected text to Title Case
- **CapsLock + K, Space**: Trim whitespace from selected text

### Utilities
- **CapsLock + P**: Generate secure 16-character password
- **CapsLock + T**: Task Manager
- **CapsLock + W**: Windows Update settings
- **CapsLock + C**: Color picker
- **CapsLock + Delete**: Disk Cleanup (admin privileges)
- **CapsLock + X**: Restart XMouseButtonControl

### Configuration & Management
- **CapsLock + Alt + C**: Configuration GUI
- **CapsLock + Alt + R**: Reload script

### Custom Shortcuts
- **CapsLock + 0-9**: Launch custom applications/paths

## Error Handling Patterns (v1.0.0)

### Comprehensive Error Management
```autohotkey
try {
    // Operation
    Logger.Info("Operation successful")
} catch Error as err {
    Logger.Error("Operation failed: " . err.Message)
    ShowTooltip("User-friendly error message")
}
```

### Key Error Handling Features
- **Try-catch blocks**: All critical operations wrapped
- **Logging integration**: All errors logged with context
- **User feedback**: Tooltip notifications for user errors
- **Graceful degradation**: Fallbacks for failed operations
- **Security validation**: Input sanitization and validation
- **Clipboard protection**: Mutex-based operation safety

## Security Features (v1.0.0)

### Input Validation
- **Configuration ranges**: All numeric values validated (e.g., timeout 50-5000ms)
- **String length limits**: Maximum lengths enforced
- **Dangerous command detection**: Prevents execution of harmful shortcuts
- **Path validation**: Security checks for custom shortcuts

### Dangerous Commands Blocked
- `format`, `del`, `rm`, `rmdir`, `rd` and other destructive commands
- Validation applied to all user-defined shortcuts

## Performance Optimizations (v1.0.0)

### Clipboard Management
- **Mutex protection**: Prevents race conditions
- **Operation throttling**: 100ms minimum between operations
- **Efficient restoration**: Proper clipboard state management

### Theme Detection
- **Caching**: 30-second cache for registry reads
- **Reduced frequency**: Tray icon updates every 30 seconds (was 5 seconds)
- **Fallback handling**: Graceful degradation if registry unavailable

### Memory Management
- **Static variables**: Proper scoping to prevent memory leaks
- **Object cleanup**: Automatic cleanup of temporary objects
- **Log rotation**: Prevents unlimited log file growth

## Update System (v1.0.0)

### GitHub Integration
- **API endpoint**: `https://api.github.com/repos/DarkoKuzmanovic/Capsulate/releases/latest`
- **Download URL**: `https://github.com/DarkoKuzmanovic/Capsulate/releases/latest/download/Capsulate.ahk`
- **Version comparison**: Proper semantic version comparison
- **File verification**: Size and integrity checks

### Update Process
1. **Check**: Compare current vs latest version using semantic comparison
2. **Download**: Secure download with timeout handling
3. **Verify**: File size and integrity validation
4. **Update**: Batch script for safe replacement
5. **Preserve**: Configuration files maintained during update

## Logging System (v1.0.0)

### Log Levels
- **INFO**: Normal operations and successful actions
- **WARNING**: Non-critical issues and validation failures
- **ERROR**: Critical errors and failures
- **DEBUG**: Detailed debugging information

### Log Format
```
[2025-07-04 23:03:01] INFO: Configuration loaded successfully
[2025-07-04 23:03:01] ERROR: Error checking for updates: Network timeout
```

### Log Management
- **File**: `capsulate.log` in script directory
- **Rotation**: Automatic rotation at 1MB to `.old` file
- **Performance**: Silent failure to prevent logging errors from crashing

## Development Notes (v1.0.0)

### Requirements
- **AutoHotkey v2.0+**: Required (`#Requires AutoHotkey v2.0`)
- **Windows 10/11**: Target platform
- **Administrator privileges**: Optional (required for some features)

### Code Standards
- **Single instance**: `#SingleInstance Force`
- **Modern syntax**: AutoHotkey v2 features (Map objects, proper class syntax)
- **Error handling**: Comprehensive try-catch throughout
- **Logging**: All significant operations logged
- **Validation**: All user input validated
- **Security**: Dangerous operations prevented

### Architecture Benefits
- **Maintainability**: Clear class separation and modular design
- **Reliability**: Comprehensive error handling and validation
- **Performance**: Optimized operations and caching
- **Security**: Input validation and dangerous command prevention
- **Debuggability**: Detailed logging and error reporting

### Helper Functions
Located after class definitions:
- `ClipboardManager_GetSelectedTextOperation()`
- `ClipboardManager_GetWordAtCursorOperation()`
- `ClipboardManager_SetClipboardTextOperation(text)`
- `ClipboardManager_ConvertSelectedTextOperation(converter)`

These functions work with `Func()` references to avoid AutoHotkey v2 fat arrow function limitations.

## Common Development Tasks

### Adding New Features
1. **Design**: Plan class structure and error handling
2. **Implement**: Add to appropriate class or create new class
3. **Validate**: Add input validation in ConfigValidator
4. **Log**: Add appropriate logging statements
5. **Test**: Manual testing with error scenarios
6. **Document**: Update CLAUDE.md and README.md

### Debugging Issues
1. **Check logs**: Review `capsulate.log` for errors
2. **Enable debug**: Add Logger.Debug() statements
3. **Test isolation**: Test individual components
4. **Validate config**: Check configuration values
5. **Monitor performance**: Watch for resource usage

### Security Considerations
- **Always validate** user input before execution
- **Use ConfigValidator** for all user-provided values
- **Log security events** for audit trails
- **Test with malicious input** to ensure protection
- **Update dangerous command list** as needed