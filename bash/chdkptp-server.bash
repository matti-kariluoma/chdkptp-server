#!/bin/bash
#
# Wraps one or more instances of chdkptp and provide a fifo and fd to
# deliver commands to the chdkptp instance(s).
#
# Matti Kariluoma Jan 2014 <matti@kariluo.ma>

CHDKPTP='chdkptp'
DEBUGGING_MESSAGES=false

debug()
{
	if $DEBUGGING_MESSAGES ; then
		echo $@
	fi
}

TMP_DIR=$(mktemp -d)
#TODO: array of fifos
FIFO0=$TMP_DIR'/chdkptp-server-0.fifo'
FIFO1=$TMP_DIR'/chdkptp-server-1.fifo'

mkfifo $FIFO0
mkfifo $FIFO1

# http://www.gnu.org/software/bash/manual/html_node/Redirections.html
#TODO: do we _really_ need file descriptors?
open_fd()
{
	debug 'entered open_fd'
	#TODO: check that all parameters are present
	FIFO=$1
	FD=$2 #TODO: check in range 3-9
	eval "exec $FD<>$FIFO"
}

# side-effect: sends EOF to fifo, which chdkptp interprets as 'quit'
close_fd()
{
	debug 'entered close_fd'
	#TODO: check that all parameters are present
	FD=$1 #TODO: check in range 3-9
	eval "exec $FD>&-"
}

write_fd()
{
	debug 'entered write_fd'
	#TODO: check that all parameters are present
	FD=$1 #TODO: check in range 3-9
	MSG=$2
	eval "echo $MSG >&$FD"
}

#TODO: smarter functions so we don't need to keep track of fds
open_fd $FIFO0 3
open_fd $FIFO1 4

cat $FIFO0 &
cat $FIFO1 &

write_fd 3 'hello'

close_fd 3
close_fd 4


rm -rf $TMP_DIR
exit 0
