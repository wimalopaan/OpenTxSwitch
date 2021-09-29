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

-- define fallback menu

local menu = {
   title = "WM MultiSwitch Fallback",

   scrollUpDn = "ls", -- speedDials: direct navigating
   scrollLR = "rs",

   pageSwitch = "6p";

--   remote = "trn16";
   remote = nil; -- deactivated
   
   state = {
      activeRow = 1,
      activeCol = 1,
      activePage = nil
   },

   pages = {
      {
	 items = {
	    {name = "Fun A", states = {"aus", "ein", "blink1", "blink2"}, state = 1, data = {switch = "sa", count = 1, module = 1}},
	    {name = "Fun B", states = {"aus", "ein", "blink1", "blink2"}, state = 1, data = {switch = "sb", count = 2, module = 1}},
	    {name = "Fun C", states = {"aus", "ein", "blink1", "blink2"}, state = 1, data = {switch = nil, count = 3, module = 1}},
	    {name = "Fun D", states = {"aus", "ein", "blink1", "blink2"}, state = 1, data = {switch = nil, count = 4, module = 1}},
	    {name = "Fun E", states = {"aus", "ein", "blink1", "blink2"}, state = 1, data = {switch = nil, count = 5, module = 1}},
	    {name = "Fun F", states = {"aus", "ein", "blink1", "blink2"}, state = 1, data = {switch = nil, count = 6, module = 1}},
	    {name = "Fun G", states = {"aus", "ein", "blink1", "blink2"}, state = 1, data = {switch = nil, count = 7, module = 1}},
	    {name = "Fun H", states = {"aus", "ein", "blink1", "blink2"}, state = 1, data = {switch = nil, count = 8, module = 1}},
	 }
      }
   }
}   

--local defaultFilename = "/MODELS/swstd.lua";
--local defaultFilenameM = "/MODELS/swstdm.lua";
--local defaultFilenameS = "/MODELS/swstdx.lua";
local config = nil;
local lib = nil;

local gVar = 5; -- fallback for digital switches
-- using gVar:     value to mixer
-- using (gVar+1): stop from config widget
-- using (gVar+2): input from other widgets

local stateTimeout = 10;  --fallback

local exportValues = {0, -50, 50, 100};

----- nothing to setup below this line

local queue = {};

local encode = nil;

local lastRemote = 0;
-- local rdbg = 0;

local lastWidgetGV = 0;
local function sendForeignWidget()
   local fv = model.getGlobalVariable(gVar + 2, 0);
   if (fv == lastWidgetGV) then
      return;
   end
   lastWidgetGV = fv;

   local st = fv % 10;
   fv = math.floor(fv / 10);
   local co = fv % 10
   fv = math.floor(fv / 10);
   local mo = fv % 10;;

--   print("it: ", mo, co, st);
   
   local menu_item = lib.findItem(menu, mo, co);
   if (menu_item) then
      menu_item.state = st;
      queue:push(menu_item);
   end   
end

local function sendRemote()
   if (not menu.remote) then
      return;
   end

   local r = (getValue(menu.remote) + 1024) / 2;

   if (r == lastRemote) then
      return;
   end
   lastRemote = r;
   
   local st = bit32.extract(r, 0, 3) + 1;
   local co = bit32.extract(r, 3, 3) + 1;
   local mo = bit32.extract(r, 6, 3) + 1;

   local menu_item = lib.findItem(menu, mo, co);
   if (menu_item) then
      menu_item.state = st;
      queue:push(menu_item);
   end   
end

local function processVirtuals(item)
   for i,v in ipairs(item.virt) do
      --	 print("v: " .. item.name .. " : " .. v.c .. " : " .. v.m);
      local vitem = { data = { count = v.c, module = v.m}, state = item.state};
      queue:push(vitem);
      local pi = v.it;
      if (pi) then
	 pi.state = item.state;
      end
   end
end

local function sendShortCuts() 
   for name,s in pairs(menu.shortCuts) do
      local ns = lib.switchState(name);
      if not (s.last == ns) then
	 s.item.state = ns;
	 s.last = ns;
	 if (s.item.virt) then
	    processVirtuals(s.item);
	 else
	    queue:push(s.item);
	 end
      end
   end
   for name,l in pairs(menu.overlays) do
      local item = l.pagelist[menu.state.activePage];
      if (item) then
	 local ns = lib.switchState(name);
	 if not (l.last == ns) then
	    item.state = ns;
	    l.last = ns;
	    if (item.virt) then
	       processVirtuals(item);
	    else
	       queue:push(item);
	    end
	 end
      end
   end
