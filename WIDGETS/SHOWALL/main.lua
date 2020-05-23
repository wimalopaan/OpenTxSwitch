local WGTNAME = "showal" .. "0.9"  -- max 9 characters

--[[
HISTORY
=======
Author Mike Shellim http://www.rc-soar.com/opentx/lua
2020-05-22  v0.9.2 	Fixed 'disabled' message when displaying full screen
2020-05-16  v0.9.1 	Added option to show undefined LS's as dots
					Displays at all pane sizes
					Cosmetic improvements
2019-11-23  v0.9.0 	First release

DESCRIPTION
===========
Displays basic info about active model.
At startup looks for output named 'armed'. If found, flashes
  'motor armed' when output value > 0.

REQUIREMENTS
============
Transmitter with colour screen (X10, X12, T16 etc.)
OpenTX v 2.2 or later

INSTRUCTIONS
============
Please read instructions in the zip package, or download from :
https://rc-soar.com/opentx/lua/showitall/ShowItAll_09.pdf


DISCLAIMER
==========
CHECK FOR CORRECT OPERATION BEFORE USE. IF IN DOUBT DO NOT FLY!!

USER SETTABLE VARIABLES
=======================
MAX_LS = maximum number of logical switches to display
A value of 20 is recommended for good performance in general use
If not using other scripts, you can increase this value
to a suggested max of 32 --]]

local MAX_LS = 20

--[[
SHOW_UNDEF_LS_AS_DOT determines how undefined logical switches
are rendered
If false (default), undefined logical switches are treated as 'off'.
If true, then undefined ls's are rendered as dots (nice!), but involves a cache
look up and a power cycle to refresh cache - best used only if logical switches
have been finalised.
 --]]

local SHOW_UNDEF_LS_AS_DOT = false

--[[
END OF USER SETTABLE VARIABLES
============================== --]]


-- ========= LOCAL VARIABLES =============
-- Field ids
local idSA
local idTmr1
local idLS1
local idTxV
local idEle
local idAil
local idRud
local idThr
local idchArmed
local idCh1

-- item counts
local nLS
local nTmr

-- options table
local defaultOptions = {
	{"Use dflt clrs", BOOL, 1},
	{"BackColor", COLOR, WHITE},
	{"ForeColor", COLOR, BLACK},
	}
local colorFlags
local sticks = {}

-- Logical switch bitmap
local LSDefLo -- bitmap of definition state for LS's 0-31
local LSDefHi -- bitmap of definition state for LS's 32-63

-- fonts
local fontht = {[SMLSIZE]=12, [0]=18}

-- ========= S T A R T   O F   F U N C T I O N S =============

--[[
FUNCTION: initLSDefs
Populate logical switch bitmap cache. 1=defined, 0=undefined
(Cache needed as getLogicalSwitch is slow.)
--]]
local function initLSDefs ()
	LSDefLo = 0
	LSDefHi = 0
	for i = 0, 31 do
		local vLo = (model.getLogicalSwitch(i).func > 0) and 1 or 0
		local vHi = (model.getLogicalSwitch(i+32).func >0) and 1 or 0
		LSDefLo = bit32.replace (LSDefLo, vLo, i)
		LSDefHi = bit32.replace (LSDefHi, vHi, i)
	end
end

--[[
FUNCTION: getLSVal
Returns logical switch value or nil
Nil = undefined
1024 = true
-1024 = false
If SHOW_UNDEF_LS_AS_DOT is false, then undefined LS's will be treated as false
--]]
local function getLSVal (i)
	local val = getValue (idLS1+i)
	if SHOW_UNDEF_LS_AS_DOT then
		local long = i>31 and LSDefHi or LSDefLo
		if bit32.extract (long, i%32) == 0 then
			val = nil
		end
	end
	return val
end

--[[
FUNCTION: getNumItems
Determine the number of items in a field
--]]
local function getNumItems (field, maxitems)
	local i = 1
	while true do
		if i > maxitems or not getFieldInfo(field ..i) then
			break
		end
		i = i + 1
	end
	return i-1
end

--[[
==================================================
FUNCTION: create
Called by OpenTX to create the widget
==================================================
--]]

