--
-- WM OTXE - OpenTX Extensions 
-- Copyright (C) 2020 Wilhelm Meier <wilhelm.wm.meier@googlemail.com>
--
-- This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ 
-- or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

local input = {
   {"VSP", VALUE, 1, 2, 1}
};

local output = { "Vsp2" }

Vsp12 = 0;
Vsp22 = 0;

local function run(vsp)
   if (vsp == 1) then
      return Vsp12;
   else
      return Vsp22;
   end
end

return {input=input, output=output, run=run}

