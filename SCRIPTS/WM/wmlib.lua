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

-- sbus rounding mess: need some correction values (gvars only ints, so multiply with 10)
-- local lut = {0, 20, 20, 10, 20, 20, 20, 10, 20, 20, 20, 10, 20, 20, 10, 5, 10, 20, 20, 10, 20, 20, 20, 10, 20, 20, 20, 10, 20, 20, 10, 5}
-- local sbuscorr = 0;

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
--  print("encodeF:", address, number, state);
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
--  print("sendV: ", value);
  model.setGlobalVariable(gvar, getFlightMode(), value);
end

local function broadcastReset(gvar) 
--  print("bcast reset");
  sendValue(gvar, encodeParameter(15, 31)); -- broadcast, turn off all outputs
end 

local function switchState(s) 
  local v = getValue(s);
  if (v < 0) then
    return 2;
  elseif (v > 0) then
    return 3;
  else 
    return 1;
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
  if (version) then
    menu.title = menu.title .. " " .. version;
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

  menu.cb = select;
  
--  for i,p in ipairs(menu.pages) do
--    for k, item in ipairs(p.items) do
--      item.cb = select;
--    end
--  end

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
          item.name = item.name .. "!";
        end
      end
    end
  end

end

local function displayFooter(pie, text)
--  lcd.drawText(pie.zone.x, pie.zone.y + pie.zone.y_offset + 9 * pie.zone.fh, text, SMLSIZE);
  lcd.drawText(pie.zone.x, pie.zone.y + pie.zone.h - pie.zone.fh, text, SMLSIZE);
end

local function displayHeader(pie, text)
  lcd.drawText(pie.zone.x + pie.zone.w - 60, pie.zone.y, text, SMLSIZE);
end

local function displayInfo(pie, text)
  lcd.drawText(pie.zone.x + pie.zone.w - 60, pie.zone.y + pie.zone.fh, text, SMLSIZE);
end

local function displayMenu(menu, event, pie, config)  
  if (lcd.drawScreenTitle) then
    lcd.clear()
    lcd.drawScreenTitle(menu.title, menu.state.activePage.number, #menu.pages);
  else  
    lcd.drawText(pie.zone.x, pie.zone.y, menu.title, MIDSIZE);
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

  for row, opt in ipairs(p.items) do
    local x = pie.zone.x;
    local y = pie.zone.y + pie.zone.y_offset + (row - 1) * pie.zone.fh;
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
--      print("X: ", p.items[menu.state.activeRow]);
       menu.cb(p.items[menu.state.activeRow], menu);
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
  lasts = 0,
  lastm = 0
}

local function readButtons(pie)  
  local e = 0;
  if (pie.options.Next) then
    local nv = getValue(pie.options.Next);
    if (nv > buttons.lastn) then
      e = EVT_VIRTUAL_INC;
    end
    buttons.lastn = nv;
  end
  if (pie.options.Previous) then
    local pv = getValue(pie.options.Previous);
    if (pv > buttons.lastp) then
      e = EVT_VIRTUAL_DEC;
    end
    buttons.lastp = pv;
  end
  if (pie.options.Left) then
    local lv = getValue(pie.options.Left);
    if (lv > buttons.lastl) then
      e = EVT_VIRTUAL_PREV;
    end
    buttons.lastl = lv;
  end
  if (pie.options.Right) then
    local rv = getValue(pie.options.Right);
    if (rv > buttons.lastr) then
      e =  EVT_VIRTUAL_NEXT;
    end
    buttons.lastr = rv;
  end
  if (pie.options.Select) then
    local sv = getValue(pie.options.Select);
    if (sv > buttons.lasts) then
      e =  EVT_VIRTUAL_ENTER;
    end
    buttons.lasts = sv;
  end
  return e;
end 

local function sendShortCuts(menu, gvar) 
  for i,s in ipairs(menu.shortCuts) do
    local ns = switchState(s.switch);
    if not (s.last == ns) then
      s.item.state = ns;
      s.last = ns;
      sendValue(gvar, encodeFunction(s.item.data.module, s.item.data.count, s.item.state)); 
    end
  end
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
  if (menu.state.activeRow > 0) then
    local n = #p.items[menu.state.activeRow].states;
    local v = getValue(name) + 1024;
    local l = math.floor((v * n) / 2049) + 1;
    return l;
  end
  return 0;
end

local function readSpeedDials(lsID, rsID, pie, menu)
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

  if (menu.msFI) then
    local ms = 0;
    ms = getValue(menu.msFI);
    if not (ms == buttons.lastm) then
      buttons.lastm = ms;
      local s = 1;
      for i = 0,5 do
        if (ms <= (-1024 + i * (2048 / 5) + 0.5)) then
          s = i + 1;
          break;
        end
      end
      --print(s);
      if (s <= #menu.pages) then
        menu.state.activePage = menu.pages[s];
      end
    end
  end
end


local function findInputId(name) 
  for i=0,31 do
    local inp = getFieldInfo("input" .. i);
    if (inp) then
      -- print(i, inp.desc);
      if (inp.name == name) then
        return i;
      end
    end
  end
  return 0;
end

return {initMenu = initMenu, displayMenu = displayMenu, findInputId = findInputId, displayInfo = displayInfo,
  encodeFunction = encodeFunction, encodeParameter = encodeParameter, sendValue = sendValue, scaleParameterValue = scaleParameterValue,
  processEvents = processEvents,
  readButtons = readButtons, readSpeedDials = readSpeedDials, switchState = switchState, sendShortCuts = sendShortCuts, broadcastReset = broadcastReset,
  encodeFunctionSbus = encodeFunctionSbus, encodeParameterSbus = encodeParameterSbus, scaleParameterValueSbus = scaleParameterValueSbus,
  Class = Class};
