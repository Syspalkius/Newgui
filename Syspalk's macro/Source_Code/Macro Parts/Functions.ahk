﻿planters(time){
	readgui()
	readplantdata()
	loop 3{
		if (time = plantdelay%A_Index%){
			safetycheck()
			y := (4*A_Index - 4)+plantcycle%A_Index%
			field := plantfield%y%
			loop 3{
				if (plantcycle%A_Index% != 0 && field != "None"){
					GoField(field,true)
					if (PlantAction("take",,harviffull%A_Index%) = true){
						break
					}
				}
			}
		}
	}
	loop 3{
		if (time = plantdelay%A_Index%){
			backs := 0
			back:
			safetycheck()
			backs++
			if (backs > 5){
				break
			}
			readplantdata()
			plantcycle%A_Index% := plantcycle%A_Index% + 1
			cyclius := plantcycle%A_Index%
			IniWrite,%cyclius%,%datapath%,planters,plantcycle%A_Index%
			readplantdata()
			y := (4*A_Index - 4)+plantcycle%A_Index%
			field := plantfield%y%
			key := planter%y%
			if (plantcycle%A_Index% > 4){
				plantcycle%A_Index% := 0
				cyclius := plantcycle%A_Index%
				IniWrite,%cyclius%,%datapath%,planters,plantcycle%A_Index%
				goto,back
			}
			if (field = "None"){
				goto,back
			}
			GoField(field,true)
			PlantAction("place",key)
		}
	}
}

planters2(time){
	;if pstatus is true then it means that the plant wasn't harvested because it wasn't fully grown yet.
	pstatus1 := takeplant(1,time)
	pstatus2 := takeplant(2,time)
	pstatus3 := takeplant(3,time)
	if (pstatus1 != true){
		placeplant(1,time)
	}
	if (pstatus2 != true){
		placeplant(2,time)
	}
	if (pstatus2 != true){
		placeplant(3,time)
	}
}

takeplant(which,time){
	readgui()
	readplantdata()
	if (time = plantdelay%which%){
		y := (4*which - 4)+plantcycle%which%
		field := plantfield%y%
		loop 3{ ;3 tries before fail
			if (plantcycle%which% != 0 && field != "None"){
				GoField(field,true)
				status := PlantAction("take",,harviffull%which%)
				if (status = 1){ ;plant was successfully harvested
					return false
				}
				if (status = 2){ ;plant wasn't harvested because not fully grown
					return true
				}
			}
		}
		return false
	}
}

placeplant(which,time){
	if (time = plantdelay%which%){
		backs := 0
		back1:
		safetycheck()
		backs++
		if (backs > 5){
			return
		}
		readplantdata()
		plantcycle%which% := plantcycle%which% + 1
		cyclius := plantcycle%which%
		IniWrite,%cyclius%,%datapath%,planters,plantcycle%which%
		readplantdata()
		y := (4*which - 4)+plantcycle%which%
		field := plantfield%y%
		key := planter%y%
		if (plantcycle%which% > 4){
			plantcycle%which% := 0
			cyclius := plantcycle%which%
			IniWrite,%cyclius%,%datapath%,planters,plantcycle%which%
			goto,back1
		}
		if (field = "None"){
			goto,back1
		}
		GoField(field,true)
		PlantAction("place",key)
	}
}

PlantAction(option,key:=0,harvfull:=0){
	readgui()
	if (option = "place"){
		Eventlog("Placed planter")
		SendHotbar(key)
		sleep 1000
		return
	}
	if (option = "take"){
		sleep 500
		Send e
		starttime := A_TickCount
		while (A_TickCount - starttime < 2500){
			WinGetPos,,,Winwidth,Winheight,Roblox
			mousemove,Winwidth/2,Winheight/2
			if (SearchFunction("Harvest_Planter.png",20)[1] = 0){
				if (harvfull){
					if (SearchFunction("no.png",20,true)[1] = 0){
						mousemove,SearchFunction("no.png",20)[2],SearchFunction("no.png",20)[3]
						sleep 100
						Send {Click Left}
						return 2
					}
				}
				else if (SearchFunction("Yes.png",20,true)[1] = 0){
					mousemove,SearchFunction("Yes.png",20)[2],SearchFunction("Yes.png",20)[3]
					sleep 200
					Send {Click Left}
					sleep 100
					Eventlog("Took planter")
					if (lootplanters){
						Eventlog("Looting planter")
						lootplanter()
					}
					return 1
				}
			}
		}
		if (harvfull){
			Eventlog("Took planter")
			Eventlog("Looting fully grown planter")
			lootplanter()
			return 1
		}
		else{
			Errorlog("Failed to take the planter due to not finding the harvest ui after 2.5 sec")
			return 0
		}
	}
}

