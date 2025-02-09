﻿#SingleInstance Force
#Requires AutoHotkey v1.1.36.01+
menu,tray,icon,Source_Code\Macro Parts\GUI\Images\logo.ico
if (A_ScreenDPI != 96){
	MsgBox,48,WARNING,Warning: Your display scaling is not set to 100, the macro might not function properly.`n`nFix: Settings → Display → Scale and layout → 100
}
Gui, loading:add,Progress, w200 h20 cgreen vprogress -smooth, 0
Gui, loading:color,0x2A2F32
Gui, loading:show, w220 h50,Loading...
SetBatchLines, -1
SetDefaultMouseSpeed, 3
ListLines Off
#Include Source_Code\Macro Parts\Data Handler.ahk
GuiControl,loading:, progress, 20
readini() ;gets all the data from the ini file.
GuiControl,loading:,progress, 30
#Include Source_Code\Macro Parts\Version checker.ahk
GuiControl,loading:,progress, 50
#Include Source_Code\Macro Parts\functions.ahk
GuiControl,loading:,progress, 70
#Include Source_Code\Macro Parts\paths.ahk
GuiControl,loading:,progress, 80
#Include Source_Code\Macro Parts\Patterns.ahk
GuiControl,loading:,progress, 90
#Include Source_Code\Macro Parts\GUI\GUI.ahk
GuiControl,loading:,progress, 100
startmacrokeys() ;activates the start/stop/pause keys.
timersafetycheck() ;resets timers if they're corrupted after restarting device.
createshortcut() ;creates a shortcut to launch the macro on the desktop.
sleep 500
Gui, loading:destroy
return

GuiClose: ;when gui closes will save data and close the macro.
savedata()
ExitApp

start: ;when the start hotkey is pressed it will jump here.
WinActivate, ahk_class WINDOWSCLIENT ahk_exe RobloxPlayerBeta.exe ;activate roblox window
walkhold("f","Up")
walkhold("l","Up")
walkhold("b","Up")
walkhold("r","Up")
Eventlog("Started macro")
tooltip, ;remove potential tooltip
Gui, -AlwaysOnTop
while(1){
	readgui()
	safetycheck()
	checktimers()
	while (A_Index < 5){
		if (farmfield%A_Index% != "None"){
			GOFarm(farmfield%A_Index%)
		}
		safetycheck()
		checktimers()
	}
	if (farmfield1 = "None" && farmfield2 = "None" && farmfield3 = "None" && farmfield4 = "None"){
		pattern()
	}
}

/* F4::
loop{
	foundharvestui := false
	foundyes := False
	foundno := false
	if (SearchFunction("Harvest_Planter.png",20)[1] = 0) {
		foundharvestui := true
	}
	if (SearchFunction("Yes.png",20)[1] = 0) {
		foundyes := true
	}
	if (SearchFunction("no.png",20)[1] = 0) {
		foundno := true
	}

	tooltip, Harvest_Planter: %foundharvestui%`nYes.png: %foundyes%`nno.png: %foundno%
	sleep 100
} */