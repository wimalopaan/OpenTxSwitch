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


local pie = {};
pie.zone = {};
pie.zone.x = 0;
pie.zone.y = 0;
pie.zone.w = LCD_W;
pie.zone.h = LCD_H;
pie.zone.fh = 8;
pie.zone.y_offset = 8;
pie.zone.y_poffset = 0;

local widget = nil;
local lib = nil;
local menu = nil;
local config = nil;

local function run_telemetry(event)
  lib.processEvents(menu, event, pie);
  lib.displayMenu(menu, event, pie, config);
end

local function init_telemetry()
  widget = loadfile("/WIDGETS/WMSW/main.lua")();
  lib, menu, config = widget.init(nil);
end

local function background_telemetry()
  widget.background();
end

return {run=run_telemetry, init=init_telemetry, background=background_telemetry}
