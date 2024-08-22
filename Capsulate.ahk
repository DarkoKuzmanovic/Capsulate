#Requires AutoHotkey v2.0
SCRIPT_VERSION := "0.2.0"

config := LoadConfiguration()
CAPS_LOCK_TIMEOUT := config["CapsLockTimeout"]
DOUBLE_CLICK_COUNT := config["DoubleClickCount"]
TOOLTIP_POSITION := config["ToolTipPosition"]

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
trayMenu.Add()
trayMenu.Add("Configuration", (*) => ShowConfigGUI())
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
        SetTimer () => (capsLockCount := 0), -CAPS_LOCK_TIMEOUT
    } else {
        capsLockCount := 0
    }
    
    if (capsLockCount = DOUBLE_CLICK_COUNT) {
        SendInput "{LWin down}{F5}{LWin up}"
        capsLockCount := 0
    }
}

^CapsLock:: SetCapsLockState GetKeyState("CapsLock", "T") ? "AlwaysOff" : "AlwaysOn"

#HotIf capsLockPressed
Up::SendInput "{Volume_Up}"
Down::SendInput "{Volume_Down}"
Delete::SendInput "{Volume_Mute}"
Left::Send "#^{Left}"
Right::Send "#^{Right}"
T::Run "taskmgr"
W::Run "ms-settings:windowsupdate"
C::Run "*RunAs cleanmgr"
K::
{
    global waitingForChord
    waitingForChord := true
    ShowTooltip("Waiting for a second key of chord...")
    SetTimer () => ToolTip(), -2000  ; Hide tooltip after 2 seconds
}
#HotIf

#HotIf waitingForChord
S::
{
    global waitingForChord
    waitingForChord := false
    ToolTip
    ; TakeScreenshot() function call removed
}
#HotIf

^!c::ShowConfigGUI()

LoadConfiguration() {
    configFile := A_ScriptDir . "\config.ini"
    if (!FileExist(configFile)) {
        CreateDefaultConfig(configFile)
    }
    
    config := Map()
    config["CapsLockTimeout"] := IniRead(configFile, "General", "CapsLockTimeout", 300)
    config["DoubleClickCount"] := IniRead(configFile, "General", "DoubleClickCount", 2)
    config["ToolTipPosition"] := IniRead(configFile, "General", "ToolTipPosition", 1)
    
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

ShowConfigGUI() {
    global config
    
    configGui := Gui(, "Capsulate Configuration")
    configGui.Add("Text", "x10 y10 w150", "Caps Lock Timeout:")
    timeoutEdit := configGui.Add("Edit", "x160 y10 w50", config["CapsLockTimeout"])
        
    configGui.Add("Text", "x10 y40 w150", "Double Click Count:")
    doubleClickCountEdit := configGui.Add("Edit", "x160 y40 w50", config["DoubleClickCount"])
    
    configGui.Add("Text", "x10 y70 w150", "Tooltip Position:")
    tooltipPositionDropdown := configGui.Add("DropDownList", "vTooltipPosition x160 y70 w100", ["Near Mouse", "Near Tray"])
    tooltipPositionDropdown.Choose(config["ToolTipPosition"] = 1 ? "Near Mouse" : "Near Tray")
    
    configGui.Add("Button", "x10 y100 w100", "Save").OnEvent("Click", (*) => SaveConfig(configGui))
    configGui.Add("Button", "x120 y100 w100", "Cancel").OnEvent("Click", (*) => configGui.Destroy())
    
    configGui.Show()
}


SaveConfig(configGui) {
    global config, CAPS_LOCK_TIMEOUT, DOUBLE_CLICK_COUNT, TOOLTIP_POSITION
    
    config["CapsLockTimeout"] := configGui["Edit1"].Value
    config["DoubleClickCount"] := configGui["Edit2"].Value
    config["ToolTipPosition"] := configGui["TooltipPosition"].Value = 1 ? 1 : 0
    
    CAPS_LOCK_TIMEOUT := config["CapsLockTimeout"]
    DOUBLE_CLICK_COUNT := config["DoubleClickCount"]
    TOOLTIP_POSITION := config["ToolTipPosition"]
    
    configFile := A_ScriptDir . "\config.ini"
    IniWrite config["CapsLockTimeout"], configFile, "General", "CapsLockTimeout"
    IniWrite config["DoubleClickCount"], configFile, "General", "DoubleClickCount"
    IniWrite config["ToolTipPosition"], configFile, "General", "ToolTipPosition"
    
    configGui.Destroy()
    MsgBox "Configuration saved successfully!"
}