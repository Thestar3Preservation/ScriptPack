#!/usr/bin/env bash
#고급 bash shell 프로그래밍 문서와 같이, 해당 위치 내에서 연결된 문서들은 모두 해당 관련 내용 밖에 없는 문서를 구조 그대로 추출해서 저장.
source ~/.bash_profile
LOAD_USER_FUNTION

#사용법 페이지
usage () {
	cat <<-EOF
		wget 기반 웹 문서 추출기
		 이 스크립트는 해당 호스트에 존재하는 트리구조의 문서를 그대로 복사해옵니다. 가급적 웹문서에만 적용할것을 권장합니다. 웹문서가 아닌 사용자 인터페이스 따위가 포함된 카페나 블로그, 게시판등의 경우 작업 자체는 되나 수 많은 경로가 다른 중복문서를 생성시켜낼수 있습니다. 또한 수 많은 중복작업으로 인해 작업시간이 최소 수배이상 증가할수 있습니다. 그런 특이 타겟의 경우 해당 사이트에 최적화된 툴을 이용하여 복사해올것을 권장합니다.

		사용법: `basename "$0"` [이 스크립트의 옵션] [wget의 옵션] [URL]

		  -d             유투브 동영상 태그를 발견하면, 동영상을 다운로드하여 저장합니다. -nc는 기본적으로 비활성화되어, 해당 옵션이 포함되어 있더라도 문서는 자동으로 UTF-8 인코딩으로 수정됩니다. (일부 동영상은 누락될수 있습니다. 사용후 전후 확인을 해주세요.)
		  -hu useragent  유저 에이전트를 설정합니다. 정의되지 않은 입력은 그대로 유저 에이전트 옵션으로 사용됩니다. 선택항목은 대소문자를 구분하지 않습니다.
		                 LF : 리눅스-파이어폭스
		                 WE : 윈도우-익스플로어
		  -ext 확장자    확장자를 지정합니다. 기본값은 webarchive입니다.
		  -name 이름     저장될 이름을 지정합니다.
		  -lo            저장된 모든 문서와 상대경로로 참조하는 모든 페이지의 GET 전달을 삭제합니다. (시험적인 기능입니다.)
		  -co            쿠키를 사용하지 않고 다운로드 합니다(일부 웹사이트는 잦은 페이지 방문을 쿠키를 이용하여 차단합니다. 이 옵션은 그러한 제한을 회피합니다).
		  -nl            관계있는 링크만 따라가도록 하는 옵션을 해제합니다.
		  -nk            UTF-8이 아닌 문서의 타이틀은 모두 UHC인코딩으로 해석하는 옵션을 끕니다.
		  -np            부모 위치로 올라가지 않도록 하는 옵션을 해제합니다.
		  -nc            문서의 charset을 UTF-8로 변환하는 기능을 비활성화합니다.
		  -lc index      WEB이 아닌 local에서 대상을 작업합니다. url의 위치에는 webarchive로 담길 폴더의 위치를 적으며, index는 그 파일의 메인 페이지가 될 파일을 적습니다. 주의! 원본 파일이 손상되니, 백업후 시도하세요.
		  -ck 파일       쿠키를 불러옵니다.
		  -cl            클립보드의 내용에서 작업할 주소를 참조합니다.
		  -cu            문서의 모든 주소를 강제로 상대경로로 변환합니다. 저장된 문서의 웹페이지가 여전히 추출된 웹페이지의 호스트 주소를 따르고 있을 때만 사용하세요. (시험적인 기능입니다.)
		  --             이 스크립트의 옵션 처리의 끝을 나타냅니다. 이 이후에 존재하는 인자는 wget과 추출 대상 URI로 처리됩니다.
		  --help, -h     도움말을 표시한뒤 종료합니다.
		  --version, -v  버전을 표시한뒤 종료합니다.
	EOF
}

