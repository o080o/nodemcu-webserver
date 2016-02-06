-- simple script to issue a PUT request with a given file as its body
-- this enables files to be coppied to the server via the web, rather than 
-- over a (slow) serial cable!
assert(arg[1] and arg[2], "called as: lua putlua.lua ADDR FILENAME [SERVERPATH]")
arg[3] = arg[3] or arg[2]
print("sending ", arg[2], "to", arg[1], "as", arg[3])
local socket = require("socket")

local file = assert(io.open( arg[2], "r"))
local content = file:read("*all")
local msg = "PUT /"..arg[3].." HTTP/1.1\nContent-Type: text/plain\nContent-Length: "..#content.."\n\n"..content

local sock = assert(socket.connect(arg[1], 80))
sock:send( msg )
print("sent", msg)
