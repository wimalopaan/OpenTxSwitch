--
-- WM OTXE - OpenTX Extensions 
-- Copyright (C) 2020 Wilhelm Meier <wilhelm.wm.meier@googlemail.com>
--

-- This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ 
-- or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

-- IMPORTANT
-- Please note that the above license also covers the transfer protocol used and the encoding scheme and 
-- all further principals of tranferring state and other information.

local ctp1 = 0;
local ctp2 = 0;
local ctp3 = 0;
local cts2 = 0;

local Class = {};

function Class.new(prototype)
   local o = {};
   setmetatable(o, prototype);
   prototype.__index = prototype;
   return o;
end

local Queue = {first = 0, last = -1};

function Queue:new()
   return Class.new(Queue);
end
function Queue:push (item)
   self.last = self.last + 1;
   self[self.last] = item;
end
function Queue:pop()
   local item = self[self.first];
   self[self.first] = nil;
   self.first = self.first + 1;
   return item;
end
function Queue:size()
   return self.last - self.first + 1;
end

Class.Queue = Queue;

local function encodeFunction(address, number, state)
   -- address / number starts at 1 (lua counting)
   -- state is unmodified
   --  print("encodeF:", address, number, state);
   --  return (128 * (address - 1) + 16 * (number - 1) + state) * 2 - 1024;
   return (64 * (address - 1) + 8 * (number - 1) + (state - 1)) * 2 - 1024;
end

-- sbus uses only half the states (0...3)
local function encodeFunctionSbus(address, number, state)
   -- address / number starts at 1 (lua counting)
   -- state is unmodified
   -- print("encodeF:", address, number, state);
   --  return (128 * (address - 1) + 16 * (number - 1) + state) * 2 - 1024;
   return (64 * (address - 1) + 8 * (number - 1) +  2 * (state - 1)) * 2 - 1024;
end


local function encodeParameter(parameter, value)
   -- parameter starts at 0 (as in protocol)
   -- value is unmodified
   --  print("encodeP:", parameter, value);
   return (512 + parameter * 32 + value) * 2 - 1024;
end

-- sbus uses only half the values (0...15)
local function encodeParameterSbus(parameter, value)
   -- parameter starts at 0 (as in protocol)
   -- value is unmodified
   --  print("encodeP:", parameter, value);
   return (512 + parameter * 32 + 2 * value) * 2 - 1024;
end

local function sendValue(gvar, value)
--   local v = bit32.band(value, 0xFFFF);
--   print("sendV: ", value, v);
   model.setGlobalVariable(gvar, getFlightMode(), value);
end

local function broadcastOff(gvar) 
   --  print("bcast off");
   sendValue(gvar, encodeParameter(15, 31)); -- broadcast, turn off all outputs
end 

local function broadcastReset(gvar) 
   --  print("bcast reset");
   sendValue(gvar, encodeParameter(15, 2)); -- broadcast, reset all channels
end 

--local function broadcastParam(gvar) 
--   --  print("bcast param");
--   sendValue(gvar, encodeParameter(15, 4)); -- broadcast, next value after selection is parameter
--end 

local function switchState(s)
   local v = getValue(s);
   if (string.find(s, "ls")) then
      if (v < 0) then
	 return 1;
      else 
	 return 2;
      end
   else
      if (v < 0) then
	 return 2;
      elseif (v > 0) then
	 return 3;
      else 
	 return 1;
      end
   end
end

local function scaleParameterValue(v)
   local s = ((v + 1024) * 32) / 2048;
   if (s > 31) then
      s = 31;
   elseif (s < 0) then
      s = 0;
   end
   return math.floor(s);
end

-- use half the range
local function scaleParameterValueSbus(v)
   local s = ((v + 1024) * 16) / 2048;
   if (s > 15) then
      s = 15;
   elseif (s < 0) then
      s = 0;
   end
   return math.floor(s);
end

local function findItem(menu, module, count)
   for i, item in ipairs(menu.allItems) do
      if (item.data.module == module) and (item.data.count == count) then
	 return item;
      end
   end
   return nil;
end

local function findSwitch(menu, name) 
   local list = {};
   for i,p in ipairs(menu.pages) do
      for k,item in ipairs(p.items) do
	 if (item.data.switch and (item.data.switch == name)) then
	    list[p] = item;
	 end
      end
   end
   return list;
end

