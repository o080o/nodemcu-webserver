-- note that the node and timer  module must be included for this script to function
if not (node and node.bootreason and tmr and tmr.alarm) then return end --make sure module is available before we proceed.
local good = { --whitelisted bootreason status codes
	[0]=true,
	[4]=true,
	[5]=true,
	[6]=true }
local bad = { --blacklisted bootreason status codes (with descriptions)
	[1]="hardware watchdog reset",
	[2]="exception reset",
	[3]="software watchdog reset" }
local raw,status = node.bootreason()
if not status then return end --old bootreason function. can't do.
if good[status] then
	local ok, err
	if status==6 then -- on rst & deep sleep wakeup
		ok, err = pcall( dofile, "wake.lua")
		if not ok then print(err)
		else return end -- do not continue
	end
	ok, err = pcall(dofile, "autorun.lua")
	if not ok then print(err) end
else 
	print("will not load startup file:", bad[status], node.bootreason())
	tmr.alarm(0, 3000, 0, function() node.restart() end)
	_G["stop"] = function() tmr.stop(0) end
end
