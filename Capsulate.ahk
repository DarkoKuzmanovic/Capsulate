#Requires AutoHotkey v2.0
#SingleInstance Force

; Initialize global variables
global CACHED_CONFIG := LoadConfiguration()
global chordMap := CACHED_CONFIG["Chords"]

ChordHandler() {
    key := A_ThisHotkey
    if (chordMap.Has(key)) {
        action := chordMap[key]
        parts := StrSplit(action, "|")
        if (parts.Length == 2) {
            func := parts[1]
            param := parts[2]
            if (func == "ConvertCase") {
                ConvertCase(param)
            } else {
                ShowTooltip("Unknown action: " . action)
            }
        } else {
            ShowTooltip("Invalid action format: " . action)
        }
    } else {
        ShowTooltip("No chord defined for: " . key)
    }
}

RegisterChordHotkeys() {
    global chordMap, registeredChordHotkeys

    HotIf(IsWaitingForChord)

    for key in registeredChordHotkeys {
        try {
            Hotkey(key, "Off")
        } catch as err {
            Logger.Warning("Failed to unregister chord hotkey '" . key . "': " . err.Message)
        }
    }
    registeredChordHotkeys := []

    for key, action in chordMap {
        chordKey := Trim(key . "")
        if (chordKey = "") {
            Logger.Warning("Skipping empty chord key in configuration")
            continue
        }
        try {
            Hotkey(chordKey, Func("ChordHandler"))
            registeredChordHotkeys.Push(chordKey)
        } catch as err {
            Logger.Error("Failed to register chord hotkey '" . chordKey . "': " . err.Message)
        }
    }

    HotIf()
}

IsWaitingForChord(*) {
    global waitingForChord
    return waitingForChord
}

global CAPS_LOCK_TIMEOUT := CACHED_CONFIG["CapsLockTimeout"]
global DOUBLE_CLICK_COUNT := CACHED_CONFIG["DoubleClickCount"]
global TOOLTIP_POSITION := CACHED_CONFIG["ToolTipPosition"]
global DOUBLE_CLICK_ACTION := CACHED_CONFIG["DoubleClickAction"]

global capsLockPressed := false
global waitingForChord := false
global registeredChordHotkeys := []
global capsLockTimer := 0
global capsLockCount := 0

RegisterChordHotkeys()

; Logger Class for Error Handling
class Logger {
    static logFile := A_ScriptDir . "\capsulate.log"
    static maxLogSize := 1024 * 1024 ; 1MB

    static Log(level, message) {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        logEntry := Format("[{1}] {2}: {3}`n", timestamp, level, message)

        try {
            ; Check log file size and rotate if necessary
            if (FileExist(Logger.logFile)) {
                logSize := FileGetSize(Logger.logFile)
                if (logSize > Logger.maxLogSize) {
                    FileMove Logger.logFile, Logger.logFile . ".old", 1
                }
            }

            FileAppend logEntry, Logger.logFile
        } catch {
            ; Silent fail for logging errors
        }
    }

    static Info(message) {
        Logger.Log("INFO", message)
    }

    static Error(message) {
        Logger.Log("ERROR", message)
    }

    static Warning(message) {
        Logger.Log("WARNING", message)
    }

    static Debug(message) {
        Logger.Log("DEBUG", message)
    }
}

; Configuration Validator Class
class ConfigValidator {
    static Validate(config) {
        errors := []
        correctedConfig := config.Clone()

        ; Validate CapsLockTimeout (50-5000ms)
        timeout := Integer(config["CapsLockTimeout"])
        if (timeout < 50 || timeout > 5000) {
            errors.Push("CapsLockTimeout must be between 50-5000ms")
            correctedConfig["CapsLockTimeout"] := 300
        }

        ; Validate DoubleClickCount (1-5)
        clickCount := Integer(config["DoubleClickCount"])
        if (clickCount < 1 || clickCount > 5) {
            errors.Push("DoubleClickCount must be between 1-5")
            correctedConfig["DoubleClickCount"] := 2
        }

        ; Validate ToolTipPosition (0 or 1)
        tooltipPos := Integer(config["ToolTipPosition"])
        if (tooltipPos != 0 && tooltipPos != 1) {
            errors.Push("ToolTipPosition must be 0 or 1")
            correctedConfig["ToolTipPosition"] := 1
        }

        ; Validate DoubleClickAction (basic validation)
        action := config["DoubleClickAction"]
        if (StrLen(action) > 100) {
            errors.Push("DoubleClickAction is too long (max 100 characters)")
            correctedConfig["DoubleClickAction"] := "{Esc}"
        }

        return {
            isValid: errors.Length == 0,
            errors: errors,
            correctedConfig: correctedConfig
        }
    }

    static ValidateShortcutPath(path) {
        if (path == "") {
            return true
        }

        ; Check for dangerous commands
        dangerousCommands := ["format", "del", "rm", "rmdir", "rd"]
        lowerPath := StrLower(path)

        for cmd in dangerousCommands {
            if (InStr(lowerPath, cmd)) {
                return false
            }
        }

        return true
    }
}

