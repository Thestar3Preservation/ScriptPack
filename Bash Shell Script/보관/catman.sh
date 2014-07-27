#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION


#터미널의 man이나 info페이지 따위를 그냥 화면에 뿌림. 앞에 man을 생략해하여 사용, man 이 아닌경우 명령어까지 모두 입력
catman(){
	local command
	command=$@
	grep -q '^info' <<<"$command" || command="man $command"
	cat < <($command)
}

exit