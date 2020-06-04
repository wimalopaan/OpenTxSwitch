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

--- define menu

local menu = {
  title = "WM Multikanal Config 0.1",
  state = {
    activeRow = 1,
    activeCol = 1,
    activePage = nil
  },
  pages = {
    {
      items = {
        {name = "Fun A1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 1}},
        {name = "Fun B1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 1}},
        {name = "Fun C1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 1}},
        {name = "Fun D1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 1}},
        {name = "Fun E1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 1}},
        {name = "Fun F1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 1}},
        {name = "Fun G1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 1}},
        {name = "Fun H1", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 1}},
      }
    },
    {
      items = {
        {name = "Fun A2", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 2}},
        {name = "Fun B2", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 2}},
        {name = "Fun C2", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 2}},
        {name = "Fun D2", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 2}},
        {name = "Fun E2", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 2}},
        {name = "Fun F2", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 2}},
        {name = "Fun G2", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 2}},
        {name = "Fun H2", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 2}},
      }
    },
    {
      items = {
        {name = "Fun A3", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 3}},
        {name = "Fun B3", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 3}},
        {name = "Fun C3", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 3}},
        {name = "Fun D3", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 3}},
        {name = "Fun E3", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 3}},
        {name = "Fun F3", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 3}},
        {name = "Fun G3", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 3}},
        {name = "Fun H3", states = {"PWM", "B1/Int", "B1/d", "B2/Int", "B2/d"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 3}},
      }
    }
  }
}   

----- nothing to setup below this line

-------


local function sendValue(module, value)
  print("sendValue m: ", module, " v: ", value);
  model.setGlobalVariable(module + 4, getFlightMode(), value);
end

local function encodeDigital(address, number, state)
  return (128 * (address - 1) + 16 * (number - 1) + state) * 2 - 1024;
end

local function sendCommand(parameter, value)
end

local function sendResetAll() 

local function init()
  menu.state.activeRow = 0;
  menu.state.activeCol = 0;
  menu.state.activePage = menu.pages[1];
  for i,p in ipairs(menu.pages) do
    p.next = nil;
    p.prev = nil;
  end
  for p = 1, #menu.pages do
    menu.pages[p].next = menu.pages[(p % #menu.pages) + 1]; 
  end
  for p = 1, #menu.pages do
    menu.pages[p].prev = menu.pages[(( p + #menu.pages - 2) % #menu.pages) + 1]; 
  end

  for i,p in ipairs(menu.pages) do
    for k, item in ipairs(p) do
      item.cb = select;
--      sstate.switches[#sstate.switches + 1] = item;
    end
  end
end

local function background()
end


local function select(item)
    print("sel: ", item.name, item.state, menu.state.activeCol);
    item.state = menu.state.activeCol;
    sendValue(1, encodeDigital(item.data.module, item.data.count, item.state)); 
end

local function displayMenu(menu, event, pie)  
  lcd.drawText(pie.zone.x, pie.zone.y, menu.title, MIDSIZE);
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
    select(p.items[menu.state.activeRow]);
    if p.items[menu.state.activeRow].cb then
      p.items[menu.state.activeRow].cb(menu);
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
  local lv = getValue(pie.options.Left);
  if (lv > buttons.lastl) then
    e = EVT_VIRTUAL_PREV;
  end
  local rv = getValue(pie.options.Right);
  if (rv > buttons.lastr) then
    e =  EVT_VIRTUAL_NEXT;
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
  local e = readButtons(pie);
  processEvents(menu, e);
  displayMenu(menu, event, pie);
--   killEvents(event);
end

local options = {
  { "Next",     SOURCE, 8 },
  { "Previous", SOURCE, 9 },
  { "Select",   SOURCE, 10 },
  { "Left",     SOURCE, 11 },
  { "Right",    SOURCE, 12 }
}

local function create(zone, options)
  init();
  local pie = { zone=zone, options=options, counter=0 };
  return pie;
end

local function update(pie, options)
  pie.options = options;
end

function refresh(pie)
  background();
  run(nil, pie);
end

return { name="WMSwConf", options=options, create=create, update=update, refresh=refresh}