GoFarm(field){ ;function for farming.
	checktimers()
	beesmastimerchecks()
	readgui()
	GoField(field)
	global currentfield := field
	if (field = "bugrun&polar"){
		return
	}
	if (field = "Pine Tree" || field = "Plant 1" || field = "Plant 2" || field = "Plant 3"){
		pinetree := true
	}else{
		pinetree := false
	}
	if (avoiddeath){
		Send {Space Down}
		sleep 10000
		Send {Space Up}
		sleep 500
	}
	breaktimer := A_TickCount
	maxfieldtime := maxtimeonfield * 60000
	zoomout()
	Sendhotbar(1)
	sleep 1000
	if (SearchFunction("nosprinkler.png",20)[1] = 0){
		return
	}
	if (glitchsprinkler = 1){
		loop 3{
			SendSpace()
			sleep 250
			Sendhotbar(1)
			sleep 1000
		}
	}
	checkbufftimer()
	toggleshiftlock()
	poptimer := 99999999999999999999999999999999999999
	firstpop := true
	while(1){
		
		loop 3{
			readgui()
			pattern(pinetree)
			zoomout()
			if (sprinkleralign && patternsize > 10){
				toggleshiftlock()
				movetosat()
				toggleshiftlock()
			}
			if (reglitter){
				if (A_Tickcount - pinereglittime < minutes(15) && A_Tickcount - pinereglittime > minutes(9)  && glitterpine){
					Eventlog("Using glitter")
					global glitterpine := False
					toggleshiftlock()
					useitemfrominv("glit.png",true)
					toggleshiftlock()
				}
			}
			if (vicious){
				toggleshiftlock()
				if (checkforvic() = true){
					return
				}
				toggleshiftlock()
			}
			if (A_TickCount - breaktimer > maxfieldtime){
				if (SearchFunction("pop.png",10)[1] = 1 && A_TickCount - poptimer < 45000 && waitforpop){
					if (firstpop){
						firstpop := false
						poptimer := A_TickCount
					}
				}else{
					toggleshiftlock()
					pinewalktohive(pinetree)
					return
				}
			}
			if (bagcheck() = 1){
				toggleshiftlock()
				pinewalktohive(pinetree)
				return
			}
		}
		
		checkbufftimer()
		safetycheck()
		if(reconnected = true){
			global reconnected := false
			return
		}
	}
}

checkmobtimers(){
	readtimers()
	readgui()
	if (A_TickCount - mob_5mtimer > minutes(7)){
		IniWrite,%A_TickCount%,%timerpath%,mobs,mob_5mtimer
		if (lady){
			killmob("ladybug")
		}
		if (rhino){
			killmob("beetle")
		}
	}
	readtimers()
	readgui()
	if (A_TickCount - mob_20mtimer > minutes(23)){
		IniWrite,%A_TickCount%,%timerpath%,mobs,mob_20mtimer
		if (scorpion){
			killmob("scorpion")
		}
		if (mantis){
			killmob("mantis")
		}
	}
	readtimers()
	readgui()
	if (A_TickCount - mob_30mtimer > minutes(33)){
		IniWrite,%A_TickCount%,%timerpath%,mobs,mob_30mtimer
		if (spider){
			killmob("spider")
		}
	}
	readtimers()
	readgui()
	if (A_TickCount - mob_1htimer > hours(1.1)){
		IniWrite,%A_TickCount%,%timerpath%,mobs,mob_1htimer
		if (wolf){
			killmob("wolf")
		}
	}
	readtimers()
	readgui()
	if (A_TickCount - mob_24htimer > hours(24.1)){
		IniWrite,%A_TickCount%,%timerpath%,mobs,mob_24htimer
		if (kingbeetle){
			killmob("kb")
		}
	}
	readtimers()
	readgui()
	if (A_TickCount - mob_48htimer > hours(48.1)){
		IniWrite,%A_TickCount%,%timerpath%,mobs,mob_48htimer
		if (tunnel){
			killmob("tb")
		}
	}
}

beesmastimerchecks(){ ;separate function to check all the timers that have anything to do with beesmas
	readgui()
	readtimers()

	if (A_Tickcount - feasttimer  > 5400000){
		IniWrite,%A_TickCount%,%timerpath%,timers,feasttimer
		if (feast){
			feast()
			safetycheck()
		}
	}
	if (A_TickCount - gingertimer > 7200000){
		IniWrite,%A_TickCount%,%timerpath%,timers,gingertimer
		if (ginger){
			gingerhouse()
			safetycheck()
		}
	}
	if (A_Tickcount - candletimer > 14400000){
		IniWrite,%A_TickCount%,%timerpath%,timers,candletimer
		if (candles){
			candles()
			safetycheck()
		}
	}
	if (A_Tickcount - samovartimer > 21600000){
		IniWrite,%A_TickCount%,%timerpath%,timers,samovartimer
		if (samovar){
			samovar()
			safetycheck()
		}
	}
	if (A_Tickcount - lidtimer > 28800000){
		IniWrite,%A_TickCount%,%timerpath%,timers,lidtimer
		if (lidart){
			lidart()
			safetycheck()
		}
	}
}

