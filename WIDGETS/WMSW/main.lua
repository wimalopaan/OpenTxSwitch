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

local mode = 1; -- 0: tiptip; 1: digital-idempotential

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
        {name = "Fun A", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "sa", count = 1, offState = 1, module = 1}},
        {name = "Fun B", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "sb", count = 2, offState = 1, module = 1}},
        {name = "Fun C", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 1}},
        {name = "Fun D", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 1}},
        {name = "Fun E", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 1}},
        {name = "Fun F", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 1}},
        {name = "Fun G", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 1}},
        {name = "Fun H", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 1}},
      }
    }
  }
}   

local defaultFilename = "/MODELS/swstd.lua";
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
sstate.active = {item= nil,
  pulseCount = 0, nextToggle = 0, startTime = getTime(),
  on = false};
sstate.switches = nil;

-------

local queue = {first = 0, last = -1};

function queue:push (item)
  self.last = self.last + 1;
  self[self.last] = item;
end
function queue:pop()
  local item = self[self.first];
  self[self.first] = nil;
  self.first = self.first + 1;
  return item;
end
function queue:size()
  return self.last - self.first + 1;
end

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
  if (mode == 0) then
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
      sstate.active.nextToggle = getTime() + ((sstate.active.item.count == 1) and parameter.pulse.long or parameter.pulse.duration);
      lib.sendValue(sstate.active.item.module + gVarOffset, parameter.pulseValue[sstate.active.item.state]);      
      sstate.state = sstate.states.pulse;
      sstate.active.on = true;
    elseif (sstate.state == sstate.states.pulse) then
      if (getTime() > sstate.active.nextToggle) then
        if (sstate.active.on) then
          lib.sendValue(sstate.active.item.module + gVarOffset, parameter.pulseValue[parameter.neutral]);
          sstate.active.on = false;
          sstate.active.nextToggle = sstate.active.nextToggle + parameter.pulse.pause;
          if (sstate.active.item.count == sstate.active.pulseCount) then
            sstate.state = sstate.states.deadWait;
            parameter.dead.lastAction = getTime();
            playHaptic(10, 100);
          end
        else 
          sstate.active.pulseCount = sstate.active.pulseCount + 1;
          lib.sendValue(sstate.active.item.module + gVarOffset, parameter.pulseValue[sstate.active.item.state]);
          sstate.active.on = true;
          sstate.active.nextToggle = sstate.active.nextToggle + ((sstate.active.item.count > sstate.active.pulseCount) and parameter.pulse.duration or parameter.pulse.long);
        end
      end
    end
  elseif (mode == 1) then
    local t = getTime();
    if (queue:size() > 0) then
--      print("q > 0");
      if ((t - lastbg1) > stateTimeout) then
        lastbg = t;
        lastbg1 = t;
        local i = queue:pop();
        lib.sendValue(gVar, lib.encodeFunction(i.data.module, i.data.count, i.state)); 
      end
    else
      if ((t - lastbg) > stateTimeout) then
        lastbg = t;
--        print("state", cycle);
        local i = menu.allItems[cycle];
        lib.sendValue(gVar, lib.encodeFunction(i.data.module, i.data.count, i.state)); 
        cycle = cycle + 1;
        if (cycle > #menu.allItems) then
          cycle = 1;
        end
      end
    end
    sendShortCuts();
--    lib.sendShortCuts(menu, gVar);
  end 
end

local function toggle(count, state, module)
--  print("toggle", count, state, module);
  local e = {count = count, state = state, module = module};
  queue:push(e);
end

local function select(item, menu)
  if (not item) then
    return;
  end
  if (mode == 0) then
    if not (item.state == menu.state.activeCol) then
      if not (item.state == item.data.offState) then
        toggle(item.data.count, item.state, item.data.module);
      end
      if not (menu.state.activeCol == item.data.offState) then
        toggle(item.data.count, menu.state.activeCol, item.data.module);
      end
      item.state = menu.state.activeCol;
    end
  elseif (mode == 1) then
--    print("sel: ", item, item.name, item.state, menu.state.activeCol);
    item.state = menu.state.activeCol;
    queue:push(item);
--    lib.sendValue(gVar, lib.encodeFunction(item.data.module, item.data.count, item.state)); 
  end
end

local function run(event, pie)
  if not event then
    event = lib.readButtons(pie);
  end
  lib.readSpeedDials(lsID, rsID, pie, menu);
  lib.processEvents(menu, event, pie);
  lib.displayMenu(menu, event, pie, config);

  if (mode == 0) then
    if not (sstate.state == sstate.states.idle) then
      lib.displayInfo(pie, "busy!");
    else
      lib.displayInfo(pie, "-----");
    end
  end
end

local function init(options)
  lib = loadfile("/SCRIPTS/WM/wmlib.lua")();
  local cfg = loadfile("/SCRIPTS/CONFIG/wmcfg.lua")();

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
    cfgName = defaultFilename;
    config = loadfile(defaultFilename)();
  end

  config.cfgName = cfgName;

  if (config.menu) then
    menu = config.menu;
  end

  lib.initMenu(menu, select, cfg.version, true);
end

local options = {
  { "Next",     SOURCE, 8},
  { "Previous", SOURCE, 9},
  { "Select",   SOURCE, 10},
  { "Name", STRING, "swstd"}  -- bug in OpenTX?
}

local function create(zone, options)
  init(options);
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

return { name="WMSwitch", options=options, create=create, update=update, refresh=refresh}
