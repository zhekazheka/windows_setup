; ============================================================
; keyboard-nav.ahk — Mouseless navigation for Windows
; AutoHotkey v2.0+
;
; Place in: shell:startup (Win+R → shell:startup)
;
; MODIFIER KEY: CapsLock
;   CapsLock is repurposed as a modifier key (like a Fn key).
;   Tap CapsLock alone = Escape (useful everywhere)
;   Hold CapsLock + key  = navigation/mouse actions
; ============================================================

if !A_IsAdmin {
    Run '*RunAs "' A_ScriptFullPath '"'
    ExitApp
}

#Requires AutoHotkey v2.0
#SingleInstance Force
SetMouseDelay -1
CoordMode "Mouse", "Screen"
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")

; --- Remap CapsLock ---
g_CapsDown := false
g_CapsUsed := false

*CapsLock:: {
    global g_CapsDown, g_CapsUsed
    g_CapsDown := true
    g_CapsUsed := false
}

*CapsLock up:: {
    global g_CapsDown, g_CapsUsed
    g_CapsDown := false
    if (!g_CapsUsed)
        Send "{Escape}"
}

#CapsLock::SetCapsLockState(!GetKeyState("CapsLock", "T") ? "On" : "Off")

MarkUsed() {
    global g_CapsUsed
    g_CapsUsed := true
}

; ============================================================
; SCROLLING — CapsLock + j/k/d/u/g/G/h/l
; ============================================================

#HotIf GetKeyState("CapsLock", "P")
j:: {
    MarkUsed()
    Send "{WheelDown 3}"
}

k:: {
    MarkUsed()
    Send "{WheelUp 3}"
}

d:: {
    MarkUsed()
    Send "{WheelDown 10}"
}

u:: {
    MarkUsed()
    Send "{WheelUp 10}"
}

g:: {
    MarkUsed()
    Send "{Home}"
}

+g:: {
    MarkUsed()
    Send "{End}"
}

h:: {
    MarkUsed()
    Send "{WheelLeft 3}"
}

l:: {
    MarkUsed()
    Send "{WheelRight 3}"
}

; ============================================================
; MOUSE CURSOR MOVEMENT — CapsLock + Arrow Keys
; ============================================================

g_MouseSpeed := 30
g_MouseSlowSpeed := 5

Left:: {
    MarkUsed()
    MouseGetPos(&mx, &my)
    DllCall("SetCursorPos", "int", mx - g_MouseSpeed, "int", my)
}

Right:: {
    MarkUsed()
    MouseGetPos(&mx, &my)
    DllCall("SetCursorPos", "int", mx + g_MouseSpeed, "int", my)
}

Up:: {
    MarkUsed()
    MouseGetPos(&mx, &my)
    DllCall("SetCursorPos", "int", mx, "int", my - g_MouseSpeed)
}

Down:: {
    MarkUsed()
    MouseGetPos(&mx, &my)
    DllCall("SetCursorPos", "int", mx, "int", my + g_MouseSpeed)
}

+Left:: {
    MarkUsed()
    MouseGetPos(&mx, &my)
    DllCall("SetCursorPos", "int", mx - g_MouseSlowSpeed, "int", my)
}

+Right:: {
    MarkUsed()
    MouseGetPos(&mx, &my)
    DllCall("SetCursorPos", "int", mx + g_MouseSlowSpeed, "int", my)
}

+Up:: {
    MarkUsed()
    MouseGetPos(&mx, &my)
    DllCall("SetCursorPos", "int", mx, "int", my - g_MouseSlowSpeed)
}

+Down:: {
    MarkUsed()
    MouseGetPos(&mx, &my)
    DllCall("SetCursorPos", "int", mx, "int", my + g_MouseSlowSpeed)
}

; ============================================================
; MOUSE CLICKS — CapsLock + Space/Enter/Backspace
; ============================================================

Space:: {
    MarkUsed()
    Click
}

Enter:: {
    MarkUsed()
    Click "Right"
}

Backspace:: {
    MarkUsed()
    Click 2
}

m:: {
    MarkUsed()
    Click "Middle"
}

; ============================================================
; MOUSE DRAG — CapsLock + Shift + Space
; ============================================================

g_Dragging := false

+Space:: {
    global g_Dragging
    MarkUsed()
    if (g_Dragging) {
        Click "Up"
        g_Dragging := false
    } else {
        Click "Down"
        g_Dragging := true
    }
}

; ============================================================
; QUICK JUMP — CapsLock + number (3x3 grid per monitor)
;   7 8 9
;   4 5 6
;   1 2 3
; ============================================================

GetCurrentMonitor() {
    MouseGetPos(&mx, &my)
    count := MonitorGetCount()
    Loop count {
        MonitorGetWorkArea(A_Index, &mL, &mT, &mR, &mB)
        if (mx >= mL && mx < mR && my >= mT && my < mB)
            return A_Index
    }
    return MonitorGetPrimary()
}