local function initMenu(menu, select, version, showShortCuts)
   if (COLOR_THEME_PRIMARY1) then
      ctp1 = COLOR_THEME_PRIMARY1;
      ctp2 = COLOR_THEME_PRIMARY2;
      ctp3 = COLOR_THEME_PRIMARY3;
      cts2 = COLOR_THEME_SECONDARY2;
   end
   if not (menu.titlev) then
      if (version) then
	 menu.titlev = menu.title .. " " .. version;
      else
	 menu.titlev = menu.title;
      end
   end
   local lsFI = getFieldInfo(menu.scrollUpDn);
   if (lsFI) then
      menu.lsID = lsFI.id;
   end

   local rsFI = getFieldInfo(menu.scrollLR);
   if (rsFI) then
      menu.rsID = rsFI.id;
   end

   local msFI = getFieldInfo(menu.pageSwitch);
   if (msFI) then
      menu.msFI= msFI.id;
      if (string.find(menu.pageSwitch, "6pos")) then
	 menu.msdiv = 10;
      else
	 menu.msdiv = math.max(2, 2 * (#menu.pages - 1));
      end
   end

   menu.state.activeRow = 0;
   menu.state.activeCol = 0;
   menu.state.activePage = menu.pages[1];
   for i,p in ipairs(menu.pages) do
      p.next = nil;
      p.prev = nil;
   end
   for p = 1, #menu.pages do
      if (p == #menu.pages) then
	 menu.pages[p].next = menu.pages[1]; 
      else
	 menu.pages[p].next = menu.pages[p + 1]; 
      end
      menu.pages[p].number = p;
      menu.pages[p].desc = "Page: " .. tostring(p) .. "/" .. tostring(#menu.pages);
   end
   for p = 1, #menu.pages do
      if (p == 1) then
	 menu.pages[p].prev = menu.pages[#menu.pages]; 
      else
	 menu.pages[p].prev = menu.pages[p - 1]; 
      end
   end

   menu.cb = select;
   
   menu.allItems = {};
   for i,p in ipairs(menu.pages) do
      for k, item in ipairs(p.items) do
	 menu.allItems[#menu.allItems + 1] = item;
      end
   end

   menu.shortCuts = {};
   for i,p in ipairs(menu.pages) do
      for k, item in ipairs(p.items) do
	 if (item.data.switch) then
	    menu.shortCuts[item.data.switch] = {item = item, last = switchState(item.data.switch)};
	    if (showShortCuts) then
	       item.name = item.name .. "/" .. item.data.switch;
	    end
	 end
      end
   end

   local usedSwitches = {};
   menu.overlays = {};
   for i,p in ipairs(menu.pages) do
      for k,item in ipairs(p.items) do
	 if (item.data.switch) then
	    if not (usedSwitches[item.data.switch]) then
	       usedSwitches[item.data.switch] = 1;
	    else
	       usedSwitches[item.data.switch] = usedSwitches[item.data.switch] + 1;
	    end
	 end
      end
   end
   for s,n in pairs(usedSwitches) do
      if (n > 1) then
	 menu.shortCuts[s] = nil;
	 local list = findSwitch(menu, s);
	 menu.overlays[s] = {pagelist = list, last = 0};
	 if (showShortCuts) then
	    for p,item in pairs(list) do 
	       item.name = item.name .. "*";
	    end
	 end
      end
   end

   for i,vit in ipairs(menu.allItems) do
      if (vit.virt) then
	 for l,pi in ipairs(vit.virt) do
	    for k,it in ipairs(menu.allItems) do
	       if (pi.c == it.data.count) and (pi.m == it.data.module) then
		  pi.it = it;
	       end
	    end
	 end
      end
   end
   
end

local function displayFooter(pie, text)
   lcd.drawText(pie.win.x, pie.win.y + pie.win.h - pie.win.fh, text, SMLSIZE + ctp3);
end

local function displayHeader(pie, text)
   lcd.drawText(pie.win.x + pie.win.w - 60, pie.win.y, text, SMLSIZE + ctp3);
end

local function displayInfo(pie, text)
   lcd.drawText(pie.win.x + pie.win.w - 60, pie.win.y + pie.win.fh, text, SMLSIZE + ctp3);
end

local function displayMenu(menu, event, pie, config)
--   print("z: ", pie.win.x, pie.win.y, pie.win.w, pie.win.h);
   if (lcd.drawScreenTitle) then
      lcd.clear()
      lcd.drawScreenTitle(menu.titlev, menu.state.activePage.number, #menu.pages);
   else  
      lcd.drawText(pie.win.x, pie.win.y, menu.titlev, MIDSIZE + ctp3);
      displayHeader(pie, menu.state.activePage.desc);
   end

   if (config) then
      local sb = (config.useSbus > 0) and "sbus" or "ibus" 
      displayFooter(pie, "Cfg: " .. config.name .. " Mdl: " .. model.getInfo().name .. " F: " .. config.cfgName .. " T: " .. sb);
   end
   local n = 0;
   for i,pa in ipairs(menu.pages) do
      if (pa == menu.state.activePage) then 
	 n = i; 
      end
   end
   local p = menu.state.activePage;

--   menu.rows = {};
--   menu.cols = {};
   
   for row, opt in ipairs(p.items) do
      local x = pie.win.x;
      local y = pie.win.y + pie.win.y_offset + (row - 1) * pie.win.fh;

--      local attr = (row == menu.state.activeRow) and (INVERS + SMLSIZE) or SMLSIZE;
--      lcd.drawText(x, y, opt.name, attr + COLOR_THEME_PRIMARY1, COLOR_THEME_SECONDARY3);

      if (row == menu.state.activeRow) then
	 lcd.drawText(x, y, opt.name, SMLSIZE + INVERS + cts2, ctp2);
      else
	 lcd.drawText(x, y, opt.name, SMLSIZE + ctp1);
      end
      
      local fw = pie.win.w / (#opt.states + 1);
      opt.rects = {};
      for col, st in ipairs(opt.states) do
	 x = x + fw;
	 
--	 attr = SMLSIZE;
--	 if (col == opt.state) then
--	    attr = attr + INVERS;
--	 else 
--	    if (menu.state.activeCol == col) and (row == menu.state.activeRow)  then
--	       attr = SMLSIZE + BLINK + INVERS;
--	    end
--	 end
--	 lcd.drawText(x, y, st, attr + COLOR_THEME_PRIMARY1, COLOR_THEME_SECONDARY3);

	 if (col == opt.state) then
	    lcd.drawText(x, y, st, SMLSIZE + INVERS + cts2, ctp2);
	 else 
	    if (menu.state.activeCol == col) and (row == menu.state.activeRow) then
	       lcd.drawText(x, y, st, SMLSIZE + INVERS + BLINK + cts2, ctp2);
	    else
	       lcd.drawText(x, y, st, ctp1);
	    end
	 end

	 if (LCD_W > 212) then
	    rect = {xmin = x, ymin = y, xmax = x + fw, ymax = y + pie.win.fh};
	    opt.rects[col] = rect;
	    if (event) then
	       if (menu.state.activeCol == col) and (row == menu.state.activeRow)  then
		  lcd.drawRectangle(x - 2, y - 2, fw - 4, pie.win.fh - 4, ORANGE);
	       else
		  lcd.drawRectangle(x - 2, y - 2, fw - 4, pie.win.fh - 4, GREY);
	       end
	    end
	 end
      end
   end
end

local function nextRow(menu) -- with page wrap
   local p = menu.state.activePage;
   if (menu.state.activeRow < #p.items) then
      menu.state.activeRow = menu.state.activeRow + 1;
   else
      if (p.next) then
	 menu.state.activePage = p.next;
	 menu.state.activeRow = 1;
end
   end
end

local function prevRow(menu) -- with page wrap
   local p = menu.state.activePage;
   if menu.state.activeRow > 1 then
      menu.state.activeRow = menu.state.activeRow - 1;
   else
      if (p.prev) then
	 menu.state.activePage = p.prev;
	 menu.state.activeRow = #p.prev.items;
      end
   end
end

local function nextCol(menu) -- with line and page wrap
   local p = menu.state.activePage;
   if (menu.state.activeRow < 1) then
      menu.state.activeRow = 1;
   end
   if (menu.state.activeCol < #p.items[menu.state.activeRow].states) then
      menu.state.activeCol = menu.state.activeCol + 1;
   else
      if (menu.state.activeRow < #p.items) then
	 menu.state.activeRow = menu.state.activeRow + 1;
	 menu.state.activeCol = 1;
      else
	 if (p.next) then
	    menu.state.activePage = p.next;
	    menu.state.activeRow = 1;
	    menu.state.activeCol = 1;
	 end
      end
   end
end

local function prevCol(menu) -- with line and page wrap
   local p = menu.state.activePage;
   if (menu.state.activeCol > 1) then
      menu.state.activeCol = menu.state.activeCol - 1;
   else
      if (menu.state.activeRow > 1) then
	 menu.state.activeRow = menu.state.activeRow - 1;
	 menu.state.activeCol = #p.items[menu.state.activeRow].states;
      else
	 if (p.prev) then
	    menu.state.activePage = p.prev;
	    menu.state.activeRow = #p.prev.items;
	    menu.state.activeCol = #p.prev.items[#p.prev.items].states;
	 end
      end
   end
end

local function processEvents(menu, event, pie)
--   if event > 0 then
--      print("ev:", event, EVT_VIRTUAL_DEC, EVT_VIRTUAL_PREV);
--   end
   local p = menu.state.activePage;
   if (event == 42) then
      nextCol(menu);
      return 1;
   elseif (event == 43) then
      prevCol(menu);
      return 1;
   elseif (event == 44) then
      nextRow(menu);
      return 1;
   elseif (event == 45) then
      prevRow(menu);
      return 1;
   elseif (event == 0x601) then
      nextCol(menu);
      return 1;
   elseif (event == 0x600) then
      prevCol(menu);
      return 1;
   elseif (event == 0x1004) then
      nextRow(menu);
      return 1;
   elseif (event == 0x1003) then
      prevRow(menu);
      return 1;
   elseif (event == EVT_VIRTUAL_DEC) then -- up
      if (EVT_VIRTUAL_DEC == EVT_VIRTUAL_PREV) then -- scroll
	 prevCol(menu);
      else
	 nextRow(menu);
      end
      return 1;
   elseif (event == EVT_VIRTUAL_INC) then
      if (EVT_VIRTUAL_INC == EVT_VIRTUAL_NEXT) then
	 nextCol(menu);
      else
	 prevRow(menu);
      end
      return 1;
   elseif (event == 100) or (event == EVT_VIRTUAL_NEXT) then
      nextCol(menu);
      return 1;
   elseif (event == 101) or (event == EVT_VIRTUAL_PREV) then
      prevCol(menu);
      return 1;
   elseif (event == EVT_VIRTUAL_ENTER) then
      if (menu.state.activeRow > 0) then
	 --      print("X: ", p.items[menu.state.activeRow]);
	 menu.cb(p.items[menu.state.activeRow], menu);
      end
   elseif (event == 0x602) then
      if (menu.state.activeRow > 0) then
	 --      print("X: ", p.items[menu.state.activeRow]);
	 menu.cb(p.items[menu.state.activeRow], menu);
      end
   elseif (event == EVT_VIRTUAL_EXIT) then
      menu.state.activeRow = 0;
      menu.state.activeCol = 1;
   end
   return 0;
end

local buttons = {
   lastn = 0,
   lastp = 0,
   lastl = 0,
   lastr = 0,
   lastu = 0,
   lastd = 0,
   lasts = 0,
   lastm = 0
}

local function readButtons(pie)  
   local e = 0;
   if (pie.options.Next) then
      local nv = getValue(pie.options.Next);
      if (nv > buttons.lastn) then
--	 e = EVT_VIRTUAL_INC;
      	 e = 42;
      end
      buttons.lastn = nv;
   end
   if (pie.options.Previous) then
      local pv = getValue(pie.options.Previous);
      if (pv > buttons.lastp) then
--	 e = EVT_VIRTUAL_DEC;
	 e = 43;
      end
      buttons.lastp = pv;
   end
   if (pie.options.Up) then
      local lu = getValue(pie.options.Up);
      if (lu > buttons.lastu) then
--	 e = EVT_VIRTUAL_PREV;
	 e = 44;
      end
      buttons.lastu = lu;
   end
   if (pie.options.Down) then
      local dv = getValue(pie.options.Down);
      if (dv > buttons.lastd) then
--	 e =  EVT_VIRTUAL_NEXT;
	 e =  45;
      end
      buttons.lastd = dv;
   end
   if (pie.options.Select) then
      local sv = getValue(pie.options.Select);
      if (sv > buttons.lasts) then
	 e =  EVT_VIRTUAL_ENTER;
      end
      buttons.lasts = sv;
   end
--   print("rb: ", e);
   return e;
end 

local function inputToMenuLine(name, menu) 
   local p = menu.state.activePage;
   local n = #p.items;
   local v = getValue(name) + 1024;
   local l = n - math.floor((v * n) / 2049);
   return l;
end

local function inputToMenuCol(name, menu) 
   local p = menu.state.activePage;
   if ((menu.state.activeRow > 0) and (menu.state.activeRow <= #p.items)) then
      local n = #p.items[menu.state.activeRow].states;
      local v = getValue(name) + 1024;
      local l = math.floor((v * n) / 2049) + 1;
      return l;
   end
   return 0;
end

local function readMenuSwitch(menu)
   if (menu.msFI) then
      local ms = 0;
      ms = getValue(menu.msFI);
      if (math.abs(ms - buttons.lastm) > 10) then
	 buttons.lastm = ms;
	 local s = 1;
	 for i = 0,5 do
	    if (ms <= (-1024 + (2 * i  + 1) * (2048 / menu.msdiv))) then
	       s = i + 1;
	       break;
	    end
	 end
	 --print(s);
	 if (s <= #menu.pages) then
	    menu.state.activePage = menu.pages[s];
	    return 1;
	 end
      end
   end
   return 0;
end

local function readSpeedDials(menu)
   if (menu.lsID) then
      local lv = 0;
      lv = inputToMenuLine(menu.lsID, menu);
      if not (lv == buttons.lastl) then
	 menu.state.activeRow = lv;
	 buttons.lastl = lv;
      end
   end
   if (menu.rsID) then
      local rv = 0;
      rv = inputToMenuCol(menu.rsID, menu);
      if not (rv == buttons.lastr) then
	 menu.state.activeCol = rv;
	 buttons.lastr = rv;
      end
   end
   readMenuSwitch(menu);
end

local function covers(touch, item) 
   if ((touch.x >= item.xmin) and (touch.x <= item.xmax) and (touch.y >= item.ymin) and (touch.y <= item.ymax)) then
      return true;
   end
   return false;
end

local function processTouch(menu, event, touch)
   if (touch) then
      local p = menu.state.activePage;
      if (event == EVT_TOUCH_TAP) then
	 for row, opt in ipairs(p.items) do
	    for col, r in ipairs(opt.rects) do   
	       if (covers(touch, r)) then
		  menu.state.activeRow = row;
		  menu.state.activeCol = col;
		  return 1;
	       end
	    end
	 end
      end
      if (event == EVT_TOUCH_SLIDE) then
	 if (touch.swipeLeft) then
	    menu.state.activePage = p.next;
	 end
	 if (touch.swipeRight) then
	    menu.state.activePage = p.prev;
	 end
      end
   end
   return 0;
end


local function readConfig(filename, cfg)
   local config = nil;
   local fd = io.open(filename, "r");
   if (fd) then
      local configFunction = loadfile(filename);
      if (configFunction) then
	 config = configFunction();
	 config.cfgName = filename;
      end
   else
      if (cfg) then
	 local f = cfg.defaultFilename;
	 if (LCD_W <= 128) then
	    f = cfg.defaultFilenameS;
	 elseif (LCD_W <= 212) then
	    f = cfg.defaultFilenameM;
	 end
	 local configFunction = loadfile(f);
	 if (configFunction) then
	    config = configFunction();
	    config.cfgName = f;
	 end
      end
   end
   return config;
end

local function nameToConfigFilename(name)
   return "/MODELS/" .. name .. ".lua";
end

return {initMenu = initMenu, displayMenu = displayMenu,
	displayInfo = displayInfo,
	encodeFunction = encodeFunction, encodeParameter = encodeParameter, sendValue = sendValue, scaleParameterValue = scaleParameterValue,
	findItem = findItem,
	processEvents = processEvents,
	readButtons = readButtons, readSpeedDials = readSpeedDials, switchState = switchState, readMenuSwitch=readMenuSwitch,
	broadcastReset = broadcastReset, broadcastOff = broadcastOff,
	processTouch = processTouch,
	--broadcastParam = broadcastParam,
	encodeFunctionSbus = encodeFunctionSbus, encodeParameterSbus = encodeParameterSbus, scaleParameterValueSbus = scaleParameterValueSbus,
	readConfig = readConfig, nameToConfigFilename=nameToConfigFilename,
	Class = Class};
