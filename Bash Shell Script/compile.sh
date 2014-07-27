#!/bin/bash
source ~/.bash_profile
LOAD_USER_FUNTION

tip(){
	cat <<-EOF
		PCH(Pre-compiled Header : 미리 컴파일된 헤더파일) 만들기.
		 	g++ -x c++-header header.h -> header.h.gch
		 	컴파일 속도를 단축시킬수 있다. 컴파일러가 header.h를 포함시킬때, +.gch가 같은 위치에 존재하면, 이를 사용한다.

		L키워드는 UTF-16LE방식으로 인코딩 함을 의미함. w가 붙는 wchar_t wcout등은 모두 UTF-16LE방식을 사용.

		|를 사용하여 여러개의 옵션을 넘겨주는 방식은 이진수에서 000100식으로 각 자리수가 1인지 아닌지 체크하는 방법으로 구현할수 있다.
		 	0x01 | 0x01 => 0x01이므로 중복 옵션이 온다 하여도 문제 없음.
		 	ex) 1은 001(2), 2는 010(2), 4는 100(2)이므로  7은 111(2)로, 1,2,4가 합성되었다고 볼수 있음.

		매크로 #progma once는 중복되는 헤더파일은 다시 불러오지 않게 한다.

		main함수의 argc는 argv의 수와 같다. 아무런 인자도 없더라도 argv[0]에는 언제나 호출된 파일명이 붙으므로 argc는 언제나 1 초과이다.
	EOF
	exit
}

help() {
	local programname=$(basename "$0")
	cat <<-EOF
		사용법 : $programname [옵션] [컴파일 대상]
		  또는 : $programname [옵션]
		지정된 대상을 컴파일합니다. 대상이 지정되지 않았을 경우, 디렉토리 내에 존재하는 모든 c++ 소스파일을 대상으로 작업합니다. 만약 폴더에 make 스크립트가 존재한다면, make 스크립트를 불러옵니다.

		옵션에 인자를 줄 경우, -[짧은옵션][인자]형식으로 붙여작성해야 합니다.
		옵션 :
		 -d, --debug           디버깅 모드로 컴파일을 수행합니다.
		 -l, --library         유저 라이브러리에 대한 PCH(Pre-compiled Header)화를 수행
		                       합니다.
		 -t, --test            소스 코드에 문제가 없는지 검사합니다(목적파일을 생성하지
		                       않습니다).
		 -s, --strip           컴파일 된 파일에 strip를 적용합니다.
		     --tip             컴파일에 관련된 도움말을 불러옵니다.
		 -e, --edit            스크립트를 편집기에 불러옵니다.
		 -n, --no-makefile     make 스크립트를 사용하지 않습니다.
		 -o, --exoption 옵션   컴파일에 필요한 추가 옵션을 전달합니다.
		 -i, --install 경로    컴파일된 파일을 경로로 복사하고, strip시키고, 단축경로에
		                       링크시킵니다. 경로의 시작점은 사용자 정의 설치공간입니다
		                       . ex) ./function
		 --                    이 인자 이후의 인자는 옵션 분석을 하지 않습니다.
		 -h, --help            이 페이지를 보여주고 프로그램을 종료합니다.

	EOF
	exit
}

CheckOP() { [[ ${!1} == $TRUE ]]; }

error(){ echo "${COL_RED}ERROR! $1$COL_RESET" >&2; }

home=$PWD
InstallPath=$PATH_SHELLSCRIPT
HeaderPath=$PATH_SOURCECODE/function
LibraryPath=$PATH_SHARELIBRARY

TRUE=1
FALSE=0

OP_library=$FALSE
OP_test=$FALSE
OP_strip=$FALSE
OP_install=$FALSE
OP_make=$TRUE
OP_debug=$FALSE

Macro_Debug='__DebugMode_c122ce555358a8dffef53c72ec834f515'

temp=$(getopt -o lhsnti::o:ed -l debug,edit,library,exoption:,test,tip,no-makefile,strip,help,install:: -- "$@") || exit 1
eval "OP=( $temp )"
set -- "${OP[@]}"
while [[ $# > 0 ]]; do
	case "$1" in
	-d|--debug)
		OP_debug=$TRUE
		;;
	-e|--edit)
		xdg-open "$0" &> /dev/null &
		exit
		;;
	--tip)
		tip
		;;
	-n|--no-makefile)
		OP_make=$FALSE
		;;
	-t|--test)
		OP_test=$TRUE
		;;
	-l|--library)
		OP_library=$TRUE
		;;
	-s|--strip)
		OP_strip=$TRUE
		;;
	-o|--exoption)
		IFS=$' \n\t' eval "OP_exoption=( $2 )"
		shift
		;;
	-i|--install)
		OP_install=$TRUE
		InstallPath+=/$2
		shift
		;;
    -h|--help)
		help
		;;
    (--)
		shift;
		break;;
    (-*)
		error "$0: 오류 - 알수 없는 옵션 $1"
		exit 1
		;;
    (*)
		break
		;;
	esac
	shift
done

if CheckOP OP_library; then
	echo '사용자 라이브러리의 PCH를 작성합니다...'
# 	if CheckOP OP_debug; then
# 		g++ -O0 -D"$Macro_Debug" -std=c++0x -x c++-header "$HeaderPath/function/UserFunctionPack.hpp" || exit 1
# 	else
	"$HeaderPath/function/make"
# 		g++ -O3 -std=c++0x -x c++-header "$HeaderPath/function/UserFunctionPack.hpp" || exit 1
# 	fi
fi

if CheckOP OP_install; then
	func(){
		install -m 755 -s "./$name" "$InstallPath"
		ln -sf "$InstallPath/$name" "$PATH_BIN"
		ln -sf "$PATH_BIN/$name" "$PATH_RUNLINK"
		rm "./$name"
	}
elif CheckOP OP_strip; then
	func(){ strip -- "$name"; }
else
	func(){ return; }
fi

if CheckOP OP_debug; then
	OP_preseting_F(){ OP_preseting=( -O0 -D"$Macro_Debug" -Wcpp -g -o "./$name" ); }
elif CheckOP OP_test; then
	OP_preseting_F(){ return; }
	OP_preseting=( -O0 -o /dev/null )
	func(){ return; }
else
	OP_preseting_F(){ OP_preseting=( -O3 -o "./$name" ); }
fi

if [ $# == 0 ]; then
	CheckOP OP_make && [ -f make ] && exec ./make
	eval "ls=( $(ls *.cpp --quoting-style=shell-always 2>/dev/null) )"
else
	ls=( "$@" )
fi

RETURNCODE=0
for file in "${ls[@]}"; do
	echo "$file을 컴파일합니다..."
	name=$(ex_name "$file");
	OP_preseting_F
	if ! g++ "${OP_preseting[@]}" -std=c++0x -L"$LibraryPath" -I"$HeaderPath" "./$file" -lUserFunctionPack -lpugixml -lboost_system -ltidy -lboost_filesystem -lcrypto -lssl -lpcrecpp -lpcre++ -licuuc -licui18n "${OP_exoption[@]}"; then
		RETURNCODE=1
		continue
	fi
	func
done

exit $RETURNCODE