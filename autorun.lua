local pins = require("gpios")
pins[12] = 1
dofile("autoconnect.lua")((file.list()['wificonfigs.lua'] and dofile("wificonfigs.lua")) or {}, nil, 2)

local modes = {
	"http",
	"put",
	"telnet"
}
dofile("tinyserver.lua")()
for _,mode in ipairs(modes) do
	local ok, modeTable = pcall(require, mode)
	if ok then table.insert(serverconf.modes, modeTable)
end
table.insert(serverconf.modes, http)
table.insert(serverconf.modes, put)
table.insert(serverconf.modes, telnet)
dofile('heartbeat.lua')
