--
-- WM OTXE - OpenTX Extensions 
-- Copyright (C) 2020 Wilhelm Meier <wilhelm.wm.meier@googlemail.com>
--
-- This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ 
-- or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

local input = {
   {"Eing 1", SOURCE},
   {"Eing 2", SOURCE},
   {"Gew 1->2", VALUE, -100, 100, 0}
};

local output = { "Vsp1" }

local function run(a, b, w)
   a = a + ((math.abs(b) * w) / 100);
   local norm = math.sqrt(a * a + b * b);
   if (norm >= 1024) then
      return  a * 1024 / norm;
   else
      return a;
   end
end

return {output=output, input=input, run=run}

