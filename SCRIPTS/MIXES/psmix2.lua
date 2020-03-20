local input = {}

local output = { "pswmod3" }

local function run()
   return gPulseSw[3];
end

return {output=output, input=input, run=run}
