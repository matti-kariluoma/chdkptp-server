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

#TODO: do these need to be set each and every time?
write_fifo "$FIFO0" 'lua set_iso_real(50)'
write_fifo "$FIFO1" 'lua set_iso_real(50)'

write_fifo "$FIFO0" 'lua set_tv96(320)'
write_fifo "$FIFO1" 'lua set_tv96(320)'

write_fifo "$FIFO0" 'lua set_focus(300)'
write_fifo "$FIFO1" 'lua set_focus(300)'

write_fifo "$FIFO0" "remoteshoot $OUT_DIR0/"
write_fifo "$FIFO1" "remoteshoot $OUT_DIR1/"

exit 0
