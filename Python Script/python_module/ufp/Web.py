#!/usr/bin/env python
#-*- coding: utf-8 -*-

import commands;
import tempfile;
import tidylib;

def dequoteJsStr(string) :
	"""
	자바 스크립트를 위해 콰우팅된 문자열을 콰우팅 해제시킵니다.
	ex) abc\'asd\' -> abc'asd'
	"""
	REGEXS = (
		(ur'\\', u'\\'),
		(ur"\'", u"'"),
		(ur'\"', u'"'),
		(ur'\n', u'\n')
	);
	for before, after in REGEXS :
		string = string.replace(before, after);
	return string;

def convertHtmlToText(html) :
	"""
	html 문서를 텍스트로 바꿉니다. 외부 프로그램을 불러와 작업을 하기 때문에 속도가 상당히 느립니다.
	commands, tempfile에 의존.
	"""
	with tempfile.NamedTemporaryFile(suffix=u'.html') as temp :
		temp.write(html);
		cmd = u"w3m -cols 98304 -dump '{0}'".format(temp.name);
		text = commands.getstatusoutput(cmd)[1];
	return text;

def clearHtml(html, inputEncoding = u"utf8") :
	"""
	html 문서를 보다 규격화된 xhtml로 변환합니다.
	참조 : HTML Tidy 설정 옵션 빠른 참조 - http://tidy.sourceforge.net/docs/quickref.html
	참조 : Html Tidy에 관한 파이썬 인터페이스 pytidylib.moudule - http://countergram.com/open-source/pytidylib/docs/index.html#small-example-of-use
	"""
	tidyOptions = {
		"output-xhtml": True, #"output-xml" : True
		"quiet": True,
		"show-errors": 0,
		"force-output": True,
		"numeric-entities": True,
		"show-warnings": False,
		"input-encoding": inputEncoding,
		"output-encoding": "utf8",
		"indent": False,
		"tidy-mark": False,
		"wrap": 0
		};
	document, errors = tidylib.tidy_document(html, options = tidyOptions);
	return document;