#버전 페이지
version () {
	cat <<-EOF
		wget 기반 웹 문서 추출기

		5.6 비정상적으로 작동되는 상대경로 변환 기능을 비활성화시킴. 옵션을 선택하더라도 작동하지 않음.
		5.5 저장될 파일명을 unix형태로 ascii형태로 저장하도록 하고, nocontrol는 적용하지 않게 함.
		5.4 쿠키를 사용하지 않고 다운로드 하는 옵션을 추가
		5.3 html문서의 get방식의 변수 전달을 모두 로컬 문서로 링크되도록 하는 기능을 추가.
		5.2 html문서의 charset 속성값을 수정하는 코드가 부적절한 범위로 charset을 찾아내는 문제를 해결.
		5.1 비디오를 video태그가 아닌 embed태그로 mplayer로 재생하도록 함.
		5.0 문서의 메인 페이지를 얻기 위해 백그라운드로 수행하는 작업을 포그그라운드로 수정.
		 	기존에 임시영역에 저장되던 메인 페이지의 위치는 변수에 저장되도록 수정됨.
		 	charset을 찾아내어 수정하는 부분을 보다 완벽하게 수정함.
		4.9 문서의 첫번째 파일을 찾아내지 못하던 오류 수정.
		4.8 임시 파일이 생성되는 지점을 /tmp로 수정.
		 	중계지점 형식 내용을 보다 완전하게 개선함.
		 	원본문서, 저장된 문서에 링크된 링크 파일에 중복 이름 회피를 적용함.
		4.7 인코딩 메타 정보 삽입 코드 개선.
		 	스크립트를 블럭화함.
		4.6 문서의 인코딩을 변환할때, 문서에 인코딩 정보가 기록되어 있지 않다면 UTF-8로 인코딩되었음을 알리는 코드를 삽입합니다.
		4.5	동영상 다운로드 기능을 사용하는 경우 강제적으로 '문서의 인코딩을 UTF-8로 변환하는 기능'을 활성화시킴.
		4.4	유투브 동영상이 내장된 것을 확인하면, 해당 동영상을 다운로드하여 로컬에 저장하는 기능을 추가함.
		4.3	document_redirection.html에 중복이름회피함수를 적용함.
		4.2	상대경로로 변환하는 기능을 추가함. htm, html을 확장자로 하는 파일의 모든 내용에서 url의 호스트 주소를 상대경로로 대치처리함.
		4.1	저장되는 파일명을 지정할수 있도록 함. 단, 중복회피는 자동으로 적용됨.
		4.0	로컬에서 작업할 경우, indexfile을 정상적으로 잡지 못하던 문제 해결.
		3.9	저장되는 확장자를 지정할수 있도록 함.
		3.8	local에 저장된 파일을 webarchive로 만들수 있게 함.
		 	스크립트 옵션을 종료 문자를 추가함.
		3.7	저장되는 문서의 charset을 모두 UTF-8로 변환시키도록 함.
		3.6	메인 페이지가 html로 끝나지 않을 경우 웹문서를 정상적으로 불러오지 못하던 문제 해결.
		3.5	클립보드에서 작업할 주소를 가져오는 기능을 추가.
		3.4	도움말과 버전 페이지에 접근하기 위한 단축 명령을 제공. -h, -v
		3.3	부모 위치로 올라가지 않도록 하게 하고, 이를 해제하는 옵션을 제공하는 기능을 추가.
		3.2	스크립트의 호환성을 상승시키고, 보다 관리가 쉬워지도록 사용자 환경변수 집합을 불러오게 함.
		3.1	maff문서 인덱스와 링크가 제대로 만들어지지 않았던 문제를 해결.
		3.0	웹문서의 파일명이 다중 바이트 및 광역 문자로 해석되게 하지 않게 위해  URI로 저장해옴.
		2.9	논리적 에러를 가진고 있는 조건식 코드를 수정함.
		2.8	일부 코드를 세련되게 바꿈.
		2.7	버전 페이지의 수정내역을 역순으로 출력하도록 함.
		2.6	작업을 완료하지 못할시 발생하던 find 무한 루프 문제를 해결.
		 	유저 에이전트를 숨길수 있는 단축옵션을 제공. 리눅스-파이어폭스,윈도우-익스플로러
		2.5	타이틀이 존재하지 않는 웹페이지의 파일명을 폴더 이름으로 삼지 않던 문제를 고침.
		2.4	파일명이 중복되지 않도록 해줍니다.
		2.3	한국문서가 아닐경우에 대한 처리 옵션을 추가. 이 옵션이 켜지면, UTF-8인가 아닌가를 검사하고 아닐경우 찾아낸 인코딩으로 타이틀의 인코딩을 변환시키게됨.
		2.2	기본으로 타이틀을 UTF-8이 아니면 UHC로 해석하도록 함.
		2.1	잘못된 형식의 인수가 주어졌을때, 도움말을 표시하도록 함.
		 	관계 있는 링크를 따라가기 옵션을 해제하는 옵션을 추가함.
		 	버전 페이지를 작성함.
		2.0	인수가 주어지지 않았을때, 도움말을 표시하도록 함.
		1.9	저장되는 파일명을 다듬도록 함.
		1.8	저장되는 파일명에만 사용불가능 문자를 대체하는 작업을 수행하도록 함.
		1.7	타이틀 제목을 가져와 저장 파일명으로 삼는 기능이 적용되지 않는 문제를 해결.
		1.6	이어서 작업하기 기능을 추가
		1.5	쿠키를 불러오는 짧은 축약어의 옵션을 추가함.
		1.4	사용자 설명서를 작성함.
		1.3	읽어오는 문서의 타이틀을 자동으로 찾아내어 저장명을 해당 타이틀명으로 자동으로 설정하게 함.
		1.2	maff파일로 묶도록 함.
		 	rdf파일을 올바르게 작성하도록 함.
		 	rdf파일에서 올바르게 원본 문서를 읽어오지 못하는 관계로 HTML 리다이렉션 기능으로 페이지를 자동으로 수정하도록 함.
		1.1	자동으로 저장된 메인 페이지와 원본 링크에 링크시키도록 함.
		1.0	옵션에 관계 없이 기본으로 쿠키를 유지하도록 함.
	EOF
}