local function create(zone, options)

	-- stash field id's (efficiency)
	idSA = getFieldInfo('sa').id
	idLS1 = getFieldInfo('ls1').id
	idTmr1 = getFieldInfo('timer1').id
	idTxV = getFieldInfo('tx-voltage').id
	idEle= getFieldInfo('ele').id
	idAil= getFieldInfo('ail').id
	idRud= getFieldInfo('rud').id
	idThr= getFieldInfo('thr').id
	idCh1 = getFieldInfo('ch1').id

	-- Limit LS count to avoid possible performance
	-- hit especially with mixer scripts.
	nLS = getNumItems ('ls', MAX_LS)
	nTmr = getNumItems ('timer',3)

	-- Initialise LS bitmap
	initLSDefs ()

	-- look for output channel named 'armed'
	idchArmed = nil
	local i = 0
	while true do
		local o = model.getOutput (i)
		if not o then break end
		if string.lower (string.sub (o.name, 1,5)) == "armed" then
			idchArmed = getFieldInfo ("ch".. (i+1)).id
			break
		end
		i = i + 1
	end

	sticks={
		{name='A', id=idAil},
		{name='E', id=idEle},
		{name='T', id=idThr},
		{name='R', id=idRud}
		}

	return {zone=zone, options=options}
end


--[[
==================================================
FUNCTION: update
Called by OpenTX on registration and at
change of settings
==================================================
--]]
local function update(wgt, newOptions)
    wgt.options = newOptions
end

--[[
==================================================
FUNCTION: background
Periodically called by OpenTX
==================================================
--]]
local function background(wgt)
end


--[[
FUNCTION: hms
Convert time in seconds into hours, minutes and seconds
--]]
local function hms (secs)
	local ss = secs % 60
	local hh = math.floor (secs/3600)
	local mm = (secs - hh*3600 - ss) / 60
	return hh,mm,ss
end




--[[
FUNCTION: drawSwitchSymbol
Draw a symobol representing switch state up/middle/down
--]]
local function drawSwitchSymbol (x,y,val)
	local w=5
	local h=8
	local weight = 2
	if val==0 then
		lcd.drawFilledRectangle (x, y+h/2, w,1, colorFlags)
	elseif val > 0 then
		lcd.drawFilledRectangle (x+ w/2, y+h/2-1, 1,h/2+1,colorFlags)
		lcd.drawFilledRectangle (x, y+h, w,weight,colorFlags)
	else
		lcd.drawFilledRectangle (x+ w/2, y, 1,h/2+2,colorFlags)
		lcd.drawFilledRectangle (x, y, w,weight,colorFlags)
	end
end

--[[
FUNCTION: drawSwitches
Draw switch block
--]]
local function drawSwitches (x,y)
	-- Switches
	local x0 = x
	local y0 = y
	for i = 0, 7 do
		lcd.drawText (x, y, "S".. string.char(string.byte('A')+i), SMLSIZE + colorFlags)
		drawSwitchSymbol (x+22, y+4, getValue (idSA+i))
		y = y + 12
		if i==3 then
			x = x0 + 40
			y = y0
		end
	end
end

--[[
FUNCTION: drawFM
Display flight mode
--]]
local function drawFM (x,y, font)
	local fmno, fmname = getFlightMode()
	if fmname == "" then
		fmname = "FM".. fmno
	end
	lcd.drawText (x, y, fmname, font + colorFlags)
end

--[[
FUNCTION: drawModelName
--]]
local function drawModelName (x,y, font)
	lcd.drawText (x, y, model.getInfo().name, font + colorFlags)
end

--[[
FUNCTION: drawEssentials
--]]
local function drawEssentials (x,y,font)
	local xOffset = 60
	local val = getValue(idTxV)
	local lineht = fontht[font]

	lcd.drawText (x, y, "TxBatt", font + colorFlags)
	lcd.drawText (x + xOffset, y, (val and val >0)  and string.format ("%.1f", val) or "---", font  + colorFlags)
	y = y + lineht

	val = getValue("RxBt")
	lcd.drawText (x, y, "RxBatt", font+ colorFlags)
	lcd.drawText (x + xOffset, y, (val and val>0)  and string.format ("%.1f", val) or "---", font  + colorFlags)
	y = y + lineht

	val = getValue("RSSI")
	lcd.drawText (x, y, "RSSI", font + colorFlags)
	lcd.drawText (x + xOffset, y, (val and val>0)  and val  or "---", font  + colorFlags)
end

--[[
FUNCTION: drawTimers
--]]
local function drawTimers(x, y)
	for i = 0, nTmr-1 do
		lcd.drawText (x, y, "T" .. (i+1) .. ":", SMLSIZE + colorFlags)
		lcd.drawText (x+85, y, string.format ("%02d:%02d:%02d",hms(getValue(idTmr1+i))) , SMLSIZE + colorFlags + RIGHT)
		y = y + 13
	end
end

