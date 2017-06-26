#coding=utf-8
from pyExcelerator import *
import sys
import os

# 格式
ali = Formatting.Alignment()
ali.horz = Formatting.Alignment.HORZ_CENTER                                                                     
ali.vert = Formatting.Alignment.VERT_CENTER                                                                     

bd = Formatting.Borders()                                                                                       
bd.left   = bd.THIN                                                                                             
bd.right  = bd.THIN
bd.top    = bd.THIN
bd.bottom = bd.THIN
        
ft = Formatting.Font()
ft.name = u'微软雅黑'
ft.height = 180                                                                                                 
ft.colour_index = 0x17                                                                                          

stynor = Style.XFStyle()                                                                                        
stynor.alignment = ali                                                                                          
stynor.borders = bd                                                                                             
stynor.font = ft
        
styper = Style.XFStyle()                                                                                        
styper.num_format_str = '0.00%'                                                                                 
styper.alignment = ali
styper.borders = bd
styper.font = ft
                
styfloat = Style.XFStyle()
styfloat.num_format_str = '0.00'
styfloat.alignment = ali        
styfloat.borders = bd           
styfloat.font = ft

def get_sheet(w,sheetname):
	sheetnum = 0
	while True:
		try:
			worksheet = w.get_sheet(sheetnum)
			if not worksheet:
				break
		except Exception,e:
			break
		if worksheet.get_name() == sheetname:
			return worksheet
		sheetnum = sheetnum + 1
	return None

def write_sheet(ws,sheet_data,row_styles):
	__doc = """
		ws为表单对象
		sheet_data格式为一个字典,如:{(0,1):xxx,(0,2):xxx,}
	"""
	length = len(row_styles)
	for rowcol,item in sheet_data.iteritems():
		row,col = rowcol
		style = (col < length) and row_styles[col] or stynor
		#print("write",ws.get_name(),row,col,item)
		ws.write(row,col,item,style)

def writexls(xlsname,sheetname,sheet_data,row_styles):
	if type(sheet_data) == list:
		dct = {}
		for rowno,row in enumerate(sheet_data):
			for colno,item in enumerate(row):
				dct[(rowno,colno)] = item
		sheet_data = dct

	w = Workbook()
	if os.path.isfile(xlsname):
		sheets = parse_xls(xlsname)
		for name,data in sheets:
			ws = w.add_sheet(name)
			if name != sheetname:
				write_sheet(ws,data,row_styles)
	else:
		w.add_sheet(sheetname)
	ws = get_sheet(w,sheetname)
	write_sheet(ws,sheet_data,row_styles)
	w.save(xlsname)

# test
if __name__ == "__main__":
	if len(sys.argv) < 3:
		print("usage: python writexls.py xlsname sheetname")
		exit(0)
	sheet_data = []
	for rowno in xrange(1,10):
		row = [1,1.0,1.0e3,"english",u"中文"]
		sheet_data.append(row)
	row_styles = [stynor,styper,styfloat,stynor,stynor,]
	xlsname = sys.argv[1]
	sheetname = sys.argv[2]
	if sys.platform == "win32":
		xlsname = xlsname.decode("gbk")
		sheetname = sheetname.decode("gbk")
	else:
		xlsname = xlsname.decode("utf8")
		sheetname = sheetname.decode("utf8")
	writexls(xlsname,sheetname,sheet_data,row_styles)
	#writexls(xlsname,sheetname,sheet_data,row_styles)
