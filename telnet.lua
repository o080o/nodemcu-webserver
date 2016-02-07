local function telnet(c, str)
	node.input(str)
end
local function telnetCo(q)
	while not q.disconnect do
		local str = table.concat(q.telnet)
		q.telnet = {}
		coroutine.yield(str)
	end
end
local function telnetSetup(c,str)
	local queue = serverconf.connections[c]
	queue.telnet = {} --queue for telnet responses
	local co = coroutine.create(telnetCo) 
	coroutine.resume(co, queue)
	table.insert(queue, co)
	node.output(function(str)
		local disconnect=true
		for c,q in pairs(serverconf.connections) do
			if q.telnet then
				table.insert(q.telnet, str)
				disconnect = false
			end
		end
		if disconnect then node.output(nil) end
	end, 0)
end
return  {pattern="", func=telnet, name='telnet', setup=telnetSetup}
