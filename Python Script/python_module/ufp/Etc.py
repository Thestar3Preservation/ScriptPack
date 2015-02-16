#!/usr/bin/env python
#-*- coding: utf-8 -*-

from __future__ import print_function;
from trashcli.trash import TrashPutCmd
import io
import unicodedata

def feed(msg) :
	print(u'\r\033[K', end = '');
	print(msg, end = '');

def pause() :
	"""
	사용자의 입력을 대기합니다.
	"""
	print(u'[Enter]를 눌러 다음으로 진행합니다...', end = '');
	raw_input("");

def stripControlChar(string):
	"""제어문자를 제거합니다."""
	#return u"".join([i for i in string if 31 < ord(i) < 127])
	return u"".join(ch for ch in string if unicodedata.category(ch)[0]!="C")
	
def trashPut(target):
	"""
	trashcli 패키지의 trash-put 명령어.
	"""
	out = io.BytesIO()
	err = io.BytesIO()
	type(target)
	TrashPutCmd(out, err).run(['', '--', target.encode('utf8')])
	if err.getvalue():
		return False
	else:
		return True
	
