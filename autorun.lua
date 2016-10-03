print("starting server...")

local pdofile = function(fname) --helpful wrapper around dofile
	local ok, result = pcall( dofile, fname )
	return (ok and result)
end

--attempt to autoconect to known access points
local configs = pdofile('wificonfigs.lua') or {}
local result = pdofile('autoconnect.lua') or pdofile('autoconnect.lc')
if result then result(configs, nil, 2) end

--load every server mode we wish
local modes = {
	"http",
	"put",
	"telnet"
}
result = pdofile('tinyserver.lua') or pdofile('tinyserver.lc')
if result then
	result() --start server
	for _,mode in ipairs(modes) do
		local ok, modeTable = pcall(require, mode)
		if ok then table.insert(serverconf.modes, modeTable) end
	end
	table.insert(serverconf.modes, http)
	table.insert(serverconf.modes, put)
	table.insert(serverconf.modes, telnet)
end
result = pdofile('hearbeat.lua') or pdofile('heartbeat.lc')
