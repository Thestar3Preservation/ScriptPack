#!/usr/bin/env bash_record
source ~/.bash_profile
targetlist=( '*.jpg' '*.jpeg' '*.png' '*.gif' )
for i in "${targetlist[@]}"; do target+=( -o -iname "$i" ); done
unset target[0]
find . -maxdepth 1 \( "${target[@]}" \) -type f | xargs -d '\n' -I{} mv {} "$PATH_PICTURE"
exit
