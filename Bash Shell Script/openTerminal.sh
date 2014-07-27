#!/bin/bash
#대상을 터미널에서 실행시킵니다. 그리고, 모든 작업이 수행된 뒤 창 닫기 여부를 사용자로 부터 입력 받습니다.
#대상은 대상이 가리키는 위치에서 실행됩니다.

source ~/.bash_profile
LOAD_USER_FUNTION

FilePath=$1
shift

Cwd=$(dirname -- "$FilePath")
cd -- "$Cwd"

Title="Terminal - $(basename -- "$FilePath")"
Script="source ~/.bash_profile
LOAD_USER_FUNTION
$(s_quote "$FilePath" "$@")
pause '
작업이 완료되었습니다.
아무 키나 눌러 창을 닫습니다.'
exit"

mate-terminal --title="$Title" -x bash -c "$Script"

exit