#!/bin/bash
#1 : savepath 지정된 위치(저장될 경로)
#주의: 인자는 넘겨지기 전 콰우팅되어 있어야 합니다. ex)#!이스크립트명 "$HOME/LOG"
#+지정된 위치가 폴더면 실행된 스크립트명으로 내용을 추가합니다.
#+지정된 위치가 존재하지 않으면, 해당 위치에 내용을 추가합니다.
#+경로가 지정되지 않으면, 기본설정된 위치에 로그를 추가합니다.
#넘겨진 인수는 기본적으로 한번더 해석되니, bash쉘에서 사용되는 특수문자를 주의해서 사용하세요.
#여러 곳에서 다양한 이름으로 불리는 경우, 저장되는 이름도 제각각이니, 저장옵션에 파일명을 수동지정해줘야만 하나의 파일에 저장됩니다.
source ~/.bash_profile
LOAD_USER_FUNTION
TEMP=( "$savepath" "$IFS" )
savepath=$PATH_LOG

if grep -qE '^\.?/' <<<"$1"; then
	savepath+=/$(ex_name "$1").log
else
	IFS=' '
	eval "op=($1)"
	case "${op[0]}" in
		#저장될 경로를 지정합니다.
		--savepath )
			unset op[0]
			savepath=$(eval echo "${op[*]}")
			#대상이 디렉토리일경우 스크립트 명으로 해당 위치에 저장합니다.
			test -d "$savepath" && savepath+=/$(ex_name "$2").log;;
		#아무런 옵션이 없을시 실행 스크립트 명을 저장명으로 기본경로에 저장합니다.
		-- )
			unset op[0]
			savepath+=/$(ex_name "$2").log;;
		#이름만 바꿔 기본경로에 저장합니다. 뒤에 자동으로 .log확장자가 붙습니다.
		--changename )
			unset op[0]
			savepath+=/$(eval echo "${op[*]}").log;;
		* )
			savepath+=/$(eval echo "${op[*]}").log;;
	esac
	shift
fi
IFS=${TEMP[1]}

{
	[ -e "$savepath" ] && echo
	savepath=${TEMP[0]}
	echo '=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
	date
	bash "$@"
} 2>&1 | tee -a "$savepath"