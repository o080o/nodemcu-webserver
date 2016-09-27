local pins = require('gpios')
local state = 0
tmr.alarm(6, 500, 1, function()
	state = (state+1)%2
	pins[0]=state
end)
