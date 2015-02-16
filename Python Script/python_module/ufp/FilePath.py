#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import os;
import re;
import urllib
from Debug import printDebugMsg as debug
import chardet
from Etc import stripControlChar
import urlparse

def trimFilename(path):
	"""
	지정된 경로의 파일이름을 다듬읍니다.
	수정된 파일명을 반환합니다. 만약 바뀐게 없다면 None을 반환합니다.
	"""
	#확장자 포함 여부
	haveExt = not os.path.isdir(path)
	
	#부모 경로를 추출
	dirname = extractDirname(path)
	
	#파일명을 trim
	srcBasename = os.path.basename(path)
	srcTrimed = trimWebname(srcBasename, consider_extension=haveExt)
	
	#만약 변한게 없다면 처리 중단
	if srcBasename == srcTrimed:
		return None
	
	#저장 경로 지정
	buffer = os.path.join(dirname, srcTrimed)
	dest = generateUniqueName(buffer, spliteExt=haveExt)
	
	#파일명을 변경
	os.rename(path, dest)
	
	#수정된 파일명을 반환
	return dest

def trimFilenames(path, recursive=False):
	"""
	지정된 경로의 파일들의 이름을 다듬읍니다.
	recursive가 True라면, 심볼릭 링크를 제외한 모든 하위 경로에 대해 파일명을 수정합니다. False라면, 지정된 경로에 있는 대상에 한하여 작업합니다.
	작업한 결과를 원본과 수정된 파일명을 묶은 튜플들의 리스트로 반환합니다.
	"""
	#재귀적 경로 탐색 옵션 처리
	if recursive:
		walk = os.walk(path, topdown=False)
	else:
		for dirname, dirs, files in os.walk(path):
			walk = ((dirname, dirs, files))
			break
	
	#파일명 변경
	works = []
	for dirname, dirs, files in walk:
		for src in files + dirs:
			#파일 이름 다듬기
			buffer = os.path.join(dirname, src)
			dest = trimFilename(buffer)
			
			#기록
			if dest:
				works += [(src, dest)]
	
	return works

def pathConvertToUrl(path):
	buffer = path.encode('utf8')
	buffer = urllib.pathname2url(buffer)
	return urlparse.urljoin(u'file:', buffer)

def trimWebname(filename, **options):
	"""
	웹에서 다운받은 파일의 이름을 손질함. 
	url coding 풀기, 사용불가능한 문자를 대체문자로 치환, 웹에서의 공백치환을 감지하고 경우에 따라 해제, 파일 이름을 다듬기. UHC로 변환가능한 인코딩은 변환. 
	주의! 실제 파일이 아닌 입력받은 내용을 대상으로만 작업합니다. 하나의 대상만을 작업합니다. 인코딩 변환이 잘못될수도 있습니다!
	
	만약 결과물이 공백이 될 경우 u'Unknown'문자열이 반환됩니다.
	
	옵션:
	from_encoding: 
		'auto' : 자동으로 인코딩을 파악합니다. 
		False : 인코딩을 변환하지 않습니다. (기본)
		기타('utf8', 'uhc', ...)
	consider_extension: 
		True: 확장자를 고려하여 작업합니다.
		False: 확장자를 고려하지 않습니다. (기본)
	"""
	#옵션 초기값 설정
	options.setdefault(u'consider_extension', False)
	options.setdefault(u'from_encoding', False)
		
	#옵션 처리 : consider_extension
	considerExtension = options[u'consider_extension']
	
	#옵션 처리 : from_encoding
	if options[u'from_encoding'] == u'auto':
		fromEncoding = chardet.detect(filename)['encoding']
	elif options[u'from_encoding'] == False:
		fromEncoding = None
	else:
		fromEncoding = options[u'from_encoding']
	
	#url 디코딩
	filename = urllib.unquote(filename)
	
	#인코딩 변환
	if fromEncoding:
		filename = filename.decode('utf8', errors='replace')
	
	#url 디코딩
	filename = urllib.unquote(filename)
	
	#전체 파일명의 앞뒤 공백 제거
	filename = filename.strip()
	
	#파일명에 사용불가능한 문자 치환
	filename = replaceSpiecalChar(filename)
	
	#확장자 분리
	if considerExtension:
		extension = extractFileExtension(filename)
		if extension:
			filename = extractFileName(filename)
		else:
			considerExtension = False
		
	#이름에 포함된 and표시 제거
	if not re.search(u' ', filename):
		pattern1 = re.compile(u'[_+]', re.UNICODE)
		pattern2 = re.compile(ur'\.', re.UNICODE)
		if pattern1.search(filename):
			filename = pattern1.sub(' ', filename)
		elif pattern2.search(filename):
			filename = pattern2.sub(' ', filename)
	
	#파일이름의 앞뒤 공백 제거
	filename = filename.strip()
	
	#제어문자 제거
	filename = stripControlChar(filename)
	#filename = re.sub('[:cntrl:]', ' ', filename, flags=re.UNICODE)
	
	#파일명 합침.
	if considerExtension:
		filename = u'.'.join((filename, extension))
	
	#파일명을 반환
	if filename:
		return filename
	else:
		return u'Unknown'
	
