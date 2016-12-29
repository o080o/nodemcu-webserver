local function http(c, str)
	-- match the first lines of the http packet
	local url, querystr = string.match(str, "^GET /([^\r\n ?]*)[?]?([^\r\n ?]*) HTTP")
	url = (url=='' and 'index.html') or url --I hate this special case
	if not url then return end
	local script = (string.match(url, ".-[.]l[uc]a?") and file.list()[url] and url) or 'sendfile.lua'
	local headerobj, name, val = {}, 'filename', serverconf.prefix..string.gsub(url, "/", serverconf.pathsymbol)
	
	-- parse the header key:value pairs
	repeat
		headerobj[name]=val
		name,val,querystr = string.match(querystr, "([^=& ]+)=([^=& ]+)(.*)")
	until not (name and val and querystr)

	-- prepare to call the next phase via script (usually the sendfile script)
	-- we have to make sure we *don't* crash since this function is an event handler
	-- and crashes will reset the chip.
	ok, func = pcall(dofile, script)
	if not ok then
		print(func)
	else
		script = coroutine.create(func)
		coroutine.resume(script, headerobj)
		table.insert(serverconf.connections[c], script) --let the queuemanager handle it from here
	end
end
return {pattern="^GET /([^\r\n ?]*)[?]?([^\r\n ?]*) HTTP", func=http, name="http"}
