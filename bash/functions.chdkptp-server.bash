#!/bin/bash
#
# Matti Kariluoma Jan 2014 <matti@kariluo.ma>

echo_stderr()
{
	echo "$@" >&2
}

debug()
{
	if $DEBUGGING_MESSAGES ; then
		echo_stderr "$@"
	fi
}

open_fifo()
{
	debug 'entered open_fifo'
	#TODO: check that all parameters are present
	local FIFO="$1"
	local ID="$2"
	mkfifo "$FIFO"
	tail -f /dev/null > "$FIFO" &
	local TAIL_PID=$!
	
	[ -r "$TMP_CONFIG" ] && echo "FIFO$ID=\"$FIFO\"" >> "$TMP_CONFIG"
	[ -r "$TMP_CONFIG" ] && echo "TAIL_PID$ID=$TAIL_PID" >> "$TMP_CONFIG"
}

# side-effect: sends EOF to fifo, which chdkptp interprets as 'quit'
close_fifo()
{
	debug 'entered close_fifo'
	local FIFO="$1"
	local PID="$2"
	kill "$PID"
}

write_fifo()
{
	debug 'entered write_fifo'
	#TODO: check that all parameters are present
	local FIFO="$1"
	local MSG="$2"
	echo "$MSG" > "$FIFO"
}
