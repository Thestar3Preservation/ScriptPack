#!/usr/bin/env bash_record
source ~/.bash_profile
LOAD_USER_FUNTION
for i; do
	ln "$i" "$(dupev_name -p . -- "$i")"
done
exit
