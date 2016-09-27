
local function receive(c, str)
	uart.write(0, str)
end
local function firstTime(c, str)
	tmr.alarm(5, 10, 0, function()
		c:on("receive", receive) --act normally from here on
	end)
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
	if disconnect then uart.on("data") end
end
local function setup(c,str)
	local queue = serverconf.connections[c]
	queue.tcp = {} --queue for responses and identifies TCP passthrough connections
	local handlerInstance = coroutine.create(handler) 

	coroutine.resume(handlerInstance, queue)
	table.insert(queue, handlerInstance)
	uart.on("data", string.match(str, "!(.)"), onInput, 0)
end
return  {pattern="!", func=firstTime, name='TCP passthrough', setup=setup}
