#!/usr/bin/env python
#-*- coding: utf-8 -*-

from __future__ import print_function;
import imp
import os
GlobalEnv = imp.load_source('', os.path.expanduser('~/.GlobalEnv.py'))
import sys
import re
from ufp import TerminalColor as color

def main():
	for a, b,c in os.walk(u'/media/TBND/N/#만화#'):
		break
	
	e = re.compile(ur'^(.+?) (외전|단[편권]|특별[화회편]|번외편|[0-9]+(\.5)?[화회권편부]?(\.[a-z0-9]+$| ))', re.UNICODE|re.IGNORECASE|re.DOTALL)
	for d in c:
		if e.search(d):
			print('{}{}{}'.format(color.red, d, color.reset))
		else:
			print(d)
	sys.exit(0)

main()
