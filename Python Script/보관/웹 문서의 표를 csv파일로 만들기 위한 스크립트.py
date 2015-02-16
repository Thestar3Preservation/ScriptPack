#!/usr/bin/env python
#-*- coding: utf-8 -*-

"""
http://stackoverflow.com/questions/81584/what-ide-to-use-for-python
위 웹 문서의 표를 csv파일로 만들기 위한 스크립트.
"""

import sys;
import gtk

def main(argv):
	reload(sys);
	sys.setdefaultencoding('utf-8');
	
	text = gtk.clipboard_get().wait_for_text();
	with open('a.csv', 'w') as f :
		for a in text.split('\n') :
			for b in a.split('|') :
				b = b.strip()
				if b :
					f.write("'")
					f.write(b)
					f.write("'")
				f.write(',')
			f.write('\n')
	
	raise SystemExit();

main(sys.argv);
