local function telnet(c, str)
	node.input(str)
end
local function telnetCo(q)
	while not q.disconnect do
		coroutine.yield(table.remove(q.telnet, 1))
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
				q.telnet[1]=(q.telnet[1] or '')..str
				disconnect = false
			end
		end
		if disconnect = true then node.output(nil) end
	end, 0)
end
return  {pattern="", func=telnet, name='telnet', setup=telnetSetup}
