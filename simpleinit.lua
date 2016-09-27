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
