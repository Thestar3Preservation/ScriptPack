#!/usr/bin/env bash
source ~/.bash_profile
# LOAD_USER_FUNTION

#deneyinternet이란 그룹을 만들고, 이 그룹에 $USER을 추가하고, 이 그룹에 대해 다음 명령을 내렸습니다.
iptables --append OUTPUT --match owner --gid-owner deneyinternet --jump DROP

if [ $# = 0 ]; then
	cat <<-EOF
	사용법 : ni command
	command의 인터넷 권한을 차단하여 실행합니다.
	ex)ni firefox -new-tab
	EOF
	exit
fi

exec sg deneyinternet "$@"

# exit
#
# sudo gpasswd -d user deneyinternet
# sudo deluser user deneyinternet
# sudo delgroup deneyinternet