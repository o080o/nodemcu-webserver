#Vibrium

Vibrium is a small collection of scripts for NoduMCU firmware running on the ESP8266. The goal of these scripts is to provide a complete set of tools to upload code easily to the ESP8266 wirelessly and provide basic web functionality in a small and small memory footprint. All told, the running server with a telnet connection takes around 15k on recent builds, with my build leaving me with around 32k (on integer builds, but I wouldn't expect too much more on float builds).

##Instalation

To install to the device, use a serial upload tool such as luatool.py, or esplorer, to upload **queuemanager.lua** **tinyserver.lua** and **put.lua**.  Access the device over the serial port using PuTTy/screen/miniterm/etc and execute ``dofile("tinyserver.lua")()`` to start the server. Then ``table.insert(serverconf.modes, require("put"))`` to add the *put* mode. The rest of the files can be uploaded using **putlua.lua** on your local machine. ex: ``lua putlua.lua 192.168.4.1 init.lua testinit.lua`` to upload *init.lua* as *testinit.lua* on the server at 192.168.4.1. (to start esp8266 in Access Point mode run ``wifi.setmode(wifi.SOFTAP);wifi.ap.config({ssid="esp8266"}))

##Tinyserver.lua

*tinyserver.lua* is a *framework* for a very tiny http/telnet server, however
its functionality can be extended to support other TCP protocols as desired.
When a client first connects to the server, based on the first packet of data,
the connection is switched to a variety of protocols, as determined by the
global table **serverconf.mode**. To add more protocols, insert the mode
description into the **serverconf.mode** table. Note that modes are matched
**in order** starting from index 1. For an example of a mode description, see
telnet.lua. For an example of adding modes to the server, see autorun.lua.

Alternatively, run the install script, **install.sh** and then execute
`dofile("simpleinit.lua")` over a serial terminal.

###Http.lua

This file provides basic handling of  **GET** requests for local files on the server, and access to cgi scripts if attempting to access *.lc* or *.lua* files. See the section on cgi scripts for more information. **note that this mode requires the sendfile.lua cgi script**

###put.lua

This file provides basic handling of **PUT** requests to upload files to the
server. 

###telnet.lua

This file provides a non-trivial telnet implementation when no other mode is
selected. This mode should therefore be placed last in the modes table, as it
will match any connection. This mode allows multigle telnet clients, and each
will receive all data from the command line. 

###CGI Scripts

Tinyserver is based around a single coroutine manager, located in queuemanager.lua, which provides 'multi-threading' of a sort. each 'thread' is a lua *thread* object, created via coroutine.create(). For each connection to the server, there is a single FIFO queue of threads which are executed in order by the queuemanager. Every timer period (configurable in serverconf.lua), the queuemanager executes a thread from one of the current connections, visiting each connection thread in some arbitrary order, checking if the socket is finished sending the last chunk of data yet. This garantees that each connection's queue will be visited if it has a thread that needs processing, and only when the socket is ready to send data. In this way, buffers don't overflow from attempts to send huge amounts of data, and data can be processed piecewise by letting the queuemanager manage your thread. 

It is important to understand how the queuemanager works, as all cgi scripts in tinyserver are executed through this queuemanager. When your cgi lua script is loaded, it is turned into a thread via ``coroutine.create(dofile("mycgi.lua"))``. Therefore, all cgi scripts should return a function that will be executed by the queuemanager whenever the connection is available to send information. A good examgle of how to write your cgi scripts is *sendfile.lua*. This script can send arbitrarily large files over a network socket as a response to a **GET** request. 

Note that your cgi script has no direct access to the socket object. In order to send data, call ``coroutine.yield("mydata")`` to let the queuemanager deal with the socket. Your thread will be resumed after the data is sent. 

As a parameter to your cgi thread, the http.lua module will provide the header
object, which is a table with the following fields:

* **filename** = the url from the **GET** request.

In addition, any name:value pairs from the query string will be placed in the header table as ``header.name=value``

##Autoconnect.lua

autoconnect.lua provides a basic way to automaticaly connect to known access
points. See autorun.lua for how to start this service. A table of ssid:password
pairs is passed to the returned function. In autorun.lua this table is loaded
from disk from the file *wificonfigs.lua*. 

##init.lua

This init file ensures that you do not boot-loop your esp8266! If the device was reset because of an exception or timeout, the script will wait for three seconds before rebooting again, and loading your code. If you do not want to restart and load your code, for instance because it will crash, call the global functino **stop()** before those three seconds to cancel the timer. Often, however, the exception was caused by code you are testing or otherwise *not* running in *autorun.lua*, which this init script references, and rebooting normally is a huge convinience. 
In order to use this service, you must be using the **dev** brance of noduMCU in order to have access to extended node.bootreason() info, and have the **tmr** and **node** modules compiled in. If these are not present, then the init script does nothing. (instead of crashing in a boot loop we were trying to avoid)
