#!/usr/bin/env python
#-*- coding: utf-8 -*-

import commands
import Shell
from FilePath import *

class Arkzip:
	SUPORT_FORMAT = [u"zip", u"alz", u"egg", u"tar", u"bh", u"7z", u"wim", u"rar", u"arj", u"cab", u"lzh", u"gz", u"bz2", u"iso", u"img", u"xz", u"z", u"lzma", u"j2j", u"hv3"]
	SUPORT_SAME_FORMAT = [u'cbz', u'cbr']
	
	class PasswordWrong(Exception):
		def __init__(self):
			self.value = '암호가 틀렸습니다!'
		
		def __init__(self, value):
			self.value = value
			
		def __str__(self):
			return repr(self.value)

	@staticmethod
	def checkSuportFormat(filename):
		"""
		지원하는 포멧인지 확인한다. 단순히, 확장자만 비교할뿐 magic number를 비교하지는 않는다.
		"""
		ext = extractFileExtension(filename)
		if ext in Arkzip.SUPORT_FORMAT + Arkzip.SUPORT_SAME_FORMAT:
			return True
		return False
	
	@staticmethod
	def decompress(filePath, **options):
		command = u'arkzip --interface none'
		
		if u'output_dir' in options:
			buffer = Shell.quote(options['output_dir'])
			command += u' --output-dir ' + buffer

		if u'key' in options:
			buffer = Shell.quote(options['key'])
			command += u' --key ' + buffer
		
		if u'skip_pass' in options:
			if options['skip_pass']:
				command += u' --skip-pass'
		
		buffer = Shell.quote(filePath)
		command += u' -- ' + buffer
		
		status = commands.getstatusoutput(command)[0]
		
		if status == 0:
			return
		elif status == 36:
			raise PasswordWrong()
		
		raise status
	
