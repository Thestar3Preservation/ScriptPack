#!/usr/bin/env perl
use strict; use warnings;
use Cwd;

#사이트의 최초 주소. ex)http://www.naver.com/. 여기에는 http:~~/main.html따위가 존재해선 안된다.
$siteuri=$uri

#작업중인 대상의 호스트 주소 부분이 될 폴더 최상단. <-작업중인 최상단이 http://www.naver.com/으로 상징화된다.
#$topdir=

#@{[getcwd]}
#찾아내는 폴더의 최상단 경로는 작업된 폴더의 최상단 영역이라 한다. 따라서,
foreach $target (`find . -type f -iname '*.htm' -iname '*.html' ! -path './document_redirection.html`){

	#현재 작업중인 폴더 경로
	dir=`dirname "$target"`

	#찾아낸 html문서 파일을 열어두고. 그 파일에서 $siteuri를 찾아낸다.
	if (open(FILE, $target)){

		#파일을 한 줄씪 읽어 온다.
		while (<>) {

			#상대경로로 변환할 uri가 존재하는지 검사하고, 존재하는 동안 반복문을 수행
			while (/\"$siteuri\/?[^\/]*\"/) {


				#매칭된 패턴에서 앞의 "과 이어지는 siteuri를 제거한다.
				$& =~ s/^"$siteuri//;

				$tmp1=$_;
				#패턴의 뒤에서 부터, /이 연속되지 않으며 "이 존재하는 부분을 찾아온다.
				s/[^\/]+"$//;
				$tmp2=$_;
				$tmp1 =~ /[^\/]+"$/
				$target_name=$_;
				$_=$tmp2;

				#만약 아무런 /도 포함되어 있지 않다면, 반복문에서 빠져나감
				if ( grep( !/\// ) ){

					break;

				}

				s/[^/]+\//..\//g;
				$_=$`$_$target_name$';

			}

			#최총 처리된 결과를 출력
			print $_;

		}

	} else {

		#파일 읽기가 실패한 경우, 오류 메시지를 출력
		die "파일읽기 오류(File: $target): $!.\n";

	}

}