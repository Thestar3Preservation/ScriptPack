#!/usr/bin/env python
#-*- coding: utf-8 -*-

"""
각종 대상의 실행 경로를 설정한다.
실행 경로, 라이브러리 등록, 삭제 등...
"""

from __future__ import print_function

import imp
import ufp
import os.path
GlobalEnv = imp.load_source('', os.path.expanduser('~/.GlobalEnv.py'))

#import argparse

def run_add(path, alias):
	"""대상을 별칭만을 입력하여 불러올수 있도록 링크한다."""
	path = os.path.realpath(path)
	toPath = os.path.join(GlobalEnv.PATH_RUNLINK, alias)
	try:
		os.remove(toPath)
	except OSError, err:
		None #[Errno 2] No such file or directory
	os.symlink(path, toPath)
	
def run_del(alias):
	"""해당 별칭을 실행 명령어 목록으로 부터 제거한다."""
	path = os.path.join(GlobalEnv.PATH_RUNLINK, alias)
	try:
		os.remove(path)
	except OSError, err:
		None
	
def lib_add(path):
	"""공유 라이브러리(.so)를 사용자가 사용가능하도록 링크한다."""
	path = os.path.realpath(path)
	filename = os.path.basename(path)
	toPath = os.path.join(GlobalEnv.PATH_SHARELIBRARY, filename)
	os.symlink(path, toPath)
	
def _main():	
	def perr(*objs):
		print(*objs, file=sys.stderr)
		
	def printHelp():
		print('사용법 : {0} [명령]'.format(sys.argv[0]))
		print()
		print('명령 :')
		print('\thelp : 도움말을 불러옵니다.')
		print('\trun : 실행 관련 명령어')
		print('\t\tadd [대상] [별칭]')
		print('\t\t\t대상을 별칭만을 입력하여 불러올수 있도록 링크한다.')
		print('\t\tdel [별칭]')
		print('\t\t\t해당 별칭을 실행 명령어 목록으로 부터 제거한다.')
		print('\tlib : 라이브러리 관련 명령어')
		print('\t\tadd [대상]')
		print('\t\t\t공유 라이브러리(.so)를 사용자가 사용가능하도록 링크한다.')
		
	##명령행 인자 파싱
	#parser = argparse.ArgumentParser(description='각종 대상의 실행 경로를 설정한다. 실행 경로, 라이브러리 등록, 삭제 등...')
	#parser.add_argument("run", nargs=0, help='대상을 별칭만을 입력하여 불러올수 있도록 링크한다. 또는 해당 실행 별칭을 제거한다.')
	#parser.add_argument("lib", nargs=0, help='공유 라이브러리(.so)를 사용자가 사용가능하도록 링크한다.')
	#parser.add_argument('-v', "--verbose", type=bool, default=True, help='작업 결과를 상세히 출력합니다. (기본값: %(default)s)')
	#args = parser.parse_args()
	if len(sys.argv) == 1:
		printHelp()
		sys.exit(0)
	opt = sys.argv[1:]
	if opt[0] == 'run':
		if opt[1] == 'add':
			if len(opt) != 4:
				perr('대상과 별칭을 정확하게 지정해야 합니다.')
				sys.exit(1)
			path = opt[2]
			alias = opt[3]
			run_add(path, alias)
			print("`{0}'를 `{1}'라는 이름으로 단축 실행 목록에 추가했습니다. ".format(path, alias))
		elif opt[1] == 'del':
			if len(opt) != 3:
				perr('별칭을 정확히 지정하십시오.')
				sys.exit(1)
			target = opt[2]
			run_del(target)
			print("`{0}'를 실행 목록으로 부터 제거했습니다.".format(target))
		else:
			perr('run 명령에서 지원하는 명령은 add, del뿐입니다.')
			sys.exit(1)
	elif opt[0] == 'lib':
		if opt[1] == 'add':
			if len(opt) != 3:
				perr('대상을 정확하게 지정해야 합니다.')
				sys.exit(1)
			target = opt[2]
			lib_add(target)
			print("`{0}'를 공유 라이브러리 폴더에 추가했습니다.".format(target))
		else:
			perr('lib 명령에서 지원하는 명령은 add뿐입니다.')
			sys.exit(1)
	elif opt[0] == 'help':
		printHelp()
		sys.exit(0)
	else:
		perr('첫번째 인자는 run과 lib, help중 하나여야 합니다.')
		sys.exit(1)
	
	sys.exit(0)

if __name__ == '__main__':
	import sys
	_main();