#명령행 인자 처리
while [ $# -gt 0 ]; do
	case "$1" in
	--help | -h )
		usage
		exit 0
		;;
	--version | -v )
		version
		exit 0
		;;
	-hu )
		case "$2" in
			[lL][fF] )
				option=( "--user-agent=Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:24.0) Gecko/20100101 Firefox/24.0" "${option[@]}" );;
			[wW][eE] )
				option=( "--user-agent=Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1)" "${option[@]}" );;
			* )
				option=( "--user-agent=$2" "${option[@]}" );;
		esac
		shift
		;;
	-d )
		videoDown_o=y
		;;
	-co )
		o_co=y
		;;
	-lo )
		o_lo=y
		;;
	-nl )
		o_nl=y
		;;
	-cu )
		o_cu=y
		;;
	-name )
		saveName=$2
		shift
		;;
	-np )
		o_np=n
		;;
	-ext )
		ext=$2
		shift
		;;
	-nc )
		o_nc=y
		;;
	-nk )
		o_nk=y
		;;
	-lc )
		o_lc=y
		o_lc_d=$(realpath -- $2)
		o_lc_p=$PWD
		shift
		;;
	-ck )
		option=( "--load-cookies=$PWD/$2" "${option[@]}" )
		shift
		;;
	-cl )
		o_cl=y
		;;
	-- )
		shift
		break;;
	* )
		break;;
	esac
	shift
done

