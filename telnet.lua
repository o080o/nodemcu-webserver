local function telnet(c, str) -- the mode's receive function
	node.input(str)
end

local function telnetCo(q) -- queue thread to *send* info
	while not q.disconnect do
		local str = table.concat(q.telnet)
		q.telnet = {}
		coroutine.yield(str)
	end
end

local function telnetSetup(c,str) -- setup for sending console output
	local queue = serverconf.connections[c]
	queue.telnet = {} --queue for telnet responses
	local co = coroutine.create(telnetCo)
	coroutine.resume(co, queue)
	table.insert(queue, co)

	-- on node.output:
	--	checks if any telnet sessions are active, and if
	--	not, reverts to default behavior.
	--	note that every telnet session will revieve the
	--	same responses.
	node.output(function(str)
		local disconnect=true
		for client,q in pairs(serverconf.connections) do
			if q.telnet then
				table.insert(q.telnet, str)
				disconnect = false
			end
		end
		if disconnect then node.output(nil) end
	end, 0)
end
return  {pattern="", func=telnet, name='telnet', setup=telnetSetup}
