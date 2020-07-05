local name = "Default";

local menu = {
  title = "WM MultiSwitch 0.4",

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
    },
    {
      items = {
        {name = "Nuf A", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 2}},
        {name = "Nuf B", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 2}},
        {name = "Nuf C", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 2}},
        {name = "Nuf D", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 2}},
        {name = "Nuf E", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 2}},
        {name = "Nuf F", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 2}},
        {name = "Nuf G", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 2}},
        {name = "Nuf H", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 2}},
      }
    },
    {
      items = {
        {name = "Ufn A", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 1, offState = 1, module = 3}},
        {name = "Ufn B", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 2, offState = 1, module = 3}},
        {name = "Ufn C", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 3, offState = 1, module = 3}},
        {name = "Ufn D", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 4, offState = 1, module = 3}},
        {name = "Ufn E", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 5, offState = 1, module = 3}},
        {name = "Ufn F", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 6, offState = 1, module = 3}},
        {name = "Ufn G", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 7, offState = 1, module = 3}},
        {name = "Ufn H", states = {"aus", "ein", "blink1", "blink2"}, state = 1, cb = nil, data = {switch = nil, count = 8, offState = 1, module = 3}},
      }
    }
  }
}   


return {name = name, menu = menu};