; Theme Manager Class
class ThemeManager {
    static cachedTheme := ""
    static lastCheck := 0
    static CACHE_DURATION := 30000 ; 30 seconds

    static IsDarkTheme() {
        currentTime := A_TickCount
        if (ThemeManager.cachedTheme == "" || currentTime - ThemeManager.lastCheck > ThemeManager.CACHE_DURATION) {
            try {
                regKey := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
                ThemeManager.cachedTheme := !RegRead(regKey, "AppsUseLightTheme")
                ThemeManager.lastCheck := currentTime
            } catch {
                ThemeManager.cachedTheme := false ; Default to light theme
            }
        }
        return ThemeManager.cachedTheme
    }

    static GetIconPath() {
        return ThemeManager.IsDarkTheme()
            ? A_ScriptDir . "\capsulate-dark.png"
            : A_ScriptDir . "\capsulate-light.png"
    }
}

; Constants Class
class Constants {
    static SCRIPT_VERSION := "1.0.3"
    static GITHUB_USER := "DarkoKuzmanovic"
    static GITHUB_REPO := "Capsulate"
    static DEFAULT_TIMEOUT := 300
    static DEFAULT_DOUBLE_CLICK_COUNT := 2
    static DEFAULT_TOOLTIP_POSITION := 1
    static DEFAULT_DOUBLE_CLICK_ACTION := "{Esc}"
    static MAX_LOG_SIZE := 1024 * 1024 ; 1MB
    static CLIPBOARD_THROTTLE_MS := 100
    static THEME_CACHE_DURATION := 30000 ; 30 seconds
    static TRAY_ICON_UPDATE_INTERVAL := 30000 ; 30 seconds

    static GetGitHubApiUrl() {
        return "https://api.github.com/repos/" . Constants.GITHUB_USER . "/" . Constants.GITHUB_REPO . "/releases/latest"
    }

    static GetDownloadUrl() {
        return "https://github.com/" . Constants.GITHUB_USER . "/" . Constants.GITHUB_REPO . "/releases/latest/download/Capsulate.ahk"
    }
}

; Clipboard Manager Class
class ClipboardManager {
    static mutex := false
    static lastOperation := 0
    static THROTTLE_MS := 100

    static SafeClipboardOperation(operation) {
        ; Wait for mutex release
        while (ClipboardManager.mutex) {
            Sleep 10
        }

        ; Acquire mutex
        ClipboardManager.mutex := true

        try {
            ; Throttle operations
            currentTime := A_TickCount
            if (currentTime - ClipboardManager.lastOperation < ClipboardManager.THROTTLE_MS) {
                Sleep ClipboardManager.THROTTLE_MS - (currentTime - ClipboardManager.lastOperation)
            }

            result := operation.Call()
            ClipboardManager.lastOperation := A_TickCount
            return result
        } finally {
            ClipboardManager.mutex := false
        }
    }

    static GetSelectedText() {
        operation := Func("ClipboardManager_GetSelectedTextOperation")
        return ClipboardManager.SafeClipboardOperation(operation)
    }

    static GetWordAtCursor() {
        operation := Func("ClipboardManager_GetWordAtCursorOperation")
        return ClipboardManager.SafeClipboardOperation(operation)
    }

    static SetClipboardText(text) {
        operation := Func("ClipboardManager_SetClipboardTextOperation").Bind(text)
        return ClipboardManager.SafeClipboardOperation(operation)
    }

    static ConvertSelectedText(converter) {
        operation := Func("ClipboardManager_ConvertSelectedTextOperation").Bind(converter)
        return ClipboardManager.SafeClipboardOperation(operation)
    }
}

; Helper functions for ClipboardManager operations
ClipboardManager_GetSelectedTextOperation() {
    savedClipboard := ClipboardAll()
    try {
        A_Clipboard := ""
        Send "^c"
        if !ClipWait(1.0) {
            throw Error("Failed to get clipboard content")
        }
        selectedText := A_Clipboard
        return selectedText
    } finally {
        A_Clipboard := savedClipboard
    }
}

ClipboardManager_GetWordAtCursorOperation() {
    savedClipboard := ClipboardAll()
    try {
        A_Clipboard := ""
        SendInput "^{Left}^+{Right}^c"
        if !ClipWait(1.0) {
            throw Error("Failed to get word at cursor")
        }
        word := A_Clipboard
        return Trim(word)
    } finally {
        A_Clipboard := savedClipboard
    }
}

ClipboardManager_SetClipboardTextOperation(text) {
    A_Clipboard := text
    return true
}

ClipboardManager_ConvertSelectedTextOperation(converter) {
    savedClipboard := ClipboardAll()
    try {
        A_Clipboard := ""
        Send "^c"
        if !ClipWait(1.0) {
            throw Error("No text selected")
        }

        text := A_Clipboard
        if (text = "") {
            throw Error("Selected text is empty")
        }

        convertedText := converter.Call(text)
        if (convertedText != "") {
            A_Clipboard := convertedText
            Send "^v"
            Sleep 100
        }
        return convertedText
    } finally {
        A_Clipboard := savedClipboard
    }
}

