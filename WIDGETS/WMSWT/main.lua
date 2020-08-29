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
  title = "WM MultiTip Fallback";

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
        {name = "Fun A", states = {"aus", "ein 1", "ein 2"}, state = 1, data = {switch = "sa", count = 1, offState = 1, module = 1}},
        {name = "Fun B", states = {"aus", "ein 1", "ein 2"}, state = 1, data = {switch = "sb", count = 2, offState = 1, module = 1}},
        {name = "Fun C", states = {"aus", "ein 1", "ein 2"}, state = 1, data = {switch = nil, count = 3, offState = 1, module = 1}},
        {name = "Fun D", states = {"aus", "ein 1", "ein 2"}, state = 1, data = {switch = nil, count = 4, offState = 1, module = 1}},
        {name = "Fun E", states = {"aus", "ein 1", "ein 2"}, state = 1, data = {switch = nil, count = 5, offState = 1, module = 1}},
        {name = "Fun F", states = {"aus", "ein 1", "ein 2"}, state = 1, data = {switch = nil, count = 6, offState = 1, module = 1}},
        {name = "Fun G", states = {"aus", "ein 1", "ein 2"}, state = 1, data = {switch = nil, count = 7, offState = 1, module = 1}},
        {name = "Fun H", states = {"aus", "ein 1", "ein 2"}, state = 1, data = {switch = nil, count = 8, offState = 1, module = 1}},
      }
    }
  }
}   

local defaultFilename = "/MODELS/tpstd.lua";
local defaultFilenameM = "/MODELS/tpstdm.lua";
local defaultFilenameS = "/MODELS/tpstds.lua";
local config = nil;
local lib = nil;
local gVar = 5; -- fallback for digital switches
local gVarOffset = 5; -- fallback for tiptip switches: gvar[module] = gVarOffset + module. Modules begin with 1, so gvars start with 6. 
local stateTimeout = 10;  --fallback

---- mostly valid values

local parameter = {
  pulse = {duration = 30, pause = 30, long = 100}; -- 300ms/750ms
  dead = {duration = 100, lastAction = getTime()}; -- 3s before next action 
  pulseValue = {0, -1024, 1024, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  neutral = 1; -- index
}

----- nothing to setup below this line

local sstate = {}

sstate.states = {idle = 0, start = 1, pulse = 2, deadWait = 3};
sstate.state  = sstate.states.idle;
sstate.active = {item = nil,
		 pulseCount = 0, nextToggle = 0, startTime = getTime(),
		 on = false};
sstate.switches = nil;

-------

local queue = {};

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
      local item = l.pagelist[menu.state.activePage];
      if (item) then
	 local ns = lib.switchState(name);
	 if not (l.last == ns) then
	    item.state = ns;
	    l.last = ns;
	    queue:push(item);
	 end
      end
   end
end

local function background()
   sendShortCuts();
   if (sstate.state == sstate.states.deadWait) and (getTime() > (parameter.dead.lastAction + parameter.dead.duration)) then
      sstate.state = sstate.states.idle;
   elseif (sstate.state == sstate.states.idle) then
      if (queue:size() > 0) then
	 sstate.active.item = queue:pop();
	 sstate.state = sstate.states.start;
      end
   elseif (sstate.state == sstate.states.start) then
      sstate.active.startTime = getTime();
      sstate.active.pulseCount = 1;
      sstate.active.nextToggle = getTime() + ((sstate.active.item.data.count == 1) and parameter.pulse.long or parameter.pulse.duration);
      lib.sendValue(sstate.active.item.data.module + gVarOffset, parameter.pulseValue[sstate.active.item.state]);      
      sstate.state = sstate.states.pulse;
      sstate.active.on = true;
   elseif (sstate.state == sstate.states.pulse) then
      if (getTime() > sstate.active.nextToggle) then
        if (sstate.active.on) then
	   lib.sendValue(sstate.active.item.data.module + gVarOffset, parameter.pulseValue[parameter.neutral]);
	   sstate.active.on = false;
	   sstate.active.nextToggle = sstate.active.nextToggle + parameter.pulse.pause;
	   if (sstate.active.item.data.count == sstate.active.pulseCount) then
	      sstate.state = sstate.states.deadWait;
	      parameter.dead.lastAction = getTime();
	      playHaptic(10, 100);
	   end
        else 
	   sstate.active.pulseCount = sstate.active.pulseCount + 1;
	   lib.sendValue(sstate.active.item.data.module + gVarOffset, parameter.pulseValue[sstate.active.item.state]);
	   sstate.active.on = true;
	   sstate.active.nextToggle = sstate.active.nextToggle + ((sstate.active.item.data.count > sstate.active.pulseCount) and parameter.pulse.duration or parameter.pulse.long);
        end
      end
   end
end

local function select(item, menu)
  if (not item) then
     return;
  end
  print("sel: ", item, item.name, item.state, menu.state.activeCol);

  if (menu.state.activeCol == item.data.offState) then
     if not (item.state == item.data.offState) then
	local dummy = {};
	dummy.state = item.state;
	dummy.data = item.data;
	item.state = item.data.offState;
	queue:push(dummy);
     end
  else
     if not (item.state == menu.state.activeCol) then
	item.state = menu.state.activeCol;
	queue:push(item);
     end
  end
end

local function procAndDisplay(event, pie)
   lib.processEvents(menu, event, pie);
   lib.displayMenu(menu, event, pie, config);
end

local function run(event, pie)
   if not event then
      event = lib.readButtons(pie);
   end
   lib.readSpeedDials(lsID, rsID, pie, menu);
   lib.processEvents(menu, event, pie);
   lib.displayMenu(menu, event, pie, config);
   
   if not (sstate.state == sstate.states.idle) then
      lib.displayInfo(pie, "busy!");
   else
      lib.displayInfo(pie, "-----");
   end
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

  local cfgName = nil;
  if (options) then
     if (options.Name) then
	local filename = "/MODELS/" .. options.Name .. "lua";
	cfgName = filename;
	local fd = io.open(filename, "r");
	if (fd) then
	   local configFunction = loadfile(filename);
	   if (configFunction) then
	      config = configFunction();
	   end
	end
     end
  end
  if not config then
     cfgName = model.getInfo().name .. ".lua";
     local configFunction = loadfile(cfgName);
     if (configFunction) then
	config = configFunction();
     end
  end
  if not config then
     if (LCD_W <= 212) then
	defaultFilename = defaultFilenameM;
     end
     if (LCD_W <= 128) then
	defaultFilename = defaultFilenameS;
     end
     cfgName = defaultFilename;
     config = loadfile(defaultFilename)();
  end

  config.cfgName = cfgName;

  if (config.menu) then
     menu = config.menu;
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

return { name="WMSwTip", options=options, create=create, update=update, refresh=refresh, init=init, background=background, run=run, procAndDisplay=procAndDisplay}
