#!/usr/bin/env python
# -*- coding: UTF-8 -*-

"""
사용자 함수 묶음.
bash -> c++ -> (qt ->) python
제작자 : 별님 <w7dn1ng75r@gmail.com>
홈페이지 : http://thestars3.tistory.com/
"""

__author__ = u'별님'
__copyright__ = u'Copyright (C) 2015년 별님'
__credits__ = [u'별님']
__maintainer__ = u"별님"
__license__ = u"GPL v3"
__version__ = u"1.0.0"
__email__ = u"w7dn1ng75r@gmail.com"
__status__ = u"Production"

from FilePath import *;
from Etc import *;
from Debug import *;
from Web import *;
import Shell
import TerminalColor;
from Decompress import *

__package__ = 'ufp';

__all__ = [
	'FilePath', 
	'Etc',
	'Debug',
	'Web',
	'TerminalColor',
	'Shell',
	'Decompress'
	];