try {
    SetCapsLockState "AlwaysOff"
    SetTrayIcon()
    Logger.Info("Capsulate v" . Constants.SCRIPT_VERSION . " started successfully")
} catch as err {
    Logger.Error("Error during startup: " . err.Message)
    MsgBox "Error during startup: " . err.Message
}

SetTrayIcon() {
    try {
        iconFile := ThemeManager.GetIconPath()
        TraySetIcon(iconFile)
    } catch as err {
        Logger.Error("Error setting tray icon: " . err.Message)
    }
}

A_IconTip := "Capsulate v" . Constants.SCRIPT_VERSION . " - Enhance Your Caps Lock"

trayMenu := A_TrayMenu
trayMenu.Delete()
trayMenu.Add("Capsulate v" . Constants.SCRIPT_VERSION, (*) => {})
trayMenu.Disable("Capsulate v" . Constants.SCRIPT_VERSION)
trayMenu.Add()
trayMenu.Add("Check for Updates", CheckForUpdates)
trayMenu.Add("Run at Startup", (*) => ToggleStartup())
trayMenu.Add()
trayMenu.Add("Configuration`tCapsLock+Alt+C", (*) => ShowUnifiedConfigGUI())
trayMenu.Add("Restart Script `tCapsLock+Alt+R", (*) => Reload())
trayMenu.Add("Exit", (*) => ExitApp())

SetTimer SetTrayIcon, 30000  ; Reduced frequency for better performance

try {
    if (CheckLatestVersion()) {
        ShowTooltip("A new version is available!")
    }
} catch as err {
    Logger.Error("Error during startup version check: " . err.Message)
}

*CapsLock:: {
    global capsLockPressed, capsLockTimer
    capsLockPressed := true
    capsLockTimer := A_TickCount
}

*CapsLock up:: {
    global capsLockPressed, capsLockTimer, capsLockCount, CAPS_LOCK_TIMEOUT, DOUBLE_CLICK_COUNT, DOUBLE_CLICK_ACTION

    capsLockPressed := false
    elapsedTime := A_TickCount - capsLockTimer

    if (elapsedTime < CAPS_LOCK_TIMEOUT) {
        capsLockCount++
        ; BUG FIX: Use comparison (==) instead of assignment (=)
        if (capsLockCount == DOUBLE_CLICK_COUNT) {
            SendInput DOUBLE_CLICK_ACTION
            capsLockCount := 0
        } else {
            SetTimer () => (capsLockCount := 0), -CAPS_LOCK_TIMEOUT
        }
    } else {
        capsLockCount := 1
    }
}
^CapsLock:: SetCapsLockState GetKeyState("CapsLock", "T") ? "AlwaysOff" : "AlwaysOn"

#HotIf capsLockPressed
+Left:: Send "#+{Left}"
+Right:: Send "#+{Right}"
1:: LaunchShortcut("1")
2:: LaunchShortcut("2")
3:: LaunchShortcut("3")
4:: LaunchShortcut("4")
5:: LaunchShortcut("5")
6:: LaunchShortcut("6")
7:: LaunchShortcut("7")
8:: LaunchShortcut("8")
9:: LaunchShortcut("9")
0:: LaunchShortcut("0")
!c:: ShowUnifiedConfigGUI()
!r:: Reload()
Up:: SendInput "{Volume_Up}"
Down:: SendInput "{Volume_Down}"
BackSpace:: SendInput "{Volume_Mute}"
Delete:: Run "*RunAs cleanmgr"
Left:: Send "#^{Left}"
Right:: Send "#^{Right}"
Space:: Send "^!{Space}"
T:: Run "taskmgr"
W:: Run "ms-settings:windowsupdate"
C:: Send "+#c"
X:: RestartXMouseButtonControl()
E:: ExpandText()
P:: GeneratePassword()
K:: {
    global waitingForChord
    waitingForChord := true
    ShowTooltip("Waiting for a second key of chord...")
    ; BUG FIX: Timer must also reset the waitingForChord state to avoid getting stuck
    SetTimer () => (waitingForChord := false, ToolTip()), -2000
}

GetSelectedText() {
    try {
        return ClipboardManager.GetSelectedText()
    } catch as err {
        Logger.Error("Error getting selected text: " . err.Message)
        ShowTooltip("Error getting selected text: " . err.Message)
        return ""
    }
}

LaunchShortcut(key) {
    try {
        path := IniRead(A_ScriptDir . "\config.ini", "Shortcuts", key, "")
        if (path != "") {
            if (ConfigValidator.ValidateShortcutPath(path)) {
                Run(path)
                Logger.Info("Launched shortcut " . key . ": " . path)
            } else {
                Logger.Warning("Blocked potentially dangerous shortcut: " . path)
                ShowTooltip("Shortcut blocked for security reasons")
            }
        }
    } catch as err {
        Logger.Error("Error launching shortcut " . key . ": " . err.Message)
        ShowTooltip("Error launching shortcut: " . err.Message)
    }
}

