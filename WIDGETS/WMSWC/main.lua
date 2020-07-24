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

--- define fallback menu

local menu = {
  title = "WM Multikanal Config Fallback",

  parameterDial = "s1",

  state = {
    activeRow = 1,
    activeCol = 1,
    activePage = nil
  },
  pages = {
    {
      items = {
        -- do NOT use states
        {name = "Fun A1", states = {""}, state = 0, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 1}},
        {name = "Fun B1", states = {""}, state = 0, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 1}},
        {name = "Fun C1", states = {""}, state = 0, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 1}},
        {name = "Fun D1", states = {""}, state = 0, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 1}},
        {name = "Fun E1", states = {""}, state = 0, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 1}},
        {name = "Fun F1", states = {""}, state = 0, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 1}},
        {name = "Fun G1", states = {""}, state = 0, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 1}},
        {name = "Fun H1", states = {""}, state = 0, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 1}},
      }
    }
  }
}   

-----

-- used as general module/channel config
local parameters = {names = {"Res", "PWM", "B1/I", "B1/d", "B2/I", "B2/d", "PThru", "Min", "Max"}, values = {0, 1, 2, 3, 4, 5, 6, 12, 13}};

-- used as global module config : parameter 14 is used also to learn module address
local globalParameters = {names = {"L/Res", "MPX0", "MPX1", "MPX2", "MPX3", "MPX4"}, values = {14, 7, 8, 9, 10, 11}};

local defaultFilename = "/MODELS/swstd.lua";
local cfgName = nil;
local config = nil;
local lib = nil;
local gVar = 5; -- fallback for digital switches
local gVarOffset = 5; -- fallback for tiptip switches: gvar[module] = gVarOffset + module. Modules begin with 1, so gvars start with 6. 

----- nothing to setup below this line

local lastSelection = {item = nil, col = 0, time = 0};

local followHasRun = false;


local function pushValue()
  local dt = getTime() - lastSelection.time;
  if (followHasRun and (dt > 10) and lastSelection.item and (lastSelection.col > 0)) then
    local v = 0;
    if (config.useSbus > 0) then
      v = lib.scaleParameterValueSbus(getValue(menu.parameterDial));
    else
      v = lib.scaleParameterValue(getValue(menu.parameterDial));
    end
--    print("push: ", v);
--    lib.sendValue(gVar, lib.encodeParameter(lastSelection.col, v));
    local pv = lastSelection.item.stateValues[lastSelection.col];
    if (config.useSbus > 0) then
      lib.sendValue(gVar, lib.encodeParameterSbus(pv, v));
    else
      lib.sendValue(gVar, lib.encodeParameter(pv, v));
    end
  end
end


local function deselectAll() 
--  print("desel");
  for prow, p in ipairs(menu.pages) do
    for row, item in ipairs(p.items) do
      item.state = 0;
    end
  end
  lastSelection.item = nil;
  lastSelection.col = 0;
end

local function select(item, menu)
--  print("sel: ", item.name, item.state, menu.state.activeCol);
  deselectAll();
  lastSelection.item = item;
  lastSelection.col = menu.state.activeCol;
  item.state = menu.state.activeCol;
  lib.broadcastReset(gVar);
  lastSelection.time = getTime();
  followHasRun = false;
end

local function selectFollow()
  local dt = getTime() - lastSelection.time;
  if (lastSelection.item and (dt > 10) and not followHasRun) then
    followHasRun = true;
    lastSelection.time = getTime();
    if (config.useSbus > 0) then
      lib.sendValue(gVar, lib.encodeFunctionSbus(lastSelection.item.data.module, lastSelection.item.data.count, 2)); -- select on state 
    else
      lib.sendValue(gVar, lib.encodeFunction(lastSelection.item.data.module, lastSelection.item.data.count, 2)); -- select on state 
    end
    --   print("selFollow");
  end
end

local function percent(value)
  return math.floor((value + 1024) * 100 / 2048);
end

local function printParameter(pie)
  local r = getValue(menu.parameterDial);
  local v = 0;
  if (config.useSbus > 0) then
    v = lib.scaleParameterValueSbus(r);
  else
    v = lib.scaleParameterValue(r);
  end
  lcd.drawText(pie.zone.x + pie.zone.w - 60, pie.zone.y + 16, "V: " .. tostring(percent(r)) .. "%/" .. tostring(v), SMLSIZE);
end

local function run(event, pie)
  if not event then
    event = lib.readButtons(pie);
  end
  lib.processEvents(menu, event, pie);
  lib.displayMenu(menu, event, pie, config);
  printParameter(pie);  
  selectFollow();
  pushValue();
end

local function init(options)
  lib = loadfile("/SCRIPTS/WM/wmlib.lua")();
  local cfg = loadfile("/SCRIPTS/CONFIG/wmcfg.lua")();

  if (cfg) then
    gVar = cfg.switchGVar;
    gVarOffset = cfg.offsetGVar;
  end

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

  menu.title = menu.title.. " - Config";

  lib.initMenu(menu, select, cfg.version, false);

  for i,p in ipairs(menu.pages) do
    if (p.config) then
      for k,item in ipairs(p.items) do
        item.states = globalParameters.names;
        item.stateValues = globalParameters.values;
      end
    else
      for k,item in ipairs(p.items) do
        item.states = parameters.names;
        item.stateValues = parameters.values;
      end
    end
  end
end

local options = {
  { "Next",     SOURCE, 8 },
  { "Previous", SOURCE, 9 },
  { "Select",   SOURCE, 10 },
  { "Left",     SOURCE, 11 },
  { "Right",    SOURCE, 12 }
}

local function create(zone, options)
  init(options);
  local pie = { zone=zone, options=options, counter=0 };
  return pie;
end

local function update(pie, options)
  pie.options = options;
end

local lastVisible = getTime();

local function background()
  if ((getTime() - lastVisible) > 30) then
    lastSelection.item = nil;
    lastSelection.col = 0;
  end
end

local function refresh(pie)
  lastVisible = getTime();
  run(nil, pie);
end

return { name="WMSwConf", options=options, create=create, update=update, refresh=refresh, background=background}
