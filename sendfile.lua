return function(header)

	local fname = header.filename
	--coroutine.yield() --must yield once before sending anything!, not really any more...

	-- check if the file exists, use code 404 if not.
	local code = "200 OK"
	if not file.list()[fname or ""] then
		code = "404 File Not Found"
		fname = (serverconf.prefix or "") .. "404.html"
	end
	str = {"HTTP/1.1 ", code, "\nContent-Length: ", tostring(file.list()[fname]), "\n\n"}

	--[[table.insert(str, "HTTP/1.1 ")
	table.insert(str, code)
	table.insert(str, "\nContent-Length: ")
	table.insert(str, tostring(file.list()[fname]))
	table.insert(str, "\n\n")--]]
	--print("sent header", fname)
	coroutine.yield( table.concat(str) ) --send header
	--print("back", fname)
	local idx = 0
	while true do
		print(node.heap(), fname, "?") --debug statement
		-- open the file and read a chunk
		file.open(fname, "r" )
		local pos = file.seek("set", idx) --can't leave file open across yield
		local str = file.read(500)
		file.close()

		-- and send it.
		if not str or not pos then break end
		idx = idx + #str
		--print(fname, "sent", idx, #str, pos)
		coroutine.yield(str)
	end
	--print(fname, "done!")
end