ExpandText() {
    try {
        word := GetWordAtCursor()
        if (word == "") {
            ShowTooltip("No word found at cursor")
            return
        }

        Logger.Debug("Expanding text: " . word)
        expansion := GetExpansion(word)
        if (expansion && expansion != "") {
            SendInput "{BackSpace " . StrLen(word) . "}"
            ; BUG FIX: Use {Text} mode to send expansion literally
            ; to avoid issues with special characters like +, ^, !, #
            SendInput "{Text}" . expansion
            ShowTooltip("Expanded: " . word . " → " . expansion)
            Logger.Info("Text expanded: " . word . " → " . expansion)
        } else {
            ShowTooltip("No expansion found for: " . word)
        }
    } catch as err {
        Logger.Error("Error expanding text: " . err.Message)
        ShowTooltip("Error expanding text: " . err.Message)
    }
}

GetWordAtCursor() {
    try {
        return ClipboardManager.GetWordAtCursor()
    } catch as err {
        Logger.Error("Error getting word at cursor: " . err.Message)
        ShowTooltip("Error getting word at cursor: " . err.Message)
        return ""
    }
}

GetExpansion(word) {
    try {
        expansionsFile := A_ScriptDir . "\expansions.ini"
        if (!FileExist(expansionsFile)) {
            Logger.Warning("Expansions file does not exist: " . expansionsFile)
            return ""
        }
        return IniRead(expansionsFile, "Expansions", word, "")
    } catch as err {
        Logger.Error("Error reading expansion: " . err.Message)
        return ""
    }
}

ShowUnifiedConfigGUI() {
    global CACHED_CONFIG

    configGui := Gui(, "Capsulate Configuration")
    configGui.SetFont("s9", "Segoe UI")

    tabs := configGui.Add("Tab3", "w400 h400", ["General", "Text Expander", "Chords"])

    tabs.UseTab(1)
    configGui.Add("Text", "x20 y40 w150", "Caps Lock Timeout:")
    timeoutEdit := configGui.Add("Edit", "x170 y40 w50", CACHED_CONFIG["CapsLockTimeout"])
    configGui.Add("Text", "x20 y70 w150", "Double Click Count:")
    doubleClickCountEdit := configGui.Add("Edit", "x170 y70 w50", CACHED_CONFIG["DoubleClickCount"])
    configGui.Add("Text", "x20 y100 w150", "Tooltip Position:")
    tooltipPositionDropdown := configGui.Add("DropDownList", "vTooltipPosition x170 y100 w100", ["Near Mouse",
        "Near Tray"])
    tooltipPositionDropdown.Choose(CACHED_CONFIG["ToolTipPosition"] ? "Near Mouse" : "Near Tray")
    configGui.Add("Text", "x20 y130 w150", "Double Click Action:")
    doubleClickActionEdit := configGui.Add("Edit", "x170 y130 w200", CACHED_CONFIG["DoubleClickAction"])

    tabs.UseTab(2)
    configGui.Add("Text", "x20 y40", "Abbreviation:")
    abbrevEdit := configGui.Add("Edit", "x20 y60 w100")
    configGui.Add("Text", "x20 y90", "Expansion:")
    expansionEdit := configGui.Add("Edit", "x20 y110 w200 h60")
    lv := configGui.Add("ListView", "x20 y180 w360 h150", ["Abbreviation", "Expansion"])
    PopulateExpansionsList(lv)
    configGui.Add("Button", "x20 y340 w100", "Add/Update").OnEvent("Click", (*) => SaveExpansion(abbrevEdit,
        expansionEdit, lv))
    configGui.Add("Button", "x130 y340 w100", "Delete").OnEvent("Click", (*) => DeleteExpansion(lv))

    tabs.UseTab(3)
    configGui.Add("Text", "x20 y40", "Key:")
    chordKeyEdit := configGui.Add("Edit", "x20 y60 w100")
    configGui.Add("Text", "x20 y90", "Action:")
    chordActionEdit := configGui.Add("Edit", "x20 y110 w200")
    chordLv := configGui.Add("ListView", "x20 y140 w360 h150", ["Key", "Action"])
    PopulateChordsList(chordLv)
    configGui.Add("Button", "x20 y300 w100", "Add/Update").OnEvent("Click", (*) => SaveChord(chordKeyEdit, chordActionEdit, chordLv))
    configGui.Add("Button", "x130 y300 w100", "Delete").OnEvent("Click", (*) => DeleteChord(chordLv))

    tabs.UseTab()
    configGui.Add("Button", "x20 y410 w100", "Save").OnEvent("Click", (*) => SaveUnifiedConfig(configGui, timeoutEdit,
        doubleClickCountEdit, tooltipPositionDropdown, doubleClickActionEdit))
    configGui.Add("Button", "x130 y410 w100", "Cancel").OnEvent("Click", (*) => configGui.Destroy())

    configGui.Show()
}