end

local lastbg = getTime();
local lastbg1 = getTime();
local cycle = 1;

local function backgroundLocal()
   if (model.getGlobalVariable(gVar + 1, 0) > 0) then
      return;
   end
   sendRemote();
   sendShortCuts();
   sendForeignWidget();   
   local t = getTime();
   if (queue:size() > 0) then
      --      print("q > 0");
      if ((t - lastbg1) > stateTimeout) then
	 lastbg = t;
	 lastbg1 = t;
	 local i = queue:pop();
	 if (i.data.module > 0) and (i.data.count > 0) then
	    lib.sendValue(gVar, encode(i.data.module, i.data.count, i.state));
	 end
	 if (i.data.export) then
	    model.setGlobalVariable(i.data.export, 0, exportValues[i.state]);
	 end
      end
   else
      if ((t - lastbg) > stateTimeout) then
      	 lastbg = t;
      	 --        print("state", cycle);
      	 local i = menu.allItems[cycle];
	 if (i.data.module > 0) and (i.data.count > 0) then
	    lib.sendValue(gVar, encode(i.data.module, i.data.count, i.state));
	 end
      	 cycle = cycle + 1;
      	 if (cycle > #menu.allItems) then
      	    cycle = 1;
      	 end
      end
   end
end

local function backgroundFull()
   backgroundLocal();
end

local function select(item, menu)
   if (not item) then
      return;
   end
   item.state = menu.state.activeCol;
   if (item.virt) then
      processVirtuals(item);
   else
      queue:push(item);
   end
end

local function procAndDisplay(event, pie)
   lib.processEvents(menu, event, pie);
   lib.displayMenu(menu, event, pie, config);
--   lib.displayInfo(pie, rdbg);
end

local function run(event, pie, touch)
   lib.displayMenu(menu, event, pie, config);
   if not event then
      event = lib.readButtons(pie);
   end
   lib.readSpeedDials(menu);
   lib.processEvents(menu, event, pie);
   lib.processTouch(menu, event, touch);
end

local function init(options)
   lib = loadfile("/SCRIPTS/WM/wmlib.lua")();
   local cfg = loadfile("/SCRIPTS/CONFIG/wmcfg.lua")();

   queue = lib.Class.Queue.new();

   if (cfg) then
      gVar = cfg.switchGVar;
      gVarOffset = cfg.offsetGVar;
      stateTimeout = cfg.stateTimeout;
   end

   if (options) then
      if (options.Name) then
	 local filename = lib.nameToConfigFilename(options.Name);
	 config = lib.readConfig(filename, nil);
      end
   end
   if not config then
      local filename = lib.nameToConfigFilename(model.getInfo().name);
      config = lib.readConfig(filename, cfg);
   end

   if (config.menu) then
      menu = config.menu;
   end

   if (config.useSbus > 0) then
      encode = lib.encodeFunctionSbus;
   else
      encode = lib.encodeFunction;
   end
   
   for i,p in ipairs(menu.pages) do
      if (p.config) then
	 menu.pages[i] = nil;
      end
   end

   lib.initMenu(menu, select, cfg.version, true);
   
   return lib, menu, config;
end

local options = {
   { "Next",     SOURCE, 8},
   { "Previous", SOURCE, 9},
   { "Select",   SOURCE, 10},
   { "Up",       SOURCE, 32},
   { "Down",     SOURCE, 32},
--   { "Name", STRING, "swstd"}  -- only 4 chars in 32bit int
}

local function create(zone, options)
   init(options);
--   zone.fh = 16; -- font height
--   zone.y_offset = 32; -- absolute offset
   local pie = {};
   pie.zone = zone;
   pie.options = options;
   pie.win = {};
   pie.win.fh = 16;
   pie.win.y_offset = 32;
   return pie;
end

local function update(pie, options)
   pie.options = options;
end

local function refresh(pie, event, touch)
   backgroundFull();
   if (event) then -- fullscreen
      pie.win.x = 0;
      pie.win.y = 0;
      pie.win.w = LCD_W;
      pie.win.h = LCD_H;
      pie.win.fh = 24;
   else
      pie.win.x = pie.zone.x;
      pie.win.y = pie.zone.y;
      pie.win.w = pie.zone.w;
      pie.win.h = pie.zone.h;
      pie.win.fh = 16;
   end
   run(event, pie, touch);
end

return { name="WMSwitch", options=options, create=create, update=update, refresh=refresh, init=init, background=backgroundFull, backgroundLocal=backgroundLocal, run=run, procAndDisplay=procAndDisplay}
