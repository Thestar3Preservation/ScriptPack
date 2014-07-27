#!/usr/bin/env bash
#'인자1'을 '인자2'칸 만큼씩 나누어 출력합니다.
source ~/.bash_profile
LOAD_USER_FUNTION
code=$1
if [ -z "$code" ]; then
	echo "값을 필요로 합니다." >&2
	exit
fi
col=${2:-$(tput cols)}
# ((max=$(wc -m <<<"$1")-1))
len=0
# for((i=0; i<max; i++)); do
for((;;)); do
	IFS=$'\0' read -N1 -r -d $'\0' c || break
	clen=$(wc -L <<<"$c")
	((len+=clen))
	if ((len==col)); then
		len=0
		temp+=$c$'\n';
	elif ((len>col)); then
		((len=clen))
		temp+=$'\n'$c;
	else
		temp+=$c;
	fi
done <<<"$code"
echo -n "$temp";
exit