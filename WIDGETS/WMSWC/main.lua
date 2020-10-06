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
        {name = "Fun A1", states = {""}, state = 0, data = {switch = nil, count = 1, module = 1}},
        {name = "Fun B1", states = {""}, state = 0, data = {switch = nil, count = 2, module = 1}},
        {name = "Fun C1", states = {""}, state = 0, data = {switch = nil, count = 3, module = 1}},
        {name = "Fun D1", states = {""}, state = 0, data = {switch = nil, count = 4, module = 1}},
        {name = "Fun E1", states = {""}, state = 0, data = {switch = nil, count = 5, module = 1}},
        {name = "Fun F1", states = {""}, state = 0, data = {switch = nil, count = 6, module = 1}},
        {name = "Fun G1", states = {""}, state = 0, data = {switch = nil, count = 7, module = 1}},
        {name = "Fun H1", states = {""}, state = 0, data = {switch = nil, count = 8, module = 1}},
      }
    }
  }
}   

-- used as general module/channel config
local parameters = {names = {"Res", "PWM", "B1/I", "B1/d", "B2/I", "B2/d", "PThru"}, values = {0, 1, 2, 3, 4, 5, 6}};

-- used as global module config : parameter 14 is used also to learn module address
local globalParameters = {names = {"Learn Ch/A", "TMpx", "TMode", "OMpx"}, values = {14, 7, 8, 9}};

local cfgName = nil;
local config = nil;
local lib = nil;
local gVar = 5; -- fallback for digital switches
local gVarOffset = 5; -- fallback for tiptip switches: gvar[module] = gVarOffset + module. Modules begin with 1, so gvars start with 6. 

----- nothing to setup below this line

local lastSelection = {item = nil, col = 0, time = 0};

local followHasRun = false;

local encode = nil;
local encodeParam = nil;
local scaleParameter = nil;

local function pushValue()
  local dt = getTime() - lastSelection.time;
  if (followHasRun and (dt > 10) and lastSelection.item and (lastSelection.col > 0)) then
    local v = scaleParameter(getValue(menu.parameterDial));
    local pv = lastSelection.item.stateValues[lastSelection.col];
    lib.sendValue(gVar, encodeParam(pv, v));
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
    lib.sendValue(gVar, encode(lastSelection.item.data.module, lastSelection.item.data.count, 2)); -- select on state 
  end
end

local function percent(value)
  return math.floor((value + 1024) * 100 / 2048);
end

local function printParameter(pie)
  local r = getValue(menu.parameterDial);
  local v = scaleParameter(r);
  local attr = SMLSIZE;
  if (lastSelection.item) then
     attr = attr + INVERS;
  end
  lcd.drawText(pie.zone.x + pie.zone.w - 60, pie.zone.y + pie.zone.y_poffset, "V: " .. tostring(percent(r)) .. "%/" .. tostring(v), attr);
end

local function run(event, pie)
  if not event then
    event = lib.readButtons(pie);
  end
  local r = lib.readMenuSwitch(menu);
  r = r + lib.processEvents(menu, event, pie);
  if (r > 0) then
     deselectAll();
  end
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

  lib.broadcastReset(gVar);
  
  if (options) then
     if (options.Name) then
	 local filename = lib.nameToConfigFilename(options.Name);
	 config = lib.readConfig(filename, cfg);
     end
  end
  if not config then
      local filename = lib.nameToConfigFilename(model.getInfo().name);
      config = lib.readConfig(filename, cfg);
  end

  if (config.menu) then
    menu = config.menu;
  end

  menu.title = menu.title.. " - Config";

  if (config.useSbus > 0) then
     encode = lib.encodeFunctionSbus;
     encodeParam = lib.encodeParameterSbus;
     scaleParameter = lib.scaleParameterValueSbus;
  else
     encode = lib.encodeFunction;
     encodeParam = lib.encodeParameter;
     scaleParameter = lib.scaleParameterValue;
  end

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

  return lib, menu, config;
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
  zone.fh = 16;
  zone.y_poffset = zone.fh;
  zone.y_offset = 32;
  local pie = { zone=zone, options=options, counter=0 };
  return pie;
end

local function update(pie, options)
  pie.options = options;
end

local lastVisible = 0;

local function background()
   if ((getTime() - lastVisible) > 30) and (lastVisible > 0) then
      model.setGlobalVariable(gVar + 1, 0, 0);
      lastVisible = 0;
      lastSelection.item = nil;
      lastSelection.col = 0;
      lib.broadcastReset(gVar);
   end
end

local function refresh(pie, event)
   lastVisible = getTime();
   model.setGlobalVariable(gVar + 1, 0, 1);
   run(event, pie);
end

return { name="WMSwConf", options=options, create=create, update=update, refresh=refresh, background=background, init=init, run=run}