SaveUnifiedConfig(configGui, timeoutEdit, doubleClickCountEdit, tooltipPositionDropdown, doubleClickActionEdit) {
    global CACHED_CONFIG, CAPS_LOCK_TIMEOUT, DOUBLE_CLICK_COUNT, TOOLTIP_POSITION, DOUBLE_CLICK_ACTION

    ; Create config from GUI values for validation
    guiConfig := Map(
        "CapsLockTimeout", Integer(timeoutEdit.Value),
        "DoubleClickCount", Integer(doubleClickCountEdit.Value),
        "ToolTipPosition", tooltipPositionDropdown.Value = "Near Mouse" ? 1 : 0,
        "DoubleClickAction", doubleClickActionEdit.Value
    )

    ; Validate GUI edits before saving
    ValidationResult := ConfigValidator.Validate(guiConfig)
    if (!ValidationResult.isValid) {
        errorMessages := ""
        for error in ValidationResult.errors {
            errorMessages .= error . "`n"
        }
        errorMessages := Trim(errorMessages, "`n")
        MsgBox("Configuration validation failed:`n`n" . errorMessages . "`n`nPlease correct the values and try again.", "Validation Error", "OK")
        return
    }

    CACHED_CONFIG["CapsLockTimeout"] := guiConfig["CapsLockTimeout"]
    CACHED_CONFIG["DoubleClickCount"] := guiConfig["DoubleClickCount"]
    CACHED_CONFIG["ToolTipPosition"] := guiConfig["ToolTipPosition"]
    CACHED_CONFIG["DoubleClickAction"] := guiConfig["DoubleClickAction"]

    CAPS_LOCK_TIMEOUT := CACHED_CONFIG["CapsLockTimeout"]
    DOUBLE_CLICK_COUNT := CACHED_CONFIG["DoubleClickCount"]
    TOOLTIP_POSITION := CACHED_CONFIG["ToolTipPosition"]
    DOUBLE_CLICK_ACTION := CACHED_CONFIG["DoubleClickAction"]

    configFile := A_ScriptDir . "\config.ini"
    IniWrite(CACHED_CONFIG["CapsLockTimeout"], configFile, "General", "CapsLockTimeout")
    IniWrite(CACHED_CONFIG["DoubleClickCount"], configFile, "General", "DoubleClickCount")
    IniWrite(CACHED_CONFIG["ToolTipPosition"], configFile, "General", "ToolTipPosition")
    IniWrite(CACHED_CONFIG["DoubleClickAction"], configFile, "General", "DoubleClickAction")

    ; Save chords
    IniDelete(configFile, "Chords")
    for key, action in chordMap {
        IniWrite(action, configFile, "Chords", key)
    }

    ; BUG FIX: This loop was redundant as it reads and rewrites the same values.
    ; It has been removed.

    RegisterChordHotkeys()
    configGui.Destroy()
    ShowTooltip("Configuration saved successfully!")
}

PopulateExpansionsList(lv) {
    lv.Delete()
    expansionsFile := A_ScriptDir . "\expansions.ini"
    if (FileExist(expansionsFile)) {
        expansions := IniRead(expansionsFile, "Expansions")
        loop parse, expansions, "`n", "`r" {
            eqPos := InStr(A_LoopField, "=")
            if (eqPos > 0) {
                abbrev := SubStr(A_LoopField, 1, eqPos - 1)
                expansion := SubStr(A_LoopField, eqPos + 1)
                lv.Add("", abbrev, expansion)
            }
        }
    }
}

SaveExpansion(abbrevEdit, expansionEdit, lv) {
    abbrev := abbrevEdit.Value
    expansion := expansionEdit.Value
    if (abbrev != "" and expansion != "") {
        IniWrite(expansion, A_ScriptDir . "\expansions.ini", "Expansions", abbrev)
        PopulateExpansionsList(lv)
        MsgBox "Expansion saved successfully!"
    } else {
        MsgBox "Please enter both abbreviation and expansion."
    }
}

DeleteExpansion(lv) {
    if (row := lv.GetNext()) {
        IniDelete(A_ScriptDir . "\expansions.ini", "Expansions", lv.GetText(row, 1))
        lv.Delete(row)
    } else {
        MsgBox "Please select an expansion to delete."
    }
}

PopulateChordsList(lv) {
    lv.Delete()
    for key, action in chordMap {
        lv.Add("", key, action)
    }
}

SaveChord(keyEdit, actionEdit, lv) {
    key := keyEdit.Value
    action := actionEdit.Value
    if (key != "" and action != "") {
        chordMap[key] := action
        PopulateChordsList(lv)
        RegisterChordHotkeys()
        MsgBox "Chord saved successfully!"
    } else {
        MsgBox "Please enter both key and action."
    }
}

DeleteChord(lv) {
    if (row := lv.GetNext()) {
        key := lv.GetText(row, 1)
        chordMap.Delete(key)
        lv.Delete(row)
        RegisterChordHotkeys()
    } else {
        MsgBox "Please select a chord to delete."
    }
}

