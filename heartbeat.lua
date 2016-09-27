local state = 0
tmr.alarm(6, 500, 1, function()
	state = (state+1)%2
	gpio.mode(3, gpio.OUTPUT)
	gpio.write(3, state)
end)
