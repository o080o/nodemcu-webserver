--[[Generic coroutine based task system for IO

 coroutines added to the system that wish to send strings to their clients
 simply return them when they yield.
 coroutines are only run when they are ready to send more data

 Each client can have a list of queued tasks, waiting to send data. these are
 executed in order.

 This handler iterates over each client, executing the first coroutine in their queue, before moving to the next client.
 --]]
 
local last --must persist across calls
local function loop()
	collectgarbage() --force garbage collect before running script
	local Conn = serverconf.connections --cache table in local var
	local c, success, err = next(Conn, last)

	--check if there are no tasks, and the client disconnected. Then we need to
	--remove them from the queuemanager.
	if c and #Conn[c]==0 and Conn[c].disconnect then c,Conn[c]=nil,nil end
	last = c
	
	--check if its nil, no tasks, or not ready
	if not c or not Conn[c][1] or(not Conn[c].ready and not Conn[c].disconnect) then return end
	
	--check if its dead.
	if coroutine.status(Conn[c][1])=="dead" then
		table.remove(Conn[c], 1)
	else
		success, err = coroutine.resume(Conn[c][1])
		success = success or print("co err", err)
	end
	--is there something to send?
	if success and err and #err>0 then
		c:send(err)
		Conn[c].ready=false
	end
end

return function(timeout, id)
	print("Queue:",id or 0)
	tmr.alarm(id or 0, timeout or 500, 1, loop)
end
