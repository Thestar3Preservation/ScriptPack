#!/bin/bash
#이 스크립트는 '보존 작업 중'이란 폴더에 든 문서파일을 recoll에서 검색가능한 문서로 변환시키는 것을 목적으로 합니다. 이 스크립트의 경우, 중복 문서를 파악하여 처리할 필요가 없으므로, 단순히 모든 파일을 하나씩 확장자를 분석하고 분류하여 처리하는 방식을 취한다.
source ~/.bash_profile
LOAD_USER_FUNTION

help(){
	cat <<-EOF
		사용법 : $(basename -- "$0") [옵션] [대상 디렉토리]
		대상 디렉토리 이하 모든 문서를 지정된 규칙에 따라 검색 가능한 문서로 변환합니다. 검색 불가능한 문서는 link폴더에 링크시켜 두고, 오류가 발생하며 오류 내역을 사용자에게 보고합니다.

		옵션 :
		      -d               유투브 동영상 태그를 발견하면, 동영상을 다운로드하여 내장 동영상으로 변환합니다(지원 확장자 : maff). Firefox의 모질라 압축 포멧 확장기능이 유투브 동영상을 다운로드 하지 못하는 것을 보완합니다(일부 동영상은 누락될수 있습니다. 사용후 전후 확인을 해주세요).
		      -n               작업하는 maff파일의 html파일에 존재하는 드래그 방지 태그를 제거합니다.
		      -g               작업 진행과정이나 결과를 GUI로 표현합니다.
		      -b               원본 파일을 백업하지 않습니다.
		      -c               확장자를 예쁘게 수정합니다.
		                       ex) .html.maff -> .maff
		      -l               링크 작업을 수행하지 않게 합니다.
		      -p               작업 결과와 오류 내역을 보고하지 않습니다.
		      -h, --help       도움말을 표시하고 종료합니다.
		      -v, -version     버전 정보를 표시하고 종료합니다.
	EOF
}

version(){
	cat <<-EOF
		문서를 검색가능한 문서로 변환시키기

		3.2 html문서의 charset 속성값을 수정하는 코드가 부적절한 범위로 charset을 찾아내는 문제를 해결.
		3.1 html문서의 charset 속성값을 수정하는 코드를 MAFF파일에 대해 작업할때와, 그렇지 않을 경우를 나누어 작업하도록 수정하여, 작업 속도를 향상시킴.
		3.0 html문서에 charset이 존재하지 않는 경우 charset을 표현하는 태그를 삽입하도록 수정.
		2.9 link폴더에 문서가 복사되지 않던 문제해결.
		 	진행표시바를 올바르게 표현하도록 수정함.
		 	진행표시바가 작업 완료후 닫기지 않던 문제 해결.
		2.8 로그 파일이 저장되는 위치를 미리 설정하도록 변경함.
		 	로그를 생성하는 형식을 간결하게 수정.
		2.7 비디오를 video태그가 아닌 embed태그로 mplayer로 재생하도록 함.
		2.6 avi, hidden을 검색제외 확장자에 추가.
		 	flash로된 유투브 동영상도 다운로드 가능하도록 수정.
		2.5 드래그 방지 코드 무력화 기능 추가.
		2.4 코드를 블럭화.
		 	동영상 처리 옵션이 켜진상태에서 동영상이 포함된 maff파일의 index.html파일이 날라가던 문제 해결.
		2.3 동영상 다운로드 기능을 maff 확장자에만 한정함. Firefox에서 다운로드되지 않고, webarchive에서 다운로드된 경우에는 이미 동영상 저장 기능이 포함되어 있기 떄문. 또한, Firefox의 모질라 압축 포멧 확장 프로그램은 wget으로 실제 html소스를 다운로드 한것과 내용이 다름. Firefox에서 현재 표현중인 태그와 이미지등으로 구성되어 나타나기 때문에 유투브 태그 형식이 원본과 다름. 즉, webarchive에서 다운받은 것과 Firefox에서 다운받은 maff파일은 서로 다른 방식으로 처리해야 함. 그런 이유로 webarchive에서는 처리하지 않고, 오직 Firefox에서 다운받은 것만 처리하도록 함.
		2.2 youtube 동영상 태그가 발견되면, 해당 영상을 다운로드하여 내장 파일로 만드는 기능을 추가.
		2.1 병합 maff파일을 정상적으로 변환하지 못하던 문제 해결.
		2.0 비정상적인 maff파일이 존재할 경우, 작업진행 여부를 물음.
		1.9 GUI로 진행현황과 결과를 알리는 옵션 추가.
		1.8 백업 기능을 비활성화시키는 옵션을 추가.
		1.7 확장자가 존재하지 않을 경우의 처리패턴 추가.
		1.6 html문서의 charset이 수정되지 않던 문제 해결.
		1.5 maff파일 변환안되던 문제 해결
		1.4 확장자를 예쁘게 수정하는 옵션을 추가. .html.maff -> .maff 등으로...
		1.3 maff파일과 html파일을 변환할수 있게 함.
		1.2 작업 위치를 사용자가 설정할수 있도록 함.
		1.1 링크 작업과 보고서 보고를 하지 않게하는 옵션을 추가.
		1.0 버전, 도움말 페이지를 추가
	EOF
}

