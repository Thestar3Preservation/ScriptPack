#!/bin/bash
#It can also mount single-tracks .BIN, .MDF, .IMG and .NRG.
#이상하게도 loop장치로 마운트할 경우, 노틸러스에서 해당 폴더가 열린뒤 상위폴더로 이동된다.

user=user
dir=/mnt

error(){
	echo "대상 : <b>$t</b>\n마운트에 실패하였습니다."
	notify-send -i error 'IMAGE MOUNT' "대상 : <b>$t</b>\n마운트에 실패하였습니다."
	rmdir "$dir/$name"
	continue
}

openfolder(){
	sudo -u $user xdg-open "$dir/$name"
	continue
}

echo "DIR : $PWD"
diskID=$(stat -c%d "$(realpath "$PWD")")
for t; do
	[ -f "$t" ] && grep -iEq '\.(bin|mdf|img|nrg|iso)$' <<<"$t" || continue
	echo "TARGET : $t"
	name=$diskID-$(ls -i -- "$t" | head -n1 | cut -d \  -f 1)
	[ -d "$dir/$name" ] && openfolder
	if ! fuseiso -p -- "$t" "$dir/$name" -o allow_other,ro,user=$user; then
		grep -i '\.iso$' <<<"$t" || error
		echo 'FUSE IMAGE MOUNT가 실패하였습니다. LOOP장치로 마운트를 시도합니다.'
		mkdir "$dir/$name"
		mount -o loop,ro,user,unhide -- "$t" "$dir/$name"
		[ $? != 0 -a $? != 32 ] && error
	fi
	openfolder
done

exit