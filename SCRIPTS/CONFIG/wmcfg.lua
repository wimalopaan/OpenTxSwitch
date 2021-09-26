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

return {
   version = "1.14",
   switchGVar = 5, -- gVar for use with digital wm-switches
   offsetGVar = 5, -- gVars to use tiptip switches (each has to use its own channel), starting from (offsetGVar + 1)
   stateTimeout = 10, -- 100ms for each state to propagate

   defaultFilename = "/MODELS/swstd.lua";
   defaultFilenameM = "/MODELS/swstdm.lua";
   defaultFilenameS = "/MODELS/swstdx.lua";
}