def replaceSpiecalChar(string, **options) :
	"""
	윈도우 및 유닉스 계열 운영체제에서 파일에 포함되면 문제가 되는 특수문자를 대체문자로 치환합니다. 또한, 경로 구분자를 대체 문자로 치환합니다.
	
	윈도우에서 파일명으로 사용 할  없는 문자들(파일 이름에 다음 문자를 사용할 수 없습니다): \ / : * ? " < > |
	
	옵션 :
	type: 'windows', 'unix'. 윈도우의 경로 구분 문자는 리눅스에서 표시되는 모양이 다릅니다. 어떤 OS에서 보여지는 모양으로 치환할지 지정합니다. 기본값은 unix입니다.
	keep_path_characters: True, False. 경로 구분자를 치환하지 않습니다. 이 설정은 type 설정에 의존합니다. 기본 값은 False입니다.
	"""
	UNIX_PATH_CHARACTER_RE = (u"/", u"／");
	ESCAPE_CHARTER_UNIX_TYPE_RE = (u"\\", u"＼")
	WINDOWS_PATH_CHARACTER_RE = (u"\\", u"￦")
	DEFAULT_REGEXS = [
		(u"?", u"？"),
		(u":", u"："),
		(u"*", u"＊"),
		(u'"', u"＂"),
		(u"<", u"〈"),
		(u">", u"〉"),
		(u"|", u"│"),
		(u"'", u"＇"),
		(u"$", u"＄"),
		(u"!", u"！")
	];
	
	#옵션 초기값 설정
	options.setdefault(u'type', u'unix')
	options.setdefault(u'keep_path_characters', False)
	
	#옵션 처리
	regexs = DEFAULT_REGEXS
	if options[u'type'] == u'unix' :
		regexs.append(ESCAPE_CHARTER_UNIX_TYPE_RE);
		if not options[u'keep_path_characters'] :
			regexs += [UNIX_PATH_CHARACTER_RE];
	elif options[u'type'] == u'windows' :
		regexs += [UNIX_PATH_CHARACTER_RE];
		if not options[u'keep_path_characters'] :
			regexs += [WINDOWS_PATH_CHARACTER_RE];
	
	for before, after in regexs :
		string = string.replace(before, after);
	
	return string;

def extractDirname(path) :
	"""
	주어진 경로의 부모 경로를 추출해냅니다. 만약 'abc'가 주어졌다면, 반환값은 '.'입니다.
	주어지는 값은 유니코드 문자열이여야 함.
	"""
	dirnameRe = re.compile(u'(?P<dirname>^.*)/', re.DOTALL | re.UNICODE).search(path);
	if dirnameRe :
		return dirnameRe.group('dirname');
	else :
		return u'.';

