local function http(c, str)
	local url, querystr = string.match(str, "^GET /([^\r\n ?]*)[?]?([^\r\n ?]*) HTTP")
	url = (url=='' and 'index.html') or url --I hate this special case
	if not url then return end
	local script = (string.match(url, ".-[.]l[uc]a?") and file.list()[url] and url) or 'sendfile.lua'
	local obj, name, val = {}, 'filename', serverconf.prefix..string.gsub(url, "/", serverconf.pathsymbol)

	repeat 
		obj[name]=val
		name,val,querystr = string.match(querystr, "([^=& ]+)=([^=& ]+)(.*)")
	until not (name and val and querystr)

	script = coroutine.create(dofile(script))
	coroutine.resume(script, obj)
	table.insert(serverconf.connections[c], script)
end
return {pattern="^GET /([^\r\n ?]*)[?]?([^\r\n ?]*) HTTP", func=http, name="http"}
