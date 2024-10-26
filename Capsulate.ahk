#Requires AutoHotkey v2.0
#SingleInstance Force
SCRIPT_VERSION := "0.5.0"

config := LoadConfiguration()
CAPS_LOCK_TIMEOUT := config["CapsLockTimeout"]
DOUBLE_CLICK_COUNT := config["DoubleClickCount"]
TOOLTIP_POSITION := config["ToolTipPosition"]
DOUBLE_CLICK_ACTION := config["DoubleClickAction"]

global capsLockPressed := false
global waitingForChord := false
global trackingCode := ""
global orderNumber := ""
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
trayMenu.Add("Check for Updates", CheckForUpdates)  ; Add this line
trayMenu.Add("Run at Startup", (*) => ToggleStartup())
trayMenu.Add()
trayMenu.Add("Configuration`tCapsLock+Alt+C", (*) => ShowUnifiedConfigGUI())

trayMenu.Add("Exit", (*) => ExitApp())

SetTimer SetTrayIcon, 5000

if (CheckLatestVersion()) {
    ShowTooltip("A new version is available!")
}

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
[:: CopyToVariable("trackingCode")
]:: CopyToVariable("orderNumber")
!c:: ShowUnifiedConfigGUI()
Esc:: TogglePomodoro()
Up:: SendInput "{Volume_Up}"
Down:: SendInput "{Volume_Down}"
Delete:: SendInput "{Volume_Mute}"
Left:: Send "#^{Left}"
Right:: Send "#^{Right}"
T:: Run "taskmgr"
W:: Run "ms-settings:windowsupdate"
C:: Run "*RunAs cleanmgr"
X:: RestartXMouseButtonControl()
E:: ExpandText()
P:: GeneratePassword()
K::
{
    global waitingForChord
    waitingForChord := true
    ShowTooltip("Waiting for a second key of chord...")
    SetTimer () => ToolTip(), -2000  ; Hide tooltip after 2 seconds
}
#HotIf

#HotIf waitingForChord
1::
{
    global waitingForChord, trackingCode, orderNumber
    waitingForChord := false
    ToolTip

    ; Handle tracking reference
    SendInput "TRACKING REFERENCE: "
    A_Clipboard := trackingCode
    SendInput "^v"
    SendInput "^a"
    SendInput "^b"
    SendInput "{Right}"

    ; Wait 2000ms
    Sleep 2000

    ; Handle order number (similar to Chord 2)
    SendInput "!u"
    Sleep 200
    SendInput "{Down}"
    Sleep 100
    SendInput "{Right}"
    Sleep 100
    SendInput "{Down}"
    Sleep 100
    SendInput "{Enter}"

    ; Place orderNumber in clipboard
    A_Clipboard := orderNumber
}

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

CopyToVariable(varName) {
    global
    %varName% := GetSelectedText()
    ShowTooltip("Copied to " . varName)
}

