--[[
--should create a new branch!
--
--changing from one queue per thread, to one global queue
--with reference counting.
--
--how does lua handle 'sparse' integer tables?
--can we have integer keys in the thousands without having tons of memory?
--
--can we sacrafice using a fixed size circular queue with the possiblity of
--erasing messages before everyone has seen them?
--	- how do we deal with locally stored indeces to the 'start'?
--]]

local outputQueue = {counts={}, registered=0}
outputQueue.next = function(idx)
	local str = outputQueue[idx]
	if not str then return str, idx end

	local count = outputQueue.counts[idx] + 1
	if count >= outputQueue.registered then
		outputQueue[idx] = nil
		count = nil
	end
	outputQueue.counts[idx] = count
	return str, idx+1
end

local function telnet(c, str)
	node.input(str)
end
local function telnetCo(q)
	while not q.disconnect do
		local str, idx = outputQueue.next( q.idx or 1 ) --returns data and next idx, increments internal counter,
		q.idx = idx
		coroutine.yield(str)
	end
	outputQueue.registered = outputQueue.registered - 1
end
	--[[
local function telnetCo(q)
	while not q.disconnect do
		local str = table.concat(q.telnet)
		q.telnet = {}
		coroutine.yield(str)
	end
end
--]]
local function telnetSetup(c,str)
	local queue = serverconf.connections[c]
	queue.telnet = {} --queue for telnet responses and signal indicator
	outputQueue.registered = outputQueue.registered + 1
	
	local co = coroutine.create(telnetCo) 
	coroutine.resume(co, queue)
	table.insert(queue, co)

	--checks if any telnet sessions are active, and if
	--not, reverts to default behavior.
	--note that every telnet session will revieve the
	--same responses.
	node.output(function(str)
		local disconnect=true
		--table.insert(outputQueue, str)
		for c,q in pairs(serverconf.connections) do
			if q.telnet then
				--table.insert(q.telnet, str)
				disconnect = false
			end
		end
		if disconnect then node.output(nil) end
	end, 0)
end
return  {pattern="", func=telnet, name='telnet', setup=telnetSetup}
