--
-- WM OTXE - OpenTX Extensions 
-- Copyright (C) 2020 Wilhelm Meier <wilhelm.wm.meier@googlemail.com>
--
-- This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License. 
-- To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ 
-- or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

local input = {
      {"Input 1", SOURCE},
      {"Input 2", SOURCE}
};

local output = { "Vsp2" }

local function init() 
end

local function run(a, b)
      local norm = math.sqrt(a * a + b * b);
      if (norm >= 1024) then
         return  b * 1024 / norm;
      else
      	 return b;
      end
end

return {output=output, input=input, run=run, init=init}

