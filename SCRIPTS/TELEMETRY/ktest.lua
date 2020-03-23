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

local filename = "/keys.txt";

local states = {start = 0, exit = 1, scr_up = 2, scr_down = 3, scr_enter = 4, menu = 5, page = 6, complete = 7};

local state = states.start;

local kfile = nil;

local function init()
   kfile = io.open(filename, "w");
   io.write(kfile, "init\n");
   io.close(kfile);
end

local toggleTime = getTime();

local function run(event)
   if (state == states.start) and (getTime() > toggleTime) then
      lcd.clear();
      lcd.drawScreenTitle("Key Test", 1, 1);

      lcd.drawText(1, 8, "Press exit!", BLINK);

      if (event > 0) then
	     kfile = io.open(filename, "a");
	     io.write(kfile, "exit\n");
	     io.close(kfile);
	     toggleTime = getTime() + 500;
	     state = states.exit;
      end
      
   end
   if (state == states.exit) and (getTime() > toggleTime) then
      lcd.drawText(1, 8, "Scroll up!", BLINK);
      if (event > 0) then
	     kfile = io.open(filename, "a");
	     io.write(kfile, "scroll up\n");
	     io.close(kfile);
	     toggleTime = getTime() + 500;
	     state = states.scr_up;
      end
      
   end
   if (state == states.scr_up) and (getTime() > toggleTime) then
      lcd.drawText(1, 8, "Scroll down!", BLINK);
      if (event > 0) then
	     kfile = io.open(filename, "a");
	     io.write(kfile, "scroll down\n");
	     io.close(kfile);
	     toggleTime = getTime() + 500;
	     state = states.scr_down;
      end
      
   end
   if (state == states.scr_down) and (getTime() > toggleTime) then
      lcd.drawText(1, 8, "Press scroll enter!", BLINK);
      if (event > 0) then
	     kfile = io.open(filename, "a");
	     io.write(kfile, "scroll enter\n");
	     io.close(kfile);
	     toggleTime = getTime() + 500;
	     state = states.scr_enter;
      end
      
   end
   if (state == states.scr_enter) and (getTime() > toggleTime) then
      lcd.drawText(1, 8, "Press menu!", BLINK);
      if (event > 0) then
	     kfile = io.open(filename, "a");
	     io.write(kfile, "menu\n");
	     io.close(kfile);
	     toggleTime = getTime() + 500;
	     state = states.menu;
      end
      
   end
   if (state == states.menu) and (getTime() > toggleTime) then
      lcd.drawText(1, 8, "Press page!", BLINK);
      if (event > 0) then
	     kfile = io.open(filename, "a");
	     io.write(kfile, "page\n");
	     io.close(kfile);
	     toggleTime = getTime() + 500;
	     state = states.page;
      end
      
   end
   if (state == states.page) and (getTime() > toggleTime) then
      if (event > 0) then
	     kfile = io.open(filename, "a");
	     io.write(kfile, "complete\n");
	     io.close(kfile);
	     toggleTime = getTime() + 500;
	     state = states.complete;
      end
      
   end

   if not (state == states.complete) and (event > 0) then
      lcd.drawText(1, 20, "Got code: ");
      lcd.drawNumber(lcd.getLastRightPos(), 20, event);
      
      kfile = io.open(filename, "a");
      io.write(kfile, getTime());
      io.write(kfile, " : ");
      io.write(kfile, event);
      io.write(kfile, "\n");
      io.close(kfile);
   end

end

return {run=run, init=init}
