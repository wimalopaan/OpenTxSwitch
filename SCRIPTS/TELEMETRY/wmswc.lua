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
--pie.zone = {};
--pie.zone.x = 0;
--pie.zone.y = 0;
--pie.zone.w = LCD_W;
--pie.zone.h = LCD_H;
--pie.zone.fh = 8;
--pie.zone.y_offset = 8;
--pie.zone.y_poffset = 0;
pie.win = {};
pie.win.x = 0;
pie.win.y = 0;
pie.win.w = LCD_W;
pie.win.h = LCD_H;
pie.win.fh = 8;
pie.win.y_offset = 8;
pie.win.y_poffset = 0;

local widget = nil;

local function run_telemetry(event)
   widget.stopOther();
--   widget.refresh(pie, event);
   widget.run(event, pie);
end

local function init_telemetry()
   widget = loadfile("/WIDGETS/WMSWC/main.lua")();
   widget.init(nil);
end

local function bg_telemetry()
   widget.backgroundLocal();
end

return {run=run_telemetry, init=init_telemetry, background=bg_telemetry}
