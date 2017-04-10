sendstring = require("sendstring")
return function(header)
		-- do the thing!
		for k,v in pairs(header) do
			print("set", k, v)
			_G[k] = v
		end
		sendstring("<p> okay </p>")
end
