#!/usr/bin/env python
#-*- coding: utf-8 -*-

import sys;
sys.path.append('/home/user/Home/쉘스크립트/python_module')

from mkcbz import MakeCbz
from gi.repository import Notify
import ufp

def main(argv):
	reload(sys);
	sys.setdefaultencoding('utf-8');
	
	#타겟 준비
	targets = argv[1:]
	
	#알림 메시지 초기화
	Notify.init("make_comic_book")
	title = u'그림책 만들기'
	
	if not targets:
		msg = u'대상을 선택해 주세요!'
		Notify.Notification.new(title, msg, '').show()
		sys.exit(1)
	
	#변환
	for target in targets:
		try:
			cbz = MakeCbz().make(target, u'.')
		except Exception, err:
			Notify.Notification.new(title, unicode(err), '').show()
			raise SystemExit()
			
		ufp.trashPut(target)
		
		#메시지 작성
		msg = u"<b>%(target)s</b>를 <b>%(cbz)s</b>로 묶었습니다." % locals()
		
		#알림 메시지 보이기
		Notify.Notification.new(title, msg, '').show()
	
	sys.exit(0)

main(sys.argv);
