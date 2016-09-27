--init script specifically for TCP to Serial devices like arduinos that don't
--want our debug info or an interactive lua vm! for shame!


--now let's quite the input/output of the vm..
uart.on("data", 255, function() end, 0)
node.output(function()end, 0)

--and continue init as normal. Other modes should be fully functional 
-- (though if a telnet session disconnects, we'll get output on the uart again)

local modes = {
	"http",
	"put",
	"arduino",
	"telnet"
}
local ok,func = pcall(dofile, "tinyserver.lua")
if not ok then ok,func = pcall(dofile, "tinyserver.lc") end
if ok then func() end

for _,mode in ipairs(modes) do
	local ok, modeTable = pcall(require, mode)
	if ok then table.insert(serverconf.modes, modeTable) end
end