#옵션 인자 처리
while [[ $# > 0 ]]; do
	case "$1" in
	-h | --help)
		help
		exit
	;;
	-v | --version)
		version;
		exit
	;;
	-d)
		videoDown_o=y
	;;
	-n)
		DragAssent_o=y
	;;
	-g)
		gui_o=y
	;;
	-b)
		backup_o=n
	;;
	-c)
		changeext_o=y
	;;
	-p)
		report_o=n
	;;
	-l)
		link_o=n
	;;
	--)
		shift
		break
	;;
	*)
		break
	;;
	esac
	shift
done

#옵션 결과 처리
{
	[ $# = 0 ] && { help; exit; } #만약 아무런 인자도 없다면, 도움말을 호출합니다.
	[ -z "$gui_o" ] && gui_o=n
	[ -z "$DragAssent_o" ] && DragAssent_o=n
	[ -z "$videoDown_o" ] && videoDown_o=n
	[ -z "$changeext_o" ] && changeext_o=n #파일 확장자를 보기 좋게 변환하는 옵션이 지정되어 있지 않다면, 기본값으로 거짓을 줍니다.
	[ -z "$backup_o" ] && backup_o=y #백업을 할지에 대한 옵션이 지정되어 있지 않다면, 기본값으로 참을 줍니다.
	[ -z "$link_o" ] && link_o=y #링크 옵션에 대해 지정되어 있지 않다면, 기본값으로 참을 줍니다.
	[ -z "$report_o" ] && report_o=y #보고서 보고 옵션에 대해 지정되어 있지 않다면, 기본값으로 참을 줍니다.
	home=$(realpath -- "$1") #시작 위치는 언제나 작업 대상의 폴더 내여야 합니다. 예를 들어, a를 작업하기 위해선, 현재경로가 ~/a식으로 되어있어야 합니다.
}

#작업 기초 설정.
{
	cd "$home"
	ppid=$$
	echo "작업 위치 : $home"
	if [ -e link -o -e error.log ]; then
		notify-send --urgency=critical 'link 폴더와 error.log파일은 이 폴더에 존재하지 않아야 합니다.'
		echo 'link 폴더와 error.log파일은 이 폴더에 존재하지 않아야 합니다.' >&2
		exit 1
	fi
	[ $link_o = y ] && mkdir -p link/{hwp,mht,html,txt,doc}{,_f} 2>/dev/null #나중에 문서 파일들을 링크시켜 따로 처리할 것들을 저장할 공간을 생성합니다.
}

#만약, maff파일이 2kb이하이면, 그 파일은 저장이 완료되지 않은 비정상적인 파일이 가능성이 높습니다. 이 파일은 사전에 확인하여 처리하여 주세요.
if [ $report_o = y ] && mafflist=( $(find . -type f -size -2k -iname '*.maff') ) && [ -n "$(echo "$mafflist")" ]; then
	echo -e '\n>>2k이하의 크기를 가진 maff문서 목록<<'
	echo "${mafflist[*]}"
	if [ $gui_o = y ]; then
		zenity --list --title '문서 일괄 변환' --text '아래 문서들은 정상적으로 저장되지 않음이 의심되는 파일입니다.\n그래도 작업하시겠습니까?' --column '목록' "${mafflist[@]}" || exit
	else
		echo -ne '위 문서들은 정상적으로 저장되지 않음이 의심되는 파일입니다. \n그래도 작업하시겠습니까? (Y/N) : '
		read -n 1 -r
		grep -xi y <<<"$REPLY" || exit
	fi
	echo '그대로 작업합니다.'
fi

#임시공간을 생성하고, 변수에 등록함.
{
	tmp=/tmp/$(dupev_name -n -- /tmp/conver2mp)
	mkdir -- "$tmp"
	chmod 700 -- "$tmp"
}

#작업 진행 현황을 알림.
{
	filelist=$(find "$PWD" -type f)
	if [ $gui_o = y ]; then
		count=0
		filelist_max=$(wc -l <<<"$filelist")
		echo 0 > /tmp/.progress-$ppid
		while true; do
			sleep .05
			temp=$(</tmp/.progress-$ppid)
			if [ "$temp" = END ]; then
				echo 100
			else
				cal=$(echo "($temp/$filelist_max)*100" | bc --mathlib)
				cal=${cal%.*}
				if [ -z "$cal" ]; then
					echo 0
				elif [ $cal = 100 ]; then
					echo 99
				else
					echo $cal
				fi
			fi
		done | { if ! zenity --progress --auto-close --percentage=0 --title='일괄 문서 변환' --text='문서 변환 중...' --width 430; then
			pstree -p $ppid | grep -oP '(?<=\()[0-9]+(?=\))' | tac | xargs -I{} kill -9 {}
		#|| kill $$; } &
		fi; } &
	fi
}

#로그 파일이 저장되는 위치를 지정합니다.
if [ $report_o = y ]; then
	logSAVE=$home/link/error.log
	logSAVE2=$home/error.log
else
	logSAVE=/dev/null
	logSAVE2=/dev/null
fi

#확장자의 문서를 추후 변환할 목적으로 링크 디렉토리에 링크시킵니다. 그리고, 오류가 존재한다면, 오류 메세지를 따로 저장합니다.
if [ $link_o = y ]; then
	ln_doc(){
		local Path=$home/link/$1
		ln -s "$filepath" "$Path/$(dupev_name "$Path/$filefullname")" 2>> "$logSAVE"
	}
	cp_doc(){
		local Path=$home/link/$1_f
		cp -v "$filepath" "$Path/$(dupev_name "$Path/$filefullname")" 2>> "$logSAVE"
	}
else
	ln_doc(){ return; }
	cp_doc(){ return; }
fi

#에러 메시지를 처리합니다. 인자를 주면, 그것이 에러 메시지가 됩니다.
report_error(){
	{
		echo "작업 대상의 이름 : $filepath"
		echo "에러 메시지 : $*"
		echo
	} >> "$logSAVE2"
	echo "${COL_RED}ERROR : $*${COL_RESET}" >&2
}

#문서를 주어진 인자의 형식으로 변환시킵니다. 인자2는 변환대상이 될 대상의 확장자를 의미합니다.
convert_doc(){
	local count=0 success=n ext
	while true; do
		((++count>3)) && break
		unoconv --listener &>/dev/null &
		#unoconv는 해당 문서가 위치하는 곳에 변환된 파일을 위치시킵니다.
		if unoconv -f $1 -- "$filename.$2"; then
			success=y
			break
		fi
	done
	if [ $success = y ]; then
		if [ $backup_o = y ]; then
			trash-put -- "$filename.$2"
		else
			rm -- "$filename.$2"
		fi
	else
		report_error "converting doc : $2->$1으로의 형식변환에 문제가 생겼습니다."
		ext=$2
		ln_doc doc
		return 1
	fi
	return 0
}

#문서의 인코딩을 UTF-8로 변경시킵니다. 첫번째 인자는 변환이 실패했을 경우, 링크되는 위치를 지정합니다. 만약 이미 UTF-8로 되어있다면, 종료코드 2를 리턴합니다. 해독이 불가능하다면 종료코드 1을 리턴하며, 변환되었을 경우 종료코드 1을 리턴합니다.
convert_txt(){
	local encoding code
	encoding=$(nkf -g "$filepath")
	if [ $encoding = UTF-8 ]; then
		echo '이 문서는 이미 UTF-8로 인코딩되어 있습니다.'
		return 2
	else
		for encoding in UHC $encoding; do
			code=$(iconv -f $encoding -- "$filepath") && break
		done
		if [ $? != 0 ]; then
			report_error 'convert_txt : 이 문서는 해독불가능한 문서입니다.'
			ln_doc $1
			cp_doc $1
			return 1
		fi
		echo "이 문서는 $encoding에서 UTF-8로 변환되었습니다."
		if [ $backup_o = y ]; then
			trash-put -- "$filepath"
		else
			rm -- "$filepath"
		fi
		cat <<<"$code" > "$filepath"
		return 0
	fi
}

#지정된 디렉토리의 하위 모든 파일 마다
for filepath in $filelist; do
	if [ "$changeext_o" = y ] && grep -iE '\.+html?\.+maff$' <<<"$filepath"; then #문서의 확장자를 정리합니다.
		ch_filepath=$(dirname -- "$filepath")/$(dupev_name -- "$(sed -r 's/\.+html?\.+maff$/.maff/i' <<<"$filepath")")
		mv -v -- "$filepath" "$ch_filepath"
		filepath=$ch_filepath
	fi
	filefullname=$(basename -- "$filepath")
	fileext=$(ex_ext -- "$filepath")
	fileextLOW=$(tr [:upper:] [:lower:] <<<"$fileext")
	filename=$(ex_name "$filepath")
	echo $'\n'"작업 대상의 이름 : $filepath" #작업 위치를 알림.
	case "$fileextLOW" in
	#무시하는 경우
	exe|css|js|rdf|jpg|jpeg|png|gif|swf|desktop|pdf|cbz|sh|mp4|ico|avi|hidden|bmp|wma|odt)
		echo "$fileext 확장자는 처리 대상에서 제외되어 있습니다."
	;;
	#docx를 doc으로 변환하고, doc을 odt로 변환시킴. 그 뒤, odt가 아닌 모든 파일을 제거.
	docx)
		convert_doc doc $fileext && convert_doc odt doc
	;;
	#doc파일을 odt로 변환시킴. 나머지 모두 삭제.
	doc)
		convert_doc odt $fileext
	;;
	#hwp만 파일만 남기고, 나머지는 삭제시킴. hwp파일은 링크시켜 따로 처리함.
	hwp)
		ln_doc hwp
		cp_doc hwp
	;;
	#mht파일만 남기고 링크시킴. maff로 일괄변환
	mht)
		ln_doc mht
		cp_doc mht
	;;
	#htm, html문서를 남기고, 인코딩을 변경시킨다. 나머지는 삭제처리.
	html | htm)
		#문서의 인코딩을 UTF-8로 변경
		convert_txt html
		temp=$?

		if [ "$UPzip" = maff ]; then
			#html문서의 charset 속성값을 수정 : MAFF전용. 범용에 비해 작업이 간결함.
			if check=$(grep -iP 'charset\s*=\s*[a-z_0-9-]+' <"$filepath") && grep -ivP 'charset\s*=\s*UTF-8' <<<"$check"; then
				code=$(perl -0pe 'use encoding "utf8"; $/=undef; s/charset\s*=\s*[a-z_0-9-]+/charset=UTF-8/i' <"$filepath")
				if [ $backup_o = y ]; then
					trash-put -- "$filepath"
				else
					rm -- "$filepath"
				fi
				echo "$code" >"$filepath"
			fi
		else
			#html문서의 charset 속성값을 수정 : 범용
			if [ $temp != 1 ]; then
				code=$(<"$filepath")
				unset change
				if temp=$(grep -Ei -m1 'charset= *"? *[a-z_0-9-]+' <<<"$code"); then
					if grep -vFi 'charset= *"? *UTF-8' <<<"$temp"; then
						change=y
						code=$(perl -0pe 'use encoding "utf8"; s/charset= *("?) *[a-z_0-9-]+/charset=\1UTF-8/i' <<<"$code")
					fi
				else
					change=y
					if grep -iE -m1 '< *HEAD( +[^>]*)*>' <<<"$code"; then
						code=$(perl -0pe 'use encoding "utf8"; s#(< *HEAD( +[^>]*)*>)#\1 <META charset="utf-8" />#i' <<<"$code")
					elif grep -iE -m1 '< *HTML( +[^>]*)*>' <<<"$code"; then
						code=$(perl -0pe 'use encoding "utf8"; s#(< *HTML( +[^>]*)*>)#\1 <META charset="utf-8" />#i' <<<"$code")
					elif grep -iE -m1 '<! *DOCTYPE( +[^>]*)*>' <<<"$code"; then
						code=$(perl -0pe 'use encoding "utf8"; s#(<! *DOCTYPE( +[^>]*)*>)#\1 <META charset="utf-8" />#i' <<<"$code")
					else
						code='<META charset="utf-8" />'$'\n'$code
					fi
				fi
				if [ "$change" = y ]; then
					if [ $backup_o = y ]; then
						trash-put -- "$filepath"
					else
						rm -- "$filepath"
					fi
					echo "$code" > "$filepath"
				fi
			fi
		fi
	;;
	#txt파일만 남기고, 인코딩을 모두 UTF-8로 변환한다.
	txt)
		convert_txt txt
	;;
	cap)
		convert_txt txt
		dupev_mv "$filepath" "$(dirname "$filepath")/$filename.txt"
	;;
	maff | webarchive )
		unzip -- "$filepath" -d "$tmp"
		if [ $backup_o = y ]; then
			trash-put -- "$filepath"
		else
			rm -- "$filepath"
		fi
		cd -- "$tmp"
		eval "targetnames=( `ls -A --quoting-style=shell-always` )"
		for targetname in "${targetnames[@]}"; do
			[ -d "$targetname" ] || continue
			unset op DragAssent_o_temp videoDown_o_temp
			if [ $DragAssent_o != n ]; then
				DragAssent_o_temp=sub
				op+=( -n )
			fi
			if [ $videoDown_o != n ]; then
				videoDown_o_temp=sub
				op+=( -d )
			fi
			if grep -ixF maff <<<"$fileext"; then
				if [ -f "$targetname/index.rdf" ] && ! grep -Fi '<MAF:charset RDF:resource="UTF-8"/>' "$targetname/index.rdf"; then
					code=$(sed -r 's#(<MAF:charset RDF:resource=")[^"]+("/>)#\1UTF-8\2#i' "$targetname/index.rdf")
					cat <<<"$code" >"$targetname/index.rdf"
				fi
				UPzip=$fileextLOW DragAssent_o=$DragAssent_o_temp videoDown_o=$videoDown_o_temp convdoc2s -b -p -l -- "$targetname"
			else
				UPzip=$fileextLOW convdoc2s "${op[@]}" -b -p -l -- "$targetname"
			fi
		done
		zip -0r "$filepath" "${targetnames[@]}"
		rm -r -- .* *
		cd -- "$home"
	;;
	#존재하지 않는 패턴일 경우를 보고.
	*)
		if [ -n "$fileext" ]; then
			echo '이 확장자는 처리 대상에 존재하지 않는 새로운 확장자입니다.'
			[ $report_o = y ] && not_reported_ext+=$fileext$'\n'
		else
			echo '이 파일은 확장자를 가지지 않은 파일입니다. 이런 파일은 처리하지 않습니다.'
		fi
	;;
	esac
	[ $gui_o = y ] && echo $((++count)) > /tmp/.progress-$ppid
