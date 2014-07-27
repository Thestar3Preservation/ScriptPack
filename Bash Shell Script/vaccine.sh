#!/usr/bin/env bash

IFS=$'\n'
export DISPLAY=:0.0 #crontab에서 사용하기 위해, 지정.
reportRootkitPath=/tmp/reportRootkit$$.log
reportVirusPath=/tmp/reportVirus$$.log
programName='clamv + rkhunter 기반 백신'

#help페이지
help(){
	cat <<-EOF
		$programName
		루트킷과 바이러스를 검사합니다.
		사용법 : $(basename "$0") [옵션] [clamvscan 옵션] [검사대상]
		대상이 파일일 경우, 해당 파일만 검사합니다. 대상이 폴더일 경우, 해당 디렉토리의 1단계 경로의 모든 파일을 검사합니다. 단, 폴더의 경우, '-r'옵션이 활성화되었다면, 하위 모든 디렉토리를 검사합니다.

		--rootkit	루트킷을 체크합니다. 이 옵션은 검사 대상 위치를 상관하지 않고 언제나 전체검사를 실시합니다.
		--virus		바이러스를 검사합니다. 이 옵션은 어떤 검사 옵션도 설정하지 않았다면 기본값으로 적용됩니다.
		-r		재귀적으로 해당 디렉토리 이하 모든 디렉토리를 탐색합니다.
		-e		제외될 대상을 선택합니다. 제외 대상 마다 -e옵션을 붙여 표현합니다. 이때, 경로는 절대경로로 표현해야 합니다. 예를 들어, "-e '/tmp/aaa' -e '/media/disk1'"식으로 표현합니다.
		--root		루트 계정으로 검사를 실행합니다. 이때, 루트 권한을 획득하기 위해, gksudo를 사용합니다.
		--notify	검사를 하기전 실행여부를 GUI방식으로 묻습니다.
		--realtime	지정된 디렉토리를 실시간으로 감시합니다. 백그라운드에서 작업합니다.
		--help, -h	이 페이지를 표시합니다.
		--version, -v	버전 페이지를 표시합니다.
		--		이 이후의 인자는 clamscan의 옵션 + 검사대상으로 취급합니다.
	EOF
}

#버전 페이지
version(){
	cat <<-EOF
		$programName

		2.4 스크립트 전체를 구조화함.
		2.3	루트킷 검사 기능을 추가.
		2.2	도움말 일부를 수정.
		2.1	파일경로를 완전하게 표시하도록 수정함.
		2.0	root모드를 사용하지 않을시, 정상적으로 작동하지 않던 문제 해결
		1.9	제외 명령을 추가함.
		1.8	루트 권한으로 검사를 수행하도록 하는 기능을 추가.
		 	검사 수행전 수행여부를 묻도록 하는 기능을 추가.
		1.7	중복되어 날자와 구분선을 표시되던 부분을 수정.
		1.6	재귀적 검사 소요시간을 단축.
		1.5	보고서 출력 및 저장 부분을 개선
		1.4	수동검사 시 출력을 실시간 출력으로 수정.
		1.3	수동검사 기능 지원.
		1.2	재귀적으로 탐색하는 기능을 지원.
		1.1	옵션 기능을 지원.
		 	버전 페이지와 도움말 페이지를 추가.
		 	인자가 존재하지 않을 경우, 도움말 페이지를 불러오도록 함.
		1.0	실시간 감시 기능 지원.
	EOF
}

#스크립트에서 진행 결과를 기록
reportRecord(){
	local context="$1 : $2" notify
	echo "$context" >&2
	[ -n "$notify" ] && notify-send -u $notify "$context"
	case $reportType in
	virus)
		echo $'\n'"$context"$'\n' >> "$reportVirusPath";;
	rootkit)
		echo $'\n'"$context"$'\n' >> "$reportRootkitPath";;
	esac
}

