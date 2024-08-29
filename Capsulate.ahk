#Requires AutoHotkey v2.0
SCRIPT_VERSION := "0.3.0"


config := LoadConfiguration()
CAPS_LOCK_TIMEOUT := config["CapsLockTimeout"]
DOUBLE_CLICK_COUNT := config["DoubleClickCount"]
TOOLTIP_POSITION := config["ToolTipPosition"]
DOUBLE_CLICK_ACTION := config["DoubleClickAction"]

global capsLockPressed := false
global waitingForChord := false
capsLockTimer := 0
capsLockCount := 0

SetCapsLockState "AlwaysOff"

SetTrayIcon() {


    iconFile := IsWindowsDarkTheme() 
        ? A_ScriptDir . "\capsulate-dark.png" 
        : A_ScriptDir . "\capsulate-light.png"
    TraySetIcon(iconFile)
}

IsWindowsDarkTheme() {
    regKey := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    return !RegRead(regKey, "AppsUseLightTheme")
}

SetTrayIcon()
A_IconTip := "Capsulate v" . SCRIPT_VERSION . " - Enhance Your Caps Lock"

trayMenu := A_TrayMenu
trayMenu.Delete()
trayMenu.Add("Capsulate v" . SCRIPT_VERSION, (*) => {})
trayMenu.Disable("Capsulate v" . SCRIPT_VERSION)
trayMenu.Add()
trayMenu.Add("Run at Startup", (*) => ToggleStartup())
trayMenu.Add()
trayMenu.Add("Configuration`tCapsLock+Alt+C", (*) => ShowUnifiedConfigGUI())
trayMenu.Add("Exit", (*) => ExitApp())

SetTimer SetTrayIcon, 5000

*CapsLock:: {
    global capsLockPressed
    capsLockPressed := true
    capsLockTimer := A_TickCount
}

*CapsLock up:: {
    global capsLockPressed, capsLockTimer, capsLockCount, CAPS_LOCK_TIMEOUT, DOUBLE_CLICK_COUNT
    
    ; Reset the CapsLock pressed state
    capsLockPressed := false
    
    ; Calculate the time elapsed since the last CapsLock press
    elapsedTime := A_TickCount - capsLockTimer
    
    ; Check if the elapsed time is within the timeout threshold
    if (elapsedTime < CAPS_LOCK_TIMEOUT) {
        ; Increment the CapsLock press count
        capsLockCount++
        
        ; Check if the double-click count has been reached
        if (capsLockCount = DOUBLE_CLICK_COUNT) {
            ; Perform the double-click action
            SendInput DOUBLE_CLICK_ACTION
            ; Reset the CapsLock press count
            capsLockCount := 0
        } else {
            ; Set a timer to reset the CapsLock press count after the timeout
            SetTimer () => (capsLockCount := 0), -CAPS_LOCK_TIMEOUT
        }
    } else {
        ; If the elapsed time is greater than the timeout, reset the count to 1
        capsLockCount := 1
    }
    
    ; Update the timer for the last CapsLock press
    capsLockTimer := A_TickCount
}

^CapsLock:: SetCapsLockState GetKeyState("CapsLock", "T") ? "AlwaysOff" : "AlwaysOn"

#HotIf capsLockPressed
1::LaunchShortcut("1")
2::LaunchShortcut("2")
3::LaunchShortcut("3")
4::LaunchShortcut("4")
5::LaunchShortcut("5")
6::LaunchShortcut("6")
7::LaunchShortcut("7")
8::LaunchShortcut("8")
9::LaunchShortcut("9")
0::LaunchShortcut("0")
!c::ShowUnifiedConfigGUI()
Esc::TogglePomodoro()
Up::SendInput "{Volume_Up}"
Down::SendInput "{Volume_Down}"
Delete::SendInput "{Volume_Mute}"
Left::Send "#^{Left}"
Right::Send "#^{Right}"
T::Run "taskmgr"
W::Run "ms-settings:windowsupdate"
C::Run "*RunAs cleanmgr"
E::ExpandText()
P::GeneratePassword()
K::
{
    global waitingForChord
    waitingForChord := true
    ShowTooltip("Waiting for a second key of chord...")
    SetTimer () => ToolTip(), -2000  ; Hide tooltip after 2 seconds
}
#HotIf

#HotIf waitingForChord
L::
{
    global waitingForChord
    waitingForChord := false
    ToolTip
    ConvertCase("lower")
}

U::
{
    global waitingForChord
    waitingForChord := false
    ToolTip
    ConvertCase("upper")
}