done

#문서 내에 존재하는 외부 참조 동영상을 로컬 디스크에 저장함
{
	cd -- "$home"
	if [ "$videoDown_o" = sub -a -f index.html -a -d index_files -a -f index.rdf ]; then
		for codefilepath in $(find . -type f -iname '*.html'); do
			grep -iE '/cache\.php(-[0-9]+)?\.html$' <<<"$codefilepath" && continue
			code=$(<"$codefilepath")
			filedir=$(dirname "$codefilepath")

			#HTML5 형식으로된 youtube동영상 추출
			for i in $(grep --text -zEio '< *iframe[^>]+src *= *"[^"]+\.html"[^>]+>[^>]+ */ *iframe *>' <<<"$code"); do
				link=$(grep -Eio 'src *= *"[^"]+"' <<<"$i" | sed -e 's/^src *= *"//' -e 's/"$//')
				grep -Fi -e html5player -e www-embed-player -e 'http://www.youtube.com/' "$filedir/$link" || continue
				uri=$(grep -m1 -iE '< *link[^>]+>' -- "$filedir/$link" | grep -iEo 'href *= *"http://www.youtube.com/[^"]+"' | sed -r -e 's/^[^"]+"//' -e 's/"$//')
				source=$(youtube-dl --get-title --get-filename "$uri") || continue
				rm -- "$filedir/$link"
				savedir=$(dirname -- "$filedir/$link")
				if [ "$savedir" = . ]; then
					savedir=index_files
					linkdir=../index_files
				else
					linkdir=../$(dirname -- "$link")
				fi
				savename=$(sed -n 2p <<<"$source" | dupev_name -i -p "$savedir")
				youtube-dl --no-part --output "$savedir/$savename" "$uri"
				temp="<div><p><a href=\"$(html_escape $uri)\" target=\"_blank\">$(head -n1 <<<"$source" | html_escape)</a></p><embed $(grep -iEo -m1 -e "width *= *\"?[0-9]+\"?" -e "height *= *\"?[0-9]+\"?" <<<"$i" | tr '\n' ' ') showcontrols=\"true\" showstatusbar=\"true\" autostart=\"false\" src=\"$(html_escape "$linkdir/$savename")\" type=\"application/x-mplayer2\"/></embed></div>"
				code=$(perl -0pe 'use encoding "utf8"; open(TEXT, "'<(echo "$temp")"\"); \$data = <TEXT>; s#$(g_quote "$i")#\$data#i" <<<"$code")
			done

			#SWF 형식으로된 youtube동영상 추출. : object
			{
				unset list
				tmpcode=$code
				while true; do
					i=$(grep --text -zPio '< *object[^>]+>[^\0]*?< */ *object *>' <<<"$tmpcode") || break
					list+=("$(perl -0pe 's#(< */ *object *>)[^\0]*$#\1#' <<<"$i")")
					tmpcode=$(perl -0pe 's#^[^\0]+?< */ *object *>([^\0]*)$#\1#' <<<"$i")
				done
				for((c=0; c<${#list[@]}; c++)); do
					i=${list[$c]}
					grep -Ei -e '<param value="[^.]+.swf" name="movie">' -e 'application/x-shockwave-flash' <<<"$i" || continue
					link=$(grep -Pio '(?<=src=")[^"]+?\.swf(?=")' <<<"$i" | head -n1 | html_unescape)
					swfdump "$filedir/$link" | grep -F 'com_google_youtube_application_SwfProxy' || continue
					uri="https://www.youtube.com/watch?v=$(ex_name "$link")"
					source=$(youtube-dl --get-title --get-filename "$uri") || continue
					rm -- "$filedir/$link"
					savedir=$(dirname -- "$filedir/$link")
					if [ "$savedir" = . ]; then
						savedir=index_files
						linkdir=../index_files
					else
						linkdir=../$(dirname -- "$link")
					fi
					savename=$(sed -n 2p <<<"$source" | dupev_name -i -p "$savedir")
					youtube-dl --no-part --output "$savedir/$savename" "$uri"
					temp="<div><p><a href=\"$(html_escape $uri)\" target=\"_blank\">$(head -n1 <<<"$source" | html_escape)</a></p><embed $(grep -iEo -m1 -e "width *= *\"?[0-9]+\"?" -e "height *= *\"?[0-9]+\"?" <<<"$i" | tr '\n' ' ') showcontrols=\"true\" showstatusbar=\"true\" autostart=\"false\" src=\"$(html_escape "$linkdir/$savename")\" type=\"application/x-mplayer2\"/></embed></div>"
					code=$(perl -0pe 'use encoding "utf8"; open(TEXT, "'<(echo "$temp")"\"); \$data = <TEXT>; s#$(g_quote "$i")#\$data#i" <<<"$code")
				done
			}

			#SWF 형식으로된 youtube동영상 추출. : embed
			for i in $(grep -Eio '<embed[^>]+src="[^.]+.swf"[^>]*>' <<<"$code"); do
				grep -Fi 'type="application/x-shockwave-flash"' <<<"$i" || continue
				link=$(grep -Pio '(?<=src=")[^"]+?\.swf(?=")' <<<"$i" | head -n1 | html_unescape)
				swfdump "$filedir/$link" | grep -F 'com_google_youtube_application_SwfProxy' || continue
				uri="https://www.youtube.com/watch?v=$(ex_name "$link")"
				source=$(youtube-dl --get-title --get-filename "$uri") || continue
				rm -- "$filedir/$link"
				savedir=$(dirname -- "$filedir/$link")
				if [ "$savedir" = . ]; then
					savedir=index_files
					linkdir=../index_files
				else
					linkdir=../$(dirname -- "$link")
				fi
				savename=$(sed -n 2p <<<"$source" | dupev_name -i -p "$savedir")
				youtube-dl --no-part --output "$savedir/$savename" "$uri"
				temp="<div><p><a href=\"$(html_escape $uri)\" target=\"_blank\">$(head -n1 <<<"$source" | html_escape)</a></p><embed $(grep -iEo -m1 -e "width *= *\"?[0-9]+\"?" -e "height *= *\"?[0-9]+\"?" <<<"$i" | tr '\n' ' ') showcontrols=\"true\" showstatusbar=\"true\" autostart=\"false\" src=\"$(html_escape "$linkdir/$savename")\" type=\"application/x-mplayer2\"/></embed></div>"
				code=$(perl -0pe 'use encoding "utf8"; open(TEXT, "'<(echo "$temp")"\"); \$data = <TEXT>; s#$(g_quote "$i")#\$data#i" <<<"$code")
			done

			cat <<< "$code" > "$codefilepath"
		done
	fi
}

