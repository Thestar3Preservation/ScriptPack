#!/usr/bin/perl
#소스 파일을 인라인화합니다.
#string wstr2str(const wstring &code) {
#const Time Time::operator +(int s) const { // 멤버

for ( <STDIN> ) {
	/^([^ ]+) ([^ (]+)([^{]+)/;
	$reutrntype = $1;
	$functionname = $2;
	$typedef = $3;
	print "inline ".$reutrntype." ".$functionname."::operator ()".$typedef."{\n";
}

exit;