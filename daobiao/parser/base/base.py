# -*- coding: utf-8 -*-
from pyExcelerator import *
from makescript.parse import *
import sys

def myparsexls(xls_filename,dstpath,parses):
	# sheet_name: unicode,xls_filename: str(win32:gbk,linux:utf-8)
	if sys.platform == "win32":
		xls_filename = xls_filename.decode("gbk")
	else:
		xls_filename = xls_filename.decode("utf-8")
	sheets = parse_xls(xls_filename)
	for sheet_name,sheet_data in sheets:
		# sheet_name: unicode, xls_filename: unicode
		show_name = "%s#%s" % (xls_filename,sheet_name)
		if sys.platform != "win32":
			show_name = show_name.encode("utf-8")
		parsefunc = parses.get(sheet_name)
		if not parsefunc:
			print "parse",show_name,": no parser"
			continue

		if type(parsefunc) != list:
			lst = [parsefunc,]
		else:
			lst = parsefunc

		for parsefunc in iter(lst):
			print "parse",show_name,"..."
			#parsefunc(sheet_name,sheet_data,dstpath)
			parsefunc({"xls_filename":xls_filename,"sheet_name":sheet_name},sheet_data,dstpath)
			print "parse",show_name,"ok"

