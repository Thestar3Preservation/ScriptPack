#!/usr/bin/env python
#-*- coding: utf-8 -*-

def quote(string):
	buffer = string.replace(u"'", ur"'\''")
	return u"'{0}'".format(buffer)
