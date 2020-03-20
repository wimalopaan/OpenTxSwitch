gPulseSw = {0, 0, 0, 0};

--- defined names and states

local menu = {
   title = "PulseSwitch",
   state = {
      activeRow = 1,
      activeCol = 1,
      activePage = nil
   },
   pages = {
      {
	 items = {
	    {name = "Fun1", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 1, offState = 2, module = 1}},
	    {name = "Fun2", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 2, offState = 2, module = 1}},
	    {name = "Fun3", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 3, offState = 2, module = 1}},
	    {name = "Fun4", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 4, offState = 2, module = 1}},
	    {name = "Fun5", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 5, offState = 2, module = 1}},
	 }
      },
      {
	 items = {
	    {name = "Fun6", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 6, offState = 2, module = 1}},
	    {name = "Fun7", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 7, offState = 2, module = 1}},
	    {name = "Fun8", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 8, offState = 2, module = 1}},
	    {name = "Fun9", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 9, offState = 2, module = 1}},
	    {name = "FunA", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 10, offState = 2, module = 1}},
	 }
      },
      {
	 items = {
	    {name = "FunB", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 1, offState = 2, module = 2}},
	    {name = "FunC", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 2, offState = 2, module = 2}},
	    {name = "FunD", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 3, offState = 2, module = 2}},
	    {name = "FunE", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 4, offState = 2, module = 2}},
	    {name = "FunF", states = {"steady", "off", "blink"}, state = 2, cb = nil, data = {switch = nil, count = 5, offState = 2, module = 2}},
	 }
      }
   }
}   

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

local function init()
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
	 sstate.switches[#sstate.switches + 1] = item;
      end
   end
end

local function background()
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
      gPulseSw[sstate.active.item.module] = parameter.pulseValue[sstate.active.item.state];      
      sstate.state = sstate.states.pulse;
      sstate.active.on = true;
   elseif (sstate.state == sstate.states.pulse) then
      if (getTime() > sstate.active.nextToggle) then
	 if (sstate.active.on) then
	    gPulseSw[sstate.active.item.module] = parameter.pulseValue[parameter.neutral];
	    sstate.active.on = false;
	    sstate.active.nextToggle = sstate.active.nextToggle + parameter.pulse.pause;
	    if (sstate.active.item.count == sstate.active.pulseCount) then
	       sstate.state = sstate.states.deadWait;
	       parameter.dead.lastAction = getTime();
	       playHaptic(10, 100);
	    end
	 else 
	    sstate.active.pulseCount = sstate.active.pulseCount + 1;
	    gPulseSw[sstate.active.item.module] = parameter.pulseValue[sstate.active.item.state];
	    sstate.active.on = true;
	    sstate.active.nextToggle = sstate.active.nextToggle + ((sstate.active.item.count > sstate.active.pulseCount) and parameter.pulse.duration or parameter.pulse.long);
	 end
      end
   end
end

local function toggle(count, state, module)
   local e = {count = count, state = state, module = module};
   queue:push(e);
end

local function select(item)
   if not (item.state == menu.state.activeCol) then
      if not (item.state == item.data.offState) then
	 toggle(item.data.count, item.state, item.data.module);
      end
      if not (menu.state.activeCol == item.data.offState) then
	 toggle(item.data.count, menu.state.activeCol, item.data.module);
      end
      item.state = menu.state.activeCol;
   end
end

local function displayMenu(menu, event)
   lcd.clear()

   local n = 0;
   for i,pa in ipairs(menu.pages) do
      if (pa == menu.state.activePage) then n = i; end;
   end
   
   lcd.drawScreenTitle(menu.title, n, #menu.pages);
   
   local p = menu.state.activePage;
   
   for row, opt in ipairs(p.items) do
      local x = 1;
      local y = 8 + (row - 1) * 8;
      local attr = (row == menu.state.activeRow) and INVERS or 0;
      lcd.drawText(x, y, opt.name, attr);
      if opt.states then
	 local fw = LCD_W / (#opt.states + 1);
	 for col, st in ipairs(opt.states) do
	    x = x + fw;
	    attr = (col == opt.state) and INVERS or 0
	    if menu.state.activeCol == col and row == menu.state.activeRow  then
	       attr = attr + BLINK;
	    end
	    lcd.drawText(x, y, st, attr);
	 end
      else
	 fw = LCD_W / 2;
	 x = x + fw;
	 lcd.drawNumber(x, y, opt.value);
      end
   end
end

local function processEvents(menu, event)
   local p = menu.state.activePage;
   if event == EVT_VIRTUAL_DEC then
      if (menu.state.activeRow < #p.items) then
	 menu.state.activeRow = menu.state.activeRow + 1;
      end
   elseif event == EVT_VIRTUAL_INC then
      if menu.state.activeRow > 1 then
	 menu.state.activeRow = menu.state.activeRow - 1;
      end
   elseif event == 100 or event == EVT_PAGE_FIRST then
      menu.state.activeCol = menu.state.activeCol + 1;
   elseif event == 101 or event == EVT_MENU_FIRST then
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
      if event == 100 or event == EVT_PAGE_FIRST then
	 if p.next then
	    menu.state.activePage = p.next;
	 end
      elseif event == 101 or event == EVT_MENU_FIRST then
	 if p.prev then
	    menu.state.activePage = p.prev;
	 end
      end
   end
end

local function run(event)
   processEvents(menu, event);
   displayMenu(menu, event);
end

return {run=run, init=init, background=background}
