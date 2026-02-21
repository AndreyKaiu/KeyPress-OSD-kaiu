; ==============================================================================
; KeyPress-OSD-kaiu v1.0, date: 2026-02-19 Author: https://github.com/AndreyKaiu
; ==============================================================================
; Script for showing pressed hotkeys. 
; Press Ctrl+Esc to end the script. Shift+Esc will temporarily hide the window. The window can be moved with the mouse to the desired area of ​​the screen.
; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
#Persistent
#NoEnv
#SingleInstance force
#MaxHotkeysPerInterval 200
#KeyHistory 0
SetBatchlines, -1
SetWinDelay, -1
SetWorkingDir %A_ScriptDir% ; working directory like a script, otherwise they change through a shortcut 
; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
; #### settings of the main window for viewing key combinations
About := "KeyPress-OSD-kaiu v1.0 (2026-02-19)" ; about the program, shown when loading
DisplayTransparency := 200  ; transparency (0 -do not show, full opacity 255)
KeyDisplayPosX := "Center" ; window position in width (can also be specified as a number)
KeyDisplayPosY := 800 ; window position from top
KeyDisplayWidth := 400 ; window width. Set with reserve for long text
KeyDisplayHeight := 30 ; window height. If the font is very large, you may have to change it.
FontSizeAbout := 10 ; font size for displaying help about the program 
FontSize := 16 ; font size for hotkey command output
FontColor := "White" ; font color (entry "0x0000FF" for blue in RGB format)
BgColor := "Black" ; window background color. Font and background colors should not be the same
FontStyle := "Bold" ; font style
FontName := "Arial" ; font name
TimeHidingText := 1200 ; time in ms after which the hotkey text will be hidden Hide display after
HideDisplayAfter := 100 ; time in ms after which the window is displayed after hiding the text, 0 -show the window constantly
; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
; #### circle settings for showing the mouse click zone ===
CircleEnable := 1 ; 1 - Allowed to show circle, 0 -do not show
CircleTransparency := 150 ; transparency (0 -do not show, full opacity 255)
CircleDiameter := 50 ; circle diameter
CircleColorLButton := "Yellow" ; for the left mouse button (entry "0xFF0000" for red in RGB format)
CircleColorMButton := "Gray" ; for middle mouse button (entry "0x808080" for gray in RGB format)
CircleColorRButton := "Blue" ; for the right mouse button (entry "0x0000FF" for blue in RGB format)
; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−
    
    
; loading settings from the settings.ini file
#Include __loading_settings.ahk

LoadSettings()


; Set the mouse coordinate mode globally
CoordMode, Mouse, Screen

; Variables for dragging
Dragging := false
OffsetX := 0
OffsetY := 0

; Variables for displaying hotkeys
SettingsGuiIsOpen := 0
FirstShow := 1
LastKey := ""
LastDisplayText := ""
LastModifiers := ""
SwitchVisibleGui := 1
WinX := KeyDisplayPosX
WinY := KeyDisplayPosY
TimeResetLastKey := 500 ; It's better not to change. Affects the display time of several text characters
TimeResetLastDisplayText := 400 ; It's better not to change. Time to display a combination of symbols before changing to the next one

; Global variables for circle
hCircle := 0
CircleActive := false
StopShowCircle := 0
CircleColor := CircleColorLButton
HoleDiameter := CircleDiameter - 10
RightClickActive := false
RightClickTimer := 0




; Create a window FIRST (without display)
Gui, CircleGui:New, +E0x20 +AlwaysOnTop -Caption +ToolWindow +LastFound +HwndhCircle
Gui, CircleGui:Color, %CircleColor%
Gui, CircleGui:Show, xCenter y500 w%CircleDiameter% h%CircleDiameter% NoActivate
WinSet, Transparent, %CircleTransparency%

; Create an outer circle
hOuterRgn := DllCall("CreateEllipticRgn", "Int", 0, "Int", 0, "Int", CircleDiameter, "Int", CircleDiameter)

