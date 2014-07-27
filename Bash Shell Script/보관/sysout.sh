#!/bin/bash
#새로 재작성된 스크립트
if [ -n "$1" ]; then
	xset dpms force off
	xdg-screensaver activate #gnome-screensaver-command -l
	xset dpms force off
	for i in {1..2}; do
		wait 1
		xset dpms force off
	done
else
	python ~/"Home/쉘스크립트/sysout.py"
fi

exit
