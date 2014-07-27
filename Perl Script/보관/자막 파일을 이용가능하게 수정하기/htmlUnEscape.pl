#!/usr/bin/perl

use Encode;
use CGI qw(unescapeHTML);

while ( <STDIN> ) {
	while ( /(&#[0-9]+);?/i ) {
		$a = unescapeHTML($1.";");
		Encode::_utf8_off( $a);
		$_ = $`.$a.$';
	}
	print $_;
}

use Encode; use CGI qw(unescapeHTML); while ( <STDIN> ) { while ( /(&#[0-9]+);?/i ) { $a = unescapeHTML($1.";"); Encode::_utf8_off( $a); $_ = $`.$a.$'; }; print $_; }