JumpToGrid(n) {
    MarkUsed()
    mon := GetCurrentMonitor()
    MonitorGetWorkArea(mon, &mL, &mT, &mR, &mB)
    w := mR - mL
    ht := mB - mT
    col := Mod(n - 1, 3)
    row := 2 - ((n - 1) // 3)
    x := mL + (col * w / 3) + (w / 6)
    y := mT + (row * ht / 3) + (ht / 6)
    DllCall("SetCursorPos", "int", x, "int", y)
}

1::JumpToGrid(1)
2::JumpToGrid(2)
3::JumpToGrid(3)
4::JumpToGrid(4)
5::JumpToGrid(5)
6::JumpToGrid(6)
7::JumpToGrid(7)
8::JumpToGrid(8)
9::JumpToGrid(9)

; ============================================================
; PAGE NAVIGATION — CapsLock + [ / ]
; ============================================================

[:: {
    MarkUsed()
    Send "{PgUp}"
}

]:: {
    MarkUsed()
    Send "{PgDn}"
}

; ============================================================
; TAB NAVIGATION — CapsLock + Tab / Shift+Tab
; ============================================================

Tab:: {
    MarkUsed()
    Send "{Tab}"
}

+Tab:: {
    MarkUsed()
    Send "+{Tab}"
}

; ============================================================
; GRID HINT OVERLAY — CapsLock + e / CapsLock + Shift+e
;
; Shows a labeled grid across ALL monitors.
; Type 2-char label to jump cursor there.
;   e  = jump only (hover)
;   E  = jump + left click
;
; Each hint is its own small GUI window placed at screen coords.
; Press Escape to cancel.
; ============================================================

; --- Grid Hint Config ---
g_HintFontSize := 14
g_HintFontName := "Consolas"
g_HintGuis := []
g_GridOverlayActive := false

; 3-stage grid: monitor → zone → fine
; Stage 1: pick monitor (1, 2, 3)
; Stage 2: pick zone (3x3 = 9 zones, keys: a s d f g h j k l)
; Stage 3: pick fine cell (3x3 = 9 cells, same keys)
; Effective resolution: 9x9 = 81 positions per monitor

g_ZoneKeys := "asdfghjkl"
g_ZoneCols := 3
g_ZoneRows := 3
g_FineCols := 3
g_FineRows := 3

; --- Helper: show hint GUIs ---
ShowHints(regions) {
    global g_HintGuis, g_HintFontSize, g_HintFontName, g_GridOverlayActive
    g_GridOverlayActive := true
    g_HintGuis := []
    for key, r in regions {
        lbl := r.HasProp("label") ? r.label : key
        boxW := 10 + (StrLen(lbl) * 10)
        boxH := 24
        cx := r.x - (boxW // 2)
        cy := r.y - (boxH // 2)
        g := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale")
        g.BackColor := r.HasProp("bg") ? r.bg : "1a1a2e"
        g.MarginX := 0
        g.MarginY := 0
        fg := r.HasProp("fg") ? r.fg : "e2e8f0"
        g.SetFont("s" g_HintFontSize " w700 c" fg, g_HintFontName)
        g.AddText("x0 y0 w" boxW " h" boxH " Center", lbl)
        g.Show("x" cx " y" cy " w" boxW " h" boxH " NoActivate")
        g_HintGuis.Push(g)
    }
}

DestroyHints() {
    global g_HintGuis, g_GridOverlayActive
    for g in g_HintGuis
        g.Destroy()
    g_HintGuis := []
    g_GridOverlayActive := false
}

; Wait for one key from allowed string, or Escape
WaitKey(allowed, timeout := 4) {
    ih := InputHook("L1 T" timeout, "{Escape}")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey" || ih.EndReason = "Timeout")
        return ""
    k := ih.Input
    if InStr(allowed, k)
        return k
    return ""
}

; Main 3-stage grid jump
GridJump(doClick := false) {
    global g_ZoneKeys, g_ZoneCols, g_ZoneRows, g_FineCols, g_FineRows

    ; --- Stage 1: pick a monitor ---
    monCount := MonitorGetCount()
    monRegions := Map()
    monAllowed := ""
    Loop monCount {
        MonitorGet(A_Index, &mL, &mT, &mR, &mB)
        key := String(A_Index)
        cx := mL + ((mR - mL) / 2)
        cy := mT + ((mB - mT) / 2)
        monRegions[key] := {
            x: cx, y: cy,
            left: mL, top: mT, w: mR - mL, h: mB - mT,
            bg: "0f3460", fg: "e94560",
            label: "[" key "]"
        }
        monAllowed .= key
    }

    ShowHints(monRegions)
    mk := WaitKey(monAllowed)
    DestroyHints()

    if (mk = "")
        return

    mon := monRegions[mk]

    ; --- Stage 2: pick a zone on that monitor ---
    zoneRegions := Map()
    keyIdx := 1
    cellW := mon.w / g_ZoneCols
    cellH := mon.h / g_ZoneRows

    Loop g_ZoneRows {
        row := A_Index
        Loop g_ZoneCols {
            col := A_Index
            if (keyIdx > StrLen(g_ZoneKeys))
                break
            key := SubStr(g_ZoneKeys, keyIdx, 1)
            cx := mon.left + ((col - 1) * cellW) + (cellW / 2)
            cy := mon.top + ((row - 1) * cellH) + (cellH / 2)
            zoneRegions[key] := {
                x: cx, y: cy,
                left: mon.left + ((col - 1) * cellW),
                top: mon.top + ((row - 1) * cellH),
                w: cellW, h: cellH
            }
            keyIdx++
        }
    }

    ShowHints(zoneRegions)
    zk := WaitKey(g_ZoneKeys)
    DestroyHints()

    if (zk = "" || !zoneRegions.Has(zk))
        return

    zone := zoneRegions[zk]
    DllCall("SetCursorPos", "int", zone.x, "int", zone.y)

    ; --- Stage 3: fine position within zone ---
    fineRegions := Map()
    fKeyIdx := 1
    fCellW := zone.w / g_FineCols
    fCellH := zone.h / g_FineRows

    Loop g_FineRows {
        row := A_Index
        Loop g_FineCols {
            col := A_Index
            if (fKeyIdx > StrLen(g_ZoneKeys))
                break
            key := SubStr(g_ZoneKeys, fKeyIdx, 1)
            fx := zone.left + ((col - 1) * fCellW) + (fCellW / 2)
            fy := zone.top + ((row - 1) * fCellH) + (fCellH / 2)
            fineRegions[key] := {x: fx, y: fy, bg: "2d2d4e", fg: "7dd3fc"}
            fKeyIdx++
        }
    }

    ShowHints(fineRegions)
    fk := WaitKey(g_ZoneKeys)
    DestroyHints()

    if (fk = "" || !fineRegions.Has(fk))
        return

    target := fineRegions[fk]
    DllCall("SetCursorPos", "int", target.x, "int", target.y)

    if (doClick) {
        Sleep 30
        Click
    }
}

; CapsLock + e = grid jump (hover)
e:: {
    MarkUsed()
    GridJump(false)
}

; CapsLock + Shift+e = grid jump + click
+e:: {
    MarkUsed()
    GridJump(true)
}

#HotIf ; End CapsLock context

; ============================================================
; HIDE WINDOWS TASKBAR
; ============================================================

HideTaskbar() {
    DllCall("ShowWindow", "Ptr", WinExist("ahk_class Shell_TrayWnd"), "Int", 0)
    DetectHiddenWindows(true)
    tbList := WinGetList("ahk_class Shell_SecondaryTrayWnd")
    for hwnd in tbList
        DllCall("ShowWindow", "Ptr", hwnd, "Int", 0)
    DetectHiddenWindows(false)
}

ShowTaskbar() {
    DetectHiddenWindows(true)
    DllCall("ShowWindow", "Ptr", WinExist("ahk_class Shell_TrayWnd"), "Int", 8)
    for hwnd in WinGetList("ahk_class Shell_SecondaryTrayWnd")
        DllCall("ShowWindow", "Ptr", hwnd, "Int", 8)
    DetectHiddenWindows(false)
}

OnExit((*) => ShowTaskbar())

; ============================================================
; TRAY MENU
; ============================================================

A_TrayMenu.Add("Reload Script", (*) => Reload())
A_TrayMenu.Add("Edit Script", (*) => Edit())
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitApp())

TraySetIcon("Shell32.dll", 25)

; ============================================================
; CHEAT SHEET (tooltip) — Win+F1
; ============================================================

g_CheatVisible := false

#F1:: {
    global g_CheatVisible
    if (g_CheatVisible) {
        ToolTip
        g_CheatVisible := false
    } else {
        cheat := "
        (
╔══════════════════════════════════════╗
║   KEYBOARD NAV CHEAT SHEET          ║
║   Modifier: CapsLock (hold)         ║
╠══════════════════════════════════════╣
║ SCROLL                              ║
║   j / k      Scroll down / up       ║
║   d / u      Half-page down / up    ║
║   h / l      Scroll left / right    ║
║   g / G      Home / End             ║
║   [ / ]      Page Up / Page Down    ║
╠══════════════════════════════════════╣
║ MOUSE CURSOR                        ║
║   Arrows     Move cursor (fast)     ║
║   Shift+Arr  Move cursor (slow)     ║
║   1-9        Jump to screen grid    ║
╠══════════════════════════════════════╣
║ GRID HINTS (3-stage zoom)            ║
║   e          Pick monitor→zone→fine ║
║   E          Same + left click      ║
║   (press 1/2/3 then letter, Esc=X) ║
╠══════════════════════════════════════╣
║ MOUSE CLICKS                        ║
║   Space      Left click             ║
║   Enter      Right click            ║
║   Backspace  Double click           ║
║   m          Middle click           ║
║   Shift+Spc  Toggle drag            ║
╠══════════════════════════════════════╣
║ OTHER                               ║
║   CapsLock   Tap alone = Escape     ║
║   Win+Caps   Toggle real CapsLock   ║
║   Win+F1     Show/hide this help    ║
╚══════════════════════════════════════╝
        )"
        ToolTip cheat, 100, 100
        g_CheatVisible := true
    }
}