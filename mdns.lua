local function tohex(str)
	local hex = {}
	for c in string.gmatch(str, ".") do
		table.insert(hex, string.byte(c))
		table.insert(hex, " ")
	end
	return table.concat(hex)
end
local function appendBytes(packet, bytes)
	for _,v in ipairs(bytes) do
		table.insert(packet, string.char(v))
	end
end
return function(hostname)
	hostname = (hostname or "esp8266")
	hostname = string.char(#hostname)..hostname..string.char(5).."local"
	mdns = net.createServer(net.UDP)
	broadcast = net.createConnection(net.UDP, 0)
	broadcast:connect(5353, "224.0.0.251")
	mdns:on("receive", function(c, str)
		print(pcall(function()
		print("mDNS:", #str)
		print(tohex(str))
		--check the hostname.
		if not string.match(str, hostname) then return end
		local header = {0,0,128,0,0,0,0,1,0,0,0,0}
		local dnsinfo = {0, 0,1, 128,1, 0,0,0,120, 0,4}
		local ip
		if wifi.getmode() == wifi.STATION then
			ip = wifi.sta.getip()
		else
			ip = "192.168.4.1" --TODO use wifi.ap api
		end
		local v1,v2,v3,v4 = string.match(ip, "(%d*)%.(%d*)%.(%d*)%.(%d*)")
		local packet = {}
		appendBytes(packet, header)
		table.insert(packet, hostname)
		appendBytes(packet, dnsinfo)
		appendBytes(packet, {v1,v2,v3,v4})
		print("response:", tohex(table.concat(packet)))
		print("aka", table.concat(packet))
		broadcast:send(table.concat(packet))
	end))
	end)
	--mdns:listen(5353, "224.0.0.251")
	mdns:listen(5353)
	net.multicastJoin(wifi.sta.getip(), "224.0.0.251")
end
