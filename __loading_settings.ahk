; file from which settings are loaded
NameIniFile := "settings.ini"

; the first command line parameter can be the name of a settings file
if( A_Args[1] <> "" ) {
    NameIniFile := A_Args[1]
}
else {
    ; check if there was a "Reload" command before    
    RegRead, NewLastArg, HKEY_CURRENT_USER\Software\KeyPress_OSD_kaiu, LastArg
    if !ErrorLevel
    {
        NameIniFile := NewLastArg        
    }     
}

LS_HelpFile := "help.txt"


LoadSettings() {
    global NameIniFile
    global DisplayTransparency
    global KeyDisplayPosX
    global KeyDisplayPosY
    global KeyDisplayWidth
    global KeyDisplayHeight
    global FontSizeAbout
    global FontSize
    global FontColor
    global BgColor
    global FontStyle
    global FontName
    global TimeHidingText
    global TimeShowKeyDisplayGui
    global CircleEnable
    global CircleTransparency
    global CircleDiameter
    global CircleColorLButton
    global CircleColorMButton
    global CircleColorRButton
    global LS_HelpFile
    
    
    IniRead, DisplayTransparency, %NameIniFile%, KEYPRESS-OSD-KAIU, DisplayTransparency, 120
    IniRead, KeyDisplayPosX, %NameIniFile%, KEYPRESS-OSD-KAIU, KeyDisplayPosX, Center 
    IniRead, KeyDisplayPosY, %NameIniFile%, KEYPRESS-OSD-KAIU, KeyDisplayPosY, 800
    IniRead, KeyDisplayWidth, %NameIniFile%, KEYPRESS-OSD-KAIU, KeyDisplayWidth, 400
    IniRead, KeyDisplayHeight, %NameIniFile%, KEYPRESS-OSD-KAIU, KeyDisplayHeight, 30
    IniRead, FontSizeAbout, %NameIniFile%, KEYPRESS-OSD-KAIU, FontSizeAbout, 10
    IniRead, FontSize, %NameIniFile%, KEYPRESS-OSD-KAIU, FontSize, 16
    IniRead, FontColor, %NameIniFile%, KEYPRESS-OSD-KAIU, FontColor, White
    IniRead, BgColor, %NameIniFile%, KEYPRESS-OSD-KAIU, BgColor, Black
    IniRead, FontStyle, %NameIniFile%, KEYPRESS-OSD-KAIU, FontStyle, Bold
    IniRead, FontName, %NameIniFile%, KEYPRESS-OSD-KAIU, FontName, Arial
    IniRead, TimeHidingText, %NameIniFile%, KEYPRESS-OSD-KAIU, TimeHidingText, 1500
    IniRead, TimeShowKeyDisplayGui, %NameIniFile%, KEYPRESS-OSD-KAIU, TimeShowKeyDisplayGui, 500
    IniRead, CircleEnable, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleEnable, 1
    IniRead, CircleTransparency, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleTransparency, 150
    IniRead, CircleDiameter, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleDiameter, 50
    IniRead, CircleColorLButton, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleColorLButton, Yellow
    IniRead, CircleColorMButton, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleColorMButton, Gray
    IniRead, CircleColorRButton, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleColorRButton, Blue  
    IniRead, LS_HelpFile, %NameIniFile%, KEYPRESS-OSD-KAIU, HelpFile, help.txt
}


SaveSettings() {
    global NameIniFile
    global DisplayTransparency
    global KeyDisplayPosX
    global KeyDisplayPosY
    global KeyDisplayWidth
    global KeyDisplayHeight
    global FontSizeAbout
    global FontSize
    global FontColor
    global BgColor
    global FontStyle
    global FontName
    global TimeHidingText
    global TimeShowKeyDisplayGui
    global CircleEnable
    global CircleTransparency
    global CircleDiameter
    global CircleColorLButton
    global CircleColorMButton
    global CircleColorRButton
    global WinX
    global WinY
    global LS_HelpFile
    
    KeyDisplayPosX := WinX
    KeyDisplayPosY := WinY
        
    
    IniWrite, %DisplayTransparency%, %NameIniFile%, KEYPRESS-OSD-KAIU, DisplayTransparency
    IniWrite, %KeyDisplayPosX%, %NameIniFile%, KEYPRESS-OSD-KAIU, KeyDisplayPosX
    IniWrite, %KeyDisplayPosY%, %NameIniFile%, KEYPRESS-OSD-KAIU, KeyDisplayPosY
    IniWrite, %KeyDisplayWidth%, %NameIniFile%, KEYPRESS-OSD-KAIU, KeyDisplayWidth
    IniWrite, %KeyDisplayHeight%, %NameIniFile%, KEYPRESS-OSD-KAIU, KeyDisplayHeight
    IniWrite, %FontSizeAbout%, %NameIniFile%, KEYPRESS-OSD-KAIU, FontSizeAbout
    IniWrite, %FontSize%, %NameIniFile%, KEYPRESS-OSD-KAIU, FontSize
    IniWrite, %FontColor%, %NameIniFile%, KEYPRESS-OSD-KAIU, FontColor
    IniWrite, %BgColor%, %NameIniFile%, KEYPRESS-OSD-KAIU, BgColor
    IniWrite, %FontStyle%, %NameIniFile%, KEYPRESS-OSD-KAIU, FontStyle
    IniWrite, %FontName%, %NameIniFile%, KEYPRESS-OSD-KAIU, FontName
    IniWrite, %TimeHidingText%, %NameIniFile%, KEYPRESS-OSD-KAIU, TimeHidingText
    IniWrite, %TimeShowKeyDisplayGui%, %NameIniFile%, KEYPRESS-OSD-KAIU, TimeShowKeyDisplayGui
    IniWrite, %CircleEnable%, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleEnable
    IniWrite, %CircleTransparency%, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleTransparency
    IniWrite, %CircleDiameter%, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleDiameter
    IniWrite, %CircleColorLButton%, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleColorLButton
    IniWrite, %CircleColorMButton%, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleColorMButton
    IniWrite, %CircleColorRButton%, %NameIniFile%, KEYPRESS-OSD-KAIU, CircleColorRButton
    IniWrite, %LS_HelpFile%, %NameIniFile%, KEYPRESS-OSD-KAIU, HelpFile
}