def generateUniqueName(targetPath, spliteExt = True) :
	"""
	해당 경로에서 유일한 경로를 만들어 냅니다. 이때, 대소문자는 구분하지 않습니다.
	만약, 주어진 경로가 충돌하지 않는다면 주어진 경로를 그대로 반환합니다.
	만약 주어진 경로의 부모 경로가 존재하지 않는다면, 주어진 문자열 그대로 반환합니다.
	ex) a/b/c -> a/b/c d(1)식으로 충복을 회피처리함.
	주어지는 값은 유니코드 문자열이여야 함.
	v4 BASH -> C++ -> QT -> PYTHON
	@return 유일한 경로
	"""
	#경로 분할
	targetDirname = extractDirname(targetPath);
	targetBasename = os.path.basename(targetPath);
	
	#부모 경로가 존재하는지 확인
	if not os.path.exists(targetDirname) :
		return targetPath;
	
	#해당 경로의 목록을 작성
	fileList = [u'.', u'..'];
	for dirpath, dirnames, filenames in os.walk(targetDirname) :
		fileList.extend(filenames);
		break;
		
	#중복되는 대상이 존재하는지 확인
	existDuplicateFile = False;
	buffer = re.escape(targetBasename);
	fullmatchRe = re.compile(u"^%(buffer)s$" % locals(), re.DOTALL | re.IGNORECASE | re.UNICODE);
	for fileName in fileList :
		if fullmatchRe.search(fileName) :
			existDuplicateFile = True;
			break;
	
	#중복되는 대상이 존재하고 있지 않다면 이름을 그대로 돌려줌.
	if not existDuplicateFile :
		return targetPath;
		
	#파일명과 확장자를 추출
	if spliteExt :
		targetFileExt = extractFileExtension(targetBasename);
		if targetFileExt :
			targetFileName = extractFileName(targetBasename);
		else :
			targetFileName = targetBasename;
			spliteExt = False;
	else :
		targetFileName = targetBasename;
	
	#중복 파일들의 숫자를 가져옴.
	escapedTargetFileName = re.escape(targetFileName);
	if spliteExt :
		extractDupCountRe = re.compile(ur"^%(escapedTargetFileName)s \(d(?P<number>[0-9]+)\)\.%(targetFileExt)s$" % locals(), re.DOTALL | re.IGNORECASE | re.UNICODE);
	else :
		extractDupCountRe = re.compile(ur"^%(escapedTargetFileName)s \(d(?P<number>[0-9]+)\)$" % locals(), re.DOTALL | re.IGNORECASE | re.UNICODE);
	counts = [];
	for fileName in fileList :
		m = extractDupCountRe.search(fileName);
		if m :
			buffer = m.group(u'number')
			buffer = int(buffer)
			counts.append(buffer);
	
	#중복 숫자를 설정
	if counts :
		counts.sort();
		notDuplicatedNumber = counts[-1] + 1;
	else :
		notDuplicatedNumber = 1;
		
	#중복 회피 이름 생성
	if spliteExt :
		uniqueName = u"%(targetFileName)s (d%(notDuplicatedNumber)d).%(targetFileExt)s" % locals();
	else :
		uniqueName = u"%(targetFileName)s (d%(notDuplicatedNumber)d)" % locals();
	
	return os.path.join(targetDirname, uniqueName);

def extractFileName(filePath) :
	"""
	파일 경로로 부터 확장자를 제외한 파일명을 추출해냅니다.
	주어지는 값은 유니코드 문자열이여야 함.
	qt에서 지원하는 QFileInfo::baseName()이 앞에 있는 .을 기준으로 파일명과 확장자를 분리함에 따라 생기는 문제(.asd asd.zip -> '(없음)')를 해결하기 위해 만들어졌습니다.
	예를 들어, `../asd/.qwe.tar.bz2'가 인자로 주어진 다면 반환값은 `.qwe.tar' 입니다.
	"""
	rx = re.compile(ur"^(.*/)?(?P<name_space>.+?)?(?P<ext_space>\.[a-z0-9]+)?$", re.DOTALL | re.IGNORECASE | re.UNICODE);
	result = rx.search(filePath)
	if not result:
		return unicode()
	nameSpace = result.group('name_space');
	if nameSpace :
		return nameSpace;
	else :
		return result.group('ext_space');

def extractFileExtension(fileName) :
	"""
	주어진 파일명의 확장자를 추출합니다.
	주어지는 값은 유니코드 문자열이여야 함.
	`../asd/.qwe'가 인자로 주어진 다면 반환값은 (빈 값) 입니다.
	만약 확장자가 없다면, (빈 값)을 리턴합니다.
	"""
	extRe = re.compile(ur"[^/]+\.(?P<ext>[a-z0-9]+)$", re.DOTALL | re.IGNORECASE | re.UNICODE);
	result = extRe.search(fileName);
	if result :
		return result.group('ext');
	else :
		return unicode();
