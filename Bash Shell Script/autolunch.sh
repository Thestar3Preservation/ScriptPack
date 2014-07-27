#!/bin/bash
ProgramName=$1
if pid=$(pgrep -x $ProgramName | head -n1); then
	target=$(wmctrl -lp | awk "\$3 == \"$pid\" { print \$1 }" | head -n1)
	if [ -n "$target" ]; then
		target=$(printf %d $target)
		if xdotool getactivewindow | grep -F $target; then
			xdotool windowminimize $target
		else
			xdotool windowactivate $target
			xdotool windowactivate $target
		fi
	else
		exec $ProgramName
	fi
else
	exec $ProgramName
fi
exit