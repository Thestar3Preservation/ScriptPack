#!/usr/bin/env bash
#변환된 문서를 원래 문서와 대치합니다. link폴더의 상단에서 시작하여 주세요.
source ~/.bash_profile
LOAD_USER_FUNTION

#link폴더가 존재하는지 확인
if [ ! -d link ]; then
	notify-sned -i error -u critical 'link폴더가 존재하지 않습니다!'
	exit 1
fi

#link폴더 내에 작업 대상이 존재하는지 확인
if [ -z "$(ls link)" ]; then
	notify-sned -i error -u critical 'link폴더 내에 작업 대상이 존재하지 않습니다!'
	exit 1
fi

#문서를 짝맞춤하고 치환
for i in $(ls link | grep -v _); do #파일의 종류 마다
	mirror_ls=$(ls link/${i}_f) #작업 대상 목록을 메모리에 올림.
	for j in $(ls link/$i); do #해당 종류의 파일의 원본 링크 마다
		mirror_file=link/${i}_f/$(grep -ixE -e "$(ex_name "$j" | g_quote)\.[A-Z0-9]+" <<<"$mirror_ls") || continue #미러 파일의 파일명을 추출하고, 만약 원본 파일에 매칭되는 미러 파일이 존재하지 않으면 작업하지 않고 다음 파일로 넘어감.
		realpath=$(realpath "link/$i/$j") #실제 경로를 추출하고
		mirror_ext=$(ex_ext -- "$mirror_file")
		trash-put -- "$realpath" #대치될 원본 파일을 실제로 삭제처리.
		mv -- "$mirror_file" "$(sed -r "s/\.[A-Z0-9]+$/.$mirror_ext/i" <<<"$realpath")" #대치될 파일을 원본의 위치로 이동.
	done
	[ -z "$(ls link/${i}_f)" ] || trash-put link/${i}{,_f} #만약 대치파일 폴더가 비어있다면, 작업이 완료된 것으로 간주하고, 링크 파일과 대치파일 폴더를 삭제처리.
done

#작업 종료
{
	rmdir link 2>/dev/null #만약 link폴더가 비어있다면, 사용자가 더 이상 확인할 것이 존재하지 않다고 여기고 링크 폴더를 삭제처리.
	notify-send '링크된 문서들을 모두 대치하였습니다.' #작업 완료를 알림
	exit
}