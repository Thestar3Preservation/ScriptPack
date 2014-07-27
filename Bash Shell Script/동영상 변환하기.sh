#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION

#인자 검사
{
	#인지가 없으면 사용법을 출력
	if [[ $# == 0 ]]; then
		echo 'test.flv -> test.mp4 : "command test.flv test.mp4"와 같은 식으로 사용하십시오.' >&2
		exit
	fi

	#원본 파일이 존재하는지 검사
	{
		if [ ! -f "$1" ]; then
			echo '원본이 존재하지 않습니다.' >&2
			exit
		fi
		source=$1
	}

	#확장자가 올바른지 검사
	{
		ext=$(ex_ext -d -- "$2")
		if [ -z "$ext" ]; then
			echo '잘못된 확장자입니다.' >&2
			exit
		fi
	}

	#저장될 파일이 이미 존재하는지 검사
	if [ -e "$2" ]; then
		echo '이미 해당 위치에 파일이 존재하므로, 새로운 이름을 지정합니다.' >&2
		target=$(dupev_name -p "$(dirname -- "$2")" -- "$(basename "$2")")
		echo "NEWNAME : $target" >&2
	else
		target=$2
	fi
}

:<<\COMMENT
#mencoder를 이용한 변환
{
	code(){
		mencoder "$source" -o "$target" -oac copy "$@"
	}

	case "$ext" in
	mp4)
		code -ovc lavc -lavcopts vcodec=mpeg1video -of mpeg
		;;
	*)
		code
		;;
	esac
}
COMMENT

#ffmpeg를 이용한 변환
{
	code(){
		ffmpeg -i "$source" "$@" -sameq -acodec copy -y -- "$target"
		# -ar 22050  -pass 2
	}

	case "$ext" in
	ogv)
		code -f ogg
		;;
	mp4)
		code -f mp4 -vcodec libx264 -flags +aic+mv4 || code -f mp4 -vcodec mpeg4 -flags +aic+mv4 || code -f mp4
		;;
	*)
		code
		;;
	esac
}

exit