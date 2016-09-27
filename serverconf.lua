return {prefix="",	-- Every http file access has the prefix appended to it
	pathsymbol="/",			-- Replaces '/' in path names
	maxConnections=2,	-- The maximum number of connections allowed at once(NYI)
	timerPeriod=50,		-- change this to set a different timeout value for tmr.alarm for the coroutine handler (co.lua)
	timerId=0,			-- change this to use a different timer for tmr.alarm for the coroutine handler (co.lua)
	port=80,			-- port number to use
	timeout=180			-- connection timeout (in seconds? )
}

