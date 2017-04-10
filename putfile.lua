-- simple bootstrapping script to upload files OTA without
-- the full tinyserver setup.
return function(port, timeout)
	if server then server:close() end
	server = net.createServer(net.TCP, timeout or 120)
	server:listen(port or 123, function(c)
		local currentfile = ""
		c:on("receive", function(c, str)
			local fname, content = string.match(str, "$$([^\r\n]*)(.*)")
			if fname then
				file.remove(fname)
			else
				fname = currentfile
				content = str
			end
			print("transfering file:", fname, #content)
			file.open(fname, "a")
			file.write(content)
			file.close()

			currentfile = fname --save this for later
		end)
	end)

	return server
end
