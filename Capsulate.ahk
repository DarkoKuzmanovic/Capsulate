#Requires AutoHotkey v2.0
#SingleInstance Force
SCRIPT_VERSION := "0.7.0"

; Initialize global variables
global CACHED_CONFIG := LoadConfiguration()
global CAPS_LOCK_TIMEOUT := CACHED_CONFIG["CapsLockTimeout"]
global DOUBLE_CLICK_COUNT := CACHED_CONFIG["DoubleClickCount"]
global TOOLTIP_POSITION := CACHED_CONFIG["ToolTipPosition"]
global DOUBLE_CLICK_ACTION := CACHED_CONFIG["DoubleClickAction"]

global capsLockPressed := false
global waitingForChord := false
global capsLockTimer := 0
global capsLockCount := 0

SetCapsLockState "AlwaysOff"
SetTrayIcon()

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

A_IconTip := "Capsulate v" . SCRIPT_VERSION . " - Enhance Your Caps Lock"

trayMenu := A_TrayMenu
trayMenu.Delete()
trayMenu.Add("Capsulate v" . SCRIPT_VERSION, (*) => {})
trayMenu.Disable("Capsulate v" . SCRIPT_VERSION)
trayMenu.Add()
trayMenu.Add("Check for Updates", CheckForUpdates)
trayMenu.Add("Run at Startup", (*) => ToggleStartup())
trayMenu.Add()
trayMenu.Add("Configuration`tCapsLock+Alt+C", (*) => ShowUnifiedConfigGUI())
trayMenu.Add("Exit", (*) => ExitApp())

SetTimer SetTrayIcon, 5000

if (CheckLatestVersion()) {
    ShowTooltip("A new version is available!")
}

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
    SetTimer () => ToolTip(), -2000
}
Esc:: {
    SendInput "e"
    Sleep 50
    SendInput "!u"
    Sleep 50
    SendInput "{Down}"
    Sleep 50
    SendInput "{Right}"
    Sleep 50
    SendInput "{Down}"
    Sleep 50
    SendInput "{Enter}"
    WinWaitActive "Enter name of file to save to…"
    Sleep 1000
    SendInput "^v"
    Sleep 50
    SendInput "{Enter}"
}
#HotIf

#HotIf waitingForChord
L:: ConvertCase("lower")
U:: ConvertCase("upper")
C:: ConvertCase("camel")
T:: ConvertCase("title")
Space:: ConvertCase("trim")
#HotIf

GetSelectedText() {
    static lastOperation := 0
    currentTime := A_TickCount

    ; Throttle clipboard operations
    if (currentTime - lastOperation < 100) {
        Sleep 50
    }

    try {
        savedClipboard := ClipboardAll()
        A_Clipboard := ""
        Send "^c"
        if !ClipWait(0.5) {
            throw Error("Failed to get clipboard content")
        }
        selectedText := A_Clipboard
        A_Clipboard := savedClipboard
        lastOperation := A_TickCount
        return selectedText
    } catch Error as err {
        ShowTooltip("Error getting selected text: " err.Message)
        return ""
    }
}

LaunchShortcut(key) {
    path := IniRead(A_ScriptDir . "\config.ini", "Shortcuts", key, "")
    if (path != "")
        Run(path)
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
    savedClipboard := ClipboardAll
    A_Clipboard := ""
    SendInput "^{Left}^+{Right}^c"
    ClipWait(0.5)
    word := A_Clipboard
    A_Clipboard := savedClipboard
    return Trim(word)
}

GetExpansion(word) {
    return IniRead(A_ScriptDir . "\expansions.ini", "Expansions", word, "")
}

ShowUnifiedConfigGUI() {
    global CACHED_CONFIG

    configGui := Gui(, "Capsulate Configuration")
    configGui.SetFont("s9", "Segoe UI")

    tabs := configGui.Add("Tab3", "w400 h400", ["General", "Text Expander"])

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

    tabs.UseTab()
    configGui.Add("Button", "x20 y410 w100", "Save").OnEvent("Click", (*) => SaveUnifiedConfig(configGui, timeoutEdit,
        doubleClickCountEdit, tooltipPositionDropdown, doubleClickActionEdit))
    configGui.Add("Button", "x130 y410 w100", "Cancel").OnEvent("Click", (*) => configGui.Destroy())

    configGui.Show()
}