C::
{
    global waitingForChord
    waitingForChord := false
    ToolTip
    ConvertCase("camel")
}

T::
{
    global waitingForChord
    waitingForChord := false
    ToolTip
    ConvertCase("title")
}

Space::
{
    global waitingForChord
    waitingForChord := false
    ToolTip
    ConvertCase("trim")
}
#HotIf

LaunchShortcut(key) {
    path := IniRead(A_ScriptDir . "\config.ini", "Shortcuts", key, "")
    if (path != "") {
        Run(path)
    }
}

ExpandText() {
    word := GetWordAtCursor()
    ShowTooltip("Word captured: " . word)
    expansion := GetExpansion(word)
    if (expansion) {
        ShowTooltip("Expansion found: " . expansion)
        SendInput "{BackSpace " . StrLen(word) . "}"
        SendInput expansion
    } else {
        ShowTooltip("No expansion found for: " . word)
    }
}

GetWordAtCursor() {
    savedClipboard := ClipboardAll()
    A_Clipboard := ""
    SendInput "^{Left}^+{Right}^c"
    ClipWait(0.5)
    word := A_Clipboard
    A_Clipboard := savedClipboard
    return Trim(word)
}

GetExpansion(word) {
    expansionsFile := A_ScriptDir . "\expansions.ini"
    return IniRead(expansionsFile, "Expansions", word, "")
}

