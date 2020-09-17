--
-- WM OTXE - OpenTX Extensions 
-- Copyright (C) 2020 Wilhelm Meier <wilhelm.wm.meier@googlemail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--

local name = nil;
local module = nil;
local config = nil;
local filename = nil;
local ownConfigFound = false;

-- Type: 0=Off, 1=PPM, 2 = XJT, 4 = LP45, 4 = DSM2, 4 = DSM4 5 = Crossfire, 6 = Multi, 7 = R9M, 13 = SBus via VBat

-- Type 6 (Multi)
-- proto: 28 (FlySky2A)
-- sproto: 0= PWM,IBus, 1=PPM,IBus, 2=PWM,SBus, 3 = PPM,SBus, 4=PWM,IB16, 5 =PPM,IB16, 6 = PWM,SB16, 7=PPM,SB16
-- proto: 3 (FrSky/8)
-- sproto: 0 = D8
-- proto: 15 (FrSky/16)
-- sproto: 0 = D8, 2=D16EU

-- XJT:
-- Type = 2
-- UseSbus = 1
-- Mixer = encxjt
-- channel 15
-- Bedienelemente

-- Multi / AFHDS2A:
-- Type = 6, Proto = 28, SubProto = 0
-- UseSbus = 0
-- Mixer = encib
-- channel 15
-- Bedienelemente

-- Multi / FrSky:
-- Type = 6, Proto = 15, SubProto = 2
-- UseSbus = 1
-- Mixer = encsbm
-- channel 15
-- Bedienelemente

local function needSBus(module)
   local type = module["Type"];
   if (type == 2) then
      return true;
   elseif (type == 6) then
      local proto = module["protocol"];
      local sproto = module["subProtocol"];
      if (proto == 28) then -- AFHDS2A
	 if (sproto == 0) or (sproto == 1) then
	    return false;
	 elseif (sproto == 2) or (sproto == 3) then
	    return true;
	 elseif (sproto == 4) or (sproto == 5) then
	    return false;
	 elseif (sproto == 6) or (sproto == 6) then
	    return true;
	 end
      elseif (proto == 3) then
	 return true;
      elseif (proto == 15) then
	 return true;
      else
      end
   end
   return false;
end

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

local algoName = {"unknown", "xjt", "ibus", "sbus"};

local lib = nil;
local function init()
   lib = loadfile("/SCRIPTS/WM/wmlib.lua")();

   if not (lib) then
      error("no lib!");
      return 2;
   end

   name = model.getInfo().name;
   module = model.getModule(0);
   if (module) then
      local type = module["Type"];
      if (type == 0) then
	 module = nil;
      end
   end
   if not (module) then
      module = model.getModule(1);
   end

   filename = lib.nameToConfigFilename(name);
   
   config = lib.readConfig(filename);
   if not (config) then
      config = lib.readConfig("/MODELS/swstd.lua");
   else
      ownConfigFound = true;
   end
end

local function drawScreenTitle(title)
    if LCD_W == 480 then
        lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
        lcd.drawText(1, 5, title, MENU_TITLE_COLOR)
    else
        lcd.drawScreenTitle(title, 0, 0)
    end
end

local function refresh(event)
   lcd.clear();
   drawScreenTitle("WMSW Check ");

   if not (module) then
      lcd.drawText(10, 10, "No module!", SMLSIZE);
      return;
   end
   local type = module["Type"];
   local proto = module["protocol"];
   local sproto = module["subProtocol"];
   local rfp = module["rfProtocol"];
   local rxid = module["modelId"];
   local first = module["firstChannel"];
   local chN = module["channelsCount"];

   local x0 = 10;
   local x = 40;
   local y = 32;
   local dy = 16;

   if (LCD_W <= 212) then
      x0 = 0;
      x = 17;
      y = 8;
      dy = 8;
   end

   lcd.drawText(x, y, "Type: " .. type);
   y = y + dy;
   if (proto) then
      lcd.drawText(x, y, "Prot: " .. proto);
      y = y + dy;
   end
   if (sproto) then
      lcd.drawText(x, y, "SubProt: " .. sproto);
      y = y + dy;
   end
   if (LCD_H > 64) then
      if (rfp) then
	 lcd.drawText(x, y, "RFp: " .. rfp);
	 y = y + dy;
      end
      if (rxid) then
	 lcd.drawText(x, y, "RX: " .. rxid);
	 y = y + dy;
      end
      if (first) then
	 lcd.drawText(x, y, "CH: " .. first);
	 y = y + dy;
      end
      if (chN) then
	 lcd.drawText(x, y, "N: " .. chN);
	 y = y + dy;
      end
   end
   if (filename) then
      lcd.drawText(x, y, "File: " .. filename);
      if (ownConfigFound) then
	 lcd.drawText(x0, y, "yes");
      else
	 lcd.drawText(x0, y, "no");
      end
      y = y + dy;
   end
   if (config) then
      lcd.drawText(x, y, "Sbus: " .. config.useSbus);
      y = y + dy;
   end

   local t1 = needSBus(module) and "yes" or "no";   
   lcd.drawText(x, y, "Need Sbus: " .. t1);
   y = y + dy;
   
   lcd.drawText(x, y, "Algo: " .. algoName[needScaleAlgo(module)]);
   y = y + dy;
   
end

local function run(event)
   if not event then
      error("Cannot run as a model script!")
      return 2;
   end
   refresh(event);
   return 0;
end

return {run = run, init = init}