SaveUnifiedConfig(configGui, timeoutEdit, doubleClickCountEdit, tooltipPositionDropdown, doubleClickActionEdit) {
    global CACHED_CONFIG, CAPS_LOCK_TIMEOUT, DOUBLE_CLICK_COUNT, TOOLTIP_POSITION, DOUBLE_CLICK_ACTION

    CACHED_CONFIG["CapsLockTimeout"] := timeoutEdit.Value
    CACHED_CONFIG["DoubleClickCount"] := doubleClickCountEdit.Value
    CACHED_CONFIG["ToolTipPosition"] := tooltipPositionDropdown.Value = "Near Mouse" ? 1 : 0
    CACHED_CONFIG["DoubleClickAction"] := doubleClickActionEdit.Value

    CAPS_LOCK_TIMEOUT := CACHED_CONFIG["CapsLockTimeout"]
    DOUBLE_CLICK_COUNT := CACHED_CONFIG["DoubleClickCount"]
    TOOLTIP_POSITION := CACHED_CONFIG["ToolTipPosition"]
    DOUBLE_CLICK_ACTION := CACHED_CONFIG["DoubleClickAction"]

    configFile := A_ScriptDir . "\config.ini"
    IniWrite(CACHED_CONFIG["CapsLockTimeout"], configFile, "General", "CapsLockTimeout")
    IniWrite(CACHED_CONFIG["DoubleClickCount"], configFile, "General", "DoubleClickCount")
    IniWrite(CACHED_CONFIG["ToolTipPosition"], configFile, "General", "ToolTipPosition")
    IniWrite(CACHED_CONFIG["DoubleClickAction"], configFile, "General", "DoubleClickAction")

    loop 10 {
        key := A_Index - 1
        path := IniRead(A_ScriptDir . "\config.ini", "Shortcuts", key, "")
        if (path != "")
            IniWrite(path, configFile, "Shortcuts", key)
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
            if (parts.Length == 2)
                lv.Add(parts[1], parts[2])
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

LoadConfiguration() {
    try {
        configFile := A_ScriptDir . "\config.ini"
        if !FileExist(configFile) {
            CreateDefaultConfig(configFile)
        }
        
        return Map(
            "CapsLockTimeout", IniRead(configFile, "General", "CapsLockTimeout", 300),
            "DoubleClickCount", IniRead(configFile, "General", "DoubleClickCount", 2),
            "ToolTipPosition", IniRead(configFile, "General", "ToolTipPosition", 1),
            "DoubleClickAction", IniRead(configFile, "General", "DoubleClickAction", "{Esc}")
        )
    } catch Error as err {
        MsgBox "Error loading configuration: " err.Message
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

    )",
        configFile
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
    chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
    password := ""
    loop 16 {
        randomIndex := Random(1, StrLen(chars))
        password .= SubStr(chars, randomIndex, 1)
    }
    A_Clipboard := password
    ShowTooltip("Password generated and copied to clipboard!")
}

ConvertCase(caseType) {
    global waitingForChord
    waitingForChord := false
    ToolTip()

    savedClipboard := ClipboardAll
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

    Sleep 100
    A_Clipboard := savedClipboard
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
    ProcessClose("XMouseButtonControl.exe")
    Run("XMouseButtonControl.exe")
    ShowTooltip("XMouseButtonControl restarted")
}

CheckLatestVersion() {
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        url := "https://api.github.com/repos/yourusername/Capsulate/releases/latest"
        whr.Open("GET", url, true)
        whr.Send()
        whr.WaitForResponse()
        
        if (whr.Status = 200) {
            response := Jxon_Load(whr.ResponseText)
            latestVersion := response["tag_name"]
            return latestVersion > SCRIPT_VERSION
        }
        return false
    } catch Error as err {
        ShowTooltip("Error checking for updates: " err.Message)
        return false
    }
}

UpdateScript() {
    try {
        Download("https://github.com/yourusername/Capsulate/releases/latest/download/Capsulate.ahk", A_ScriptDir .
            "\Capsulate_new.ahk")

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
    } catch {
        ShowTooltip("Failed to update script.")
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