checktimers(){
	allowconvert := false
	beesmastimerchecks()
	checkmobtimers()
	readtimers()
	if (A_Min < 13 && A_Min > 00){
		if (allowmondo){
			mondo()
			global allowmondo := false
		}
	}else{
		global allowmondo := true
	}
	if (A_TickCount - 30mtimer > hours(0.5)){
		safetycheck()
		IniWrite,%A_TickCount%,%timerpath%,timers,30mtimer
		checkforpaidant("30 min")
		planters2("30 min")
	}
	readtimers()
	if (A_TickCount - 1htimer > hours(1.05)){
		safetycheck()
		IniWrite,%A_TickCount%,%timerpath%,timers,1htimer
		checkforpaidant("1 hour")
		planters2("1 hour")
		if (clock){
			Clock()
		}
		if (redbooster){
			redbooster()
		}
		if (whitebooster){
			whitebooster()
		}
		if (shrine){
			shrine()
		}
		if (bluebooster){
			bluebooster()
		}
		if (donatesticker){
			donatesticker()
		}
	}
	readtimers()
	if (A_TickCount - 2htimer > hours(2.1)){
		safetycheck()
		IniWrite,%A_TickCount%,%timerpath%,timers,2htimer
		checkforpaidant("2 hours")
		planters2("2 hours")
		if (ant){
			ant()
			if (freeant){
				GoDoAnt()
			}
		}
	}
	readtimers()
	if (A_TickCount - 4htimer > hours(4.1)){
		safetycheck()
		IniWrite,%A_TickCount%,%timerpath%,timers,4htimer
		checkforpaidant("4 hours")
		planters2("4 hours")
		if (cocodisp){
			cocodisp()
		}
	}
	readtimers()
	if (A_TickCount - 22htimer > hours(22.2)){
		safetycheck()
		IniWrite,%A_TickCount%,%timerpath%,timers,22htimer
		if (gluedisp){
			gluedisp()
		}
	}
	if (A_TickCount - 24htimer > hours(24.3)){
		safetycheck()
		IniWrite,%A_TickCount%,%timerpath%,timers,24htimer
		if (robopass){
			robopass()
		}
	}
	allowconvert := true
}


walk(time,dir){ ;makes the character do walking and stuff like that.
	readgui()
	distance := (time/speed)*28
	if (dir = "f"){
		Send {%forward% down}
		sleep %distance%
		Send {%forward% up}	
	}else if (dir = "l"){
		Send {%left% down}
		sleep %distance%
		Send {%left% up}
	}else if (dir = "b"){
		Send {%backwards% down}
		sleep %distance%
		Send {%backwards% up}
	}else if (dir = "r"){
		Send {%right% down}
		sleep %distance%
		Send {%right% up}
	}
}

walkhold(dir,setting){ ;basically just the same as keydown but without a keyup after.
	getkeyinfo()
	if (dir = "f"){
		Send {%forward% %setting%}
	}else if (dir = "l"){
		Send {%left% %setting%}
	}else if (dir = "b"){
		Send {%backwards% %setting%}
	}else if (dir = "r"){
		Send {%right% %setting%}
	}
}

SendSpace(){ ;makes the character jump.
	Send {space down}
	sleep 100
	Send {space up}
}

camrotate(amount,dir){ ;just rotates the damn camera
	getkeyinfo()
	if (dir = "l"){
		dir := camleft
	}else{
		dir := camright
	}
	loop %amount%{
		Send %dir%
		sleep 5
	}
}

SendHotbar(var){ ;sends key to the hotbar.
	getkeyinfo()
	var := hotbar%var%
	Send %var%
}

r(wait){ ;kills your character
	SendInput {Escape}
	sleep 500
	SendInput {r}
	sleep 500
	SendInput {Enter}
	sleep 500
	if(wait){
		sleep 8000
	}
}

