#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION

case "$1" in
help | h)
	cat <<-\EOF
		아무런 인자가 없으면 팁을 보여줍니다.
		help, h : 이 페이지를 보여줍니다.
		edit, e : TIP 내용을 수정할수 있도록 합니다.
	EOF
	exit;;
edit | e)
	xdg-open "$0" &>/dev/null &
	exit;;
esac

sed -r -e "s/^([a-z -_]+ : )/${COL_CYAN}\1${COL_RESET}/" <<EOF
apropos word : 주어진 단어 word와 연관된 모든 man 페이지의 요소들을 보여준다. 특히 프로그래머에게 유용하다.
tput : 터미널을 제어합니다. 이 프로그램을 사용하면 터미널에서의 문자 출력 위치를 바꾸거나 현재 줄의 위치, 창의 너비등을 알아낼수 있습니다. 그 밖의 터미널에 관련된 전반적인 조작을 수행할수 있습니다.
clear : 화면을 지워줍니다. 이 방법은 보이는 화면을 공백으로 채워줄뿐, 위로 스크롤하면 텍스트들이 여전히 남아있습니다.
dialog : 터미널에서 선택창, 리스트 박스 등을 표시할수 있다.
mogrify : 이미지 편집 명령어. 원본을 남긴다.
import : 대상을 추출한다. ex) 화면을 캡쳐할수 있다.
count : 사용자 스크립트 타이머. 일정 간격마다 수를 세어, 목표점에 도달되면 스크립트를 중단한다.
convert : 이미지 변환 명령어. 만약 원본의 출력이 지정되지 않는 명령인 경우 원본을 수정한다.
	다른 형식으로 변환한는 방법 convert a.pdf a.png
tac : 표준입력을 줄 끝 부터 표준출력으로 내보낸다. 즉, 텍스트를 거꾸로 내보냄.
xdg-open : 시스템에 지정된 형식대로 대상을 연다. 예를 들어, 폴더를 노틸러스로 여는게 아니라 돌핀으로 열라고 지정되어 있다면 돌핀으로 대상을 연다. 대상이 폴더던 파일이던 상관하지 않으며, uri형식으로된 경우도 인식한다. ex) xdg-open /home ex) file:///home ex) file:///%68%6f%6d%65
youtube-dl : 유투브 동영상을 다운로드한다.
uic : qt 디자이너로 만들어진 ui파일에 대한 c++ 헤더파일을 작성해준다.
strip : 실행 가능한 이진 프로그램들과 목적 파일들로부터 모든 디버깅과 상징 정보를 지운다. 이로 인하여 잠재적으로 더 나은 성과를 기대할 수 있으며 때로는 현저한 디스크 공간 사용 절약을 기대할 수도 있다.
	strip 대상; 대상은 strip된 상태로 바뀜.
install : cp 명령과 유사하나, install에 필요한 옵션이 존재함. 예를 들어, 복사 되어질 위치에 특정한 권한으로 기록한다던가, strip명령을 적용한다던가 하는 식...
file path : 대상경로에 존재하는 파일의 정보를 출력한다. 텍스트/바이너리/폴더... 크기, 음질, 생성일, 인코딩 등...
type command : command가 위치한 경로를 알려준다. 만약, 내장 함수라면, 그렇다고 알린다.
time command : command 수행에 사용된 시간을 측정해서 표준출력으로 보낸다. real은 실제로 총소요된 시간, user는 사용자 CPU사용 시간, sys는 커널이 사용한 시간을 의미한다. sys+user 시간이 실제로 작업에 할애된 시간이며, real 값에서 sys+user 값을 뺀 결과값은 다른 프로세서 처리에 할당된 시간이다.
dbus-monitor : 현재 전달되는 dbus 메시지를 표준출력으로 내보낸다.
git : github의 소스코드를 다운받거나 어쩌거나 할때 유용한 도구.
	ex) git clone 'git://github.com/Thestars3/arkzip'
history : 입력된 명령어의 기록을 보여준다.
EOF

exit