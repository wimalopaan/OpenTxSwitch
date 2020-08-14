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

local gstates1 = {"aus", "ein", "blink1", "blink2"};
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
        {name = "M1A", states = gstates1, state = 1, data = {switch = "sa", count = 1, module = 1}},
        {name = "M1B", states = gstates1, state = 1, data = {switch = "sb", count = 2, module = 1}},
        {name = "M1C", states = gstates1, state = 1, data = {switch = nil, count = 3, module = 1}},
        {name = "M1D", states = gstates1, state = 1, data = {switch = "se", count = 4, module = 1}},
        {name = "M1E", states = gstates1, state = 1, data = {switch = nil, count = 5, module = 1}},
        {name = "M1F", states = gstates1, state = 1, data = {switch = nil, count = 6, module = 1}},
        {name = "M1G", states = gstates1, state = 1, data = {switch = nil, count = 7, module = 1}},
        {name = "M1H", states = gstates1, state = 1, data = {switch = nil, count = 8, module = 1}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(2)
      items = {
        {name = "M2A", states = gstates1, state = 1, data = {switch = "sc", count = 1, module = 2}},
        {name = "M2B", states = gstates1, state = 1, data = {switch = "sd", count = 2, module = 2}},
        {name = "M2C", states = gstates1, state = 1, data = {switch = nil, count = 3, module = 2}},
        {name = "M2D", states = gstates1, state = 1, data = {switch = "se", count = 4, module = 2}},
        {name = "M2E", states = gstates1, state = 1, data = {switch = nil, count = 5, module = 2}},
        {name = "M2F", states = gstates1, state = 1, data = {switch = nil, count = 6, module = 2}},
        {name = "M2G", states = gstates1, state = 1, data = {switch = nil, count = 7, module = 2}},
        {name = "M2H", states = gstates1, state = 1, data = {switch = nil, count = 8, module = 2}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(3)
      items = {
        {name = "M3A", states = gstates2, state = 1, data = {switch = "se", count = 1, module = 3}},
        {name = "M3B", states = gstates2, state = 1, data = {switch = nil, count = 2, module = 3}},
        {name = "M3C", states = gstates2, state = 1, data = {switch = nil, count = 3, module = 3}},
        {name = "M3D", states = gstates2, state = 1, data = {switch = nil, count = 4, module = 3}},
        {name = "M3E", states = gstates2, state = 1, data = {switch = nil, count = 5, module = 3}},
        {name = "M3F", states = gstates2, state = 1, data = {switch = nil, count = 6, module = 3}},
        {name = "M3G", states = gstates2, state = 1, data = {switch = nil, count = 7, module = 3}},
        {name = "M3H", states = gstates2, state = 1, data = {switch = nil, count = 8, module = 3}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(4)
      items = {
        {name = "M4A", states = gstates2, state = 1, data = {switch = "se", count = 1, module = 4}},
        {name = "M4B", states = gstates2, state = 1, data = {switch = "sg", count = 2, module = 4}},
        {name = "M4C", states = gstates2, state = 1, data = {switch = nil, count = 3, module = 4}},
        {name = "M4D", states = gstates2, state = 1, data = {switch = nil, count = 4, module = 4}},
        {name = "M4E", states = gstates2, state = 1, data = {switch = nil, count = 5, module = 4}},
        {name = "M4F", states = gstates2, state = 1, data = {switch = nil, count = 6, module = 4}},
        {name = "M4G", states = gstates2, state = 1, data = {switch = nil, count = 7, module = 4}},
        {name = "M4H", states = gstates2, state = 1, data = {switch = nil, count = 8, module = 4}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(5)
      items = {
        {name = "M5A", states = gstates2, state = 1, data = {switch = "se", count = 1, module = 5}},
        {name = "M5B", states = gstates2, state = 1, data = {switch = nil, count = 2, module = 5}},
        {name = "M5C", states = gstates2, state = 1, data = {switch = nil, count = 3, module = 5}},
        {name = "M5D", states = gstates2, state = 1, data = {switch = nil, count = 4, module = 5}},
        {name = "M5E", states = gstates2, state = 1, data = {switch = nil, count = 5, module = 5}},
        {name = "M5F", states = gstates2, state = 1, data = {switch = nil, count = 6, module = 5}},
        {name = "M5G", states = gstates2, state = 1, data = {switch = nil, count = 7, module = 5}},
        {name = "M5H", states = gstates2, state = 1, data = {switch = nil, count = 8, module = 5}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(6)
      items = {
        {name = "M6A", states = gstates2, state = 1, data = {switch = "se", count = 1, module = 6}},
        {name = "M6B", states = gstates2, state = 1, data = {switch = nil, count = 2, module = 6}},
        {name = "M6C", states = gstates2, state = 1, data = {switch = nil, count = 3, module = 6}},
        {name = "M6D", states = gstates2, state = 1, data = {switch = nil, count = 4, module = 6}},
        {name = "M6E", states = gstates2, state = 1, data = {switch = nil, count = 5, module = 6}},
        {name = "M6F", states = gstates2, state = 1, data = {switch = nil, count = 6, module = 6}},
        {name = "M6G", states = gstates2, state = 1, data = {switch = nil, count = 7, module = 6}},
        {name = "M6H", states = gstates2, state = 1, data = {switch = nil, count = 8, module = 6}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(7)
      items = {
        {name = "M7A", states = gstates2, state = 1, data = {switch = "se", count = 1, module = 7}},
        {name = "M7B", states = gstates2, state = 1, data = {switch = nil, count = 2, module = 7}},
        {name = "M7C", states = gstates2, state = 1, data = {switch = nil, count = 3, module = 7}},
        {name = "M7D", states = gstates2, state = 1, data = {switch = nil, count = 4, module = 7}},
        {name = "M7E", states = gstates2, state = 1, data = {switch = nil, count = 5, module = 7}},
        {name = "M7F", states = gstates2, state = 1, data = {switch = nil, count = 6, module = 7}},
        {name = "M7G", states = gstates2, state = 1, data = {switch = nil, count = 7, module = 7}},
        {name = "M7H", states = gstates2, state = 1, data = {switch = nil, count = 8, module = 7}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(8)
      items = {
        {name = "M8A", states = gstates2, state = 1, data = {switch = "se", count = 1, module = 8}},
        {name = "M8B", states = gstates2, state = 1, data = {switch = nil, count = 2, module = 8}},
        {name = "M8C", states = gstates2, state = 1, data = {switch = nil, count = 3, module = 8}},
        {name = "M8D", states = gstates2, state = 1, data = {switch = nil, count = 4, module = 8}},
        {name = "M8E", states = gstates2, state = 1, data = {switch = nil, count = 5, module = 8}},
        {name = "M8F", states = gstates2, state = 1, data = {switch = nil, count = 6, module = 8}},
        {name = "M8G", states = gstates2, state = 1, data = {switch = nil, count = 7, module = 8}},
        {name = "M8H", states = gstates2, state = 1, data = {switch = nil, count = 8, module = 8}},
      }
    },
    { -- template for digital/analog adapter RC-MultiSwitch/Adapter-DA global module configuration
      config = true; -- enables globalParameters
      items = {
        {name = "Mod@1", states = {}, state = 1, data = {switch = nil, count = 1, module = 1}},
        {name = "Mod@2", states = {}, state = 1, data = {switch = nil, count = 1, module = 2}},
        {name = "Mod@3", states = {}, state = 1, data = {switch = nil, count = 1, module = 3}},
        {name = "Mod@4", states = {}, state = 1, data = {switch = nil, count = 1, module = 4}},
        {name = "Mod@5", states = {}, state = 1, data = {switch = nil, count = 2, module = 5}},
        {name = "Mod@6", states = {}, state = 1, data = {switch = nil, count = 3, module = 6}},
        {name = "Mod@7", states = {}, state = 1, data = {switch = nil, count = 4, module = 7}},
        {name = "Mod@8", states = {}, state = 1, data = {switch = nil, count = 8, module = 8}},
      }
    }
  }
}   

return {name = name, menu = menu, gVar = gVariable, useSbus = useSbus};