walktocannon(){ ;makes the character walk to the cannon.
	attempts := 0
	cannonstart:
	if (attempts != 0){
		Reset()
	}
	attempts++
	readgui()
	sleep 100
	walk(1000,"f") 
	walkhold("r","Down")
	sleep 6000
	sendSpace()
	sleep 300
	walkhold("r","up")
	WinGetPos , windowX, windowY, windowWidth, windowY, Roblox
	WindowY := windowY/3
	btimer := A_Tickcount
	sleep 300
	walk(75,"f")
	walkhold("r","Down")
	loop{
		ImageSearch,foundx,foundy,0,0,A_ScreenWidth,windowY,*10 Source_Code\Macro Parts/images/e.png
		if (errorlevel = 0){
			walkhold("r","Up")
			break
		}
		if (A_Tickcount - btimer > 5000){
			if (attempts > 2){
				ErrorLog("Reconnected (Issue : E button for cannon wasn't detected after too many tries)")
				walkhold("r","Up")
				Reconnect()
				global reconnectedcannon := true
				return
			}else{
				walkhold("r","Up")
				goto,cannonstart
			}
		}
	}
	WinGetPos,,,Winwidth,Winheight,Roblox
	mousemove,Winwidth/2,Winheight/2
}

Reset(){ ;this will make your character commit suicide and also has some crapy anti bear glitch protection which only works half of the time but it's better than other macros which will let your character fling all the way to the onett house instead of going to pepper
	Retryy:
	readgui()
	r(false)
	sleep 2000
	breaktimer := A_TickCount
	resetagain := false
	WinGetPos,,,Winwidth,Winheight,Roblox
	Winheight := Winheight/4
	while (1){ ;search for bear
		sleep 250
		if (SearchFunctionv2("BrownBear.png",20,0,0,Winwidth,Winheight)[1] = 0 || SearchFunctionv2("BlackBear.png",20,0,0,Winwidth,Winheight)[1] = 0 || SearchFunctionv2("MotherBear.png",20,0,0,Winwidth,Winheight)[1] = 0 || SearchFunctionv2("PandaBear.png",20,0,0,Winwidth,Winheight)[1] = 0 || SearchFunctionv2("PolarBear.png",20,0,0,Winwidth,Winheight)[1] = 0 || SearchFunctionv2("Sciencebear.png",20,0,0,Winwidth,Winheight)[1] = 0 ){
			resetagain := true ;if bear detected set to true
		}
		if (A_TickCount - breaktimer > 6500){
			break
		}
	}
	if (resetagain){
		goto, Retryy ;if bear detected go back to start
	}
	breaktimer := A_TickCount
	while (1){
		sleep 100
		if (SearchFunction("hive.png",30)[1] = 0 || SearchFunction("hiven.png",30)[1] = 0){ ;look for hive image
			global Fails := 0
			camrotate(4,"l")
			zoomout()
			break
		}
		else{
			camrotate(4,"l")
		}
		if (A_TickCount - breaktimer > 10000){
			if (Fails = 4){
				global Fails := 0
				ErrorLog("Reconnected (Issue : Hive image wasn't found too many times in a row)")
				Reconnect()
				goto,Retryy
			}
			else{
				Fails++
				goto,Retryy
			}
		}
	}
	zoomout()
	breaktimer := A_TickCount
	if (convsetting && allowconvert && SearchFunction("e.png",10)[1] = 0){ ;convert balloon if balloon convert
		Send e
		while (1){
			sleep 1000
			if (SearchFunction("e.png",30)[1] = 1){
				sleep 5000
				break
			}
			if (A_TickCount - breaktimer > 360000){
				break
			}
			checkbufftimer(true)
			safetycheck()
		}
	}
}

SearchFunction(image,variation,movecenter := false){ ;imagesearch in function so it's nicer to use.
	if (movecenter = true){
		WinGetPos,,,Winwidth,Winheight,Roblox
		mousemove,Winwidth/2,Winheight/2
	}
	ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%variation% Source_Code\Macro Parts\images\%image%
	return [ErrorLevel,FoundX,FoundY]
}

SearchFunctionv2(image,variation,x1,y1,x2,y2){ ;imagesearch in function with coordinate option so it's nicer to use.
	ImageSearch, FoundX, FoundY, %x1%, %y1%, %x2%, %y2%, *%variation% Source_Code\Macro Parts\images\%image%
	return [ErrorLevel,FoundX,FoundY]
}

