#!/usr/bin/env python
#-*- coding: utf-8 -*-

import imp
import os.path
GlobalEnv = imp.load_source('', os.path.expanduser('~/.GlobalEnv.py'))

import re
import ufp
import codecs

def makeDesktopLink(src, dest=u'.'):
	"""
	.desktop파일로 된 링크를 생성합니다. 폴더를 dest에 지정할 경우 자동으로 해당 경로에 적절한 이름을 가진 링크 파일을 생성시킵니다.
	생성된 파일의 경로를 반환합니다.
	"""
	#아이콘 설정
	if os.path.isdir(src):
		icon = 'folder'
	elif re.search(ur'\.html?$', src, re.UNICODE|re.IGNORECASE) :
		icon = 'gnome-fs-bookmark'
	else :
		icon = 'emblem-symbolic-link'
	
	#파일명
	filename = os.path.basename(src)
	
	#바로가기 경로 설정
	if os.path.isdir(dest):
		buffer = filename + u'.desktop'
		buffer = os.path.join(dest, buffer)
		dest = ufp.generateUniqueName(buffer)
	
	#바로가기 이름
	buffer = filename.replace('\\', r'\\')
	#buffer = buffer.maketrans('[:cntrl:]', ' ')
	buffer = ufp.stripControlChar(buffer)
	#buffer = re.sub('[:cntrl:]', ' ', buffer, flags=re.UNICODE)
	shortcutTitle = buffer + '의 바로가기'
	
	#file URL
	buffer = os.path.abspath(src)
	srcUrl = ufp.pathConvertToUrl(buffer)
	
	#desktop파일 작성
	with codecs.open(dest, 'w', encoding='utf8') as f:
		f.write('[Desktop Entry]\n')
		f.write('Encoding=UTF-8\n')
		f.write('Type=Link\n')
		f.write('Icon={0}\n'.format(icon))
		f.write('Name={0}\n'.format(shortcutTitle))
		f.write('URL={0}'.format(srcUrl))
	
	#생성된 바로가기 경로를 반환
	return dest
	
def _main():
	for a in sys.argv[1:]:
		a = a.decode('utf8')
		makeDesktopLink(a, u'.')
		
	sys.exit(0)

if __name__ == '__main__':
	import sys
	_main()
