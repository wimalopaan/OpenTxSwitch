local input = {}

local output = { "psw0" }

local function run()
   return gPulseSw0;
end

return {output=output, input=input, run=run}