GOField(field,nectar := false,lootmob := false,fromplant := false){ ;function that takes input and turns it in to an output that lets you go to the field and stuff like that.
	message := "Traveling to " . field
	if not (fromplant || field = "Plant 1" || field = "Plant 2" || field = "Plant 3"){
		eventlog(message)
	}
	readgui()
	readplantdata()
	if (field = "None"){
		return true
	}else if (field = "Bamboo"){
		bamboo(nectar)
	}else if (field = "Blue Flower"){
		bluf(nectar)
	}else if (field = "Cactus"){
		cactus(nectar)
	}else if (field = "Coconut"){
		coco(nectar)
	}else if (field = "Dandelion"){
		dande(nectar)
	}else if (field = "Mountain"){
		mountain(nectar)
	}else if (field = "Mushroom"){
		mush(nectar)
	}else if (field = "Pepper"){
		pep(nectar)
	}else if (field = "Pine Tree"){
		pinetree(nectar)
	}else if (field = "Pineapple"){
		pineapple(nectar)
	}else if (field = "Pumpkin"){
		pump(nectar)
	}else if (field = "Rose"){
		rose(nectar)
	}else if (field = "Spider"){
		spider(nectar)
	}else if (field = "Strawberry"){
		straw(nectar)
	}else if (field = "Stump"){
		stump(nectar)
	}else if (field = "Sunflower"){
		sunf(nectar)
	}else if (field = "Clover"){
		clover(nectar)
	}else if (field = "bugrun&polar"){
		bugrun()
	}else if(field = "Plant 1"){
		if (doublereset){
			r(true)
		}
		y := plantcycle1
		field := plantfield%y%
		message := "Traveling to Plant 1 (" . field ")"
		eventlog(message)
		GoField(field,,,1)
	}else if(field = "Plant 2"){
		if (doublereset){
			r(true)
		}
		y := plantcycle2 + 4
		field := plantfield%y%
		message := "Traveling to Plant 2 (" . field ")"
		eventlog(message)
		GoField(field,,,1)
	}else if(field = "Plant 3"){
		if (doublereset){
			r(true)
		}
		y := plantcycle2 + 8
		field := plantfield%y%
		message := "Traveling to Plant 3 (" . field ")"
		eventlog(message)
		GoField(field,,,1)
	}
	if (lootmob){
		squares(100,false)
		squares(100,false)
	}
}

bagcheck(){ ;checks if the bag is full I should have done this with a return but at the time I didn't know how that stuff worked but this works too I guess.
	if (SpecificPixelSearchFunction(0x1700F7,0,0,A_ScreenWidth,150)[1] = 0){
		return true
	}
}

satsearcher(x1,y1,x2,y2){
	if (SearchFunctionv2("sprinkler1.png",0,x1,y1,x2,y2)[1] = 0){
		return 0
	}
	else if (SearchFunctionv2("sprinkler2.png",0,x1,y1,x2,y2)[1] = 0){
		return 0
	}
	else if (SearchFunctionv2("sprinkler3.png",0,x1,y1,x2,y2)[1] = 0){
		return 0
	}
	else if (SearchFunctionv2("sprinkler4.png",0,x1,y1,x2,y2)[1] = 0){
		return 0
	}
	else{
		return 1
	}
}

movetosat(){
	WinGetPos,,,Winwidth,Winheight,Roblox
	Top := WinHeight / 2.2
	Bottom := WinHeight / 1.8
	Leftt := Winwidth / 2.2
	Rightt := Winwidth / 1.8

	if (satsearcher(0,0,Winwidth,Top) = 0){
		walkhold("f","Down")
		satstarttime := A_TickCount
		while (A_TickCount - satstarttime < 2000){
			if (satsearcher(0,0,Winwidth,Top) = 1){
				break
			}
			sleep 10
		}
		walkhold("f","Up")
	}
	else if (satsearcher(0,Bottom,Winwidth,WinHeight) = 0){
		walkhold("b","Down")
		satstarttime := A_TickCount
		while (A_TickCount - satstarttime < 2000){
			if (satsearcher(0,Bottom,Winwidth,WinHeight) = 1){
				break
			}
			sleep 10
		}
		walkhold("b","Up")
	}
	
	if (satsearcher(0,0,Leftt,Winheight) = 0){
		walkhold("l","Down")
		satstarttime := A_TickCount
		while (A_TickCount - satstarttime < 2000){
			if (satsearcher(0,0,Leftt,Winheight) = 1){
				break
			}
			sleep 10
		}
		walkhold("l","Up")
	}
	else if (satsearcher(Rightt,0,WinWidth,Winheight) = 0){
		walkhold("r","Down")
		satstarttime := A_TickCount
		while (A_TickCount - satstarttime < 2000){
			if (satsearcher(Rightt,0,WinWidth,Winheight) = 1){
				break
			}
			sleep 10
		}
		walkhold("r","Up")
	}
}

SpecificPixelSearchFunction(color,x1,y1,x2,y2){ ;pixelsearch in a function.
	PixelSearch, FoundX, FoundY,%x1%,%y1%,%x2%,%y2%,%color%,,fast
	return [ErrorLevel,FoundX,FoundY]
}