ShowUnifiedConfigGUI() {
    global config
    
    configGui := Gui(, "Capsulate Configuration")
    configGui.SetFont("s9", "Segoe UI")  ; Set Segoe UI as the default font
    
    tabs := configGui.Add("Tab3", "w400 h400", ["General", "Text Expander", "Shortcuts"])
    
    tabs.UseTab(1)
    configGui.Add("Text", "x20 y40 w150", "Caps Lock Timeout:")
    timeoutEdit := configGui.Add("Edit", "x170 y40 w50", config["CapsLockTimeout"])
    
    configGui.Add("Text", "x20 y70 w150", "Double Click Count:")
    doubleClickCountEdit := configGui.Add("Edit", "x170 y70 w50", config["DoubleClickCount"])
    
    configGui.Add("Text", "x20 y100 w150", "Tooltip Position:")
    tooltipPositionDropdown := configGui.Add("DropDownList", "vTooltipPosition x170 y100 w100", ["Near Mouse", "Near Tray"])
    tooltipPositionDropdown.Choose(config["ToolTipPosition"] = 1 ? "Near Mouse" : "Near Tray")
    
    configGui.Add("Text", "x20 y130 w150", "Double Click Action:")
    doubleClickActionEdit := configGui.Add("Edit", "x170 y130 w200", config["DoubleClickAction"])
    
    tabs.UseTab(2)
    configGui.Add("Text", "x20 y40", "Abbreviation:")
    abbrevEdit := configGui.Add("Edit", "x20 y60 w100")
    configGui.Add("Text", "x20 y90", "Expansion:")
    expansionEdit := configGui.Add("Edit", "x20 y110 w200 h60")
    
    lv := configGui.Add("ListView", "x20 y180 w360 h150", ["Abbreviation", "Expansion"])
    PopulateExpansionsList(lv)
    
    configGui.Add("Button", "x20 y340 w100", "Add/Update").OnEvent("Click", (*) => SaveExpansion(abbrevEdit, expansionEdit, lv))
    configGui.Add("Button", "x130 y340 w100", "Delete").OnEvent("Click", (*) => DeleteExpansion(lv))

    tabs.UseTab(3)
    configGui.Add("Text", "x20 y40 w150", "Select a number key:")
    shortcutKeyDropdown := configGui.Add("DropDownList", "x170 y40 w50", ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"])
    configGui.Add("Text", "x20 y70 w150", "Executable or folder path:")
    shortcutPathEdit := configGui.Add("Edit", "x170 y70 w180")
    configGui.Add("Button", "x360 y70 w30", "...").OnEvent("Click", (*) => BrowseExe(shortcutPathEdit))
    configGui.Add("Button", "x170 y100 w100", "Set Shortcut").OnEvent("Click", (*) => SetShortcut(shortcutKeyDropdown, shortcutPathEdit))
    
    global shortcutListView
    shortcutListView := configGui.Add("ListView", "x20 y130 w360 h230", ["Key", "Path"])
    PopulateShortcutList(shortcutListView)

    tabs.UseTab()
    configGui.Add("Button", "x20 y410 w100", "Save").OnEvent("Click", (*) => SaveUnifiedConfig(configGui, timeoutEdit, doubleClickCountEdit, tooltipPositionDropdown, doubleClickActionEdit))
    configGui.Add("Button", "x130 y410 w100", "Cancel").OnEvent("Click", (*) => configGui.Destroy())
    
    configGui.Show()
}

SaveUnifiedConfig(configGui, timeoutEdit, doubleClickCountEdit, tooltipPositionDropdown, doubleClickActionEdit) {
    global config, CAPS_LOCK_TIMEOUT, DOUBLE_CLICK_COUNT, TOOLTIP_POSITION, DOUBLE_CLICK_ACTION
    
    config["CapsLockTimeout"] := timeoutEdit.Value
    config["DoubleClickCount"] := doubleClickCountEdit.Value
    config["ToolTipPosition"] := tooltipPositionDropdown.Value = "Near Mouse" ? 1 : 0
    config["DoubleClickAction"] := doubleClickActionEdit.Value
    
    CAPS_LOCK_TIMEOUT := config["CapsLockTimeout"]
    DOUBLE_CLICK_COUNT := config["DoubleClickCount"]
    TOOLTIP_POSITION := config["ToolTipPosition"]
    DOUBLE_CLICK_ACTION := config["DoubleClickAction"]
    
    configFile := A_ScriptDir . "\config.ini"
    IniWrite config["CapsLockTimeout"], configFile, "General", "CapsLockTimeout"
    IniWrite config["DoubleClickCount"], configFile, "General", "DoubleClickCount"
    IniWrite config["ToolTipPosition"], configFile, "General", "ToolTipPosition"
    IniWrite config["DoubleClickAction"], configFile, "General", "DoubleClickAction"
    
    ; Save shortcuts
    Loop 10 {
        key := A_Index - 1
        path := IniRead(A_ScriptDir . "\config.ini", "Shortcuts", key, "")
        if (path != "") {
            IniWrite(path, configFile, "Shortcuts", key)
        }
    }
    
    configGui.Destroy()
    ShowTooltip("Configuration saved successfully!")
}
PopulateExpansionsList(lv) {
    lv.Delete()
    expansionsFile := A_ScriptDir . "\expansions.ini"
    if (FileExist(expansionsFile)) {
        expansions := IniRead(expansionsFile, "Expansions")
        Loop Parse, expansions, "`n", "`r"
        {
            parts := StrSplit(A_LoopField, "=")
            if (parts.Length == 2) {
                lv.Add(, parts[1], parts[2])
            }
        }
    }
}

LoadSelectedItem(lv, abbrevEdit, expansionEdit) {
    if (row := lv.GetNext()) {
        abbrevEdit.Value := lv.GetText(row, 1)
        expansionEdit.Value := lv.GetText(row, 2)
    }
}

SaveExpansion(abbrevEdit, expansionEdit, lv) {
    abbrev := abbrevEdit.Value
    expansion := expansionEdit.Value
    if (abbrev != "" and expansion != "") {
        expansionsFile := A_ScriptDir . "\expansions.ini"
        IniWrite expansion, expansionsFile, "Expansions", abbrev
        PopulateExpansionsList(lv)
        MsgBox "Expansion saved successfully!"
    } else {
        MsgBox "Please enter both abbreviation and expansion."
    }
}

DeleteExpansion(lv) {
    if (row := lv.GetNext()) {
        abbrev := lv.GetText(row, 1)
        expansionsFile := A_ScriptDir . "\expansions.ini"
        IniDelete expansionsFile, "Expansions", abbrev
        lv.Delete(row)
    } else {
        MsgBox "Please select an expansion to delete."
    }
}
LoadConfiguration() {
    configFile := A_ScriptDir . "\config.ini"
    if (!FileExist(configFile)) {
        CreateDefaultConfig(configFile)
    }
    
    config := Map()
    config["CapsLockTimeout"] := IniRead(configFile, "General", "CapsLockTimeout", 300)
    config["DoubleClickCount"] := IniRead(configFile, "General", "DoubleClickCount", 2)
    config["ToolTipPosition"] := IniRead(configFile, "General", "ToolTipPosition", 1)
    config["DoubleClickAction"] := IniRead(configFile, "General", "DoubleClickAction", "{LWin down}{F5}{LWin up}")
    
    DOUBLE_CLICK_ACTION := config["DoubleClickAction"]
    
    return config
}

CreateDefaultConfig(configFile) {
    FileAppend "
    (
    [General]
    CapsLockTimeout=300
    DoubleClickCount=2
    ToolTipPosition=1
    )", configFile
}

ShowTooltip(text) {
    if (TOOLTIP_POSITION = 1) {
        ToolTip text
    } else {
        CoordMode "ToolTip", "Screen"
        trayX := A_ScreenWidth - 20
        trayY := A_ScreenHeight - 20
        ToolTip text, trayX, trayY
    }
    SetTimer () => ToolTip(), -2000  ; Hide tooltip after 2 seconds
}

ToggleStartup() {
    startupFolder := A_Startup . "\Capsulate.lnk"
    if (FileExist(startupFolder)) {
        FileDelete startupFolder
        trayMenu.Uncheck("Run at Startup")
        ShowTooltip("Capsulate removed from startup")
    } else {
        FileCreateShortcut A_ScriptFullPath, startupFolder
        trayMenu.Check("Run at Startup")
        ShowTooltip("Capsulate added to startup")
    }
}

if (FileExist(A_Startup . "\Capsulate.lnk")) {
    trayMenu.Check("Run at Startup")
}

GeneratePassword() {
    chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
    password := ""
    Loop 16 {
        randomIndex := Random(1, StrLen(chars))
        password .= SubStr(chars, randomIndex, 1)
    }
    A_Clipboard := password
    ShowTooltip("Password generated and copied to clipboard!")
}

global pomodoroTimer := 0
global pomodoroActive := false

TogglePomodoro() {
    global pomodoroActive
    global pomodoroTimer

    if (!pomodoroActive) {
        pomodoroActive := true
        pomodoroTimer := 25 * 60  ; 25 minutes in seconds
        SetTimer PomodoroTick, 1000
        ShowTooltip("Pomodoro started: 25:00")
    } else {
        pomodoroActive := false
        SetTimer PomodoroTick, 0
        ShowTooltip("Pomodoro stopped")
        pomodoroTimer := 0  ; Reset the timer when stopped
    }
}
PomodoroTick() {
    global pomodoroTimer

    if (pomodoroTimer > 0) {
        pomodoroTimer--
        minutes := Floor(pomodoroTimer / 60)
        seconds := Mod(pomodoroTimer, 60)
        ShowTooltip("Pomodoro: " . Format("{:02d}:{:02d}", minutes, seconds))
    } else {
        SetTimer PomodoroTick, 0
        ShowTooltip("Pomodoro finished!")
        SoundPlay "*-1"  ; Play a system sound
    }
}

BrowseExe(pathEdit) {
    selectedFile := FileSelect("3", , "Select an executable", "Executables (*.exe)")
    if (selectedFile != "") {
        pathEdit.Value := selectedFile
    }
}


SetShortcut(keyDropdown, pathEdit) {
    key := keyDropdown.Text
    path := pathEdit.Value
    if (key != "" and path != "") {
        IniWrite(path, A_ScriptDir . "\config.ini", "Shortcuts", key)
        PopulateShortcutList(shortcutListView)
        ShowTooltip("Shortcut set successfully!")
    }
}

PopulateShortcutList(listView) {
    listView.Delete()
    Loop 10 {
        key := A_Index - 1
        path := IniRead(A_ScriptDir . "\config.ini", "Shortcuts", key, "")
        if (path != "") {
            listView.Add(, key, path)
        }
    }
}

ConvertCase(caseType) {
    savedClipboard := ClipboardAll()
    A_Clipboard := ""
    Send "^c"
    if !ClipWait(0.5)
    {
        ShowTooltip("No text selected")
        return
    }
    
    text := A_Clipboard
    
    if (text = "") {
        ShowTooltip("Selected text is empty")
        return
    }
    
    convertedText := ""
    switch caseType {
        case "lower":
            convertedText := StrLower(text)
        case "upper":
            convertedText := StrUpper(text)
        case "camel":
            convertedText := ToCamelCase(text)
        case "title":
            convertedText := ToTitleCase(text)
        case "trim":
            convertedText := Trim(text)
    }
    
    if (convertedText != "") {
        A_Clipboard := convertedText
        Send "^v"
        ShowTooltip("Text converted to " . caseType)
    } else {
        ShowTooltip("Failed to convert text")
    }
    
    Sleep 100  ; Give some time for the paste operation
    A_Clipboard := savedClipboard
}

ToCamelCase(str) {
    result := ""
    nextUpper := false
    Loop Parse, str
    {
        if (A_LoopField = " " or A_LoopField = "_" or A_LoopField = "-")
        {
            nextUpper := true
        }
        else if (nextUpper)
        {
            result .= StrUpper(A_LoopField)
            nextUpper := false
        }
        else
        {
            result .= StrLower(A_LoopField)
        }
    }
    return result
}

ToTitleCase(str) {
    return StrTitle(str)
}