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

local options = {
  { "Name", STRING}, -- display name
  { "GVar", VALUE, 7, 0, 8}, -- gvar (counting from 0)
  { "Address", VALUE, 1, 1, 8},
  { "Function", VALUE, 1, 1, 8},
  { "State", SOURCE, 8}, -- telemetry state variable
};

local gvalue = 1; -- state 1 := off

local function isDigit(v)
   return (v >= string.byte("0")) and (v <= string.byte("9"));
end

local function isLetter(v)
   return (v >= string.byte("A") and (v <= string.byte("Z"))) or (v >= string.byte("a") and (v <= string.byte("z")));
end

local function nthChar(n, v)
   local c = bit32.extract(v, n * 8, 8);
   if (isDigit(c) or isLetter(c)) then
      return string.char(c);
   end
   return nil;
end

local function optionString(option)
   local s = "";
   for i = 0,3 do
      local c = nthChar(i, option);
      if (c) then
	 s = s .. c;
      else
	 return s;
      end;
   end
   return s
end


local function create(zone, options)
   zone.cx = zone.x + zone.w / 2;
   zone.cy = zone.y + zone.h / 2;
   return {
      zone = zone,
      options = options,
      events = 0,
      canvas = {}
   };
end

local function update(widget, options)
  widget.options = options;
end

local function background(widget)
end

local function makeButton(f, border)
   return {x = f.x + border, y = f.y + border, w = f.w - (2 * border), h = f.h - (2 * border), state = 0};
end

local function covers(touch, btn) 
   if ((touch.x >= btn.x) and (touch.x <= (btn.x + btn.w)) and (touch.y >= btn.y) and (touch.y <= (btn.y + btn.h))) then
      return true;
   end
   return false;
end

local function buttonText(button, text)
      lcd.drawText(button.x + 16, button.y + button.h/2 - 8, text, SML);
end

local function buttonBorder(button)
      lcd.drawRectangle(button.x, button.y, button.w, button.h, DOTTED + LIGHTGREY);
end

local function refresh(widget, event, touch)
   if (event) then -- fullscreen
      widget.canvas.x = 0;
      widget.canvas.y = 0;
      widget.canvas.cx = LCD_W / 2;
      widget.canvas.cy = LCD_H / 2;
      widget.canvas.w = LCD_W;
      widget.canvas.h = LCD_H;
   else
      widget.canvas.x = widget.zone.x;
      widget.canvas.y = widget.zone.y;
      widget.canvas.cx = widget.zone.cx;
      widget.canvas.cy = widget.zone.cy;
      widget.canvas.w = widget.zone.w;
      widget.canvas.h = widget.zone.h;
   end

   local border = 2;
   local iw = (widget.canvas.w / 6);
   local ih = widget.canvas.h;
   if (ih > iw) then
      ih = iw;
   end

   local f1 = {x = widget.canvas.x, y = widget.canvas.y, w = iw / 2, h = ih};
   if (event) then
      f1.y = widget.canvas.cy - ih / 2;
   end
   local f2 = {x = f1.x + f1.w, y = f1.y, w = iw, h = ih};
   local f3 = {x = f2.x + f2.w, y = f1.y, w = iw, h = ih};
   local f4 = {x = f3.x + f3.w, y = f1.y, w = iw, h = ih};
   local f5 = {x = f4.x + f4.w, y = f1.y, w = iw / 2, h = ih};
   local f6 = {x = f5.x + f5.w, y = f1.y, w = iw, h = ih};
   local f7 = {x = f6.x + f6.w, y = f1.y, w = iw, h = ih};

   local holdBtn = makeButton(f3, border);
   local leftBtn = makeButton(f2, border);
   local rightBtn = makeButton(f4, border);
   local stopBtn = makeButton(f7, border);
  
   lcd.drawFilledRectangle(holdBtn.x, holdBtn.y, holdBtn.w, holdBtn.h, GREEN);
   lcd.drawFilledCircle(stopBtn.x + stopBtn.w/2, stopBtn.y + stopBtn.h/2, stopBtn.h/2 - border, RED);
   lcd.drawFilledTriangle(leftBtn.x + border, leftBtn.y + leftBtn.h/2,
			   leftBtn.x + leftBtn.w - border, leftBtn.y + border,
			   leftBtn.x + leftBtn.w - border, leftBtn.y + leftBtn.h - border, ORANGE);
   lcd.drawFilledTriangle(rightBtn.x + rightBtn.w - border, rightBtn.y + rightBtn.h/2,
			   rightBtn.x + border, rightBtn.y + border,
			   rightBtn.x + border, rightBtn.y + rightBtn.h - border, ORANGE);

   lcd.drawFilledRectangle(f1.x + border, f1.y + border, f1.w - (2 * border), f1.h - (2 * border), YELLOW);
   lcd.drawFilledRectangle(f5.x + border, f5.y + border, f5.w - (2 * border), f5.h - (2 * border), YELLOW);
   lcd.drawText(f6.x + border, f6.y + f6.h / 2 - 16, optionString(widget.options.Name));

   buttonText(holdBtn, "Hold");
   buttonText(leftBtn, "Left");
   buttonText(rightBtn, "Right");
   buttonText(stopBtn, "FREE");

   buttonBorder(holdBtn);
   buttonBorder(leftBtn);
   buttonBorder(rightBtn);

   if (event == EVT_TOUCH_TAP) then
      if (covers(touch, holdBtn)) then
	 gvalue = 1;
	 gvalue = gvalue + 10 * widget.options.Function + 100 * widget.options.Address;
	 --print(gvalue);
      elseif (covers(touch, leftBtn)) then
	 gvalue = 2;
	 gvalue = gvalue + 10 * widget.options.Function + 100 * widget.options.Address;
	 --print(gvalue);
      elseif (covers(touch, rightBtn)) then
	 gvalue = 3;
	 gvalue = gvalue + 10 * widget.options.Function + 100 * widget.options.Address;
	 --print(gvalue);
      elseif (covers(touch, stopBtn)) then
	 gvalue = 4;
	 gvalue = gvalue + 10 * widget.options.Function + 100 * widget.options.Address;
	 --print(gvalue);
      end
   end   
   model.setGlobalVariable(widget.options.GVar, getFlightMode(), gvalue);
end

return { name="WM Win",
	 options = options,
	 create = create,
	 update = update,
	 refresh = refresh,
	 background = background
};