toggleshiftlock(){
	readgui()
	if (shiftlock){
		Send Shift
	}
}

zoomout(){
	loop 10{
		Send o
		sleep 1
	}
}

zoomin(){
	loop 10{
		Send i
		sleep 1
	}
}

checkbufftimer(athive := false){ ;checks the timers for the hotbar buffs.
	readgui()
	readtimers()
	while (A_Index < 8){
		if (A_TickCount - buff%A_Index%timer > buff%A_Index%time*1000 && buff%A_Index%){
			if (athive){
				if (buff%A_Index%hive){
					SendHotbar(A_Index)
				}
			}else{
				SendHotbar(A_Index)
			}
			IniWrite,%A_TickCount%,%timerpath%,buffs,buff%A_Index%timer
		}
	}
}

hours(time){
	return time*3600000
}

minutes(time){
	return time*60000
}

EventLog(Event){ ;saves what it does and when it does it in a text file for debugging
	FormatTime,Time,, (MM/dd/yyyy) hh:mm:ss
	FileAppend,%Time% %Event% `n,Source_Code\Macro Parts\logs\EventLog.txt
	try{
		IniRead,url,%linkpath%,webhooks,hookevent
		postdata=
		(
		{
		"content": "{%Time%}[EVENT] %Event%"
		}
		)
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("POST", url, false)
		WebRequest.SetRequestHeader("Content-Type", "application/json")
		WebRequest.Send(postdata) 
	}
}

ErrorLog(ErrorMessage){ ;same thing as eventlog but this time it logs errors in a seperate file xd
	FormatTime,Time,, (MM/dd/yyyy) hh:mm:ss
	FileAppend,%Time% %ErrorMessage%  `n,Source_Code\Macro Parts\logs\ErrorLog.txt
	try{
		IniRead,url,%linkpath%,webhooks,hookerror
		postdata=
		(
		{
		"content": "{%Time%}[ERROR] %ErrorMessage%"
		}
		)
		WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		WebRequest.Open("POST", url, false)
		WebRequest.SetRequestHeader("Content-Type", "application/json")
		WebRequest.Send(postdata) 
	}
}

cub(searchfor){
	loop 2{
		mousemove,140,125
		Send {click}
		sleep 30
	}
	mousemove,250,125
	sleep 50
	Send {Click}
	sleep 1000
	if (SearchFunction("cub.png",10)[1] = 0){
		mousemove,SearchFunction("cub.png",10)[2],SearchFunction("cub.png",10)[3]
		sleep 100
		MouseMove, 20, 5 , 10, Relative
		sleep 200
		Send {Click}
		sleep 500
		if (SearchFunction(searchfor,10)[1] = 0){
			mousemove,SearchFunction(searchfor,10)[2],SearchFunction(searchfor,10)[3]
			sleep 100
			MouseMove, 10, 5 , 10, Relative
			sleep 200
			Send {Click}
			sleep 500
		}
	}
}

