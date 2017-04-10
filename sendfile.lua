return function(header)

	local fname = header.filename
	coroutine.yield() --must yield once before sending anything! The first call passes in parameters

	-- check if the file exists, use code 404 if not.
	local code = "200 OK"
	if not file.list()[fname or ""] then
		code = "404 File Not Found"
		fname = (serverconf.prefix or "") .. "404.html"
	end

	str = {"HTTP/1.1 ", code, "\nContent-Length: ", tostring(file.list()[fname] or 13), "\n\n"}
	coroutine.yield( table.concat(str) ) --send header
	if not code then return "404 not found" end --incase there is no 404 page...

	local idx = 0
	while true do
		print('heap', node.heap(), fname) --debug statement
		-- open the file and read a chunk
		file.open(fname, "r" )
		local pos = file.seek("set", idx) --can't leave file open across yield
		local str = file.read(500)
		file.close()

		-- and send it.
		if not str or not pos then break end
		idx = idx + #str
		coroutine.yield(str)
	end
	print("sent", header.filename, code)
end
