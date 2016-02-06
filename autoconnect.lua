-- attempts to connect with given network config(s). aborts and starts up AP mode upon failure
local autoconnect = function(networks, onFinish, ...)
	wifi.setmode(wifi.STATION)
	for ssid, password in pairs(networks) do
			wifi.sta.config(ssid, password)
			wifi.sta.connect()
			coroutine.yield()
			while wifi.sta.status() == 1 do
				print("connecting...")
				coroutine.yield()
			end
			--networks[ssid] = wifi.sta.status()
			print(ssid, wifi.sta.status())
			if wifi.sta.status()==5 then break end
	end
	coroutine.yield()
	if not next(networks) or wifi.sta.status() ~= 5 then
		wifi.setmode(wifi.SOFTAP)
		wifi.ap.config{ssid="ESP8266", pwd=""}
	end
	if onFinish then tmr.alarm(1, 100, tmr.ALARM_SINGLE, onFinish) end
end
-- return a helper function to load autoconnect asynchronously with coroutines
return function(networks, onFinish, tmrId,...)
	tmrId= tmrId or 0
	local co = coroutine.create(autoconnect)
	print(coroutine.resume(co, networks, onFinish, ...))
	tmr.alarm(tmrId, 500, tmr.ALARM_SEMI, function()
		if coroutine.status(co) == "dead" then return end
		coroutine.resume(co, networks)
		tmr.start(tmrId)
	end)
end
