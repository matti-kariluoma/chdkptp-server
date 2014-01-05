#!/bin/bash
#
# Sends a capture command to a chdkptp instance started 
# by chdkptp-server.
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

# ensure output directory exists

#TODO: do these need to be set each and every time?
write_fd 3 "lua set_iso_real(50)"
write_fd 4 "lua set_iso_real(50)"

write_fd 3 "lua set_tv96(320)"
write_fd 4 "lua set_tv96(320)"

write_fd 3 "lua set_focus(300)"
write_fd 4 "lua set_focus(300)"

write_fd 3 "remoteshoot $OUT_DIR0/"
write_fd 4 "remoteshoot $OUT_DIR1/"

exit 0
