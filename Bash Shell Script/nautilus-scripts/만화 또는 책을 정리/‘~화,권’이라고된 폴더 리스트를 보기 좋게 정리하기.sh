#!/usr/bin/env bash_record
#1)현재 위치에 위치한 파일들을 타이틀 별로 디렉토리를 생성시켜 분류합니다. 2)디렉토리에 위치한 대상파일들의 자릿수를 계산하여, 해당 디렉토리 내 타겟이 된 대상의 이름을 자릿수에 맞춰 줍니다.
source ~/.bash_profile
LOAD_USER_FUNTION
home=$PWD #현재경로를 저장
exclusionlist=( cbz zip txt pdf ) #작업대상 확장자 목록
delimiter=( 화 권 ) #작업 대상 구분자 목록
#확장자 목록을 검색가능한 옵션으로 변환
for i in "${exclusionlist[@]}"; do exclusioncode+=( -o -iname "*.$i" ); done
unset exclusioncode[0]
#구분자목록을 사용가능한 정규표현식으로 변환
for i in "${delimiter[@]}"; do delimitercode+=`g_quote "$i"`\|; done
#확장자 목록을 사용 가능한 정규 표현식으로 변환
for i in "${exclusionlist[@]}"; do delimiterext+=\\.`g_quote "$i"`\|; done
#1)현재 위치에 위치한 파일들을 타이틀 별로 디렉토리를 생성시켜 분류합니다.
targetlist=$(ls | grep -Ei " [0-9]+(\.5)?($delimitercode)?($delimiterext)?$")
for title in $(sed -rn "s/ [0-9]+(\.5)?($delimitercode)?($delimiterext)$//p" <<<"$targetlist" | sort -uf); do
	worklist=$(grep -Exi "`g_quote "$title"` [0-9]+(\.5)?($delimitercode)?($delimiterext)?" <<<"$targetlist")
	if [ -d "$title" ] || [[ $(wc -l <<<"$worklist") > 1 ]]; then
		mkdir "$title"
		for target in $worklist; do
			dupev_mv -- "$target" "$title"
		done
	fi
done
#2)디렉토리에 위치한 대상파일들의 자릿수를 계산하여, 해당 디렉토리 내 타겟이 된 대상의 이름을 자릿수에 맞춰 줍니다.
#home=$PWD
for title in $(find . -mindepth 1 -maxdepth 2 \( "${exclusioncode[@]}" \) | xargs -I{} dirname {} | sort -uf); do
	cd "$home"
	cd "$title"
	targetlist=$(ls | grep -Ei " [0-9]+(\.5)?($delimitercode)?($delimiterext)?$")
	positonnumber=$(sed -r "s/^.* 0*([0-9]+)(\.5)?($delimitercode)?($delimiterext)?$/\1/" <<<"$targetlist" | sort -n | tail -n 1 | tr -d '\n' | wc -m) #| expr `cat` - 1)
	for target in $targetlist; do
		number=$(sed -r "s/^.* 0*([0-9]+)(\.5)?($delimitercode)?($delimiterext)?$/\1/" <<<"$target" | printf %0${positonnumber}d `cat`)
		dupev_mv -- "$target" "`sed -r "s/ 0*[0-9]+((\.5)?($delimitercode)?($delimiterext)?)$/ $number\1/" <<<"$target"`"
	done
done
exit