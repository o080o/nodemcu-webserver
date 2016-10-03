if [ -z "$1" ]; then
	echo "Usage: install.sh PORT"
	echo "ex 'install.sh /dev/ttyUSB0'"
else
	read -p "Install base (y/n)?" choice
	case "$choice" in
		y|Y ) python2 luatool.py -p $1 -cf queuemanager.lua; python2 luatool.py -p $1 -cf tinyserver.lua; python2 luatool.py -p $1 -cf put.lua;;
	esac

	read -p "Install telnet mode (y/n)?" choice
	case "$choice" in
		y|Y ) python2 luatool.py -p $1 -cf telnet.lua;;
	esac

	read -p "Install autorun (y/n)?" choice
	case "$choice" in
		y|Y ) python2 luatool.py -p $1 -f autorun.lua;;
	esac

	read -p "Install init.lua (y/n)?" choice
	case "$choice" in
		y|Y ) python2 luatool.py -p $1 -f init.lua;;
	esac

	read -p "Install http mode (y/n)?" choice
	case "$choice" in
		y|Y ) python2 luatool.py -p $1 -cf http.lua; python2 luatool.py -p $1 -cf sendfile.lua;;
	esac

	#read -p "Start server now? (y/n)?" choice
	#case "$choice" in
		#y|Y ) python2 luatool.py -p $1 -cf http.lua; python2 luatool.py -p $1 -cf sendfile.lua;;
	#esac
fi
