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
        {name = "Fun A", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "sa", count = 1, offState = 1, module = 1}},
        {name = "Fun B", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "sb", count = 2, offState = 1, module = 1}},
        {name = "Fun C", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 1}},
        {name = "Fun D", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "se", count = 4, offState = 1, module = 1}},
        {name = "Fun E", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 1}},
        {name = "Fun F", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 1}},
        {name = "Fun G", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 1}},
        {name = "Fun H", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 1}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(2)
      items = {
        {name = "Nuf A", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "sc", count = 1, offState = 1, module = 2}},
        {name = "Nuf B", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "sd", count = 2, offState = 1, module = 2}},
        {name = "Nuf C", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 2}},
        {name = "Nuf D", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "se", count = 4, offState = 1, module = 2}},
        {name = "Nuf E", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 2}},
        {name = "Nuf F", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 2}},
        {name = "Nuf G", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 2}},
        {name = "Nuf H", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 2}},
      }
    },
    { -- template for digital multiswitch RC-MultiSwitch-D @ Address(3)
      items = {
        {name = "Ufn A", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "se", count = 1, offState = 1, module = 3}},
        {name = "Ufn B", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = "sg", count = 2, offState = 1, module = 3}},
        {name = "Ufn C", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 3}},
        {name = "Ufn D", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 3}},
        {name = "Ufn E", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 3}},
        {name = "Ufn F", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 3}},
        {name = "Ufn G", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 3}},
        {name = "Ufn H", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 3}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(4) ... Address(8)
      items = {
        {name = "Foo A", states = {"aus", "ein 1", "ein 2"}, state = 1, cb = nil, data = {switch = "se", count = 1, offState = 1, module = 4}},
        {name = "Foo B", states = {"aus", "ein 1", "ein 2"}, state = 1, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 4}},
        {name = "Foo C", states = {"aus", "ein 1", "ein 2"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 4}},
        {name = "Foo D", states = {"aus", "ein 1", "ein 2"}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 4}},
        {name = "Foo E", states = {"aus", "ein 1", "ein 2"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 4}},
        {name = "Foo F", states = {"aus", "ein 1", "ein 2"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 4}},
        {name = "Foo G", states = {"aus", "ein 1", "ein 2"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 4}},
        {name = "Foo H", states = {"aus", "ein 1", "ein 2"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 4}},
      }
    },
    { -- template for digital/analog adapter RC-MultiAdapter-DA @ Address(4) global module configuration
      config = true;
      items = {
        {name = "Mod@1", states = {}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 1}},
        {name = "Mod@2", states = {}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 2}},
        {name = "Mod@3", states = {}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 3}},
        {name = "Mod@4", states = {}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 4}},
        {name = "Mod@5", states = {}, state = 1, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 5}},
        {name = "Mod@6", states = {}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 6}},
        {name = "Mod@7", states = {}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 7}},
        {name = "Mod@8", states = {}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 8}},
      }
    }
  }
}   

return {name = name, menu = menu, gVar = gVariable};