#드래그 방지 태그를 제거.
{
	cd -- "$home"

	#일반 페이지인 경우
	for i in $(find . -type f -iname '*.html' -o -iname '*.htm'); do
		grep -F -e '-moz-user-select: none;' "$i" || continue
		code=$(sed 's#-moz-user-select: none;##g' "$i")
		cat <<<"$code" >"$i"
	done

	#네이버 인쇄 페이지의 경우
	if [ $DragAssent_o = sub -a -f index.rdf -a -f index.html ] && grep -Ei '"네이버 [^ ]+ :: 포스트 내용 Print"' index.rdf; then
		code=$(<index.html)
		perl -0pe 's#< *div +class *= *"?clickprevent"?.*?< */ *div *>##i' <<<"$code" >index.html
	fi
}

#작업 결과 보고 및 작업종료 처리
{
	[ $gui_o = y ] && echo END > /tmp/.progress-$ppid
	[ $report_o = y -a -z "$(<"$home/link/error.log")" ] && rm "$home/link/error.log" #ln 오류 내역이 내용이 존재하지 않을 경우 삭제처리
	[ $link_o = y ] && rmdir link/* link 2>/dev/null #만약, 링크된 것이 존재하지 않는 폴더가 존재한다면, 해당 빈 폴더는 삭제합니다.

	if [ $report_o = y ]; then
		[ $gui_o = y ] && notify-send '문서 일괄 변환이 끝났습니다.'
		#만약 보고되지 않은 확장자가 존재한다면 보고서를 작성함.
		[ -n "$not_reported_ext" ] && echo '등록되지 않은 확장자가 존재합니다!'$'\n'"$(sort -uf <<<"$not_reported_ext")" > "$home/not_reported_ext.log"
		#만약 오류 보고서가 존재한다면, 해당 보고서를 염.
		for error_path in "$home/link/error.log" "$home/error.log" "$home/not_reported_ext.log" "$home/link"; do
			[ -e "$error_path" ] && xdg-open "$error_path" &
		done
	fi

	rm -r -- "$tmp"
	exit
}