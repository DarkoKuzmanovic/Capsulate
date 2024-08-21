; TODO: Add more useful shortcuts
; TODO: Add autoexpander functionality to expand selected text

#Requires AutoHotkey v2.0
SCRIPT_VERSION := "0.1.0"

; Load configuration
config := LoadConfiguration()

; Constants (now loaded from config)
CAPS_LOCK_TIMEOUT := config.CapsLockTimeout
DOUBLE_CLICK_COUNT := config.DoubleClickCount

; Global variables
capsLockPressed := false
capsLockTimer := 0
capsLockCount := 0

; Disable the standard Caps Lock key
SetCapsLockState "AlwaysOff"

; Call this function to initially set the tray icon
SetTrayIcon()
A_IconTip := "Capsulate v" . SCRIPT_VERSION . " - Enhance Your Caps Lock"

; Add the tray menu setup here
trayMenu := A_TrayMenu
trayMenu.Delete()  ; Clear the default menu
trayMenu.Add("Capsulate v" . SCRIPT_VERSION, (*) => {})  ; Add version as a non-clickable item
trayMenu.Add()  ; Add a separator line
trayMenu.Add("Configuration", (*) => ShowConfigGUI())
trayMenu.Add("Exit", (*) => ExitApp())

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


; Set up a timer to check for theme changes every 5 seconds
SetTimer SetTrayIcon, 5000


*CapsLock:: {
    global capsLockPressed, capsLockTimer
    capsLockPressed := true
    capsLockTimer := A_TickCount
}

*CapsLock up:: {
    global capsLockPressed, capsLockTimer, capsLockCount, CAPS_LOCK_TIMEOUT, DOUBLE_CLICK_COUNT
    capsLockPressed := false
    elapsedTime := A_TickCount - capsLockTimer
    
    if (elapsedTime < CAPS_LOCK_TIMEOUT) {
        capsLockCount++
        try {
            SetTimer () => (capsLockCount := 0), -CAPS_LOCK_TIMEOUT
        } catch as err {
            MsgBox "Error setting timer: " . err.Message
        }
    } else {
        capsLockCount := 0
    }
    
    if (capsLockCount = DOUBLE_CLICK_COUNT) {
        try {
            SendInput config.DoubleClickAction
        } catch as err {
            MsgBox "Error sending input: " . err.Message
        }
        capsLockCount := 0
    }
}

^CapsLock::
{
    try {
        SetCapsLockState GetKeyState("CapsLock", "T") ? "AlwaysOff" : "AlwaysOn"
    } catch as err {
        MsgBox "Error toggling Caps Lock state: " . err.Message
    }
}

#HotIf capsLockPressed
Up::SendInput config.UpAction
Down::SendInput config.DownAction
Delete::SendInput config.DeleteAction
Left::Send config.LeftAction
Right::Send config.RightAction
#HotIf

LoadConfiguration() {
    configFile := A_ScriptDir . "\config.ini"
    if (!FileExist(configFile)) {
        CreateDefaultConfig(configFile)
    }
    
    config := {}
    config.CapsLockTimeout := IniRead(configFile, "General", "CapsLockTimeout", 300)
    config.DoubleClickCount := IniRead(configFile, "General", "DoubleClickCount", 2)
    config.DoubleClickAction := IniRead(configFile, "Actions", "DoubleClick", "{LWin down}{F5}{LWin up}")
    config.UpAction := IniRead(configFile, "Actions", "Up", "{Volume_Up}")
    config.DownAction := IniRead(configFile, "Actions", "Down", "{Volume_Down}")
    config.DeleteAction := IniRead(configFile, "Actions", "Delete", "{Volume_Mute}")
    config.LeftAction := IniRead(configFile, "Actions", "Left", "#^{Left}")
    config.RightAction := IniRead(configFile, "Actions", "Right", "#^{Right}")
    
    return config
}

CreateDefaultConfig(configFile) {
    FileAppend "
    (
    [General]
    CapsLockTimeout=300
    DoubleClickCount=2

    [Actions]
    DoubleClick={LWin down}{F5}{LWin up}
    Up={Volume_Up}
    Down={Volume_Down}
    Delete={Volume_Mute}
    Left=#^{Left}
    Right=#^{Right}
    )", configFile
}

; Add a new hotkey to open the configuration GUI
^!c::ShowConfigGUI()

ShowConfigGUI() {
    global config
    
    configGui := Gui(, "Capsulate Configuration")
    configGui.Add("Text", "x10 y10 w150", "Caps Lock Timeout:")
    timeoutEdit := configGui.Add("Edit", "x160 y10 w50", config.CapsLockTimeout)
        
    configGui.Add("Text", "x10 y70 w150", "Double Click Action:")
    doubleClickEdit := configGui.Add("Edit", "x160 y70 w150", config.DoubleClickAction)
    
    configGui.Add("Button", "x10 y100 w100", "Save").OnEvent("Click", (*) => SaveConfig(configGui))
    configGui.Add("Button", "x120 y100 w100", "Cancel").OnEvent("Click", (*) => configGui.Destroy())
    
    configGui.Show()
}

SaveConfig(configGui) {
    global config, CAPS_LOCK_TIMEOUT, DOUBLE_CLICK_COUNT
    
    config.CapsLockTimeout := configGui["Edit1"].Value
    config.DoubleClickCount := configGui["Edit2"].Value
    config.DoubleClickAction := configGui["Edit3"].Value
    
    CAPS_LOCK_TIMEOUT := config.CapsLockTimeout
    DOUBLE_CLICK_COUNT := config.DoubleClickCount
    
    configFile := A_ScriptDir . "\config.ini"
    IniWrite config.CapsLockTimeout, configFile, "General", "CapsLockTimeout"
    IniWrite config.DoubleClickCount, configFile, "General", "DoubleClickCount"
    IniWrite config.DoubleClickAction, configFile, "Actions", "DoubleClick"
    
    configGui.Destroy()
    MsgBox "Configuration saved successfully!"
}