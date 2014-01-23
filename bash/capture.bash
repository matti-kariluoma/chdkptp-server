#!/bin/bash
#
# Sends a capture command to a chdkptp instance started 
# by chdkptp-server.
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

if [ ! -r "$TMP_CONFIG" ]; then
	echo_stderr "You need to start the chdkptp-server first!"
	exit 1
fi

write_fifo "$FIFO0" "getm"
write_fifo "$FIFO1" "getm"
sleep 1

tail -n 1 "$FIFO0"
tail -n 1 "$FIFO1"

write_fifo "$FIFO0" "putm ping"
write_fifo "$FIFO1" "putm ping"

exit 0
