#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

PrintHelp(){
	local ProgramName=$(basename "$0")
	cat <<-EOF
		사용법 : $ProgramName [종류]
		
		종류 :
		 	lib [대상...] : 공유 라이브러리(.so)를 사용자가 사용가능하도록 링크한다.
		 	run [대상] [별칭] : 대상을 별칭만을 입력하여 불러올수 있도록 링크한다.
		 	
	EOF
}

SetTargetListByArgument(){
	GV_TargetList=( "$@" )
}

SetArgument(){
	if [ $# = 0 ]; then
		PrintHelp
		exit 1
	fi
	
	GV_Type=$1
	shift
	
	case "$GV_Type" in
	lib)
		if [[ $# == 0 ]]; then
			ErrorMessage '인자의 수가 잘못되었습니다.'
			exit 1
		fi
		SetTargetListByArgument "$@"
		;;
	run)
		if [ $# != 2 ]; then
			ErrorMessage '인자의 수가 잘못되었습니다.'
			exit 1
		fi
		SetTargetListByArgument "$@"
		;;
	*)
		ErrorMessage '지원되지 않는 종류입니다.'
		exit 1
		;;
	esac
}

ErrorMessage(){
	local Mesg=$1
	echo "$Mesg" >&2
}

VervoseMessage(){
	local Mesg=$1
	echo "$Mesg"
}

LinkTo_Lib(){
	set "${GV_TargetList[@]}"
	local Path
	for Path; do
		local OriPath=$Path
		Path=$(realpath "$Path")
		ln -fs "$Path" "$PATH_SHARELIBRARY" || pause
		VervoseMessage "\`$OriPath'를 공유 라이브러리 폴더에 추가했습니다."
	done
}

LinkTo_Run(){
	set "${GV_TargetList[@]}"
	local Src=$1 LinkName=$2
	local OriSrc=$1
	Src=$(realpath "$Src")
	local ReferPath=$PATH_BIN/$LinkName
	ln -fs "$Src" "$ReferPath" || pause
	ln -fs "$ReferPath" "$PATH_RUNLINK" || pause
	VervoseMessage "\`$OriSrc'를 \`$LinkName'란 이름으로 단축 실행 목록에 추가했습니다."
}

LinkByType(){
	case "$GV_Type" in
	lib)
		LinkTo_Lib
		;;
	run)
		LinkTo_Run
		;;
	esac
}

main(){
	SetArgument "$@"
	LinkByType 
	exit 0
}

main "$@"