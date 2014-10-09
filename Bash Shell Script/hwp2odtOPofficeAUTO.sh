#!/bin/bash
#hwp를 odt로 변환을 시도하고, 실패하면 txt로 변환을 시도한다. 그래도 실패하면 에러 알림을 띄운다.
source ~/.bash_profile
LOAD_USER_FUNTION

WORK_PATH=/tmp/.hwp-$UID
GV_sourcePath=
GV_sourceFullName=
GV_PROGRESS_WIN_PID=
OPEN_BY_VM_WHEN_ALL_TRY_FAILED=FALSE  # TRUE시, 모든 작업이 실패시 가상머신에서 HWP파일을 열도록 합니다.

function exit()
{
	local exitCode sourceDirPath
	
	exitCode=${1:-success}
	sourceDirPath=$(dirname -- "$GV_sourcePath")
	
	case "$exitCode" in
	success)
		exitCode=0
		;;
	faile|*)
		notify-send -i error 'hwp->odt 변환 오류' "<a href='$sourceDirPath'>$GV_sourceFullName</a>를 변환시키는데 실패했습니다."
		exitCode=1
		;;
	esac
	kill $GV_PROGRESS_WIN_PID
	builtin exit $exitCode
}

function main()
{
	local sourceName text
	
	umask 0077
	mkdir -p $WORK_PATH
	cd $WORK_PATH
	
	GV_sourcePath=$1
	GV_sourceFullName=$(basename -- "$GV_sourcePath")
	sourceName=$(ex_name "$GV_sourcePath")
	
	yes | zenity --progress --pulsate --auto-kill --text="$GV_sourceFullName" --title='HWP를 여는 중...' --width=350 &
	GV_PROGRESS_WIN_PID=$!

	if [ -z "$(hwp5odt "$GV_sourcePath" 2>&1)" ]; then
		xdg-open "$sourceName.odt"
	else
		hwp5proc xml "$GV_sourcePath" | html2text -nometa -utf8 | read text
		if [[ $(wc -l <<<"$text") == 1 ]] && grep -xiF '<?xml version="1.0" encoding="utf-8"?>' <<<"$text"; then
			echo -n "$text" > "$sourceName.txt"
			xdg-open "$sourceName.txt"
		elif [ $OPEN_BY_VM_WHEN_ALL_TRY_FAILED = TRUE ]; then
			runbyvm "$GV_sourcePath"
		else
			exit faile
		fi
	fi

	exit success
}

main "$@"