#옵션 처리
{
	option+=( "$@" ) #( "${option[@]}" "$@" )
	[ -z "$o_nc" -o "$videoDown_o" = y ] && o_nc=n
	if [ "$o_co" = y ]; then
		option=( "--no-cookies" "${option[@]}" )
	else
		option=( "--keep-session-cookies" "${option[@]}" )
	fi
	[ -n "$o_nl" ] || option=( "-L" "${option[@]}" )
	[ -n "$o_np" ] || option=( "-np" "${option[@]}" )
	[ -n "$ext" ] || ext=webarchive
	if [ -n "$o_cl" ]; then
		url=$(clip out)
		option+=( "$url" )
	else
		url=${!#}
	fi
	if [ -z "$o_lc" ] && grep -ivqE '^https?://' <<<"$url"; then #grep -iq -e '^-' <<<"$url"; then
		if [ "$0" = "$url" ]; then
			usage
			exit 1
		else
			echo '작업오류! 인자를 다시한번 점검해주세요.' >&2
			exit 1
		fi
	fi
}

#작업 위치 설정
{
	if [ -n "$o_lc" ]; then
		o_lc_d=$(sed "s#^$(realpath -- "$url" | g_quote)#.#i" <<<"$(realpath -- "$o_lc_d")")
		cd "$url"
		target=$(basename -- "$url")
	else
		target=$(dupev_name -p . -- target)
		mkdir -p "$target" #/DATA"
		cd "$target" #/DATA"
	fi
	home=$PWD
}

#문서 다운로드
[ -z "$o_lc" ] && wget -E -nv --content-disposition -l inf -p -k -r -nH -N -nc -t 3 -T 15 --local-encoding=UTF-8 --restrict-file-name=ascii,unix -e robots=off "${option[@]}" 2>&1 | tee -a /tmp/.$$.txt #-nd -R
temp=$(</tmp/.$$.txt)
rm /tmp/.$$.txt

#main.html로 보여질 문서 주소 얻기
if [ "$o_lc" = y ]; then
	doc_url=$o_lc_d
else
	#첫번째로 작업된 문서의 주소를 얻기
	doc_url=$(grep -Po -m1 '(?<=")[^"]+\.(html|htm)(?=")' <<<"$temp")
fi

#문서의 charset을 UTF-8로 변환처리 함.
if [ "$o_nc" = n ]; then
	for i in $(find . -type f -iname '*.htm' -o -iname '*.html'); do
		unset change
		encoding=$(nkf -g -- "$i")
		case $encoding in
		UTF-8)
			code=$(<"$i")
			;;
		*)
			for encoding in UHC $(grep -Pio 'charset= *"? *[a-z_0-9-]+' -- "$i" | grep -oiE '[a-z_0-9-]+$') $encoding; do
				code=$(iconv -f $encoding -- "$i") && break
			done
			if [ $? != 0 ]; then
				echo "문서 \"$PWD/$i\"의 변환에 실패함." >&2
				continue
			fi
			change=y
			;;
		esac
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
		[ "$change" = y ] && cat <<<"$code" > "$i"
	done
	cd "$home"
fi

#문서 내에 존재하는 외부 참조 동영상을 로컬 디스크에 저장함
if [ "$videoDown_o" = y ]; then
	for filepath in $(find . -type f -iname '*.htm' -o -iname '*.html'); do
		code=$(cat <"$filepath")
		for i in $(grep --text -zEio '< *iframe[^>]+src *= *\"?http://www\.youtube\.com/[^>]+>[^>]+ *iframe *>' <<<"$code"); do
			uri=$(grep -Eio 'src *= *"http://[^"]+"' <<<"$i" | sed -e 's/^src *= *"//' -e 's/"$//')
			source=$(youtube-dl --get-title --get-filename "$uri")
			savename=$(sed -n 2p <<<"$source" | dupev_name -i -p .)
			youtube-dl --no-part --output "$savename" "$uri"
			temp="<div><p><a herf=\"$(html_escape "$uri")\" target=\"_blank\">$(head -n1 <<<"$source" | html_escape)</a></p><embed $(grep -iEo -e "width *= *\"?[0-9]+\"?" -e "height *= *\"?[0-9]+\"?" <<<"$i" | tr '\n' ' ') showcontrols=\"true\" showstatusbar=\"true\" autostart=\"false\" src=\"../$savename\" type=\"application/x-mplayer2\"></embed></div>"
			code=$(perl -0pe 'use encoding "utf8"; open(TEXT, "'<(echo "$temp")\""); \$data = <TEXT>; s#$(g_quote "$i")#\$data#i" <<<"$code")
		done
		cat <<<"$code" >"$filepath"
	done
fi

#문서의 링크를 상대링크로 변환 : 이 기능은 미완성입니다. 작동에 오류가 존재합니다. 사용하려면 수정해야 합니다.
# if [ "$o_cu" = y ]; then
# 	cd "$home"
# 	temp=$(grep -oE '^[^/]+//[^/]+/' <<<"$url" | g_quote)
# 	for i in $(find . -type f -regextype posix-egrep -iregex '^.*\.(htm|html)$'); do
# 		path=$(grep -o / <<<"$i" | tr -d '\n' | sed -e 's#/#../#g' -e 's#^\.##' -e 's#/$##')
# 		content=$(sed "s#$temp#${path%/}/#gi" "$i")
# 		cat >"$i" <<<"$content"
# 	done
# fi