--[[
FUNCTION: drawLS
--]]
local function drawLS (x,y)
	local x0 = x
	local w = 6
	local h = 7
	local i = 0
	while i < nLS do
		local v = getLSVal (i)
		if not v then
			-- undefined
			lcd.drawFilledRectangle(x+w/2-2, y+h/2-1, 3, 3, colorFlags)
		elseif v > 0 then
			-- defined and true
			lcd.drawFilledRectangle(x, y, w, h, colorFlags)
		else
			-- anything else
			lcd.drawRectangle(x, y, w, h, colorFlags)
		end

		i = i + 1
		if i%10 == 0 then
			x = x0
			y = y + 9
		elseif i%5 == 0 then
			x = x + 12
		else
			x = x + 8
		end
	end
	lcd.drawText (x, y-4, "LS 01-"..nLS, SMLSIZE + colorFlags)
end

--[[
FUNCTION: drawSticks
--]]
local function drawSticks (x,y)
	for _, st in ipairs (sticks) do
		lcd.drawText (x, y -5,
			st.name .. ":" .. math.floor (0.5 + getValue(st.id)/10.24),
			SMLSIZE + colorFlags
			)
		y = y + 12
	end
end

--[[
FUNCTION: drawChans
--]]
local function drawChans (x,y)
	local yTxtOff = -5
	local wBar
	local wRect = 36
	local charsLt = {[0]="1","","3","","5","","7"}
	local charsRt = {[0]="","2","","4","","6",""}
	for i = 0, 6 do
		-- label
		lcd.drawText (x-3, y + yTxtOff, charsLt[i], SMLSIZE + colorFlags + RIGHT)
		lcd.drawText (x+38, y + yTxtOff, charsRt[i], SMLSIZE + colorFlags)
		-- bar outline
		lcd.drawRectangle (x, y, wRect, 5, colorFlags)
		local val = (getValue(idCh1 + i) + 1024)/2048
		wBar = 4
		if val < 0 then
			val  = 0
		elseif val > 1 then
			val = 1
		else
			wBar = 2
		end
		local xBar = val*wRect - wBar/2
		lcd.drawFilledRectangle (x + xBar, y, wBar, 5, colorFlags)
		y = y + 8
	end
end

--[[
FUNCTION: drawAlerts
--]]
local function drawAlerts (x,y)
	if idchArmed and getValue (idchArmed) > 0 then
		lcd.drawText (x, y, "motor armed!", RIGHT + MIDSIZE +  BLINK + INVERS)
	end
end



--[[
==================================================
FUNCTION: refresh
Called by OpenTX when the Widget is being displayed
==================================================
--]]
local function refresh(wgt)

	-- Colour option
	-- Check for LS bit (Github #7059)
	if bit32.btest (wgt.options["Use dflt clrs"], 1) then
		colorFlags = 0
	else
		lcd.setColor (CUSTOM_COLOR, wgt.options.BackColor)
		colorFlags = CUSTOM_COLOR
		lcd.drawFilledRectangle (
			wgt.zone.x,
			wgt.zone.y,
			wgt.zone.w,
			wgt.zone.h,
			colorFlags)
	end

	lcd.setColor (CUSTOM_COLOR, wgt.options.ForeColor)

	-- render

	if wgt.zone.w >= 390 and wgt.zone.h >= 172  then

		drawModelName (wgt.zone.x+2, wgt.zone.y, MIDSIZE)
		drawSwitches (wgt.zone.x + 6, wgt.zone.y + 36)
		drawSticks (wgt.zone.x + 6, wgt.zone.y + 110)
		drawChans (wgt.zone.x + 70, wgt.zone.y + 105)
		drawFM (wgt.zone.x + 140, wgt.zone.y + 105, MIDSIZE)
		drawEssentials (wgt.zone.x + 140, wgt.zone.y + 34, 0)
		drawTimers (wgt.zone.x + 288, wgt.zone.y + 107)
		drawLS (wgt.zone.x+290, wgt.zone.y+39)
		drawAlerts (wgt.zone.x + wgt.zone.w - 2, wgt.zone.y, MIDSIZE)

	elseif wgt.zone.w >= 175  then

		drawModelName (wgt.zone.x + 2, wgt.zone.y, SMLSIZE)
		drawEssentials (wgt.zone.x + 10, wgt.zone.y + 25, SMLSIZE)

		if wgt.zone.h >= 150 then
		--[[
			drawSticks (wgt.zone.x + 10, wgt.zone.y + 80)
			drawChans (wgt.zone.x + 75, wgt.zone.y + 80)
		--]]
		drawTimers (wgt.zone.x + 10, wgt.zone.y + 87)
		end

	else
		drawModelName (wgt.zone.x+2, wgt.zone.y, SMLSIZE)
	end
end

return { name=WGTNAME, options=defaultOptions, create=create, update=update, refresh=refresh, background=background }
