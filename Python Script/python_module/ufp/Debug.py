#!/usr/bin/env python
#-*- coding: utf-8 -*-

from __future__ import print_function;
import TerminalColor as Color;
import pprint

def printDebugMsg(*objs) :
	print(u'{0}[디버그]{1} '.format(Color.Bak.red, Color.reset), end='');
	pprint.pprint(*objs);