#GET방식의 전달을 파일명으로 포함한 웹문서를 로컬 페이지로 수정하고, 모든 페이지에서 상대경로로 링크된 문서를 로컬 페이지에서 찾도록 수정
if [ "$o_lo" = y ]; then
	cd "$home"
	for i in $(find . -type f \( -iname '*.html' -o -iname '*.htm' \) | grep -F -e '#' -e '?'); do
		dupev_mv -- "$i" "$(dirname "$i")/$(basename "$i" | sed 'y/?#/？＃/')"
	done
	for i in $(find . -type f \( -iname '*.html' -o -iname '*.htm' \)); do
		code=$(<"$i")
		for j in $(grep -Eio " href *= *['\"]?[^' \">]+['\">]?" <<<"$code"); do
			grep -Evi " href *= *['\"]?[a-z]+://" <<<"$j" | grep -F -e '#' -e '?' || continue
			if grep -F / <<<"$j"; then
				temp=$(grep -Eo "^[^=]+= *['\"]?" <<<"$j")$(dirname -- "$(sed "s/^[^=]+= *['\"]?//" <<<"$j")")/$(basename "$j" | sed 'y/?#/？＃/')
			else
				temp=$(sed 'y/?#/？＃/' <<<"$j")
			fi
			code=$(perl -p0e "use encoding \"utf8\"; open(TEXT, \""<(echo "$temp")\""); \$data = <TEXT>; s#$(g_quote "$j")#\$data#i" <<<"$code")
		done
		cat <<<"$code" >"$i"
	done
fi

#타이틀 명을 추출해내고, 인코딩을 고쳐 기억함.
{
	title=$(tr -d '\n\r' <"$doc_url") #GET "$url" | tr -d '\n\r')
	encoding=$(nkf -g <<<"$title")
	if [ "$encoding" != UTF-8 ]; then
		[ -n "$o_nk" ] || encoding=UHC
		title=$(iconv -f $encoding -t UTF-8 -c <<<"$title")
	fi
	title=$(sed -n -e 's/[<][/]title[>].*$//I' -e 's/^.*[<]title[>]//Ip' <<<"$title" | html_unescape)
}

#페이지로 바로가기를 위한 중계지점을 생성
{
	indexFileName=$(dupev_name ./document_redirection.html)
	echo '<!DOCTYPE HTML>'$'\n'"<HTML><BODY><SCRIPT>document.location.href='$doc_url';</SCRIPT></BODY></HTML>" > "$indexFileName"
}

#maff문서 정보 페이지 생성
{
	#Sat, 14 Jan 2012 20:20:35 +0900`\"/>
	cat >index.rdf <<EOF
<?xml version="1.0"?>
<RDF:RDF xmlns:MAF="http://maf.mozdev.org/metadata/rdf#"
		xmlns:NC="http://home.netscape.com/NC-rdf#"
		xmlns:RDF="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
<RDF:Description RDF:about="urn:root">
	<MAF:originalurl RDF:resource="$( [ -z "$o_lc" ] && echo -n "$url")"/>
	<MAF:title RDF:resource="$title"/>
	<MAF:archivetime RDF:resource="$(seten date '+%a,%e %b %Y %T %z')"/>
	<MAF:indexfilename RDF:resource="$indexFileName"/>
	<MAF:charset RDF:resource="UTF-8"/>
</RDF:Description>
</RDF:RDF>
EOF
}

#원본 문서와 저장된 문서의 메인 페이지로 이동하는 단축 링크를 만들기
{
	echo "[Desktop Entry]
Encoding=UTF-8
Name=원본문서에 링크
Type=Link
URL=$url
Icon=gnome-fs-bookmark" > "$(dupev_name ./link_original.desktop)"
	echo "[Desktop Entry]
Encoding=UTF-8
Name=저장된 문서에 링크
Type=Link
URL=$doc_url
Icon=gnome-fs-bookmark" > "$(dupev_name ./link_document.desktop)"
}

#압축파일로 묶기
{
	cd ..
	[ -z "$saveName" ] && saveName=$(echo "${title:-$target}" | wl_replace | trim_name)
	if [ "$o_lc" = y ]; then
		zipPath=$o_lc_p/$(dupev_name -p "$o_lc_p" -- "$saveName.$ext")
	else
		zipPath=$(dupev_name -p . -- "$saveName.$ext")
	fi
	zip -0Dr "$zipPath" "$target"
}

#나머지 처리
{
	if [ -n "$o_lc" ]; then
		trash-put -- "$target"
	else
		rm -rf -- "$target"
	fi
	exit
}