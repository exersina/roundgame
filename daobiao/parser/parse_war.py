# -*- coding: utf-8 -*-
from base import *
import os
import sys

def append_if_not_exist(filename,cond,append_data):
	fd = open(filename,"rb")
	data = fd.read()
	found = True if data.find(cond) >= 0 else False
	fd.close()
	if not found:
		fd = open(filename,"wb")
		fd.write(data + "\n" + append_data)
		fd.close()

def writemodule(modfilename,data):
	cfg = {
		"startline" : "--<<auto import 导表开始>>",
		"endline" : "--<<auto import 导表结束>>",
	}
	parser = CParser(cfg,None)
	parser.write(modfilename,data)


def parse_skill(sheet_name,sheet,dstpath):
	cfg = {
		"startline" : "--<<skill 导表开始>>",
		"endline" : "--<<skill 导表结束>>",
		"linefmt" :
"""
local super = require "gamelogic.war.skill.skill"
cskill%(type)d = class("cskill%(type)d",super,{
	type = %(type)d,
	name = "%(name)s",
	canuse = %(canuse)d,
	cd = %(cd)d,
	use_max_cnt = %(use_max_cnt)d,
	_use_effect = %(use_effect)d,
	_passive_effects = %(passive_effects)s,
	desc = "%(desc)s",
})

function cskill%(type)d:init(option)
	super.init(self,option)
""",
	}
	dstpath = os.path.join(dstpath,"skill")
	if not os.path.isdir(dstpath):
		os.makedirs(dstpath)
	filename_pat = "skill%d.lua"
	require_pat = "require \"gamelogic.war.skill.skill%d\""
	assign_pat = "skill_class[%d] = cskill%d"
	append_pat = \
"""
end --导表生成


return cskill%d
"""
	append_cond = "end --导表生成"
	require_list = []
	assign_list = []
	sheet = CSheet(sheet_name,sheet)
	parser = CParser(cfg,sheet)
	ignorerow = parser.m_cfg.get("ignorerows",0) 
	for row in range(ignorerow,sheet.rows()):
		line = sheet.line(row)		
		typ = int(line["type"])
		linefmt = cfg["linefmt"]
		data = linefmt % line
		filename = os.path.join(dstpath,filename_pat % typ)
		parser.write(filename,data)
		require_list.append(require_pat % typ)
		assign_list.append(assign_pat % (typ,typ))
		append_data = append_pat % typ
		append_if_not_exist(filename,append_cond,append_data)
	data = \
"""
skill_class = skill_class or {}
%s
%s
return skill_class
""" % ("\n".join(require_list),"\n".join(assign_list))
	writemodule(os.path.join(dstpath,"init.lua"),data)

def parse_effect(sheet_name,sheet,dstpath):
	cfg = {
		"startline" : "--<<effect 导表开始>>",
		"endline" : "--<<effect 导表结束>>",
		"linefmt" :
"""
local super = require "gamelogic.war.effect.effect"
ceffect%(type)d = class("ceffect%(type)d",super,{
	type = %(type)d,
	name = "%(name)s",
	skill_type = %(skill_type)d,
	damage_type = "%(damage_type)s",
	event = "%(event)s",
	can_select_target = %(can_select_target)d,
	target_limit = {
		ally = %(ally)d,
		enemy = %(enemy)d,
		hero = %(hero)d,
		pet = %(pet)d,
		monster = %(monster)d,
	},
	target_max_num = %(target_max_num)d,
	cmd = "%(cmd)s",
	args = %(args)s,
	desc = "%(desc)s",
})

function ceffect%(type)d:init(option)
	super.init(self,option)
""",
	}
	dstpath = os.path.join(dstpath,"effect")
	if not os.path.isdir(dstpath):
		os.makedirs(dstpath)
	filename_pat = "effect%d.lua"
	require_pat = "require \"gamelogic.war.effect.effect%d\""
	assign_pat = "effect_class[%d] = ceffect%d"
	append_pat = \
"""
end --导表生成


return ceffect%d
"""
	append_cond = "end --导表生成"
	require_list = []
	assign_list = []
	sheet = CSheet(sheet_name,sheet)
	parser = CParser(cfg,sheet)
	ignorerow = parser.m_cfg.get("ignorerows",0) 
	for row in range(ignorerow,sheet.rows()):
		line = sheet.line(row)		
		typ = int(line["type"])
		linefmt = cfg["linefmt"]
		data = linefmt % line
		filename = os.path.join(dstpath,filename_pat % typ)
		parser.write(filename,data)
		require_list.append(require_pat % typ)
		assign_list.append(assign_pat % (typ,typ))
		append_data = append_pat % typ
		append_if_not_exist(filename,append_cond,append_data)
	data = \
