local writing, url, len
local function put(c, str)
	if not writing then -- match the header
		local query, rest
		url, query, len, rest = string.match(str, "^PUT /([^\r\n ?]*)[?]?([^\r\n ?]*) HTTP.-Content%-Length: (%d*).-\r?\n\r?\n(.*)")
		len = tonumber(len)
		if url and len then -- valid header
			writing = 0
			url = serverconf.prefix .. string.gsub(url, "/", serverconf.pathsymbol)
			str= rest
			file.remove(url)
		else -- invalid header...
			return
		end
	end

	-- write a chunk to the end of the file
	file.open(url, 'a')
	file.write(string.sub(str, 1, len))
	file.close()
	print("wrote", url, #str, "out of", len)
	-- and update our state
	if len <= #str then -- check if we are done?
		writing=nil
		return put(c, string.sub(str,len+1))
	end
	len = len - #str
end
return {pattern="^PUT /([^\r\n ?]*)[?]?([^\r\n ?]*) HTTP", func=put, name="put"}
