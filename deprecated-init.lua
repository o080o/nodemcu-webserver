--This is just a bootstrap file to make sure we dont brick anything
--
--if it starts failing, call global stop() before the timer.

tmr.alarm(0, 2000, tmr.ALARM_SINGLE, function() --give time to not brick something!
	local reason, extended = node.bootreason()
	--allow poweron(0) software reset(4) wake-from-sleep(5)
	if (extended==0 or extended==4 or extended==5) or
		(extended==nil and (reason==1 or reason==2 or reason==3)) then
		local ok,err = pcall(dofile, "initialize.lua") --this can still fail without a lua error
		if not ok then print(err) end
	else
		print("invalid boot reason", reason, extended)
	end
	_G["stop"]=function tmr.stop(0) end --give an escape!
end)