LoadConfiguration() {
    try {
        configFile := A_ScriptDir . "\config.ini"
        if !FileExist(configFile) {
            CreateDefaultConfig(configFile)
        }

        config := Map(
            "CapsLockTimeout", IniRead(configFile, "General", "CapsLockTimeout", 300),
            "DoubleClickCount", IniRead(configFile, "General", "DoubleClickCount", 2),
            "ToolTipPosition", IniRead(configFile, "General", "ToolTipPosition", 1),
            "DoubleClickAction", IniRead(configFile, "General", "DoubleClickAction", "{Esc}")
        )

        ; Load chords
        chords := Map(
            "L", "ConvertCase|lower",
            "U", "ConvertCase|upper",
            "C", "ConvertCase|camel",
            "T", "ConvertCase|title",
            "Space", "ConvertCase|trim"
        )
        try {
            chordData := IniRead(configFile, "Chords", , "")
            if (chordData != "") {
                loop parse, chordData, "`n", "`r" {
                    line := Trim(A_LoopField)
                    if (line = "" || SubStr(line, 1, 1) = ";")
                        continue
                    separatorPos := InStr(line, "=")
                    if (separatorPos = 0)
                        continue
                    key := Trim(SubStr(line, 1, separatorPos - 1))
                    action := Trim(SubStr(line, separatorPos + 1))
                    if (key != "" && action != "")
                        chords[key] := action
                }
            }
        } catch as err {
            Logger.Warning("Failed to load chords from configuration: " . err.Message)
        }
        config["Chords"] := chords

        ; Validate configuration
        ValidationResult := ConfigValidator.Validate(config)
        if (!ValidationResult.isValid) {
            errorMessages := ""
            for error in ValidationResult.errors {
                errorMessages .= error . "; "
            }
            errorMessages := Trim(errorMessages, "; ")
            Logger.Warning("Configuration validation failed: " . errorMessages)
            ShowTooltip("Configuration issues found. Check log for details.")
            ; Persist corrected values back to config file
            for key, value in ValidationResult.correctedConfig {
                IniWrite(value, configFile, "General", key)
            }
            ; Use corrected values
            config := ValidationResult.correctedConfig
        }

        Logger.Info("Configuration loaded successfully")
        return config
    } catch as err {
        Logger.Error("Error loading configuration: " . err.Message)
        MsgBox "Error loading configuration: " . err.Message
        ExitApp
    }
}

CreateDefaultConfig(configFile) {
    FileAppend "
    (
    [General]
    CapsLockTimeout=300
    DoubleClickCount=2
    ToolTipPosition=1
    DoubleClickAction={Esc}

    [Chords]
    L=ConvertCase|lower
    U=ConvertCase|upper
    C=ConvertCase|camel
    T=ConvertCase|title
    Space=ConvertCase|trim

    )",
        configFile
}

ShowTooltip(text) {
    static tooltipGui := 0
    maxWidth := 400  ; Maximum width in pixels

    if (!tooltipGui) {
        tooltipGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        tooltipGui.BackColor := "0x333333"
        tooltipGui.Opt("+E0x20")
        tooltipGui.MarginX := 12
        tooltipGui.MarginY := 12
        tooltipGui.SetFont("s10 cWhite", "Segoe UI")
        tooltipGui.Add("Text", "vTooltipText w" . maxWidth . " +Wrap", text)
    } else {
        tooltipGui["TooltipText"].Value := text
    }

    tooltipGui.Show("AutoSize Hide")  ; Get dimensions without showing
    tooltipGui.GetPos(, , &width, &height)

    if (TOOLTIP_POSITION = 1) {
        MouseGetPos(&mouseX, &mouseY)
        xPos := mouseX + 5
        yPos := mouseY + 5

        ; Ensure tooltip stays within screen bounds
        if (xPos + width > A_ScreenWidth)
            xPos := A_ScreenWidth - width - 5
        if (yPos + height > A_ScreenHeight)
            yPos := mouseY - height - 5
    } else {
        MonitorGetWorkArea(MonitorGetPrimary(), &monLeft, &monTop, &monRight, &monBottom)
        xPos := monRight - width - 5
        yPos := monBottom - height - 5
    }

    ; Ensure tooltip is always visible
    xPos := Max(5, Min(xPos, A_ScreenWidth - width - 5))
    yPos := Max(5, Min(yPos, A_ScreenHeight - height - 5))

    tooltipGui.Show(Format("x{} y{}", xPos, yPos))
    SetTimer () => tooltipGui.Hide(), -2000
}

ToggleStartup() {
    startupFolder := A_Startup . "\Capsulate.lnk"
    if (FileExist(startupFolder)) {
        FileDelete startupFolder
        trayMenu.Uncheck("Run at Startup")
        ShowTooltip("Capsulate removed from startup")
    } else {
        FileCreateShortcut(A_ScriptFullPath, startupFolder)
        trayMenu.Check("Run at Startup")
        ShowTooltip("Capsulate added to startup")
    }
}

if (FileExist(A_Startup . "\Capsulate.lnk"))
    trayMenu.Check("Run at Startup")

GeneratePassword() {
    try {
        chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
        password := ""
        loop 16 {
            randomIndex := Random(1, StrLen(chars))
            password .= SubStr(chars, randomIndex, 1)
        }
        ClipboardManager.SetClipboardText(password)
        ShowTooltip("Password generated and copied to clipboard!")
        Logger.Info("Password generated successfully")
    } catch as err {
        Logger.Error("Error generating password: " . err.Message)
        ShowTooltip("Error generating password: " . err.Message)
    }
}

