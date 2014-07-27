#!/home/user/Home/.usersys/bashscriptrecode
IFS=$'\n'
cmd=$(zenity --entry \
  --title "$(basename "$0")" \
  --entry-text "rename -v 's///' "'"$t"' \
  --text '명령어를 입력해 주세요. 대상은 "$t"으로 지정됩니다.
선택된 대상이 없으면, 전체의 각 요소마다 적용됩니다.
~를 커맨드의 선두에 입력하면 타겟지정이 무효화됩니다.' || exit)
echo "$cmd"
if echo -e "$cmd" | grep '^~'; then
	cmd=$(echo "$cmd" | sed 's/~//')
	echo "선택범위 : 전부"
	$cmd
else
	if [ "$*" ]; then
		for t in $(echo "$*" | sed 's/^.*\///'); do
			echo "작업대상 : $t"
			$cmd
		done
	else
		for t in $(ls); do
			echo "작업대상 : $t"
			$cmd
		done
	fi
fi
exit
