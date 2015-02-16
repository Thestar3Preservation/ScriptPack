#!/usr/bin/env python
#-*- coding: utf-8 -*-

"""
책 정리하기.
xxx ~권, xxx ~화 따위로된 파일들을 정리합니다. 동일한 시리즈의 책들은 한 폴더에 저장시키고, 각 화, 권수의 자릿수를 기수 정렬시에서도 동일한 순서로 나열되도록 자릿수를 맞춥니다. 1, ..., 100권 -> 001, ..., 100권.

폴더 = 시리즈
최상위 레벨의 대상만 시리즈 분류.
레벨2의 대상에 대해서는 자릿수만 맞춰줌.

구성 : 시리즈 단위.확장자

목록에서 정규 표현식을 적용하여 타이틀을 분리해낸다. 이 타이틀이 2개 이상일 경우 해당 타이틀의 대상을 한 묶음으로 처리한다.
각 타이틀에서 단위 별로 작업한다. 단위 하나와 일치하는 대상을 따로 모와 자연수 정렬시키고, 값의 자릿수를 맞춘다.
"""

import imp
import os
GlobalEnv = imp.load_source('', os.path.expanduser('~/.GlobalEnv.py'))
import itertools
import re
import ufp
from ufp import printDebugMsg as debug

class CleanEbookDir:
	"""
	만약 대상에 대한 타이틀 폴더를 만들수 없다면, 해당 타이틀을 가진 레벨1에 위치한 파일들은 처리되지 않습니다.
	하나의 정규 표현식을 복잡하게 작성하지 않고, 발견된 패턴마다 명확한 규격의 정규표현을 작성하는게 좋을것 같다.
	
	* 이걸 정규표현식으로 작성.
	오프셋 0부터 매칭 시작.
	나머지 매칭을 제외한 최소 매칭. 그룹화
	공백 문자 존재해야함.
	단편 존재 가능
		존재시, 숫자는 오지 않음.
	특별편 존재 가능(단편, 특별편, 번외편)
		특별편 존재시 공백 존재 가능
		특별편 존재시, 뒤에 끝이 와도 좋음.
	숫자 (정수, 0.5화)
		앞에 특별편이 존재한다면 공백문자가 존재해야 함
	단위; 없을 수 있음.
	완결 표시 여부
		괄호로 묶여 있을 수 있음
			괄호로 묶이지 않는다면 앞에 오는 문자는 공백이여야 함
	번역 표시 여부
		괄호로 묶여있을수 있음
			괄호로 묶이지 않는다면 앞에 오는 문자는 공백이여야 함
	공백 또는 확장자 + 끝
	~~~~~~~~~~~
	숫자+확장자로 구성된 경우도 존재.
	"""
	_RE_WHOLE = re.compile(ur'^(.+?) ?([0-9]+)([화회권편부]?)\.([a-z0-9]+)$', re.UNICODE|re.IGNORECASE|re.DOTALL)
	_RE_TITLE = re.compile(ur'^(?P<title>.+?) (외전|단[편권]|특별[화회편]|번외편|[0-9]+(\.5)?([화회권편부])?(\.[a-z0-9]+$| ))', re.UNICODE|re.IGNORECASE|re.DOTALL)
	
	def _groupingTitle(self, filename):
		"""작업할 타이틀을 그룹핑."""
		buffer = self._RE_TITLE.search(filename)
		if buffer:
			return buffer.group('title')
		return None
		
	def _moveFileToTitleDir(self, path, files, titlePath):
		for file_ in files:
			#원본 경로 설정
			srcPath = os.path.join(path, file_)
			
			#저장 경로 설정
			buffer = os.path.join(titlePath, file_)
			destPath = ufp.generateUniqueName(buffer)
			
			#옮기기
			os.rename(srcPath, destPath)
	
	def _groupingUnit(self, filename):
		buffer = self._RE_WHOLE.search(filename)
		if buffer:
			buffer = buffer.group(3)
			if buffer:
				return buffer
			else:
				return 'DIGIT'
		return None
	
	def _packingToSameTitleFiles(self, path, files, dirs):
		for title, files in itertools.groupby(files, self._groupingTitle):
			#정규표현식에 일치되지 않는 그룹은 건너뜀.
			if not title:
				continue
			
			#자료형 변환
			files = list(files)
			
			#타이틀이 하나인 그룹은 무시
			if len(files) == 1 and not title in dirs:
				continue
			
			#타이틀 폴더 설정
			titlePath = os.path.join(path, title)
			if not os.path.isdir(titlePath):
				if os.path.islink(titlePath) or os.path.exists(titlePath):
					continue
				else:
					os.mkdir(titlePath)
			dirs += [title]
					
			#파일들을 타이틀 폴더로 이동
			self._moveFileToTitleDir(path, files, titlePath)
		return dirs
	
	def _setNumberLength(self, matchObj):
		title = matchObj.group(1)
		number = self._length % int(matchObj.group(2))
		unit = matchObj.group(3)
		ext = matchObj.group(4).lower()
		return u'{0} {1}{2}.{3}'.format(title, number, unit, ext)
	
	def _extractNumber(self, filename):
		buffer = self._RE_WHOLE.search(filename).group(2)
		return int(buffer)
	
	def _matcherNumberLength(self, dirname, values):
		for filename in values:
			convertedFilename = self._RE_WHOLE.sub(self._setNumberLength, filename)
			if convertedFilename == filename:
				continue
			dest = os.path.join(dirname, convertedFilename)
			if os.path.islink(dest) or os.path.exists(dest):
				continue
			src = os.path.join(dirname, filename)
			os.rename(src, dest)
	
	def _makeLengthFormat(self, values):
		buffer = map(self._extractNumber, values)
		buffer = max(buffer)
		buffer = unicode(buffer)
		buffer = len(buffer)
		return '%0{0}d'.format(buffer)
			
	def _matcherNumberLengthWork(self, dirs):
		for dir_ in dirs:
			#파일 목록 불러오기
			for dirname, x, files in os.walk(dir_):
				break
			
			#단위 별로 자릿수 맞추기.
			for unit, values in itertools.groupby(files, self._groupingUnit):
				if not unit:
					continue
				
				#처리 가능한 대상만을 목록으로 만들어 넘겨줌
				values = filter(lambda i: self._RE_WHOLE.search(i), values)
				if len(values) == 0:
					continue
				
				#수치 길이 파악
				if dirs[-1] == dirname:
					self._length = u'%d'
				else:
					self._length = self._makeLengthFormat(values)
				
				#자릿수 맞추기
				self._matcherNumberLength(dirname, values)
		
	def clean(self, path):
		#작업할 대상 목록 작성
		for dirname, dirs, files in os.walk(path):
			break

		#타이틀 폴더로 파일들을 묶기
		dirs = self._packingToSameTitleFiles(path, files, dirs)
		
		#자리수 맞추기 및 파일명 다듬기. 자연수 정렬된 목록의 순서와 기수 정렬된 목록의 순서를 일치시킴.
		dirs += [path]
		self._matcherNumberLengthWork(dirs)
		
def _main():
	CleanEbookDir().clean(u'.')
	sys.exit(0)

if __name__ == '__main__':
	import sys
	_main()
