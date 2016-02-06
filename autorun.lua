local pins = require("gpios")
pins[12] = 1
dofile("autoconnect.lua")((file.list()['wificonfigs.lua'] and dofile("wificonfigs.lua")) or {}, nil, 2)
dofile("tinyserver.lua")()
table.insert(serverconf.modes, require("http"))
table.insert(serverconf.modes, require("put"))
table.insert(serverconf.modes, require("telnet"))
