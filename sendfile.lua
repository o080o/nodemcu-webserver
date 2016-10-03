return function(header)

	local fname=header.filename
	print("sending ", fname)
	coroutine.yield() --must yield once before sending anything! (not anymore?)

	local code = "200 OK"
	if not file.list()[fname or ""] then
		code = "404 File Not Found"
		fname = (serverconf.prefix or "") .. "404.html"
	end
	print("sending header")
	str = {}
	table.insert(str, "HTTP/1.1 ")
	table.insert(str, code)
	table.insert(str, "\nContent-Length: ")
	code = file.list()[fname] --reuse code variable.
	table.insert(str, tostring(code or 13)) --incase there is no 404 page we have a builtin string
	table.insert(str, "\n\n")
	print("sent header", fname)
	coroutine.yield( table.concat(str) ) --send header
	print("back", fname)
	if not code then return "404 not found" end --incase there is no 404 page...

	local idx = 0
	while true do
		print(node.heap(), fname, "?")
		file.open(fname, "r" )
		local pos = file.seek("set", idx) --can't leave file open across yield
		local str = file.read(500)
		file.close()

		if not str or not pos then break end
		idx = idx + #str
		print(fname, "sent", idx, #str, pos)
		coroutine.yield(str)
	end
	print(fname, "done!")
end