GetSelectedText() {
    savedClipboard := ClipboardAll()
    A_Clipboard := ""
    Send "^c"
    ClipWait(0.5)
    selectedText := A_Clipboard
    A_Clipboard := savedClipboard
    return selectedText
}

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
    tooltipPositionDropdown := configGui.Add("DropDownList", "vTooltipPosition x170 y100 w100", ["Near Mouse",
        "Near Tray"])
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

    configGui.Add("Button", "x20 y340 w100", "Add/Update").OnEvent("Click", (*) => SaveExpansion(abbrevEdit,
        expansionEdit, lv))
    configGui.Add("Button", "x130 y340 w100", "Delete").OnEvent("Click", (*) => DeleteExpansion(lv))

    tabs.UseTab(3)
    configGui.Add("Text", "x20 y40 w150", "Select a number key:")
    shortcutKeyDropdown := configGui.Add("DropDownList", "x170 y40 w50", ["1", "2", "3", "4", "5", "6", "7", "8", "9",
        "0"])
    configGui.Add("Text", "x20 y70 w150", "Executable or folder path:")
    shortcutPathEdit := configGui.Add("Edit", "x170 y70 w180")
    configGui.Add("Button", "x360 y70 w30", "...").OnEvent("Click", (*) => BrowseExe(shortcutPathEdit))
    configGui.Add("Button", "x170 y100 w100", "Set Shortcut").OnEvent("Click", (*) => SetShortcut(shortcutKeyDropdown,
        shortcutPathEdit))

    global shortcutListView
    shortcutListView := configGui.Add("ListView", "x20 y130 w360 h230", ["Key", "Path"])
    PopulateShortcutList(shortcutListView)

    tabs.UseTab()
    configGui.Add("Button", "x20 y410 w100", "Save").OnEvent("Click", (*) => SaveUnifiedConfig(configGui, timeoutEdit,
        doubleClickCountEdit, tooltipPositionDropdown, doubleClickActionEdit))
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
    loop 10 {
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
        loop parse, expansions, "`n", "`r" {
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
    static tooltipGui := 0

    if (!tooltipGui) {
        tooltipGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        tooltipGui.BackColor := "0x202020"
        tooltipGui.Opt("+E0x20")

        tooltipGui.MarginX := 16
        tooltipGui.MarginY := 12
        tooltipGui.SetFont("s10 cWhite", "Segoe UI")
        tooltipGui.Add("Text", "vTooltipText", text)
    } else {
        tooltipGui["TooltipText"].Value := text
    }

    if (TOOLTIP_POSITION = 1) {
        MouseGetPos(&mouseX, &mouseY)
        xPos := mouseX + 10
        yPos := mouseY + 10
    } else {
        xPos := A_ScreenWidth - 250
        yPos := A_ScreenHeight - 100
    }

    tooltipGui.Show(Format("x{} y{} AutoSize", xPos, yPos))
    SetTimer () => tooltipGui.Hide(), -2000
}

ShowPomodoroTooltip(text) {
    static pomodoroGui := 0

    if (!pomodoroGui) {
        pomodoroGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        pomodoroGui.BackColor := "0x1a472a"
        pomodoroGui.Opt("+E0x20")  ; Click-through enabled
        pomodoroGui.Opt("+E0x80000")  ; Layered window for transparency

        pomodoroGui.MarginX := 16
        pomodoroGui.MarginY := 12
        pomodoroGui.SetFont("s10 cWhite", "Segoe UI")
        pomodoroGui.Add("Text", "vPomodoroText", text)
    } else {
        pomodoroGui["PomodoroText"].Value := text
    }

    xPos := A_ScreenWidth - 250
    yPos := A_ScreenHeight - 100

    pomodoroGui.Show(Format("x{} y{} AutoSize", xPos, yPos))
    WinSetTransparent(180, pomodoroGui)
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
    loop 16 {
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
        ShowPomodoroTooltip("Pomodoro started: 25:00")
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
        ShowPomodoroTooltip(Format("{:02d}:{:02d}", minutes, seconds))
    } else {
        SetTimer PomodoroTick, 0
        ShowTooltip("Pomodoro finished!")
        SoundPlay "*-1"
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
    loop 10 {
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
    if !ClipWait(0.5) {
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
    loop parse, str {
        if (A_LoopField = " " or A_LoopField = "_" or A_LoopField = "-") {
            nextUpper := true
        }
        else if (nextUpper) {
            result .= StrUpper(A_LoopField)
            nextUpper := false
        }
        else {
            result .= StrLower(A_LoopField)
        }
    }
    return result
}

ToTitleCase(str) {
    return StrTitle(str)
}

RestartXMouseButtonControl() {
    ProcessClose("XMouseButtonControl.exe")
    Run("XMouseButtonControl.exe")
    ShowTooltip("XMouseButtonControl restarted")
}

CheckLatestVersion() {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", "https://api.github.com/repos/DarkoKuzmanovic/capsulate/releases/latest", true)
        whr.Send()
        whr.WaitForResponse()
        response := whr.ResponseText
        parsed := Jxon_Load(&response)
        latestVersion := parsed["tag_name"]

        if (latestVersion != SCRIPT_VERSION) {
            return true
        }
    }
    catch {
        ShowTooltip("Failed to check for updates.")
    }
    return false
}

UpdateScript() {
    try {
        ; Download new version
        Download("https://github.com/DarkoKuzmanovic/capsulate/releases/latest/download/Capsulate.ahk", A_ScriptDir .
            "\Capsulate_new.ahk")

        ; Create update batch script
        updateScript := '
        (
        @echo off
        timeout /t 1 /nobreak
        del "' . A_ScriptFullPath . '"
        move "' . A_ScriptDir . '\Capsulate_new.ahk" "' . A_ScriptFullPath . '"
        start "" "' . A_ScriptFullPath . '"
        del "%~f0"
        )'

        FileAppend(updateScript, A_ScriptDir . "\update.bat")
        Run(A_ScriptDir . "\update.bat", , "Hide")
        ExitApp
    }
}

CheckForUpdates(*) {
    if (CheckLatestVersion()) {
        result := MsgBox("A new version is available. Update now?", "Update Available", "YesNo")
        if (result = "Yes") {
            UpdateScript()
        }
    }
    else {
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

            msg := Format("{}: line {} col {} (char {})"
                , (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
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
                , val := StrReplace(val, "\b", "`b")
                , val := StrReplace(val, "\f", "`f")
                , val := StrReplace(val, "\n", "`n")
                , val := StrReplace(val, "\r", "`r")
                , val := StrReplace(val, "\t", "`t")

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

            loop spaces ; ===> changed
                indent .= " "
        }
        indt := ""

        loop indent ? lvl : 0
            indt .= indent

        is_array := (obj is Array)

        lvl += 1, out := "" ; Make #Warn happy
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