ConvertCase(caseType) {
    global waitingForChord
    waitingForChord := false
    ToolTip()

    try {
        converter := ""
        switch caseType {
            case "lower":
                converter := (text) => StrLower(text)
            case "upper":
                converter := (text) => StrUpper(text)
            case "camel":
                converter := (text) => ToCamelCase(text)
            case "title":
                converter := (text) => ToTitleCase(text)
            case "trim":
                converter := (text) => Trim(text)
        }

        if (converter) {
            convertedText := ClipboardManager.ConvertSelectedText(converter)
            ShowTooltip("Text converted to " . caseType)
        } else {
            ShowTooltip("Unknown conversion type: " . caseType)
        }
    } catch as err {
        Logger.Error("Error converting text: " . err.Message)
        ShowTooltip("Error converting text: " . err.Message)
    }
}

ToCamelCase(str) {
    result := ""
    nextUpper := false
    loop parse, str {
        if (A_LoopField = " " or A_LoopField = "_" or A_LoopField = "-") {
            nextUpper := true
        } else if (nextUpper) {
            result .= StrUpper(A_LoopField)
            nextUpper := false
        } else {
            result .= StrLower(A_LoopField)
        }
    }
    return result
}

ToTitleCase(str) {
    return StrTitle(str)
}

RestartXMouseButtonControl() {
    try {
        if (ProcessExist("XMouseButtonControl.exe")) {
            ProcessClose("XMouseButtonControl.exe")
            Sleep 1000 ; Wait for process to close
        }
        Run("XMouseButtonControl.exe")
        ShowTooltip("XMouseButtonControl restarted")
        Logger.Info("XMouseButtonControl restarted successfully")
    } catch as err {
        Logger.Error("Error restarting XMouseButtonControl: " . err.Message)
        ShowTooltip("Error restarting XMouseButtonControl: " . err.Message)
    }
}

CheckLatestVersion() {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        url := Constants.GetGitHubApiUrl()
        whr.Open("GET", url, true)
        whr.SetTimeouts(5000, 5000, 10000, 10000) ; Set reasonable timeouts
        whr.SetRequestHeader("User-Agent", "Capsulate/" . Constants.SCRIPT_VERSION)
        whr.Send()
        whr.WaitForResponse()

        if (whr.Status = 200) {
            responseText := whr.ResponseText
            response := Jxon_Load(&responseText)
            latestVersion := response["tag_name"]
            Logger.Info("Latest version check: current=" . Constants.SCRIPT_VERSION . ", latest=" . latestVersion)
            return CompareVersions(latestVersion, Constants.SCRIPT_VERSION) > 0
        } else {
            Logger.Warning("HTTP error checking for updates: " . whr.Status)
            return false
        }
    } catch as err {
        Logger.Error("Error checking for updates: " . err.Message)
        ShowTooltip("Error checking for updates: " . err.Message)
        return false
    }
}

CompareVersions(version1, version2) {
    ; Remove 'v' prefix if present
    v1 := StrReplace(version1, "v", "")
    v2 := StrReplace(version2, "v", "")

    v1Parts := StrSplit(v1, ".")
    v2Parts := StrSplit(v2, ".")

    maxLength := Max(v1Parts.Length, v2Parts.Length)

    Loop maxLength {
        part1 := v1Parts.Has(A_Index) ? Integer(v1Parts[A_Index]) : 0
        part2 := v2Parts.Has(A_Index) ? Integer(v2Parts[A_Index]) : 0

        if (part1 > part2)
            return 1
        if (part1 < part2)
            return -1
    }
    return 0
}

UpdateScript() {
    try {
        downloadUrl := Constants.GetDownloadUrl()
        newScriptPath := A_ScriptDir . "\Capsulate_new.ahk"

        Logger.Info("Starting script update from: " . downloadUrl)
        Download(downloadUrl, newScriptPath)

        ; Verify the downloaded file
        if (!FileExist(newScriptPath)) {
            throw Error("Downloaded file does not exist")
        }

        downloadedSize := FileGetSize(newScriptPath)
        if (downloadedSize < 1000) {
            throw Error("Downloaded file is too small, likely corrupted")
        }

        ; Resolve paths before creating batch script
        currentScriptPath := A_ScriptFullPath
        scriptDir := A_ScriptDir

        updateScript := '
        (
        @echo off
        timeout /t 2 /nobreak
        del "' . currentScriptPath . '"
        move "' . scriptDir . '\Capsulate_new.ahk" "' . currentScriptPath . '"
        start "" "' . currentScriptPath . '"
        del "%~f0"
        )'

        FileAppend(updateScript, A_ScriptDir . "\update.bat")
        Logger.Info("Update script created, starting update process")
        Run(A_ScriptDir . "\update.bat", , "Hide")
        ExitApp
    } catch as err {
        Logger.Error("Failed to update script: " . err.Message)
        ShowTooltip("Failed to update script: " . err.Message)
        ; Clean up failed download
        if (FileExist(A_ScriptDir . "\Capsulate_new.ahk")) {
            FileDelete A_ScriptDir . "\Capsulate_new.ahk"
        }
    }
}

CheckForUpdates(*) {
    if (CheckLatestVersion()) {
        result := MsgBox("A new version is available. Update now?", "Update Available", "YesNo")
        if (result = "Yes") {
            UpdateScript()
        }
    } else {
        ShowTooltip("You have the latest version!")
    }
}