; Create an inner circle (in the center)
InnerOffset := (CircleDiameter - HoleDiameter) // 2
hInnerRgn := DllCall("CreateEllipticRgn", "Int", InnerOffset, "Int", InnerOffset, "Int", InnerOffset + HoleDiameter, "Int", InnerOffset + HoleDiameter)

; Merge areas: outer circle minus inner circle = donut (RGN_DIFF = 3)
hDonutRgn := DllCall("CreateRectRgn", "Int", 0, "Int", 0, "Int", 0, "Int", 0) ; Empty area
DllCall("CombineRgn", "Ptr", hDonutRgn, "Ptr", hOuterRgn, "Ptr", hInnerRgn, "Int", 3) ; RGN_DIFF

; Applying an area to a window
DllCall("SetWindowRgn", "Ptr", hCircle, "Ptr", hDonutRgn, "UInt", True)

; Free temporary areas (except for hDonutRgn, it now belongs to the window)
DllCall("DeleteObject", "Ptr", hOuterRgn)
DllCall("DeleteObject", "Ptr", hInnerRgn)

; We update the show
Gui, CircleGui:Show, xCenter y500 w%CircleDiameter% h%CircleDiameter% NoActivate
Gui, CircleGui:Hide


if (FontSize < 1.5*FontSizeAbout) {
    FontSizeAboutNew := FontSize / 1.8 
}
else {
    FontSizeAboutNew := FontSizeAbout
}

; Creating a Hotkey View Window
Gui, KeyDisplayGui:New, +AlwaysOnTop -Caption +ToolWindow +LastFound
Gui, KeyDisplayGui:Color, %BgColor%
Gui, KeyDisplayGui:Font, s%FontSizeAboutNew% c%FontColor% %FontStyle%, %FontName%
SizeWH = w%KeyDisplayWidth% h%KeyDisplayHeight%
Gui, KeyDisplayGui:Add, Text, vTextGui Center %SizeWH%, 
WinSet, Transparent, %DisplayTransparency%
PosXY = x%KeyDisplayPosX% y%KeyDisplayPosY%
Gui, KeyDisplayGui:Show, %PosXY% NoActivate, KeyDisplayGui
 