Reconnect(){ ;this code is disgusting but it works and I don't want to fix it.
	startreconnect:
	savedata()
	while (1){
		attempt := 1
		retry:
		WinClose, ahk_class WINDOWSCLIENT ahk_exe RobloxPlayerBeta.exe
		WinClose, ahk_class WINDOWSCLIENT ahk_exe RobloxPlayerBeta.exe
		IniRead,plink1,%linkpath%,private servers,main
		IniRead,plink2,%linkpath%,private servers,alt
		WinClose, ahk_exe chrome.exe
		sleep 1000
		if (plink1 != "Insert Link" && serverjoinstatus){
			try{
				run, %plink1%
			}
			attempt := attempt + 1
		}else if (plink1 != "Insert Link" && attempt < 3){
			try{
				run, %plink1%
			}
			attempt := attempt + 1
		}else if (plink2 != "Insert Link" && serverjoinstatus != true && attempt = 3){
			try{
				run, %plink2%
			}
			attempt := 4
		}else if (serverjoinstatus != true){
			run, https://www.roblox.com/games/2000343487?privateServerLinkCode=67181684702561561812873405717919
			if (plink1){
				attempt := 1
			}else{
				attempt := 2
			}
		}
		gloobgloobtime := A_TickCount
		while (1){
			WinActivate, ahk_class WINDOWSCLIENT ahk_exe RobloxPlayerBeta.exe
			IfWinActive, ahk_class WINDOWSCLIENT ahk_exe RobloxPlayerBeta.exe
			{
				Break
			}
			WinActivate, ahk_class WINDOWSCLIENT ahk_exe RobloxPlayerBeta.exe
			if (A_TickCount - gloobgloobtime > 45000){
				WinClose, ahk_exe chrome.exe
				Send w
				SendInput {Enter}
				goto,retry
			}
		}
		looptime := A_TickCount
		while(1){ ;search for the loading screen if loading screen found wait for loading screen to go away and then claim the hive, if the loading screen is there for longer than 60 seconds something must have gone wrong and it will exit the loop
			if (SearchFunction("LoadingScreen.png",20)[1] = 0){
				breaktimerr := A_TickCount
				while (1){
					if (SearchFunction("LoadingScreen.png",20)[1] = 1){
						goto, claimhive
					}
					if (A_TickCount - breaktimerr > 90000){
						ErrorLog("[RECONNECT] LoadingScreen Detected For 90 Seconds, will retry")
						break
					}
				}
			}
			if (A_TickCount - looptime > 120000){ ;if it has been in the infinite while loop for more than 120 seconds something must have gone wrong so get out of the loop
				Errorlog("[RECONNCT] Loadingscreen hasn't been detected after 3 minutes, will retry")
				goto,retry
			}
		}
		WinClose, ahk_exe chrome.exe
		SendInput {Enter}
	}
	
	
	
	claimhive:
	SendInput {Enter}
	global previousreconnect := A_TickCount
	WinClose, ahk_class Chrome_WidgetWin_1 ahk_exe chrome.exe
	sleep 5000
	mouseMove, 100, 100,
	
	if (rejoinclaim){
		walk(8000,"f")
		walk(6000,"r")
		walk(650,"b")
		walkhold("l","Down")
		loopbreak := A_TickCount
		WinGetPos , windowX, windowY, windowWidth, windowY, Roblox
		WindowY := windowY/3
		while (1){
			ImageSearch, OutputVarX, OutputVarY, 0, 0, A_ScreenWidth, WindowY, *10 *TransBlack Source_Code\Macro Parts\images\claim.png
			if (errorlevel = 0){
				Send e
				break
			}
			if (A_TickCount - loopbreak > 8000){
				bloobiebloobkoop := true
				break
			}
		}
		walkhold("l","Up")
		if (bloobiebloobkoop)
		{
			bloobiebloobkoop := false
			goto,startreconnect
		}
	}
}

safetycheck(){ ;this will make sure that you stay in the game
	ImageSearch,founx,foundy,A_ScreenWidth/4,A_ScreenHeight/4,A_ScreenWidth/1.5,A_ScreenHeight/1.5,*10 Source_Code\Macro Parts/Images/Disconnected.PNG
	if (errorlevel = 0){
		global reconnected := true
		ErrorLog("Reconnected (Issue : Disconnected.png was found)")
		Reconnect()
	}
	WinActivate, ahk_class WINDOWSCLIENT ahk_exe RobloxPlayerBeta.exe
	IfWinExist, ahk_class WINDOWSCLIENT ahk_exe RobloxPlayerBeta.exe
	{
	}else{
		global reconnected := true
		ErrorLog("Reconnected (Issue : Roblox Window Wasn't Detected)")
		Reconnect()
	}
}

useitemfrominv(item,closeafter){
	loop 2{
		mousemove,140,125
		sleep 80
		Send {click}
	}
	mousemove,40,125
	sleep 200
	Send {Click}
	sleep 80
	mousemove,40,200
	loop 120{
		Send {WheelUp}
		sleep 20
	}
	sleep 250
	if (SearchFunction("ticket.png",10)[1] = 0){
		loop 30{
			if (SearchFunction(item,20,true)[1] = 0){
				sleep 500
				mousemove,SearchFUnction(item,20)[2],SearchFUnction(item,20)[3]
				sleep 250
				Send {Click Left Down}
				mousemove,A_ScreenWidth/2,A_ScreenHeight/2
				sleep 250
				Send {Click Left Up}
				if (closeafter = true){
					mousemove,40,140
					sleep 100
					Send {Click Left}
				}
				return
			}
			mousemove,40,200
			sleep 250
			Send {WheelDown}
			sleep 10
			Send {WheelDown}
			sleep 10
		}
		itemerror := "Failed to find " . item 
		Errorlog(itemerror)
		if (closeafter = true){
			mousemove,40,140
			sleep 100
			Send {Click Left}
		}
		return
	}else{
		Errorlog("Failed to find ticket.png")
		return
	}
}

checkforpaidant(timestamp){
	readgui()
	if (buyant){
		if (timestamp = playtimer){
			buyplayant()
		}
	}
}

