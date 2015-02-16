#!/usr/bin/env python
#-*- coding: utf-8 -*-

import imp
import os
GlobalEnv = imp.load_source('', os.path.expanduser('~/.GlobalEnv.py'))
import sys
from gi.repository import Notify
import ufp

def main():
	#타겟 준비
	targets = map(lambda x: x.decode('utf8'), sys.argv[1:])
	if len(targets) == 0:
		for root, dirs, files in os.walk(u'.'):
			targets = files + dirs
			break
	
	#알림 메시지 초기화
	Notify.init("trim_filenames_recursive")
	title = u'파일명 다듬기'
	
	#다듬기
	count = 0
	for target in targets:
		if not os.path.islink(target) and os.path.isdir(target):
			buffer = ufp.trimFilenames(target, recursive=True)
			count += len(buffer)
		else:
			if ufp.trimFilename(target):
				count += 1
			
	#메시지 보이기
	msg = '지정된 {0}개의 대상에 내포된 파일들 중 {1}개의 대상에 대하여 파일명 다듬기 작업이 수행되었습니다.'.format(len(targets), count)
	Notify.Notification.new(title, msg, '').show()
	
	sys.exit(0)

main()
