return function(string)
		coroutine.yield() --must yield once before sending anything! (maybe?)

		local code = "200 OK"
		str = {}
		table.insert(str, "HTTP/1.1 ")
		table.insert(str, code)
		table.insert(str, "\nContent-Length: ")
		code = #string
		table.insert(str, tostring(code or 13)) --incase there is no 404 page we have a builtin string
		table.insert(str, "\n\n")
		coroutine.yield( table.concat(str) ) --send header
		coroutine.yield( string ) -- send string in the response (NOT CHUNKED, since a string never needs to be chunked)
		print("sent", string)
	end
