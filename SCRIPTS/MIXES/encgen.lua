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

local output = { "encgen" }

local gvar = 5; -- fallback

local offset1 = 0.0;
local offset2 = 0.0;
local algo = 0;

local function needScaleAlgo(module)
   local type = module["Type"];
   if (type == 2) then
      return 2; -- xjt
   elseif (type == 6) then
      local proto = module["protocol"];
      local sproto = module["subProtocol"];
      if (proto == 28) then -- AFHDS2A
	 if (sproto == 0) or (sproto == 1) then
	    return 3; -- ibus
	 elseif (sproto == 2) or (sproto == 3) then
	    return 4; -- sbus
	 elseif (sproto == 4) or (sproto == 5) then
	    return 3; -- ibus
	 elseif (sproto == 6) or (sproto == 6) then
	    return 4; -- sbus
	 end
      elseif (proto == 3) then
	 return 4; -- sbus
      elseif (proto == 15) then
	 return 4 -- sbus;
      else
      end
   end
   return 1;
end

local function init() 
   local cfg = loadfile("/SCRIPTS/CONFIG/wmcfg.lua")();
   if (cfg) then
      gvar = cfg.switchGVar;
   end
   
   local module = model.getModule(0);
   if (module) then
      local type = module["Type"];
      if (type == 0) then
	 module = nil;
      end
   end
   if not (module) then
      module = model.getModule(1);
   end
   
   algo = needScaleAlgo(module);

   if (algo == 4) then -- sbus
      offset1 = 1.5;
      offset2 = 0.5;
   end
   elseif (algo == 2) then -- xjt
      offset1 = 0.5;
      offset2 = 0.1;
   end
end

local function run()
   local x = model.getGlobalVariable(gvar, 0);
   if (algo == 1) return 0; -- unknown
   if (algo == 3) then -- ibus
      if (x >= 0) then
	 return x + 1;
      else
	 return x;
      end
   else -- sbus multi
      if (x >= 0) then
	 return (x * 1024) / 1638 + offset1;
      else
	 return (x * 1024) / 1638 + offset2;
      end
   end
   return 0;
end

return {output=output, input=input, run=run, init=init}
