-- A tiny server that acts as both a webserver AND a Telnet server!
local function connect(c, str)
	local inputFunc
	for _, mode in ipairs(serverconf.modes) do
		if string.match(str, mode.pattern) then
			inputFunc = mode.func
			if mode.setup then mode.setup(c,str) end
			print(mode.name, "connected", c)
			break
		end
	end
	if inputFunc then
		c:on("receive", inputFunc)
		return inputFunc(c,str)
	end
end
return function()
	if server then server:close() end
	serverconf =  (file.list()["serverconf.lua"] and dofile("serverconf.lua")) or {prefix="", pathsymbol="/", timerID=0, timerPeriod=50, port=80}

	--attemp both compiled and source versions
	local ok, Q = pcall(dofile, "queuemanager.lua")
	if not ok then ok, Q = pcall(dofile, "queuemanager.lc") end
	Q(serverconf.timerPeriod, serverconf.timerID)
	--dofile("queuemanager.lua")(serverconf.timerPeriod, serverconf.timerID)

	server = net.createServer(net.TCP, serverconf.timeout or 180)
	serverconf.connections = {}
	serverconf.modes = {}

	server:listen(serverconf.port, function(c)
		serverconf.connections[c] = {ready=true}

		c:on("sent", function(c) serverconf.connections[c].ready = true end)
		c:on("receive", connect)
		c:on("disconnection", function(c)
			-- inform the queuemanager that we disconnected
			serverconf.connections[c].disconnect = true
			serverconf.connections[c].ready = true
			if not next(serverconf.connections) then node.output(nil) end end)
	end)

end
