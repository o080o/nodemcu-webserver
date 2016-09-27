
local function receive(c, str)
	uart.write(0, str)
end
local function firstTime(c, str)
	c:on("receive", receive) --act normally from here on
end

local function handler(q)
	while not q.disconnect do
		local str = table.concat(q.tcp)
		q.tcp = {}
		coroutine.yield(str)
	end
end
local function onInput(data)
	local disconnect=true
	for c,q in pairs(serverconf.connections) do
		if q.tcp then
			table.insert(q.tcp, data)
			disconnect=  false
		end
	end
	if disconnect then uart.on("data", 255, function() end, 0) end --don't return control. that might mess things up for connected devices.
end
local function setup(c,str)
	local queue = serverconf.connections[c]
	queue.tcp = {} --queue for responses and identifies TCP passthrough connections
	local handlerInstance = coroutine.create(handler) 

	coroutine.resume(handlerInstance, queue)
	table.insert(queue, handlerInstance)
	local delim = tonumber(string.match(str, "!(%d+)")) or string.match(str, "!(.)") or 0
	uart.on("data", delim, onInput, 0)
end
return  {pattern="!", func=firstTime, name='TCP passthrough', setup=setup}
