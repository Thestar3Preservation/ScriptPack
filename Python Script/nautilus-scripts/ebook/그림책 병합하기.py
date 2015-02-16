#!/usr/bin/env python
#-*- coding: utf-8 -*-

import sys;
sys.path.append('/home/user/Home/쉘스크립트/python_module')

import mkcbz
import ufp
import re
from gi.repository import Notify

def main(argv):
	reload(sys);
	sys.setdefaultencoding('utf-8');
	
	#타겟 준비
	targets = map(lambda x: x.decode('utf8'), argv[1:])
	
	Notify.init("merge_comic_book")
	title = u'그림책 병합하기'
	
	if not targets:
		msg = u'대상을 선택해 주세요!'
		Notify.Notification.new(title, msg, '').show()
		sys.exit(1)
		
	#병합
	try:
		cbz = mkcbz.MakeCbz().merge(targets, u'.')
	except Exception, err:
		Notify.Notification.new(title, unicode(err), '').show()
		raise SystemExit()
	
	#지우기
	for target in targets:
		ufp.trashPut(target)
	
	#메시지 작성
	msg = unicode()
	for f in targets:
		msg += u"<b>%(f)s</b>와 " % locals()
	msg = re.sub(u'와 $', '', msg, flags=re.UNICODE)
	msg += u"를 <b>%(cbz)s</b>로 병합했습니다." % locals()
	
	#알림 메시지 보이기
	Notify.Notification.new(title, msg, '').show()
	
	raise SystemExit();

main(sys.argv);
