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
local stateTimeout = 10;  --fallback

----- nothing to setup below this line

local queue = {};

local encode = nil;

local function sendShortCuts() 
   for name,s in pairs(menu.shortCuts) do
      local ns = lib.switchState(name);
      if not (s.last == ns) then
	 s.item.state = ns;
	 s.last = ns;
	 queue:push(s.item);
      end
   end
   for name,l in pairs(menu.overlays) do
      --    print(name);
      local item = l.pagelist[menu.state.activePage];
      if (item) then
	 --      print(item.name);
	 local ns = lib.switchState(name);
	 if not (l.last == ns) then
	    item.state = ns;
	    l.last = ns;
	    queue:push(item);
	    --        print(item.name);
	 end
      end
   end
end

local lastbg = getTime();
local lastbg1 = getTime();
local cycle = 1;

local function background()
   if (model.getGlobalVariable(gVar + 1, 0) > 0) then
      return;
   end
   sendShortCuts();
   local t = getTime();
   if (queue:size() > 0) then
      --      print("q > 0");
      if ((t - lastbg1) > stateTimeout) then
	 lastbg = t;
	 lastbg1 = t;
	 local i = queue:pop();
	 lib.sendValue(gVar, encode(i.data.module, i.data.count, i.state)); 
      end
   else
      if ((t - lastbg) > stateTimeout) then
      	 lastbg = t;
      	 --        print("state", cycle);
      	 local i = menu.allItems[cycle];
      	 lib.sendValue(gVar, encode(i.data.module, i.data.count, i.state)); 
      	 cycle = cycle + 1;
      	 if (cycle > #menu.allItems) then
      	    cycle = 1;
      	 end
      end
   end
end

local function select(item, menu)
   if (not item) then
      return;
   end
   --    print("sel: ", item, item.name, item.state, menu.state.activeCol);
   item.state = menu.state.activeCol;
   queue:push(item);
end

local function procAndDisplay(event, pie)
   lib.processEvents(menu, event, pie);
   lib.displayMenu(menu, event, pie, config);
end

local function run(event, pie)
   if not event then
      event = lib.readButtons(pie);
   end
   lib.readSpeedDials(menu);
   procAndDisplay(event, pie);
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

--   local cfgName = nil;
   if (options) then
      if (options.Name) then
	 local filename = lib.nameToConfigFilename(options.Name);
--	 cfgName = filename;
	 config = lib.readConfig(filename, cfg);
      end
   end
   if not config then
      local filename = lib.nameToConfigFilename(model.getInfo().name);
--      cfgName = filename;
      config = lib.readConfig(filename, cfg);
   end
--   if not config then
--      if (LCD_W <= 212) then
--	 defaultFilename = defaultFilenameM;
--      end
--      if (LCD_W <= 128) then
--	 defaultFilename = defaultFilenameS;
--      end
--      cfgName = defaultFilename;
--      config = loadfile(defaultFilename)();
--   end

--   config.cfgName = cfgName;

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
   { "Name", STRING, "swstd"}  -- bug in OpenTX?
}

local function create(zone, options)
   init(options);
   zone.fh = 16;
   zone.y_offset = 32;
   local pie = { zone=zone, options=options};
   return pie;
end

local function update(pie, options)
   pie.options = options;
end

local function refresh(pie)
   background();
   run(nil, pie);
end

return { name="WMSwitch", options=options, create=create, update=update, refresh=refresh, init=init, background=background, run=run, procAndDisplay=procAndDisplay}
