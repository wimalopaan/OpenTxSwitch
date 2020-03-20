local input = {}

local output = { "psmod2" }

local function run()
   return gPulseSw[2];
end

return {output=output, input=input, run=run}
