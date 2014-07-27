#!/usr/bin/env bash
source ~/.bash_profile
LOAD_USER_FUNTION
#perl로 만드는게 훨씬 나을것 같다. perl에서 선택한 대상의 앞뒤를 추출해내어 조작할수 있다.

#사이트의 최초 주소. ex)http://www.naver.com/. 여기에는 http:~~/main.html따위가 존재해선 안된다.
siteuri=

#작업중인 대상의 호스트 주소 부분이 될 폴더 최상단. <-작업중인 최상단이 http://www.naver.com/으로 상징화된다. ex)
topdir=

for dir in $(find . -type f -iname '*.htm' -iname '*.html'); do

	#현재 작업중인 폴더 경로
	dir=$(dirname "$dir")

	for uri in $(grep -Fni "$siteuri"); do

		#찾아내고 있는 줄에 해당 링크가 하나 이상 존재하는지 여부를 확인해야 함.

		#작업 중인 링크
		oruri=$(grep -oi "${siteuri}[^\"]*\"" <<<"$uri" | sed 's/"$//')

		for((i=0; i<$(wc -l <<<"$oruri"); i++)); do

			#http://www.naver.com/a/b/c.html을 /a/b/c.html로 보고, 대상을 /main.html로 보면, main.html은 ../../main.html에 위치했다. 즉, 주소 부분을 /을 포함하여 제외시키고, /부분을 세어 그 만큼의 ../로 만든뒤, 이 부분을 대상의 앞에 가져다 붙이면 된다.
			churi=$(sed -r -e "s#^$siteuri##" -e 's#[^/]+/#../#g' -e 's#/[^/]*$#/#' <<<"$uri")$(grep -o '[^/]*$' <<<"$uri")

			uri=$(sed "s#$uri#$oruri#" <<<"$oruri")

		done



	done

	#링크의 폴더식 경로와 현재 비교 대상 파일이 위치한 경로를 비교함. 만약, 같은 경로면, 주소를 생략하고, 해당 파일명만 쓰도록 하고, 만약 보다 상위에 존재하고 있다면, 상대경로를 계산해내어 상대경로로 표시한다.
	#주소를 어떻게 경로로 만드는가?
	#주소를 어떻게 경로와 비교하는가?
	#현재 위치와 주소를 어떻게 비교하여 상대경로로 만드는가?

	#http://www.naver.com/a/b/c.html을 a/b/c.html로 보고 이를 ../로 만들고, ../../부분만 남김.
	tmp1=$(sed -r -e "s#^$siteuri##" -e 's#[^/]+/#../#g' -e 's#/[^/]*$#/#' <<<"$uri")
	#이것을 main에다 붙여 ../../main.html로 만들어냄.
	churi=$tmp1$(grep -o '[^/]*$' <<<"$uri")

	#해당 부분을 치환시키면 됨.

done