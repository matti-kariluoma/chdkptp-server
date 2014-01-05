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

# http://stackoverflow.com/questions/8410439/how-to-avoid-echo-closing-fifo-named-pipes-funny-behavior-of-unix-fifos/8436387#8436387
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

exit 0