Jxon_Load(&src, args*) {
    key := "", is_key := false
    stack := [tree := []]
    next := '"{[01234567890-tfn'
    pos := 0

    while ((ch := SubStr(src, ++pos, 1)) != "") {
        if InStr(" `t`n`r", ch)
            continue
        if !InStr(next, ch, true) {
            testArr := StrSplit(SubStr(src, 1, pos), "`n")
            ln := testArr.Length
            col := pos - InStr(src, "`n", , -(StrLen(src) - pos + 1))
            msg := Format("{}: line {} col {} (char {})", (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
                : (next == "'") ? "Unterminated string starting at"
                    : (next == "\") ? "Invalid \escape"
                        : (next == ":") ? "Expecting ':' delimiter"
                            : (next == '"') ? "Expecting object key enclosed in double quotes"
                                : (next == '"}') ?
                                    "Expecting object key enclosed in double quotes or object closing '}'"
                                    : (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
                                        : (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
                                            : [
                                                "Expecting JSON value(string, number, [true, false, null], object or array)",
                                                ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$") - 1)][1]
            , ln, col, pos)
            throw Error(msg, -1, ch)
        }

        obj := stack[1]
        is_array := (obj is Array)

        if i := InStr("{[", ch) { ; start new object / map?
            val := (i = 1) ? Map() : Array()	; ahk v2
            is_array ? obj.Push(val) : obj[key] := val
            stack.InsertAt(1, val)
            next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
        } else if InStr("}]", ch) {
            stack.RemoveAt(1)
            next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
        } else if InStr(",:", ch) {
            is_key := (!is_array && ch == ",")
            next := is_key ? '"' : '"{[0123456789-tfn'
        } else { ; string | number | true | false | null
            if (ch == '"') { ; string
                i := pos
                while i := InStr(src, '"', , i + 1) {
                    val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
                    if (SubStr(val, -1) != "\")
                        break
                }
                if !i ? (pos--, next := "'") : 0
                    continue

                pos := i ; update pos

                val := StrReplace(val, "\/", "/")
                val := StrReplace(val, '\"', '"')
                val := StrReplace(val, "\b", "`b")
                val := StrReplace(val, "\f", "`f")
                val := StrReplace(val, "\n", "`n")
                val := StrReplace(val, "\r", "`r")
                val := StrReplace(val, "\t", "`t")

                i := 0
                while i := InStr(val, "\", , i + 1) {
                    if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                        continue 2

                    xxxx := Abs("0x" . SubStr(val, i + 2, 4)) ; \uXXXX - JSON unicode escape sequence
                    if (xxxx < 0x100)
                        val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
                }

                if is_key {
                    key := val, next := ":"
                    continue
                }
            } else { ; number | true | false | null
                val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$", , pos) - pos)

                if IsInteger(val)
                    val += 0
                else if IsFloat(val)
                    val += 0
                else if (val == "true" || val == "false")
                    val := (val == "true")
                else if (val == "null")
                    val := ""
                else if is_key {
                    pos--, next := "#"
                    continue
                }

                pos += i - 1
            }

            is_array ? obj.Push(val) : obj[key] := val
            next := obj == tree ? "" : is_array ? ",]" : ",}"
        }
    }

    return tree[1]
}

Jxon_Dump(obj, indent := "", lvl := 1) {
    if IsObject(obj) {
        if !(obj is Array || obj is Map || obj is String || obj is Number)
            throw Error("Object type not supported.", -1, Format("<Object at 0x{:p}>", ObjPtr(obj)))

        if IsInteger(indent) {
            if (indent < 0)
                throw Error("Indent parameter must be a postive integer.", -1, indent)
            spaces := indent, indent := ""
            loop spaces
                indent .= " "
        }
        indt := ""
        loop indent ? lvl : 0
            indt .= indent

        is_array := (obj is Array)

        lvl += 1, out := ""
        for k, v in obj {
            if IsObject(k) || (k == "")
                throw Error("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", ObjPtr(obj)) : "<blank>")

            if !is_array ;// key ; ObjGetCapacity([k], 1)
                out .= (ObjGetCapacity([k]) ? Jxon_Dump(k) : escape_str(k)) (indent ? ": " : ":") ; token + padding

            out .= Jxon_Dump(v, indent, lvl) ; value
            . (indent ? ",`n" . indt : ",") ; token + indent
        }

        if (out != "") {
            out := Trim(out, ",`n" . indent)
            if (indent != "")
                out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent) + 1)
        }

        return is_array ? "[" . out . "]" : "{" . out . "}"

    } else if (obj is Number)
        return obj
    else ; String
        return escape_str(obj)

    escape_str(obj) {
        obj := StrReplace(obj, "\", "\\")
        obj := StrReplace(obj, "`t", "\t")
        obj := StrReplace(obj, "`r", "\r")
        obj := StrReplace(obj, "`n", "\n")
        obj := StrReplace(obj, "`b", "\b")
        obj := StrReplace(obj, "`f", "\f")
        obj := StrReplace(obj, "/", "\/")
        obj := StrReplace(obj, '"', '\"')
        return '"' obj '"'
    }
}