"""
effect_class = effect_class or {}
%s
%s
return effect_class
""" % ("\n".join(require_list),"\n".join(assign_list))
	writemodule(os.path.join(dstpath,"init.lua"),data)

def parse_buff(sheet_name,sheet,dstpath):
	cfg = {
		"startline" : "--<<buff 导表开始>>",
		"endline" : "--<<buff 导表结束>>",
		"linefmt" :
"""
local super = require "gamelogic.war.buff.buff"
cbuff%(type)d = class("cbuff%(type)d",super,{
	type = %(type)d,
	name = "%(name)s",
	debuff = %(debuff)d,
	dotbuff = %(dotbuff)d,
	cover_max = %(cover_max)d,
	cover_kind = "%(cover_kind)s",
	lifetime = %(lifetime)d,
	data = %(data)s,
	desc = "%(desc)s",
})

function cbuff%(type)d:init(option)
	super.init(self,option)
""",
	}
	dstpath = os.path.join(dstpath,"buff")
	if not os.path.isdir(dstpath):
		os.makedirs(dstpath)
	filename_pat = "buff%d.lua"
	require_pat = "require \"gamelogic.war.buff.buff%d\""
	assign_pat = "buff_class[%d] = cbuff%d"
	append_pat = \
"""
end --导表生成


return cbuff%d
"""
	append_cond = "end --导表生成"
	require_list = []
	assign_list = []
	sheet = CSheet(sheet_name,sheet)
	parser = CParser(cfg,sheet)
	ignorerow = parser.m_cfg.get("ignorerows",0) 
	for row in range(ignorerow,sheet.rows()):
		line = sheet.line(row)		
		typ = int(line["type"])
		linefmt = cfg["linefmt"]
		data = linefmt % line
		filename = os.path.join(dstpath,filename_pat % typ)
		parser.write(filename,data)
		require_list.append(require_pat % typ)
		assign_list.append(assign_pat % (typ,typ))
		append_data = append_pat % typ
		append_if_not_exist(filename,append_cond,append_data)
	data = \
"""
buff_class = buff_class or {}
%s
%s
return buff_class
""" % ("\n".join(require_list),"\n".join(assign_list))
	writemodule(os.path.join(dstpath,"init.lua"),data)

def parse_aura(sheet_name,sheet,dstpath):
	cfg = {
		"startline" : "--<<aura 导表开始>>",
		"endline" : "--<<aura 导表结束>>",
		"linefmt" :
"""
local super = require "gamelogic.war.aura.aura"
caura%(type)d = class("caura%(type)d",super,{
	type = %(type)d,
	name = "%(name)s",
	buff_type = %(buff_type)d,
	lifetime = %(lifetime)d,
	desc = "%(desc)s",
})

function caura%(type)d:init(option)
	super.init(self,option)
""",
	}
	dstpath = os.path.join(dstpath,"aura")
	if not os.path.isdir(dstpath):
		os.makedirs(dstpath)
	filename_pat = "aura%d.lua"
	require_pat = "require \"gamelogic.war.aura.aura%d\""
	assign_pat = "aura_class[%d] = caura%d"
	append_pat = \
"""
end --导表生成


return caura%d
"""
	append_cond = "end --导表生成"
	require_list = []
	assign_list = []
	sheet = CSheet(sheet_name,sheet)
	parser = CParser(cfg,sheet)
	ignorerow = parser.m_cfg.get("ignorerows",0) 
	for row in range(ignorerow,sheet.rows()):
		line = sheet.line(row)		
		typ = int(line["type"])
		linefmt = cfg["linefmt"]
		data = linefmt % line
		filename = os.path.join(dstpath,filename_pat % typ)
		parser.write(filename,data)
		require_list.append(require_pat % typ)
		assign_list.append(assign_pat % (typ,typ))
		append_data = append_pat % typ
		append_if_not_exist(filename,append_cond,append_data)
	data = \
"""
aura_class = aura_class or {}
%s
%s
return aura_class
""" % ("\n".join(require_list),"\n".join(assign_list))
	writemodule(os.path.join(dstpath,"init.lua"),data)


def parse(xlsfilename,dstpath):
	parses = {
		"skill" : parse_skill,
		"effect" : parse_effect,
		"buff" : parse_buff,
		"aura" : parse_aura,
	}
	myparsexls(xlsfilename,dstpath,parses)


if __name__ == "__main__":
	if len(sys.argv) != 3:
		print("usage: python parse_war.py xlsfilename dstpath")
		exit(0)
	xlsfilename = sys.argv[1]
	dstpath = sys.argv[2]
	parse(xlsfilename,dstpath)
