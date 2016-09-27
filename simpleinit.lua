local modes = {
	"http",
	"put",
	"arduino",
	"telnet"
}
dofile("tinyserver.lua")()
for _,mode in ipairs(modes) do
	local ok, modeTable = pcall(require, mode)
	if ok then table.insert(serverconf.modes, modeTable) end
end
