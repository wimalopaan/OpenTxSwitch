local input = {}

local output = { "psmod4" }

local function run()
   return gPulseSw[4];
end

return {output=output, input=input, run=run}
