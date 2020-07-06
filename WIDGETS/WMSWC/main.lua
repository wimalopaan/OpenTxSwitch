--
-- WM OTXE - OpenTX Extensions 
-- Copyright (C) 2020 Wilhelm Meier <wilhelm.wm.meier@googlemail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

--- define fallback menu

local menu = {
  title = "WM Multikanal Config 0.2",
  state = {
    activeRow = 1,
    activeCol = 1,
    activePage = nil
  },
  pages = {
    {
      items = {
        {name = "Fun A1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"}, state = 0, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 1}},
        {name = "Fun B1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"}, state = 0, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 1}},
        {name = "Fun C1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"}, state = 0, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 1}},
        {name = "Fun D1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"}, state = 0, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 1}},
        {name = "Fun E1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"}, state = 0, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 1}},
        {name = "Fun F1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"}, state = 0, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 1}},
        {name = "Fun G1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"}, state = 0, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 1}},
        {name = "Fun H1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"}, state = 0, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 1}},
      }
    }
  }
}   

-----

local parameters = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d", "PThru", "Min", "Max"};

local defaultFilename = "/MODELS/swstd.lua";
local cfgName = nil;
local config = nil;
local lib = nil;

----- nothing to setup below this line

local lastSelection = {item = nil, col = 0, time = 0};

local followHasRun = false;


local function pushValue()
  local dt = getTime() - lastSelection.time;
  if (followHasRun and (dt > 10) and lastSelection.item and (lastSelection.col > 0)) then
    local v = lib.scaleParameterValue(getValue("s1"));
    print("push: ", v);
    lib.sendValue(1, lib.encodeParameter(lastSelection.col, v));
  end
end


local function deselectAll() 
  print("desel");
  for prow, p in ipairs(menu.pages) do
    for row, item in ipairs(p.items) do
      item.state = 0;
    end
  end
  lastSelection.item = nil;
  lastSelection.col = 0;
end

local function select(item, menu)
  print("sel: ", item.name, item.state, menu.state.activeCol);
  deselectAll();
  lastSelection.item = item;
  lastSelection.col = menu.state.activeCol;
  item.state = menu.state.activeCol;
  lib.broadcastReset();
  lastSelection.time = getTime();
  followHasRun = false;
end

local function selectFollow()
  local dt = getTime() - lastSelection.time;
  if (lastSelection.item and (dt > 10) and not followHasRun) then
    followHasRun = true;
    lastSelection.time = getTime();
    lib.sendValue(1, lib.encodeFunction(lastSelection.item.data.module, lastSelection.item.data.count, 2)); -- select on state 
    print("selFollow");
  end
end

local function percent(value)
  return math.floor((value + 1024) * 100 / 2048);
end

local function printParamater(pie)
  local r = getValue("s1");
  local v = lib.scaleParameterValue(r);
  lcd.drawText(pie.zone.x + pie.zone.w - 60, pie.zone.y + 16, "V: " .. tostring(percent(r)) .. "%/" .. tostring(v), SMLSIZE);
end

local function run(event, pie)
  if not event then
    event = lib.readButtons(pie);
  end
  lib.processEvents(menu, event, pie);
  lib.displayMenu(menu, event, pie, config);
  printParamater(pie);  
  selectFollow();
  pushValue();
end

local function init(options)
  lib = loadfile("/SCRIPTS/WM/wmlib.lua")();

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

  lib.initMenu(menu, select);

  for i,p in ipairs(menu.pages) do
    for k,item in ipairs(p.items) do
      item.states = parameters;
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

function refresh(pie)
  run(nil, pie);
end

return { name="WMSwConf", options=options, create=create, update=update, refresh=refresh}
