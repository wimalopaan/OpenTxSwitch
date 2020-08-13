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

local gstates1 = {"aus", "ein", "b1", "b2"};
local gstates2 = {"aus", "ein 1", "ein 2"};

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
        {name = "Fun A", states = gstates1, state = 1, data = {switch = "sa", count = 1, module = 1}},
        {name = "Fun B", states = gstates1, state = 1, data = {switch = "sb", count = 2,  module = 1}},
        {name = "Fun C", states = gstates1, state = 1, data = {switch = nil, count = 3, module = 1}},
        {name = "Fun D", states = gstates1, state = 1, data = {switch = "se", count = 4, module = 1}},
        {name = "Fun E", states = gstates1, state = 1, data = {switch = nil, count = 5, module = 1}},
        {name = "Fun F", states = gstates1, state = 1, data = {switch = nil, count = 6, module = 1}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(1)
      items = {
        {name = "Fun G", states = gstates1, state = 1, data = {switch = nil, count = 7, module = 1}},
        {name = "Fun H", states = gstates1, state = 1, data = {switch = nil, count = 8, module = 1}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(2)
      items = {
        {name = "Nuf A", states = gstates1, state = 1, data = {switch = "sc", count = 1, module = 2}},
        {name = "Nuf B", states = gstates1, state = 1, data = {switch = "sd", count = 2, module = 2}},
        {name = "Nuf C", states = gstates1, state = 1, data = {switch = nil, count = 3, module = 2}},
        {name = "Nuf D", states = gstates1, state = 1, data = {switch = "se", count = 4, module = 2}},
        {name = "Nuf E", states = gstates1, state = 1, data = {switch = nil, count = 5, module = 2}},
        {name = "Nuf F", states = gstates1, state = 1, data = {switch = nil, count = 6, module = 2}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(2)
      items = {
        {name = "Nuf G", states = gstates1, state = 1, data = {switch = nil, count = 7, module = 2}},
        {name = "Nuf H", states = gstates1, state = 1, data = {switch = nil, count = 8, module = 2}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(3)
      items = {
        {name = "Ufn A", states = gstates1, state = 1, data = {switch = "se", count = 1, module = 3}},
        {name = "Ufn B", states = gstates1, state = 1, data = {switch = "sg", count = 2, module = 3}},
        {name = "Ufn C", states = gstates1, state = 1, data = {switch = nil, count = 3, module = 3}},
        {name = "Ufn D", states = gstates1, state = 1, data = {switch = nil, count = 4, module = 3}},
        {name = "Ufn E", states = gstates1, state = 1, data = {switch = nil, count = 5, module = 3}},
        {name = "Ufn F", states = gstates1, state = 1, data = {switch = nil, count = 6, module = 3}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(3)
      items = {
        {name = "Ufn G", states = gstates1, state = 1, data = {switch = nil, count = 7, module = 3}},
        {name = "Ufn H", states = gstates1, state = 1, data = {switch = nil, count = 8, module = 3}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(4) ... Address(8)
      items = {
        {name = "Foo A", states = gstates2, state = 1, data = {switch = "se", count = 1, module = 4}},
        {name = "Foo B", states = gstates2, state = 1, data = {switch = nil, count = 2, module = 4}},
        {name = "Foo C", states = gstates2, state = 1, data = {switch = nil, count = 3, module = 4}},
        {name = "Foo D", states = gstates2, state = 1, data = {switch = nil, count = 4, module = 4}},
        {name = "Foo E", states = gstates2, state = 1, data = {switch = nil, count = 5, module = 4}},
        {name = "Foo F", states = gstates2, state = 1, data = {switch = nil, count = 6, module = 4}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(4) ... Address(8)
      items = {
        {name = "Foo G", states = gstates2, state = 1, data = {switch = nil, count = 7, module = 4}},
        {name = "Foo H", states = gstates2, state = 1, data = {switch = nil, count = 8, module = 4}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(4) global module configuration
      config = true; -- enables globalParameters
      items = {
        {name = "Mod@1", states = {}, state = 1, data = {switch = nil, count = 1, module = 1}},
        {name = "Mod@2", states = {}, state = 1, data = {switch = nil, count = 1, module = 2}},
        {name = "Mod@3", states = {}, state = 1, data = {switch = nil, count = 1, module = 3}},
        {name = "Mod@4", states = {}, state = 1, data = {switch = nil, count = 1, module = 4}},
        {name = "Mod@5", states = {}, state = 1, data = {switch = nil, count = 2, module = 5}},
        {name = "Mod@6", states = {}, state = 1, data = {switch = nil, count = 3, module = 6}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(4) global module configuration
      config = true; -- enables globalParameters
      items = {
        {name = "Mod@7", states = {}, state = 1, data = {switch = nil, count = 4, module = 7}},
        {name = "Mod@8", states = {}, state = 1, data = {switch = nil, count = 8, module = 8}},
      }
    }
  }
}   

return {name = name, menu = menu, gVar = gVariable, useSbus = useSbus};