checkforvic(){
	readgui()
	if (vicious){
		if (currentfield = "Pineapple"){
			zoomin()
			sleep 500
			if (viccheck(false) = true){
				return true
			}
			zoomout()
		}
		if (currentfield = "Spider"){
			camrotate(4,"r")
			zoomout()
			sleep 500
			if (viccheck(true) = true){
				return true
			}
			camrotate(4,"r")
		}
		if (currentfield = "Strawberry"){
			camrotate(2,"l")
			zoomout()
			sleep 500
			if (viccheck(false) = true){
				return true
			}
			camrotate(2,"r")
		}
		if (currentfield = "Mushroom"){
			camrotate(2,"r")
			zoomin()
			sleep 500
			if (viccheck(false) = true){
				return true
			}
			camrotate(2,"l")
			zoomout()
		}
		else{
			if (viccheck(false) = true){
				return true
			}
		}
		return false
	}
}

viccheck(changecam){ ;check for nighttime.
	if (A_Tickcount - lastvickill < 360000){
		return false
	}
	if (changecam){
		zoomin()
		loop 10{
			Send {PGDN}
			sleep 20
		}
		loop 5{
			Send {PGUP}
			sleep 20
		}
		sleep 100
	}
	ImageSearch,Ox,OY,0,0,A_ScreenWidth,150, Source_Code\Macro Parts\images\night.png
	if (ErrorLevel = 0){
		global allowconvert := false
		global lastvickill := A_Tickcount
		readgui()
		if (vicious){
			stingerrun()
		}
		global allowconvert := true
		return true
	}
	if (changecam){
		zoomout()
		sleep 20
		Send {PGUP}
		sleep 20
		Send {PGUP}
	}
	return false
}

fightcheck(){ ;checks if a vicious bee is present.
	readgui()
	sleep 500
	Send /
	sleep 500
	SendInput {Enter}
	sleep 250
	if (checkshiftlock() = 0){ ;if shiftlock is enabled
		camrotate(1,"l")
		sleep 30
		Send {Shift}
	}
	sleep 250
	if (SearchFunction("vicattacking.png",40)[1] = 0 || SearchFunction("vicattacking1.png",40)[1] = 0){
		status := true
		starty := A_TickCount
		if (vicfield = "mountain"){
			walk(1000,"l")
			walk(1500,"b")
			global vicfield := "false"
		}else if (vicfield = "rose"){
			camrotate(2,"r")
			walk(500,"b")
			walk(1500,"l")
			global vicfield := "false"
		}else if (vicfield = "clover"){
			walk(1250,"b")
			walk(1250,"r")
			global vicfield := "false"
		}
		while(1){
			walk(1000,"f")
			if (SearchFunction("deadvic.png",20)[1] = 0){
				break
			}
			walk(1000,"l")
			if (SearchFunction("deadvic.png",20)[1] = 0){
				break
			}
			walk(1000,"b")
			if (SearchFunction("deadvic.png",20)[1] = 0){
				break
			}
			walk(1000,"r")
			if (SearchFunction("deadvic.png",20)[1] = 0){
				break
			}
			if (A_TickCount - starty > maxcombattime*1000 || A_TickCount - starty > 300000){
				break
			}
		}
		return true
	}
}

killmob(mob){
	if (mob = "ladybug"){
		Eventlog("killing the ladybugs")
		GoField("Strawberry",,true)
		GoField("Mushroom",,true)
		GoField("Clover",,true)
		return
	}else if (mob = "beetle"){
		Eventlog("killing the rhino beetles")
		readgui()
		if not (lady){
			GoField("Clover",,true)
		}
		GoField("Bamboo",,true)
		GoField("Pineapple",,true)
		return
	}else if (mob = "scorpion"){
		Eventlog("killing the scorpions")
		GoField("Rose",,true)
		return
	}else if (mob = "mantis"){
		Eventlog("killing the mantisses")
		GoField("Pine Tree",,true)
		GoField("Pineapple",,true)
		return
	}else if (mob = "spider"){
		Eventlog("killing the spider")
		GoField("Spider",,true)
		return
	}else if (mob = "wolf"){
		Eventlog("killing werewolf")
		GoField("Pine Tree",,true)
		return
	}else if (mob = "kb"){
		Eventlog("killing the king beetle")
		kingbeetle()
		return
	}else if (mob = "tb"){
		Eventlog("killing the tunnel bear")
		tunnelbear()
		return
	}
}

Clicker(delay){ ;uses the mouse to click.
	mouseMove,A_ScreenWidth/2,A_ScreenHeight/2
	Send {Click Left Down}
	sleep %delay%
	Send {Click Left Up}
}

checkshiftlock(){
	WinGetPos,,,Winwidth,Winheight,Roblox
	return SearchFunctionv2("shiftlock.png",10,0,Winheight-70,70,Winheight-15)[1]
}