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

local name = "Default";

local gVariable = 5;

local useSbus = 1; -- only 4 states, only 16 parameter values

local gstates = {"aus", "ein", "b1", "b2"}

local menu = {
  title = "WM MultiSwitch",

  scrollUpDn = "ls", -- direct navigating
  scrollLR = "rs",

  parameterDial = "s1",
  
  pageSwitch = "6pos";

  state = {
    activeRow = 1,
    activeCol = 1,
    activePage = nil
  },
  pages = {
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(1)
      items = {
        {name = "FA", states = gstates, state = 1, data = {switch = "sa", count = 1, module = 1}},
        {name = "FB", states = gstates, state = 1, data = {switch = "sb", count = 2, module = 1}},
        {name = "FC", states = gstates, state = 1, data = {switch = nil, count = 3, module = 1}},
        {name = "FD", states = gstates, state = 1, data = {switch = nil, count = 4, module = 1}},
        {name = "FE", states = gstates, state = 1, data = {switch = nil, count = 5, module = 1}},
        {name = "FF", states = {"a", "e", "A", "B"}, state = 1, data = {switch = nil, count = 6, module = 1}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(1)
      items = {
        {name = "FG", states = gstates, state = 1, data = {switch = nil, count = 7, module = 1}},
        {name = "FH", states = gstates, state = 1, data = {switch = nil, count = 8, module = 1}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(4) global module configuration
      config = true; -- enables globalParameters
      items = {
        {name = "M@1", states = {}, state = 1, data = {switch = nil, count = 1, module = 1}}
      }
    }
  }
}   

return {name = name, menu = menu, gVar = gVariable, useSbus = useSbus};