TextAbout = %About% . `n[Ctrl+Esc] - Exit : [Shift+Esc] - Hide\Show : RClick - Settings
GuiControl, KeyDisplayGui:, TextGui, %TextAbout%
Gui, Show, %PosXY% NoActivate

; How long will we show About
SetTimer, HideTextAbout, -5000




; Mouse handlers
OnMessage(0x201, "WM_LBUTTONDOWN")
OnMessage(0x202, "WM_LBUTTONUP")
OnMessage(0x204, "WM_RBUTTONDOWN")
OnMessage(0x205, "WM_RBUTTONUP")
OnMessage(0x200, "WM_MOUSEMOVE")


; Hotkey for tracking modifiers
Hotkey, IfWinNotActive, KeyDisplayGui
Hotkey, ~*a, KeyPressed
Hotkey, ~*b, KeyPressed
Hotkey, ~*c, KeyPressed
Hotkey, ~*d, KeyPressed
Hotkey, ~*e, KeyPressed
Hotkey, ~*f, KeyPressed
Hotkey, ~*g, KeyPressed
Hotkey, ~*h, KeyPressed
Hotkey, ~*i, KeyPressed
Hotkey, ~*j, KeyPressed
Hotkey, ~*k, KeyPressed
Hotkey, ~*l, KeyPressed
Hotkey, ~*m, KeyPressed
Hotkey, ~*n, KeyPressed
Hotkey, ~*o, KeyPressed
Hotkey, ~*p, KeyPressed
Hotkey, ~*q, KeyPressed
Hotkey, ~*r, KeyPressed
Hotkey, ~*s, KeyPressed
Hotkey, ~*t, KeyPressed
Hotkey, ~*u, KeyPressed
Hotkey, ~*v, KeyPressed
Hotkey, ~*w, KeyPressed
Hotkey, ~*x, KeyPressed
Hotkey, ~*y, KeyPressed
Hotkey, ~*z, KeyPressed

; Numbers
Hotkey, ~*0, KeyPressed
Hotkey, ~*1, KeyPressed
Hotkey, ~*2, KeyPressed
Hotkey, ~*3, KeyPressed
Hotkey, ~*4, KeyPressed
Hotkey, ~*5, KeyPressed
Hotkey, ~*6, KeyPressed
Hotkey, ~*7, KeyPressed
Hotkey, ~*8, KeyPressed
Hotkey, ~*9, KeyPressed

; digital block
Hotkey, ~*sc146, KeyPressed ; NumLock
Hotkey, ~*NumpadDot, KeyPressed
Hotkey, ~*Numpad0, KeyPressed
Hotkey, ~*Numpad1, KeyPressed
Hotkey, ~*Numpad2, KeyPressed
Hotkey, ~*Numpad3, KeyPressed
Hotkey, ~*Numpad4, KeyPressed
Hotkey, ~*Numpad5, KeyPressed
Hotkey, ~*Numpad6, KeyPressed
Hotkey, ~*Numpad7, KeyPressed
Hotkey, ~*Numpad8, KeyPressed
Hotkey, ~*Numpad9, KeyPressed

Hotkey, ~*NumpadDel, KeyPressed
Hotkey, ~*NumpadIns, KeyPressed
Hotkey, ~*NumpadEnd, KeyPressed
Hotkey, ~*NumpadDown, KeyPressed
Hotkey, ~*NumpadPgDn, KeyPressed
Hotkey, ~*NumpadLeft, KeyPressed
Hotkey, ~*NumpadClear, KeyPressed
Hotkey, ~*NumpadRight, KeyPressed
Hotkey, ~*NumpadHome, KeyPressed
Hotkey, ~*NumpadUp, KeyPressed
Hotkey, ~*NumpadPgUp, KeyPressed

Hotkey, ~*NumpadDiv, KeyPressed
Hotkey, ~*NumpadMult, KeyPressed
Hotkey, ~*NumpadSub, KeyPressed
Hotkey, ~*NumpadAdd, KeyPressed
Hotkey, ~*NumpadEnter, KeyPressed

; Function keys
Hotkey, ~*F1, KeyPressed
Hotkey, ~*F2, KeyPressed
Hotkey, ~*F3, KeyPressed
Hotkey, ~*F4, KeyPressed
Hotkey, ~*F5, KeyPressed
Hotkey, ~*F6, KeyPressed
Hotkey, ~*F7, KeyPressed
Hotkey, ~*F8, KeyPressed
Hotkey, ~*F9, KeyPressed
Hotkey, ~*F10, KeyPressed
Hotkey, ~*F11, KeyPressed
Hotkey, ~*F12, KeyPressed

; Special keys
Hotkey, ~*CapsLock, KeyPressed
Hotkey, ~*PrintScreen, KeyPressed
Hotkey, ~*sc046, KeyPressed ; ScrollLock
Hotkey, ~*sc146, KeyPressed ; Pause
Hotkey, ~*Space, KeyPressed
Hotkey, ~*Enter, KeyPressed
Hotkey, ~*Backspace, KeyPressed
Hotkey, ~*Tab, KeyPressed
Hotkey, ~*Escape, KeyPressed
Hotkey, ~*Delete, KeyPressed
Hotkey, ~*Insert, KeyPressed
Hotkey, ~*Home, KeyPressed
Hotkey, ~*End, KeyPressed
Hotkey, ~*PgUp, KeyPressed
Hotkey, ~*PgDn, KeyPressed
Hotkey, ~*Up, KeyPressed
Hotkey, ~*Down, KeyPressed
Hotkey, ~*Left, KeyPressed
Hotkey, ~*Right, KeyPressed

; modifiers 
Hotkey, ~*Shift, KeyPressed
Hotkey, ~*Shift Up, KeyPressed
Hotkey, ~*Ctrl, KeyPressed
Hotkey, ~*Ctrl Up, KeyPressed
Hotkey, ~*Alt, KeyPressed
Hotkey, ~*Alt Up, KeyPressed
Hotkey, ~*LWin, KeyPressed
Hotkey, ~*LWin Up, KeyPressed
Hotkey, ~*RWin, KeyPressed
Hotkey, ~*RWin Up, KeyPressed

Hotkey, ~*LButton, MouseLDown
Hotkey, ~*RButton, MouseRDown
Hotkey, ~*MButton, MouseMDown
Hotkey, ~*LButton Up, MouseUp
Hotkey, ~*RButton Up, MouseUp
Hotkey, ~*MButton Up, MouseUp
Hotkey, ~*WheelUp, KeyPressed
Hotkey, ~*WheelDown, KeyPressed
Hotkey, ~*WheelLeft, KeyPressed
Hotkey, ~*WheelRight, KeyPressed
Hotkey, ~*XButton1, KeyPressed
Hotkey, ~*XButton2, KeyPressed

; Symbol
Hotkey, ~*sc00C, KeyPressed ; -
Hotkey, ~*sc00D, KeyPressed ; =
Hotkey, ~*sc01A, KeyPressed ; [
Hotkey, ~*sc01B, KeyPressed ; ]
Hotkey, ~*sc02B, KeyPressed ; \
Hotkey, ~*sc027, KeyPressed ; ;
Hotkey, ~*sc028, KeyPressed ; '
Hotkey, ~*sc033, KeyPressed ; ,
Hotkey, ~*sc034, KeyPressed ; .
Hotkey, ~*sc035, KeyPressed ; /

; rarely used
Hotkey, ~*Browser_Back, KeyPressed
Hotkey, ~*Browser_Forward, KeyPressed
Hotkey, ~*Browser_Refresh, KeyPressed
Hotkey, ~*Browser_Stop, KeyPressed
Hotkey, ~*Browser_Search, KeyPressed
Hotkey, ~*Browser_Favorites, KeyPressed
Hotkey, ~*Browser_Home, KeyPressed
Hotkey, ~*Volume_Mute, KeyPressed
Hotkey, ~*Volume_Down, KeyPressed
Hotkey, ~*Volume_Up, KeyPressed
Hotkey, ~*Media_Next, KeyPressed
Hotkey, ~*Media_Prev, KeyPressed
Hotkey, ~*Media_Stop, KeyPressed
Hotkey, ~*Media_Play_Pause, KeyPressed
Hotkey, ~*Launch_Mail, KeyPressed
Hotkey, ~*Launch_Media, KeyPressed
Hotkey, ~*Launch_App1, KeyPressed
Hotkey, ~*Launch_App2, KeyPressed

Hotkey, If


; menu loading
#Include __menu.ahk

; subroutine executed at the end of the script 
OnExit, OnExitSub


^Esc:: ; Ctrl+Esc to exit the script    
    RegDelete, HKEY_CURRENT_USER\Software\KeyPress_OSD_kaiu, LastArg 
    SaveSettings()    
    gosub OnExitSub
return

+Esc:: ; Shift+Esc for temporary hiding
    gosub SwitchGui
return


; −−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−

OnExitSub:            
    ExitApp
return


HideTextAbout:   
    global TimeHidingText
    
    if (SettingsGuiIsOpen)
        return
        
    Gui, KeyDisplayGui:Font, s%FontSize% c%FontColor% %FontStyle%, %FontName%
    GuiControl, KeyDisplayGui:Font, TextGui        
    GuiControl, KeyDisplayGui:, TextGui,
    Gui, KeyDisplayGui:Show, NoActivate
    if (TimeHidingText != 0) {            
        SetTimer, HideTextGui, -%TimeHidingText%
    }
    else {
        SetTimer, HideTextGui, -1
    }
return

; toggle window visibility
SwitchGui:
    global SwitchVisibleGui, WinX, WinY, HideDisplayAfter
    
    SwitchVisibleGui := !SwitchVisibleGui
        
    if (SwitchVisibleGui) {        
        if (HideDisplayAfter != 0) {
            SetTimer, HideTextGui, -%HideDisplayAfter%
        }
        SetTimer, ShowKeyDisplayGui, -40        
    }
    else {         
        SetTimer, HideKeyDisplayGui, -40        
    }
return 


ShowKeyDisplayGui:
    global HideDisplayAfter
    SetTimer, ShowKeyDisplayGui, off
    if (HideDisplayAfter != 0 || SettingsGuiIsOpen) {
        Gui, KeyDisplayGui:Show, NoActivate
    }    
return

HideKeyDisplayGui:
    global HideDisplayAfter
    SetTimer, HideKeyDisplayGui, off
    if (HideDisplayAfter != 0 && !SettingsGuiIsOpen) {
        Gui, KeyDisplayGui:Hide
    }
return

HideTextGui:
    global LastKey, LastModifiers, TimeHidingText, HideDisplayAfter
    
    if (SettingsGuiIsOpen)
        return
    
    GuiControl, KeyDisplayGui:, TextGui,    
    LastKey := ""
    LastModifiers := ""    
    if (HideDisplayAfter != 0) {
        SetTimer, HideKeyDisplayGui, -%HideDisplayAfter%
    }    
return


; Turn on/off circle
ToggleCircle() {
    global CircleActive, hCircle    
    if (CircleActive) {
        HideCircle()
    } else {
        ShowCircle()        
    }    
}

; Show circle
ShowCircle() {
    global CircleActive, CircleEnable, hCircle, CircleDiameter, CircleColor, CircleTransparency   
    
    if (CircleEnable){
        Gui, CircleGui:Show, NoActivate
        
        CircleActive := true
        
        ; Immediately move the circle to the current mouse position
        UpdateCirclePosition()
    }
}

MouseLDown:    
    global StopShowCircle, CircleEnable
    ShowKeyPress("Click")    
    StopShowCircle := 0    
    if (CircleEnable){
        if (CircleColor != CircleColorLButton) {
            CircleColor := CircleColorLButton
            Gui, CircleGui:Color, %CircleColor%
        }        
        ShowCircle()
        SetTimer, TimerUpdateCirclePosition, 1
    }        
return

MouseRDown:    
    global StopShowCircle, CircleEnable
    ShowKeyPress("Right Click")    
    StopShowCircle := 0
    if (CircleEnable){
        if (CircleColor != CircleColorRButton) {
            CircleColor := CircleColorRButton
            Gui, CircleGui:Color, %CircleColor%
        }
        ShowCircle()
        SetTimer, TimerUpdateCirclePosition, 1
    }
return

MouseMDown:    
    global StopShowCircle, CircleEnable
    ShowKeyPress("Middle Click")    
    StopShowCircle := 0
    if (CircleEnable){
        if (CircleColor != CircleColorMButton) {
            CircleColor := CircleColorMButton
            Gui, CircleGui:Color, %CircleColor%
        }
        ShowCircle()
        SetTimer, TimerUpdateCirclePosition, 1
    }
return


TimerUpdateCirclePosition:
    global StopShowCircle, hCircle, CircleDiameter, CircleEnable    
    if (CircleEnable) {
        CoordMode, Mouse, Screen
        MouseGetPos, mouseX, mouseY
        cd2 := CircleDiameter/2
        lastmouseX := mouseX
        lastmouseY := mouseY     
        SetWinDelay, -1
        
        ; We ignore if our window is active
        if WinActive("KeyDisplayGui") {
            StopShowCircle := 1
            goto MouseUp
            return    
        }
        
        while (StopShowCircle = 0) {              
            MouseGetPos, mouseX, mouseY
            if (mouseX != lastmouseX || mouseY != lastmouseY) {                           
                WinMove, ahk_id %hCircle%, , mouseX - cd2, mouseY - cd2                           
                lastmouseX := mouseX
                lastmouseY := mouseY
            }
        }    
    }
return

MouseUp:
    global StopShowCircle
    SetTimer, TimerUpdateCirclePosition, off
    StopShowCircle := 1
    SetTimer, HideCircleTmr, -100
return 
    
HideCircleTmr:
    SetTimer, HideCircleTmr, off
    HideCircle()
return


; Hide circle
HideCircle() {
    global CircleActive, hCircle
    if (hCircle) {
        Gui, CircleGui:Hide
    }
    CircleActive := false        
}

; Update circle position
UpdateCirclePosition() {
    global hCircle, CircleDiameter
    if (hCircle) {
        CoordMode, Mouse, Screen
        MouseGetPos, mouseX, mouseY
        WinMove, ahk_id %hCircle%, , mouseX - CircleDiameter/2, mouseY - CircleDiameter/2 
    }       
}




ShowKeyPress(KeyName) {
    global LastKey, LastDisplayText, LastModifiers, HideDisplayAfter, TimeResetLastKey, TimeResetLastDisplayText, SwitchVisibleGui, FirstShow, SettingsGuiIsOpen
    
    ; CurrentTime := A_TickCount  ; It might be necessary to add if you need to control the time more precisely.
    if (SettingsGuiIsOpen)
        return
    
    ; Getting the current modifiers
    Modifiers := ""
    if (GetKeyState("Ctrl", "P") ) {
        Modifiers .= "CTRL + "
        ; We don’t count the pressed key
        if(KeyName = "CTRL") {
            KeyName := ""
        }
    }
        
    if (GetKeyState("Alt", "P") ) {
        Modifiers .= "ALT + "
        ; We don’t count the pressed key
        if(KeyName = "ALT") {
            KeyName := ""
        }
    }
        
    if (GetKeyState("Shift", "P") ) {
        Modifiers .= "SHIFT + "
        ; We don’t count the pressed key
        if(KeyName = "SHIFT") {
            KeyName := ""
        }
    }
        
    if (GetKeyState("LWin", "P") || GetKeyState("RWin") ) {
        Modifiers .= "WIN + "
        ; We don’t count the pressed key 
        if(KeyName = "WIN") {
            KeyName := ""
        }
    }
        
        
    if (KeyName = "Click") {
        if (LastKey = "Click") {
            LastKey := ""
            KeyName := "Click2"
        }
        else if(LastKey = "Click2") {
            LastKey := ""
            KeyName := "Click3"
        }
    }    
        
    
    ; if there is something to output
    if (KeyName != "") {
        DisplayText := ""        
        ; if the previous key has not yet left
        if (LastKey != "") {
            ; if the modifiers have not changed
            if (Modifiers = LastModifiers) {
                ; if not empty modifier
                if (Modifiers != "") {                    
                    DisplayText .= Modifiers . LastKey . " + " . KeyName  
                    LastKey := KeyName
                }
                else {
                    ; if the key has not changed, then output it via +
                    if (LastKey = KeyName) {
                        LastKey := KeyName
                        DisplayText .= LastKey . " + " . LastKey
                    }
                    else {
                        LastKey := KeyName
                        DisplayText .= LastKey  
                    }
                }
            }
            else { ; modifiers are different
                DisplayText .= LastModifiers . LastKey . "  ||  " . Modifiers . KeyName 
                LastModifiers := Modifiers 
                LastKey := KeyName             
            }
        }
        else { ; The time spent holding the last key is completed
            ; if the modifiers have not changed
            LastKey := KeyName
            LastModifiers := Modifiers 
            DisplayText .= Modifiers . LastKey         
        }
        
        LastDisplayText := DisplayText 
        
        SetTimer, ResetLastKey, -%TimeResetLastKey%
        SetTimer, ResetLastDisplayText, -%TimeResetLastDisplayText%
    }
    else { ; otherwise it displays the past
        if (LastDisplayText != "") {
            DisplayText := LastDisplayText 
        }
        else {
            DisplayText := Modifiers
            if (Modifiers != "") {
                StringTrimRight, DisplayText, Modifiers, 3 ; Remove the "+" at the end
            }            
        }        
    }
        
    
    ; We do not display a single click, nor do we display mouse scrolling
    if (DisplayText != "Click"
        && DisplayText != "WHEELDOWN" && DisplayText != "WHEELUP"
        && DisplayText != "WHEELLEFT" && DisplayText != "WHEELRIGHT"
        && DisplayText != "WHEELDOWN + WHEELDOWN" && DisplayText != "WHEELUP + WHEELUP"
        && DisplayText != "WHEELLEFT + WHEELLEFT" && DisplayText != "WHEELRIGHT + WHEELRIGHT") {
        
        if (FirstShow) {   
            FirstShow := 0
            SetTimer, HideTextAbout, off
            gosub HideTextAbout 
        }         
        
        GuiControl, KeyDisplayGui:, TextGui, %DisplayText%
        if (SwitchVisibleGui) { ; showing only if allowed             
            Gui, KeyDisplayGui:Show, NoActivate                
        }        
        if (TimeHidingText != 0) {            
            SetTimer, HideTextGui, -%TimeHidingText%
        }
        else {
            SetTimer, HideTextGui, -1
        }
    }
           
}


ResetLastKey:
    global LastKey
    LastKey := ""
return


ResetLastDisplayText:
    global LastDisplayText
    LastDisplayText := ""
return





WM_LBUTTONDOWN() {
    global Dragging, OffsetX, OffsetY, WinX, WinY, HideDisplayAfter, TimeHidingText, SettingsGuiIsOpen       
    
    ; Get the mouse position (in screen coordinates)
    MouseGetPos, MouseX, MouseY    
   
    if( WinActive("KeyDisplayGui") && SwitchVisibleGui) {
        WinGet, Style, Style, KeyDisplayGui
        if (Style & 0x10000000) {  ; WS_VISIBLE style
            WinGetPos, WinX, WinY, , , KeyDisplayGui            
            ; Calculate the offset from the upper left corner of the window to the cursor
            OffsetX := MouseX - WinX
            OffsetY := MouseY - WinY            
            Dragging := true
            ; Capture the mouse to receive events even outside the window   
            SetCapture()
        }
    }        
        
    SetTimer, HideKeyDisplayGui, off
    SetTimer, HideTextGui, off
    SetTimer, HideTextAbout, off
}



WM_LBUTTONUP() {
    global Dragging, HideDisplayAfter, TimeHidingText, SettingsGuiIsOpen    
    
    if (Dragging)
        ReleaseCapture()    
    Dragging := false
    if (!SettingsGuiIsOpen) {
        SetTimer, HideKeyDisplayGui, on
        SetTimer, HideTextGui, on
    }
}



WM_RBUTTONDOWN() {     
    SetTimer, HideKeyDisplayGui, off
    SetTimer, HideTextGui, off
    SetTimer, HideTextAbout, off
    
    ShowSettingsGUI()
}

WM_RBUTTONUP() {     
}



WM_MOUSEMOVE() {
    global Dragging, OffsetX, OffsetY, WinX, WinY, HideDisplayAfter, TimeHidingText, SettingsGuiIsOpen
        
    if (!Dragging)
        return
    
    ; Get the current mouse position (in screen coordinates)
    MouseGetPos, MouseX, MouseY
    
    ; Calculate the new window position (absolutely)
    NewX := MouseX - OffsetX
    NewY := MouseY - OffsetY
    WinX := NewX
    WinY := NewY 
    
    ; Moving the window
    WinMove, KeyDisplayGui, , %NewX%, %NewY%    
}



; Functions for catching/releasing the mouse
SetCapture() {
    DllCall("SetCapture", "ptr", WinActive("KeyDisplayGui"))    
}


ReleaseCapture() {
    DllCall("ReleaseCapture")    
}



; renaming key names
KeyPressed:
    ; Getting the name of the pressed key
    KeyName := SubStr(A_ThisHotkey, 3) ; Remove "~*" from the beginning
                
    ; Handling special names
    if (KeyName = "Escape") {
        KeyName := "ESC"
        gosub MouseUp ; To avoid freezing when activating a click in the tray
    }        
    else if (KeyName = "Delete")
        KeyName := "DEL"
    else if (KeyName = "Insert")
        KeyName := "INS"    
    else if (KeyName = "SC00C")
        KeyName := "-"
    else if (KeyName = "SC00D")
        KeyName := "="
    else if (KeyName = "SC01A")
        KeyName := "["
    else if (KeyName = "SC01B")
        KeyName := "]"
    else if (KeyName = "SC02B")
        KeyName := "\"
    else if (KeyName = "SC027")
        KeyName := ";"
    else if (KeyName = "SC028")
        KeyName := "'"
    else if (KeyName = "SC033")
        KeyName := ","
    else if (KeyName = "SC034")
        KeyName := "."
    else if (KeyName = "SC035")
        KeyName := "/"
    else if (KeyName = "Shift")
        KeyName := "SHIFT"
    else if (KeyName = "Shift Up")
        KeyName := ""
    else if (KeyName = "Ctrl")
        KeyName := "CTRL"
    else if (KeyName = "Ctrl Up")
        KeyName := ""
    else if (KeyName = "ALT")
        KeyName := "ALT"
    else if (KeyName = "Alt Up")
        KeyName := ""
    else if (KeyName = "LWin" || KeyName = "RWin")
        KeyName := "WIN"
    else if (KeyName = "LWin Up" || KeyName = "RWin Up")
        KeyName := ""
    else if (KeyName = "LButton")
        KeyName := "Click"
    else if (KeyName = "RButton")
        KeyName := "Right Click"
    else if (KeyName = "MButton")
        KeyName := "Middle Click"       
            
    else if (KeyName = "SC046")
        KeyName := "ScrollLock"        
    else if (KeyName = "SC146")
        KeyName := "Pause"
             
        
    else if (KeyName = "NumpadDot")  
        KeyName := "NP."    
    else if (KeyName = "Numpad0")  
        KeyName := "NP0"
    else if (KeyName = "Numpad1")  
        KeyName := "NP1"
    else if (KeyName = "Numpad2")  
        KeyName := "NP2"
    else if (KeyName = "Numpad3")  
        KeyName := "NP3"
    else if (KeyName = "Numpad4")  
        KeyName := "NP4"
    else if (KeyName = "Numpad5")  
        KeyName := "NP5"
    else if (KeyName = "Numpad6")  
        KeyName := "NP6"
    else if (KeyName = "Numpad7")  
        KeyName := "NP7"
    else if (KeyName = "Numpad8")  
        KeyName := "NP8"
    else if (KeyName = "Numpad9")  
        KeyName := "NP9"
    
    else if (KeyName = "NumpadDiv")  
        KeyName := "NP/"
    else if (KeyName = "NumpadMult")  
        KeyName := "NP*"
    else if (KeyName = "NumpadSub")  
        KeyName := "NP-"
    else if (KeyName = "NumpadAdd")  
        KeyName := "NP+"
    else if (KeyName = "NumpadEnter")  
        KeyName := "NP-Enter"
    else if (KeyName = "NumpadIns")  
        KeyName := "NP-Ins"
    else if (KeyName = "NumpadEnd")  
        KeyName := "NP-End"
    else if (KeyName = "NumpadDown")  
        KeyName := "NP-Down"
    else if (KeyName = "NumpadPgDn")  
        KeyName := "NP-PgDn"
    else if (KeyName = "NumpadLeft")  
        KeyName := "NP-Left"
    else if (KeyName = "NumpadClear")  
        KeyName := "NP-CLR"
    else if (KeyName = "NumpadRight")  
        KeyName := "NP-Right"
    else if (KeyName = "NumpadHome")  
        KeyName := "NP-Home"
    else if (KeyName = "NumpadUp")  
        KeyName := "NP-Up"
    else if (KeyName = "NumpadPgUp")  
        KeyName := "NP-PgUp"
    else if (KeyName = "NumpadDel")  
        KeyName := "NP-Del"    
    else if (KeyName = "SC146")
        KeyName := "NumLock"
    else {
        KeyName := Format("{:U}", KeyName)
    }
    
            
    ShowKeyPress(KeyName)
return

