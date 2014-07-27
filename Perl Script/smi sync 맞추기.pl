#!/usr/bin/perl

if ($#ARGV != 2) {
	print "자막 싱크 조절기 : 지정된 파일에서 내용을 읽어와 지정된 파일에 저장합니다.\n";
	print "인자 1 : 시작줄,끝줄(END) 또는 ALL(전부다)\n";
	print "인자 2 : +-time\n";
	print "인자 3 : 파일\n";
	print "ex) sync 4683,END -126900 g.smi\n";
	print "    g.smi파일에 대해 4683번째 줄 부터 끝까지의 sync를 -126900ms한다.\n";
	exit;
}

$file_name = $ARGV[2];
open(TEXT, $file_name);
$time = $ARGV[1];
$_ = $ARGV[0];
if ( /,/ ) {
	$startl = $`;
	if ( $' =~ /^END$/i ) {
		$endl = 0;
	} else {
		$endl = $';
	}
} elsif ( /^ALL$/i ) {
	$nocheck = 1;
} else {
	print "인자가 잘못되었습니다.\n";
	exit;
}

while ( <TEXT> ) {
	if ( $nocheck != 1 ) {
		if ( $endl != 0 && $. > $endl ) {
			$data = $data.$_;
			next;
		}
		if ( $startl > $. ) {
			$data = $data.$_;
			next;
		}
	}
	if ( /<Sync Start=(\d+)>/i ) {
		$_ = $`."<Sync Start=".($1+$time).">".$';
	}
	$data = $data.$_;
}
close (TEXT);

open (TEXT, ">$file_name");
print TEXT $data;
close (TEXT);