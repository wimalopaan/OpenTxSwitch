local name = "Def";

local gVariable = 5;

local useSbus = 0; 

local gstates1 = {"aus", "ein", "blink1", "blink2"};
local gstates2 = {"aus", "ein 1", "ein 2"};

local menu = {
   title = "WM MultiTip",
   
   scrollUpDn = "ls", -- speedDials: direct navigating
   scrollLR = "rs",
   
   pageSwitch = "6p",
   
   state = {
      activeRow = 1,
      activeCol = 1,
      activePage = nil
   },
   
   pages = {
      {
	 items = { 
	    {name = "Fun A", states = gstates2, state = 1, data = {switch = "sa", count = 1, offState = 1, module = 1}},
	    {name = "Fun B", states = gstates2, state = 1, data = {switch = "sb", count = 2, offState = 1, module = 1}},
	    {name = "Fun C", states = gstates2, state = 1, data = {switch = nil, count = 3, offState = 1, module = 1}},
	    {name = "Fun D", states = gstates2, state = 1, data = {switch = nil, count = 4, offState = 1, module = 1}},
	    {name = "Fun E", states = gstates2, state = 1, data = {switch = nil, count = 5, offState = 1, module = 1}},
	    {name = "Fun F", states = gstates2, state = 1, data = {switch = nil, count = 6, offState = 1, module = 1}},
	    {name = "Fun G", states = gstates2, state = 1, data = {switch = nil, count = 7, offState = 1, module = 1}},
	    {name = "Fun H", states = gstates2, state = 1, data = {switch = nil, count = 8, offState = 1, module = 1}}
	 }
      }
   }
}   

return {name = name, menu = menu, gVar = gVariable, useSbus = useSbus};
