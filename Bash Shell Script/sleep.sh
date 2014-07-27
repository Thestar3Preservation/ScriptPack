#!/usr/bin/env bash
xset dpms force off
xdg-screensaver activate #gnome-screensaver-command -l
xset dpms force off
for i in {1..2}; do
	wait 1
	xset dpms force off
done
exit