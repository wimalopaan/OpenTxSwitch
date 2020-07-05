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

-- define menu

-- Version 0.2
--- Customization:
---- only modify menu: name, states, switch (if needed) 

local mode = 1; -- 0: tiptip; 1: digital-idempotential

local menu = {
  title = "WM MultiSwitch 0.3",

  scrollUpDn = "ls", -- direct navigating
  scrollLR = "rs",

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
local cfgName = nil;
local config = nil;

---- mostly valid values

local parameter = {
  pulse = {duration = 30, pause = 30, long = 100}; -- 300ms/750ms
  dead = {duration = 100, lastAction = getTime()}; -- 3s before next action 
  pulseValue = {-1024, 0, 1024};
  neutral = 2; -- index
}

----- nothing to setup below this line

local sstate = {}

sstate.states = {idle = 0, start = 1, pulse = 2, deadWait = 3};
sstate.state  = sstate.states.idle;
sstate.active = {item= nil,
  pulseCount = 0, nextToggle = 0, startTime = getTime(),
  on = false};
sstate.switches = nil;

local shortCuts = {};

local lsID = 0;
local rsID = 0;

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

local function sendValue(gvar, value)
  model.setGlobalVariable(gvar + 4, getFlightMode(), value);
end

local function encodeFunction(address, number, state)
  return (128 * (address - 1) + 16 * (number - 1) + state) * 2 - 1024;
end

local function findInputId(name) 
  for i=0,31 do
    local inp = getFieldInfo("input" .. i);
    if (inp) then
      print(i, inp.desc);
      if (inp.name == name) then
        return i;
      end
    end
  end
  return 0;
end

local function init(options)
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

  if (config.menu) then
    menu = config.menu;
  end

  local lsFI = getFieldInfo(menu.scrollUpDn);
  if (lsFI) then
    lsID = lsFI.id;
  end

  local rsFI = getFieldInfo(menu.scrollLR);
  if (rsFI) then
    rsID = rsFI.id;
  end

  menu.state.activeRow = 0;
  menu.state.activeCol = 0;
  menu.state.activePage = menu.pages[1];
  for i,p in ipairs(menu.pages) do
    p.next = nil;
    p.prev = nil;
  end
  for p = 1, #menu.pages do
    menu.pages[p].next = menu.pages[(p % #menu.pages) + 1]; 
    menu.pages[p].number = p;
    menu.pages[p].desc = "Page: " .. tostring(p) .. "/" .. tostring(#menu.pages);
  end
  for p = 1, #menu.pages do
    menu.pages[p].prev = menu.pages[(( p + #menu.pages - 2) % #menu.pages) + 1]; 
  end

--  for i,p in ipairs(menu.pages) do
--    for k, item in ipairs(p) do
--      item.cb = select;
--      sstate.switches[#sstate.switches + 1] = item;
--    end
--  end

  for i,p in ipairs(menu.pages) do
    for k, item in ipairs(p.items) do
      if (item.data.switch) then
        shortCuts[#shortCuts + 1] = {item = item, switch = item.data.switch};
        item.name = item.name .. "/" .. item.data.switch;
      end
    end
  end
end

local function swState(s) 
  local v = getValue(s);
  if (v < 0) then
    return 2;
  elseif (v > 0) then
    return 3;
  else 
    return 1;
  end
end

local function readShortCuts() 
  for i,s in ipairs(shortCuts) do
    local ns = swState(s.switch);
    if not (s.item.state == ns) then
      --     print(ns);
      s.item.state = ns;
      sendValue(1, encodeFunction(s.item.data.module, s.item.data.count, s.item.state)); 
    end
  end
end


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
      sendValue(sstate.active.item.module, parameter.pulseValue[sstate.active.item.state]);      
      sstate.state = sstate.states.pulse;
      sstate.active.on = true;
    elseif (sstate.state == sstate.states.pulse) then
      if (getTime() > sstate.active.nextToggle) then
        if (sstate.active.on) then
          sendValue(sstate.active.item.module, parameter.pulseValue[parameter.neutral]);
          sstate.active.on = false;
          sstate.active.nextToggle = sstate.active.nextToggle + parameter.pulse.pause;
          if (sstate.active.item.count == sstate.active.pulseCount) then
            sstate.state = sstate.states.deadWait;
            parameter.dead.lastAction = getTime();
            playHaptic(10, 100);
          end
        else 
          sstate.active.pulseCount = sstate.active.pulseCount + 1;
          sendValue(sstate.active.item.module, parameter.pulseValue[sstate.active.item.state]);
          sstate.active.on = true;
          sstate.active.nextToggle = sstate.active.nextToggle + ((sstate.active.item.count > sstate.active.pulseCount) and parameter.pulse.duration or parameter.pulse.long);
        end
      end
    end
  elseif (mode == 1) then
    readShortCuts();
  end 
end

local function toggle(count, state, module)
  local e = {count = count, state = state, module = module};
  queue:push(e);
end

local function select(item)
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
--    print("sel: ", item.name, item.state, menu.state.activeCol);
    item.state = menu.state.activeCol;
    sendValue(1, encodeFunction(item.data.module, item.data.count, item.state)); 
  end
end

local function displayMenu(menu, event, pie)  
  lcd.drawText(pie.zone.x, pie.zone.y, menu.title, MIDSIZE);

  lcd.drawText(pie.zone.x + pie.zone.w - 60, pie.zone.y, menu.state.activePage.desc, SMLSIZE);

  if (config) then
    lcd.drawText(pie.zone.x, pie.zone.y + 32 + 9 * 16, "Cfg: " .. config.name .. " Mdl: " .. model.getInfo().name .. " F: " .. cfgName, SMLSIZE);
  end
  -- lcd.clear()
  local n = 0;
  for i,pa in ipairs(menu.pages) do
    if (pa == menu.state.activePage) then 
      n = i; 
    end
  end
--    lcd.drawScreenTitle(menu.title, n, #menu.pages);
  local p = menu.state.activePage;

  for row, opt in ipairs(p.items) do
    local x = pie.zone.x;
    local y = pie.zone.y + 32 + (row - 1) * 16;
    local attr = (row == menu.state.activeRow) and (INVERS + SMLSIZE) or SMLSIZE;
    lcd.drawText(x, y, opt.name, attr);
    if opt.states then
      local fw = pie.zone.w / (#opt.states + 1);
      for col, st in ipairs(opt.states) do
        x = x + fw;
--        attr = (col == opt.state) and INVERS or 0
        if (menu.state.activeCol == col) and (row == menu.state.activeRow)  then
          lcd.drawText(x, y, st, BLINK + INVERS + SMLSIZE);
--          attr = BLINK;
        else
          if (col == opt.state) then
            lcd.drawText(x, y, st, INVERS + SMLSIZE);
          else
            lcd.drawText(x, y, st, SMLSIZE);
          end
        end
--        lcd.drawText(x, y, st, attr);
      end
    else
      fw = pie.zone.w / 2;
      x = x + fw;
      lcd.drawNumber(x, y, opt.value);
    end
  end
end

local function processEvents(menu, event, pie)
  local p = menu.state.activePage;
  if event == EVT_VIRTUAL_DEC then
    if (EVT_VIRTUAL_DEC == EVT_VIRTUAL_PREV) then
      if (menu.state.activeCol > 1) then
        menu.state.activeCol = menu.state.activeCol - 1;
      else
        if (menu.state.activeRow > 1) then
          menu.state.activeRow = menu.state.activeRow - 1;
          menu.state.activeCol = #p.items[menu.state.activeRow].states;
        else
          if p.prev then
            menu.state.activePage = p.prev;
            menu.state.activeRow = #p.items;
            menu.state.activeCol = #p.items[#p.items].states;
          end
        end
      end
    else
      if (menu.state.activeRow < #p.items) then
        menu.state.activeRow = menu.state.activeRow + 1;
      end
    end
  elseif event == EVT_VIRTUAL_INC then
    if (EVT_VIRTUAL_INC == EVT_VIRTUAL_NEXT) then
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
          if p.next then
            menu.state.activePage = p.next;
            menu.state.activeRow = 1;
            menu.state.activeCol = 1;
          end
        end
      end
    else
      if menu.state.activeRow > 1 then
        menu.state.activeRow = menu.state.activeRow - 1;
      end
    end
  elseif event == 100 or event == EVT_VIRTUAL_NEXT then
    menu.state.activeCol = menu.state.activeCol + 1;
  elseif event == 101 or event == EVT_VIRTUAL_PREV then
    if menu.state.activeCol > 1 then
      menu.state.activeCol = menu.state.activeCol - 1;
    end
  elseif event == EVT_VIRTUAL_ENTER then
    if (menu.state.activeRow > 0) then
      select(p.items[menu.state.activeRow]);
      if p.items[menu.state.activeRow].cb then
        p.items[menu.state.activeRow].cb(menu);
      end
    end
  elseif event == EVT_VIRTUAL_EXIT then
    menu.state.activeRow = 0;
    menu.state.activeCol = 1;
  end

  if menu.state.activeRow > 0 then
    if p.items[menu.state.activeRow].states then
      if menu.state.activeCol > #p.items[menu.state.activeRow].states then
        menu.state.activeCol = #p.items[menu.state.activeRow].states;
      end
    end
  else
    if event == 100 or event == EVT_VIRTUAL_NEXT then
      if p.next then
        menu.state.activePage = p.next;
      end
    elseif event == 101 or event == EVT_VIRTUAL_PREVT then
      if p.prev then
        menu.state.activePage = p.prev;
      end
    end
  end
end

local buttons = {
  lastn = 0,
  lastp = 0,
  lastl = 0,
  lastr = 0,
  lasts = 0
}

local function inputToMenuLine(name) 
  local p = menu.state.activePage;
  local n = #p.items;
  local v = getValue(name) + 1024;
  local l = n - math.floor((v * n) / 2049);
  return l;
end

local function inputToMenuCol(name) 
  local p = menu.state.activePage;
  if (menu.state.activeRow > 0) then
    local n = #p.items[menu.state.activeRow].states;
    local v = getValue(name) + 1024;
    local l = math.floor((v * n) / 2049) + 1;
    return l;
  end
  return 0;
end


local function readButtons(pie)  
  local e = 0;
  local nv = getValue(pie.options.Next);
  if (nv > buttons.lastn) then
    e = EVT_VIRTUAL_INC;
  end
  local pv = getValue(pie.options.Previous);
  if (pv > buttons.lastp) then
    e = EVT_VIRTUAL_DEC;
  end
  local lv = 0;
  if (lsID > 0) then
    lv = inputToMenuLine(lsID);
    if not (lv == buttons.lastl) then
      menu.state.activeRow = lv;
    end
  else
--    local lv = getValue(pie.options.Left);
--    if (lv > buttons.lastl) then
--      e = EVT_VIRTUAL_PREV;
--    end
  end
  local rv= 0;
  if (rsID > 0) then
    rv = inputToMenuCol(rsID);
    if not (rv == buttons.lastr) then
      menu.state.activeCol = rv;
    end
  else
--    local rv = getValue(pie.options.Right);
--    if (rv > buttons.lastr) then
--      e =  EVT_VIRTUAL_NEXT;
--    end
  end

  local sv = getValue(pie.options.Select);
  if (sv > buttons.lasts) then
    e =  EVT_VIRTUAL_ENTER;
  end
  buttons.lastn = nv;
  buttons.lastp = pv;
  buttons.lastl = lv;
  buttons.lastr = rv;
  buttons.lasts = sv;

  return e;
end 

local function run(event, pie)
  if not event then
    event = readButtons(pie);
  end
  processEvents(menu, event);
  displayMenu(menu, event, pie);
--   killEvents(event);
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

function refresh(pie)
  background();
  run(nil, pie);
end

return { name="WMSwitch", options=options, create=create, update=update, refresh=refresh}
