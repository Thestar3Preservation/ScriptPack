#!/usr/bin/env bash
# 반디집은 하나 초과의 인수를 넘겨주게 되면 해당 파일들을 압축시키는 화면이 나타난다.
# 우리가 바라는 것은 순차적인 처리이다. 한 작업이 끝나면 다음 작업이 이어지는 식의 작업이다.
# 그런데, 반디집으로 여러개의 파일을 한꺼번에 실행시켰을 경우 모두 각자 풀리기 시작한다.
# 이 스크립트는 각 파일을 순차적으로 전달해주는 역할을 한다.

#이 스크립트는 절대경로를 인식합니다. 파일은 그 파일이 위치한 곳에서 풀리게 됩니다. 거기다, 풀리는 방법도 알아서 처리해버립니다.
source ~/.bash_profile
#for param in "$@" -(can)-> for param
cd "$(dirname "$1")"
unset list
for param; do
	#list[$((++c))]=$(wine winepath -w "`realpath "$param"`")
	#list+=( "$(wine winepath -w "$(realpath "$param")")" )
	#[]가 포함되거나, 긴 경로의 경우 제대로 변환해주지 못하고 있어서, 수동으로 경로를 구하게 하였다. Z:에는 리눅스의 루트 디렉토리가 매핑되어 있다. 이런 이유로 어떤 경우에도 문제가 생길일은 없다.
	#list+=( "$(wine winepath -u "$(realpath -- "$param")" | sed -e  "s#^$HOME/.wine/dosdevices/##" -e 's#/#\\#g')" )
	#list+=( "Z:${param//\//\\}" ) #$(sed 's#/#\\#g' <<<"$param")" )
	list+=( "Z:$(realpath -- "$param" | sed 's#/#\\#g')" )
done
env WINEPREFIX=~/.wine wine 'C:\users\'$USER'\Local Settings\Application Data\Bandizip\Bandizip64.exe' /extract_autodest . "${list[@]}"
exit
