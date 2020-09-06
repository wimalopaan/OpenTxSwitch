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

local input = {}

local output = { "encib" }

local gvar = 5; -- fallback

local function init() 
  cfg = loadfile("/SCRIPTS/CONFIG/wmcfg.lua")();
  if (cfg) then
    gvar = cfg.switchGVar;
  end
end

local function run()
   local x = model.getGlobalVariable(gvar, 0);
   if (x >= 0) then
      return x + 1;
   else
      return x;
   end
end

return {output=output, input=input, run=run, init=init}
