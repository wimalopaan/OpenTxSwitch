local input = {}

local output = { "psmod1" }

local function run()
   return gPulseSw[1];
end

return {output=output, input=input, run=run}
