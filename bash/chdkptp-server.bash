#!/bin/bash
#
# Wraps one or more instances of chdkptp and provide a fifo and fd to
# deliver commands to the chdkptp instance(s).
#
# Matti Kariluoma Jan 2014 <matti@kariluo.ma>

CWD="$(dirname $0)"
CONFIG="$CWD/config.chdkptp-server.bash"
TMP_CONFIG="$CWD/tmp-config.chdkptp-server.bash"
FUNCTIONS="$CWD/functions.chdkptp-server.bash"

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
	if [ -r "$TMP_CONFIG" ]; then
		echo_stderr "chdkptp-server already running, or stale lock file \"$TMP_CONFIG\"!"
		echo_stderr "Try calling \"$0 stop\""
		exit 1
	fi
	
	#debug "Sending 'list' to a throw-away chdkptp instance..."
	#NUM_CAMS=$($CHDKPTP -e'list' | wc -l)
	
	touch "$TMP_CONFIG"
	TMP_DIR="$(mktemp -d)"
	echo "TMP_DIR=\"$TMP_DIR\"" >> "$TMP_CONFIG"
	
	# create fifos
	debug "Creating FIFOs"
	FIFO0=$TMP_DIR'/chdkptp-server-0.fifo'
	FIFO1=$TMP_DIR'/chdkptp-server-1.fifo'
	open_fifo "$FIFO0" 0
	open_fifo "$FIFO1" 1
	
	# create output directory
	debug "Creating output directories"
	OUT_DIR="$OUT_PREFIX/$(date +%Y-%m-%d_%H-%M)"
	OUT_DIR0="$OUT_DIR/left"
	OUT_DIR1="$OUT_DIR/right"
	
	mkdir -p "$OUT_DIR0" "$OUT_DIR1"
	echo "OUT_DIR0=\"$OUT_DIR0\"" >> "$TMP_CONFIG"
	echo "OUT_DIR1=\"$OUT_DIR1\"" >> "$TMP_CONFIG"
	
	# start chdkptp in interactive mode as a daemon
	debug "Starting chdkptp 0"
	cat "$FIFO0" | tee "$LOG0" | "$CHDKPTP" -i &> "$LOG0" &
	CHDKPTP_PID0=$!
	debug "Starting chdkptp 1"
	cat "$FIFO1" | tee "$LOG1" | "$CHDKPTP" -i &> "$LOG1" &
	CHDKPTP_PID1=$!
	
	echo "CHDKPTP_PID0=$CHDKPTP_PID0" >> "$TMP_CONFIG"
	echo "CHDKPTP_PID1=$CHDKPTP_PID1" >> "$TMP_CONFIG"
	
	write_fifo "$FIFO0" "connect -s=$CAM0"
	sleep 1
	write_fifo "$FIFO1" "connect -s=$CAM1"
	sleep 1
	
	write_fifo "$FIFO0" 'rec'
	write_fifo "$FIFO1" 'rec'
}

do_stop()
{
	write_fifo "$FIFO0" 'quit'
	write_fifo "$FIFO1" 'quit'

	close_fifo "$FIFO0" "$TAIL_PID0"
	close_fifo "$FIFO1" "$TAIL_PID1"
	
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
