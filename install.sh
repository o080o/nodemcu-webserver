if [ -z "$1" ]; then
	echo "Usage: install.sh PORT"
	echo "ex 'install.sh /dev/ttyUSB0'"
else
	python2 luatool.py -p $1 -cf queuemanager.lua
	python2 luatool.py -p $1 -cf tinyserver.lua
	python2 luatool.py -p $1 -cf put.lua
	python2 luatool.py -p $1 -f simpleinit.lua
fi
