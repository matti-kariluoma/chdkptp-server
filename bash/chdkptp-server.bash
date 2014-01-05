#!/bin/bash
#
# Wraps one or more instances of chdkptp and provide a fifo and fd to
# deliver commands to the chdkptp instance(s).
#
# Matti Kariluoma Jan 2014 <matti@kariluo.ma>

CWD="$(dirname $0)"
CONFIG="$CWD/config.chdkptp-server.bash"
TMP_CONFIG="$CWD/tmp-config.chdkptp-server.bash"
FUNCTIONS="$CWD/config.chdkptp-server.bash"

# load in configurations first,
. "$CONFIG"
[ -r "$TMP_CONFIG" ] && . "$TMP_CONFIG"

# then load functions
. "$FUNCTIONS"

if [ "$(id -u)" -eq "0" ]; then
	echo_stderr "Do not run this script as root!"
	exit 1
fi

do_start()
{
	if [ -r $TMP_CONFIG ]; then
		echo_stderr "chdkptp-server already running, or stale lock file \"$TMP_CONFIG\"!"
		echo_stderr "Try calling \"$0 stop\""
		exit 1
	else
		touch "$TMP_CONFIG"
		TMP_DIR=$(mktemp -d)
		
		# create fifos
		FIFO0=$TMP_DIR'/chdkptp-server-0.fifo'
		FIFO1=$TMP_DIR'/chdkptp-server-1.fifo'
		#TODO: array of fifos
		
		echo "TMP_DIR=$TMP_DIR" >> "$TMP_CONFIG"
		echo "FIFO0=$FIFO0" >> "$TMP_CONFIG"
		echo "FIFO1=$FIFO1" >> "$TMP_CONFIG"
		mkfifo $FIFO0
		mkfifo $FIFO1
		
		# create output directory
		OUT_DIR="$OUT_PREFIX/$(date +%Y-%m-%d_%H-%M)"
		OUT_DIR0="$OUT_DIR/left"
		OUT_DIR1="$OUT_DIR/right"
		#TODO: array of directories
		
		mkdir -p $OUT_DIR0 $OUT_DIR1
		echo "OUT_DIR0=$OUT_DIR0" >> "$TMP_CONFIG"
		echo "OUT_DIR1=$OUT_DIR1" >> "$TMP_CONFIG"
	fi
	
	#TODO: smarter functions so we don't need to keep track of fds
	open_fd $FIFO0 3
	open_fd $FIFO1 4
	
	# start chdkptp in interactive mode as a daemon
	cat $FIFO0 | $CHDKPTP -i &
	cat $FIFO1 | $CHDKPTP -i &
	
	write_fd 3 "connect -s=$CAM0"
	write_fd 4 "connect -s=$CAM1"
	
	write_fd 3 "rec"
	write_fd 4 "rec"
}

do_stop()
{
	write_fd 3 "quit"
	write_fd 4 "quit"

	close_fd 3
	close_fd 4
	
	[ -r "$TMP_CONFIG" ] && rm "$TMP_CONFIG"
	[ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
}

case "$1" in
	start)
	echo_stderr "Starting chdkptp-server..."
	do_start
	echo_stderr "chdkptp-server started."
	;;
	stop)
	echo_stderr "Stopping chdkptp-server..."
	do_stop
	echo_stderr "chdkptp-server stopped."
	;;
	*)
	echo_stderr "USAGE: $0 (start|stop)"
	exit 3
	;;
esac

exit $?
