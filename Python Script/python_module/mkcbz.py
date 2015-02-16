#!/usr/bin/env python
#-*- coding: utf-8 -*-

import tempfile
import zipfile
import shutil
import re
import os
from xml.dom import minidom
from ufp import printDebugMsg as debug
from xml.etree import ElementTree
import ufp
from natsort import natsorted, ns #자연수 정렬 모듈
import datetime

class UnsuportedType(Exception):
	_MSG = u'{0}(은)는 지원하지 않는 형식의 대상입니다!'
	
	def __init__(self, value):
		self.value = value
		
	def __unicode__(self):
		return self._MSG.format(self.value)

class HavePasswordFile(Exception):
	_MSG = u'{0}(은)는 암호가 걸린 파일입니다!'
	
	def __init__(self, value):
		self.value = value
		
	def __unicode__(self):
		return self._MSG.format(self.value)

class MakeCbz:
	_INFO_FILE_NAME = u'info.xml'
	_IMG_RE = re.compile(ur'\.(jpe?g|png|gif|bmp)$', flags=re.UNICODE|re.IGNORECASE)
	
	def merge(self, targets, savePath=u'.'):
		"""
		대상들을 하나로 합칩니다. 주어진 목록의 순서대로 누적됩니다.
		저장 경로를 디렉토리로 지정할시, 첫번째 대상의 이름으로 부터 파일명을 지정합니다.
		[a, b, c] -> a000 ~ c100
		경로 준비/목록 생성/저장 경로 설정/정보 생성/cbz로 묶기/임시 폴더 삭제
		"""
		#저장 경로 설정
		if os.path.isdir(savePath) :
			target = targets[0]
			if os.path.isfile(target):
				buffer = ufp.extractFileName(target)
			else:
				buffer = os.path.basename(target)
			buffer += u'.cbz'
			buffer = os.path.join(savePath, buffer)
			savePath = ufp.generateUniqueName(buffer)
		
		#목록을 생성
		files = []
		tmpFiles = []
		for target in targets:
			path, isTmep = self._initTargetPath(target)
			self._check(target)
			if isTmep:
				tmpFiles += [path]
			filenames = []
			subPathRe = re.compile('^{}/?'.format(re.escape(path)), re.UNICODE)
			for root, dirnames, here_filenames in os.walk(path):
				root = subPathRe.sub('', root)
				for here_filename in here_filenames:
					filenames += [os.path.join(root, here_filename)]
			parentSrc = os.path.basename(target)
			for filename in self._sort(filenames):
				files += [(parentSrc, path, filename)]
		
		#저장 파일명 설정
		fileList = []
		format_ = u'%0{0}d'.format(len(unicode(len(files))))
		for index, buffer in enumerate(files):
			parentSrc, path, filename = buffer
			
			#확장자를 추출
			ext = ufp.extractFileExtension(filename)
			
			#저장할 파일명을 구성
			savename = format_ % index + u"." + ext
			
			#정보를 기록
			fileList += [(parentSrc, path, filename, savename)]
		
		#정보를 생성
		info = self._makeInfoFile(fileList)
		
		#cbz파일로 묶기
		self._saveToCbz(fileList, info, savePath)
		
		#임시 파일 삭제
		for tmp in tmpFiles:
			shutil.rmtree(tmp)
			
		return savePath
	
	def _makeInfoFile(self, files):
		"""정보를 생성"""
		#루트 노드 생성
		root = ElementTree.Element(u'comic_book_info')
		
		#생성 시각을 기록
		buffer = unicode(datetime.datetime.now())
		ElementTree.SubElement(root, 'created_time').text = buffer
		
		#파일 목록 정보를 기록
		fileList = ElementTree.SubElement(root, 'file_list')
		for parentSrc, path, filename, savename in files:
			file_ = ElementTree.SubElement(fileList, 'file')
			
			#원본 경로를 기록
			buffer = os.path.join(parentSrc, filename)
			file_.attrib['orignal_filepath'] = buffer
			
			#저장 파일명을 기록
			file_.text = savename
		
		#저장
		buffer = ElementTree.tostring(root, encoding="utf-8")
		buffer = minidom.parseString(buffer)
		return buffer.toprettyxml(indent="\t", encoding='utf-8')
		
	def _sort(self, fileList):
		"""
		주어진 파일 목록을 자연수를 포함하여 정렬하여 반환. 이때, 대소문자는 구분하지 않음.
		"""
		return natsorted(fileList, alg=ns.IGNORECASE|ns.DIGIT|ns.NOEXP)
	
	def _saveToCbz(self, files, info, savePath):
		"""
		주어진 목록을 cbz파일로 만듭니다.
		[(파일 경로, 저장 이름), ...]
		"""
		with zipfile.ZipFile(savePath, 'w', zipfile.ZIP_STORED) as cbz:
			for parentSrc, path, filename, savename  in files:
				buffer = os.path.join(path, filename)
				cbz.write(buffer, savename)
			cbz.writestr(self._INFO_FILE_NAME, info.encode('utf8'))
	
	def make(self, target, savePath=u'.'):
		"""
		생성한 cbz 경로를 반환
		경로 준비/예외 처리/목록 생성/저장 경로 설정/정보 생성/cbz로 묶기/임시 폴더 삭제
		"""
		return self.merge([target], savePath)
	
	def _check(self, target):
		for root, dirs, files in os.walk(target):
			if len(dirs) > 0:
				raise Exception(u'디렉토리가 존재합니다. ' + dirs[0])
			for file_  in files:
				if not ( os.path.isfile(file_) or self._IMG_RE.search(file_) ):
					raise Exception(u'이미지 파일 외의 대상이 존재합니다. ' + file_)
	
	def _initTargetPath(self, target):
		"""
		대상을 처리하기 위한 준비를 합니다. 압축파일의 경우 파일을 풀어둡니다.
		"""
		#타겟이 심볼릭 링크인 경우
		if os.path.islink(target):
			raise UnsuportedType(target)
			
		#타겟이 디렉토리의 경우
		elif os.path.isdir(target):
			path = target
			useTmpDir = False
			
		#타겟이 파일의 경우
		elif os.path.isfile(target):
			#지원되는 형식의 파일이 아니라면 오류를 던짐
			if not ufp.Arkzip.checkSuportFormat(target):
				raise UnsuportedType(target)

			#임시 디렉토리를 생성
			buffer = ufp.extractDirname(target)
			useTmpDir = True
			path = tempfile.mkdtemp(prefix='tmp_cbz_', dir=buffer)
			
			#압축해제
			try:
				ufp.Arkzip.decompress(target, output_dir=path, key='password')
			
			#비밀번호가 걸린 파일이라면 오류를 던짐
			except Arkzip.PasswordWrong:
				shutil.rmtree(path)
				raise HavePasswordFile(target)
			
		#타겟이 기타 형식인 경우 오류를 던짐
		else:
			raise UnsuportedType(target)
		
		return path, useTmpDir
