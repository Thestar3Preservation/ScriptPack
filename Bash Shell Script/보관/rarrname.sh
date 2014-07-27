#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION
#rar rn이 정상적으로 이름을 치환해주지 않으므로, 단순히 풀기 위한 변환만을 수행한뒤, 압축이 해제된뒤의 파일명을 원래대로 고쳐주는게 가장 좋을 것 같다.

#윈도우에서 생성된 폴더 트리라도, 모든 /를 구분자로 삼음.
#애초에 모든 파일의 인코딩을 확인해서 변경해야 하므로, 무엇을 구분자로 삼느냐는 중요하지 않음.
#어떤 경우, 폴더와 파일의 인코딩이 다를 경우도 있을수 있으나, 어쨋거나 우리가 압축해제할 압축파일은 윈도우에서 만들어진것이므로, 폴더도 윈도우 인코딩일 것이다. 라고 가정함.
#어차피 인코딩은 모두 같을테니, 한꺼번에 확인해서 변환함.

target=$1
report_error() {
	echo $'\n'"TARGET : $path/$target"$'\n'"*$1" | tee -a $error
	notify-send -i error "`basename "$0"`" "대상 : $target\n$1"
}
target_file=$(dupev_name -p . -- ".$target.$$")
cp "$target" "$target_file"
list=$(rar vb "$target_file")
encoding=$(nkf -g <<<"$list")
[ $encoding = BINARY ] && unset encoding

if ! [ $encoding = UTF-8 ]; then
	#압축 파일 내 파일명을 변환하는 작업을 하지 않고, 곧 바로 압축을 해제함.

	for encoding in UHC JOHAB UTF-8 $encoding; do
		converting_list=$(iconv -f $encoding -t UTF-8 <<<"$list") && break
	done

	[ $encoding = UTF-8 ] && #이 경우에도 압축 파일 내 파일명을 변환하는 작업을 하지 않고, 곧 바로 압축을 해제함.

	if [ $? != 0 ]; then
		report_error '이 파일은 처리불가능한 인코딩을 포함하고 있습니다. 작업을 중단합니다.'
		break
	fi

	count=0
	#이 경우 문제가 있음. 예를 들어 경로 폴더가 변환되기 전에, 경로폴더+파일 식으로 된 경우, 파일은 정상적으로 파일을 변환시키지 않을 것이다. 그런데, 그럴일은 없을 것이다. 만약 정렬이 된다고 한다면, 파일은 무조건, 더 이름이 짧은 쪽이 같은 이름의 더 긴 이름 보다 상위에 위치하게 되기 때문이다.
	for original_name in $list; do
		rar rn "$target_file" "$original_name" "$(sed $((++count))p <<<"$converting_list")"
	done

fi

unrar x -p- "$target_file" "$(ex_name "$target_file" | dupev_name -p .)"
case $((code=$?)) in
	0)
		echo '*압축파일을 성공적으로 압축해제하였습니다.';;
	3)
		report_error '파일 일부에 암호가 걸려있습니다. 집합 명령 제작자는 이 파일을 시스템에서 제외할것을 명령합니다.'
		rm -r "$savename"
		trash-put "$target"
		#continue;;
	;;
	10|126)
		report_error '이 파일은 RAR압축파일이 아닙니다. 집합 명령 제작자는 이 파일을 시스템에서 제외할것을 명령합니다.'
		#rm -r "$savename"
		#trash-put "$target"
		#continue;;
	;;
	*)
		report_error "압축해제 중 해결할수 없는 오류 $code을 만나 작업이 중단됩니다."
		rm -r "$savename"
		#continue;;
	;;
esac

#rm "$target_file"

exit