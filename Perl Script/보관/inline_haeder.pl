#!/usr/bin/perl
#헤더 파일의 선언을 함수 객체로 수정합니다.

# wstring str2wstr(const string &code);
# class utf8towchar { public: wchar_t operator () (const string &code, int i = 0, int &byte = nullreference_int); };

for ( <STDIN> ) {
	/^([^ ]+) ([^ (]+)([^;]+)/;
	$reutrntype = $1;
	$functionname = $2;
	$typedef = $3;
	print "class ".$functionname." { public: ".$reutrntype." operator () ".$typedef."; };\n";
}

exit;