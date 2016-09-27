local last --must persist across calls
local function loop()
	collectgarbage() --force garbage collect before running script
	local Conn = serverconf.connections --cache table in local var
	local c, success, err = next(Conn, last)
	if c and #Conn[c]==0 and Conn[c].disconnect then c,Conn[c]=nil,nil end
	last = c
	if not c or not Conn[c][1] or(not Conn[c].ready and not Conn[c].disconnect) then return end
	if coroutine.status(Conn[c][1])=="dead" then
		table.remove(Conn[c], 1)
	else
		success, err = coroutine.resume(Conn[c][1])
		success = success or print("co err", err)
	end
	if success and err and #err>0 then
		c:send(err)
		Conn[c].ready=false
	end
end

return function(timeout, id)
	print("Queue:",id or 0)
	tmr.alarm(id or 0, timeout or 500, 1, loop)
end
