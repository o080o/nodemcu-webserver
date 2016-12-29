if [ -z "$1" ]; then
	echo "Usage: install.sh PORT"
	echo "ex 'install.sh /dev/ttyUSB0'"
else
	python2 luatool.py -p $1 -f queuemanager.lua
	python2 luatool.py -p $1 -f tinyserver.lua
	python2 luatool.py -p $1 -f put.lua
	python2 luatool.py -p $1 -f telnet.lua
	#python2 luatool.py -p $1 -f simpleinit.lua
	python2 luatool.py -p $1 -f arduino.lua
	python2 luatool.py -p $1 -f arduinoinit.lua -t init.lua
fi
