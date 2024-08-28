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
    capsLockPressed := false
    elapsedTime := A_TickCount - capsLockTimer
    
    if (elapsedTime < CAPS_LOCK_TIMEOUT) {
        capsLockCount++
        if (capsLockCount = DOUBLE_CLICK_COUNT) {
            SendInput DOUBLE_CLICK_ACTION
            capsLockCount := 0
        } else {
            SetTimer () => (capsLockCount := 0), -CAPS_LOCK_TIMEOUT
        }
    } else {
        capsLockCount := 1
    }
    
    capsLockTimer := A_TickCount
}

^CapsLock:: SetCapsLockState GetKeyState("CapsLock", "T") ? "AlwaysOff" : "AlwaysOn"

#HotIf capsLockPressed
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
S::{
    global waitingForChord
    waitingForChord := false
    ToolTip
    ; TakeScreenshot() function call removed
}
#HotIf


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
    
    tabs := configGui.Add("Tab3", "w400 h300", ["General", "Text Expander"])
    
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
    
    lv := configGui.Add("ListView", "x20 y180 w360 h100", ["Abbreviation", "Expansion"])
    PopulateExpansionsList(lv)
    
    configGui.Add("Button", "x20 y290 w100", "Add/Update").OnEvent("Click", (*) => SaveExpansion(abbrevEdit, expansionEdit, lv))
    configGui.Add("Button", "x130 y290 w100", "Delete").OnEvent("Click", (*) => DeleteExpansion(lv))
    
    tabs.UseTab()
    configGui.Add("Button", "x20 y310 w100", "Save").OnEvent("Click", (*) => SaveUnifiedConfig(configGui, timeoutEdit, doubleClickCountEdit, tooltipPositionDropdown, doubleClickActionEdit))
    configGui.Add("Button", "x130 y310 w100", "Cancel").OnEvent("Click", (*) => configGui.Destroy())
    
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