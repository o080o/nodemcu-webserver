local PCBpinout = {
	[0]=3,
	[2]=4,
	[3]=9,
	[4]=1,
	[5]=2,
	[9]=11,
	[10]=12,
	[12]=6,
	[13]=7,
	[14]=5,
	[15]=8,
	[16]=0
} 

local G = {} --make a metatable to make pin access *easy*
G.__index = function(t,k)
	gpio.mode(PCBpinout[k], gpio.INPUT)
	return gpio.read(PCBpinout[k])
end
G.__newindex = function(t,k,v)
	gpio.mode(PCBpinout[k], gpio.OUTPUT)
	gpio.write(PCBpinout[k], v)
end
return setmetatable({pin=PCBpinout}, G)