#옵션 처리
{
	#옵션이 존재하지 않을 경우, help페이지를 불러옴.
	[[ $# == 0 ]] && { help; exit 0; }

	#옵션 인자 처리
	{
		while [[ $# > 0 ]]; do
			case "$1" in
			--help | -h )
				help
				exit 0;;
			--version | -v )
				version
				exit 0;;
			--realtime )
				op_realtime=y
				shift;;
			--notify )
				op_notify=y
				shift;;
			--rootkit )
				op_chrootkit=y
				shift;;
			--virus )
				op_chvirus=y
				shift;;
			--root )
				#관리자 권한으로 실행하려 할 경우, 현재 프로세서를 관리자 권한으로 재시작함.
				[ $USER != root ] && exec gksudo "$0" "$@"
				for i in $reportVirusPath $reportRootkitPath; do
					touch "$i"
					chmod 777 "$i"
				done
				op_rootmode=y
				shift;;
			-e )
				exclude+=( "$2" )
				shift 2;;
			-r )
				op_recurrence=y
				shift;;
			-- )
				shift
				break;;
			* )
				break;;
			esac
		done
	}

	#검사 대상의 위치
	watchdirpath=${!#}

	#루트킷 검사 옵션도 켜지지 않았다면 자동으로 바이러스 검사를 선택
	[ "$op_chrootkit" != y -a "$op_chrootkit" != y ] && op_chvirus=y

	#clamscan의 옵션을 정리
	{
		[ "$op_recurrence" = y ] && optionVirus+=( --recursive=yes )
		optionVirus+=( "$@" )
		unset optionVirus[$((${#optionVirus[*]}-1))]
	}

	#사용자에게 GUI방식으로 작업을 진행할것인지 묻습니다.
	{
		if [ "$op_notify" = y ] && ! zenity --question --no-wrap --text="'$(realpath "$watchdirpath")'을(를)$([ "$op_recurrence" = y ] && echo ' 재귀적으로') 지금 $(if [ "$op_realtime" = y ]; then echo '실시간 검사'; else echo '수동 검사'; fi)를 수행 하시겠습니까?" --title="$programName"; then
			reportRecord exit '검사가 취소 되었습니다.'
			exit
		fi
	}

	#제외목록을 작성
	{
		exclude+=( /sys )
		if [[ ${#exclude[@]} > 0 ]]; then
			scan_ex=--exclude-dir=
			find_ex=( ! \( )
			for i in "${exclude[@]}"; do
				find_ex+=( -path "$i/*" -o )
				scan_ex+="^$i|"
			done
			unset find_ex[$((${#find_ex[*]}-1))]
			find_ex+=( \) )
			option+=( "$(sed 's/|$//' <<<"$scan_ex")" )
		fi
	}
}

#루트킷을 검사합니다.
{
	if [ "$op_chrootkit" = y ]; then
		reportType=rootkit
		echo -e '\n<<<루트킷을 검사합니다.>>>'
		{ rkhunter --check --propupd --report-warnings-only || reportRootkit=y; } | tee "$reportRootkitPath"
	fi
}

#바이러스를 검사합니다.
{
	if [ "$op_chvirus" = y ]; then
		reportType=virus
		echo -e '\n<<<바이러스를 검사합니다.>>>'
		virusCommand=( clamscan --verbose --max-filesize=4095M --max-scansize=4095M --max-files=9999999 --max-recursion=9999999 --max-dir-recursion=9999999 "${option[@]}" )
		if [ "$op_realtime" = y ]; then
			#실시간 감시
			{
				if ! cd -- "$watchdirpath"; then
					notify=critical reportRecord caution '대상에 접근하는데, 오류가 발생했습니다!'
					exit 1
				fi

				{ inotifywait $([ "$op_recurrence" = y ] && echo -r) --format %f -e create -e moved_to --monitor . | while read -r -d $'\n' target; do
					#max filessize와 sacnsize는 4GB가 최대다. 4GB - 1MB를 상한성으로 설정했다.
					"${virusCommand[@]}" "$target" 2>&1 | tee -a "$reportVirusPath"
					#--log=$HOME/Home/.usersys/Log/clamscan.log
					if [[ $? == 1 ]]; then
						notify-send -u critical -i dialog-warning '의심스러운 바이러스가 탐지되었습니다.' "<b>대상 : </b><a href='$watchdirpath'>$target</a>\n<a href='$reportVirusPath'>보고서 보기</a>"
					fi
				done; } &

				echo "PID : $!"
			}
		else
			#수동 검사
			{
				#검사. 검사 중 오류가 발생한 경우도 보고함.
				{ "${virusCommand[@]}" "$watchdirpath" 2>&1 || reportVirus=y; } | tee -a "$reportVirusPath"

				#제외되는 대상을 검사하고, 알림.
				{
					exclusion_list=$(find "$watchdirpath" -type f "${find_ex[@]}" -size +4095M)
					if [ -n "$exclusion_list" ]; then
						reportRecord warning '4GB를 초과하여 검사에서 제외된 대상이 존재합니다.'$'\n'"$exclusion_list"
						reportVirus=y
					fi
				}
			}
		fi
	fi
}

#사용자에게 결과를 보고
{
	if [ "$op_realtime" != y ]; then
		#아무것도 존재하지 않으면 무결함을 통보
		if [ "$reportVirus" = n -a "$reportRootkit" = n ]; then
			zenity --info --text='검사결과 시스템은 무결합니다.' --no-wrap &
		else
			#바이러스 검사에서 보고할것이 존재하면 보고
			[ "$reportVirus" = y ] && xdg-open "$reportVirusPath" &

			#루트킷 검사에서 보고할것이 존재하면 보고
			[ "$reportRootkit" = y ] && xdg-open "$reportRootkitPath" &
		fi
	fi
}