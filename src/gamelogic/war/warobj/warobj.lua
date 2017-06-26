cwarobj = class("cwarobj")

function cwarobj:init(option)
	objmgr:add("cwarobj",self)
	self.owner = assert(option.owner)
	self.kind = assert(option.kind)
	self.pid = option.pid
	if self.pid then
		self.gamesrv = assert(option.gamesrv)
	end
	self.baseattrs = assert(option.baseattrs)
	self.attrs = deepcopy(self.baseattrs)
	self.state = option.state or {}
	self.is_attacker = option.is_attacker
	self.is_ai = option.is_ai
	self.lv = assert(option.lv)


	self.is_die = false
	self.die_cnt = 0
	self.die_last_time = 0
	self.is_quit = false
	self.quit_last_time = 0
	self.join_last_time = os.time()
	self.pets = {}
	self.buffs = cbuffs.new({owner=self})
	self.aura_buffs = cbuffs.new({owner=self})
	self.skills = cskills.new({owner=self})
	self.history_op = {}
	self.op_queue = {}

	if not table.isempty(option.buffs) then
		for i,buff_data in ipairs(option.buffs) do
			buff_data.source = self
			buff_data.owner = self
			local buff = helper.new_buff(buff_data)
			self.buffs:add(buff)
		end
	end
	
	if not table.isempty(option.skills) then
		for i,skill_data in ipairs(option.skills) do
			skill_data.source = self
			skill_data.owner = self
			local skill = helper.new_skill(skill_data)
			self.skills:add(skill)
		end
	end
end

function cwarobj:destroy()
	self.buffs:destroy()
	self.aura_buffs:destroy()
	self.skills:destroy()
end

function cwarobj:do_effect(source,effect)
end

function cwarobj:use_skill(skillid,focus_id)
	local skill = self.skills:get(skillid)
	if focus_id then
		focus = war:get_warobj(focus_id)
	end
	local isok,errmsg = skill:can_use(focus)
	if not isok then
		print("use_skill",self.objid,skill.objid,skill.type,focus_id,errmsg,skill.use_round,skill.cd,war.round)
		return
	end
	skill:use(focus)
end

function cwarobj:enter_war()
	war:sendpackage(war:all_warobj(),"war_enter_war",{warobj=self:pack()})
	self.event:send("before_enter_war")
	for i,skillid in ipairs(self.skills.skills) do
		local skill = self.skills:get(skillid)
		skill.auras:enter_war()
	end
	for i,id in ipairs(war.attackers) do
		local attacker = war:get_warobj(id)
		if not attacker.is_die then
			attacker:on_see(self)
		end
	end
	for i,id in ipairs(war.defensers) do
		local defenser = war:get_warobj(id)
		if not defenser.is_die then
			defenser:on_see(self)
		end
	end
	self.event:send("after_enter_war")
end

function cwarobj:leave_war()
	self.event:send("before_leave_war")
	for i,skillid in ipairs(self.skills.skills) do
		local skill = self.skills:get(skillid)
		skill.auras:leave_war()
	end
	for i=#self.aura_buffs.buffs,1,-1 do
		local id = self.aura_buffs.buffs[i]
		local buff = self.aura_buffs:get(id)
		local aura = buff.source
		aura:del_buff(self)
	end
	self.event:send("after_leave_war")

	war:sendpackage(war:all_warobj(),"war_leave_war",{warobj=self:pack4leave()})
end

function cwarobj:on_see(who)
	for i,skillid in ipairs(self.skills.skills) do
		local skill = self.skills:get(skillid)
		for i,aura in ipairs(skill.auras.auras) do
			aura:on_see(who)
		end
	end
end

function cwarobj:die()
	logger.logf("info","war","op=cwarobj:die,warid=%s,objid=%s,pid=%s,kind=%s",war.id,self.objid,self.pid,self.kind)
	self.is_die = true
	self.die_cnt = self.die_cnt + 1
	self.die_last_time = os.time()
	if self.kind == "pet" then
		war:leave(self)
	end
end

function cwarobj:alive()
	logger.logf("info","war","op=cwarobj:alive,warid=%s,objid=%s,pid=%s,kind=%s",war.id,self.objid,self.pid,self.kind)
	self.is_die = nil
end



function cwarobj:getstate(state)
	for i=#self.aura_buffs,1,-1 do
		local buff = self.aura_buffs[i]
		local data = buff.data
		if data.state and data.state[state] ~= nil then
			return data.state[state]
		end
	end
	for i=#self.buffs,1,-1 do
		local buff = self.aura_buffs[i]
		local data = buff.data
		if data.state and data.state[state] ~= nil then
			return data.state[state]
		end
	end
	return self.state[state]
end

function cwarobj:setstate(state,isopen)
	self.state[state] = isopen
end

function cwarobj:getattr(attr)
	local val = self.attrs[attr] or 0
	if attr ~= "hp" and attr ~= "mp" then
		for i,id in ipairs(self.buffs.buffs) do
			local buff = self.buffs:get(id)
			local data = buff.data
			if data.set and data.set[attr] then
				val = data.set[attr]
			end
			if data.add and data.add[attr] then
				val = val + data.add[attr]
			end
		end
		for i,id in ipairs(self.aura_buffs.buffs) do
			local buff = self.buffs:get(id)
			local data = buff.data
			if data.set and data.set[attr] then
				val = data.set[attr]
			end
			if data.add and data.add[attr] then
				val = val + data.add[attr]
			end
		end
	end
	if attr == "hp" then
		return math.min(val,self:getattr("maxhp"))
	elseif attr == "mp" then
		return math.min(val,self:getattr("maxmp"))
	end
	return val
	--return math.min(helper.maxattr(attr),math.max(helper.minattr(attr),val))
end

function cwarobj:addattr(attr,val)
	local oldval = self.attrs[attr] or 0
	self.attrs[attr] = oldval + val
	if attr == "hp" or attr == "mp" then
		local max = self:getattr("max"..attr)
		self.attrs[attr] = math.min(max,self.attrs[attr])
	end
	return self.attrs[attr]
end

-- 受伤
function cwarobj:damage(source,damage)
	assert(damage.value > 0)
	damage = deepcopy(damage)
	damage.value = damage.value * (math.random(1,150)/100 + 0.9)
	-- TODO: 转换伤害类型
	if damage.type == "atk" then
		damage.valid_value = (damage.value - self:getattr("defense")) * (1 - self:getattr("kang"))
		-- 物理伤害
	elseif damage.type == "abs_atk" then
		-- 绝对物理伤害: 无视防御+物理吸收
		damage.valid_value = damage.value
	elseif damage.type == "fire_fs_atk" then
		damage.valid_value = (damage.value - self:getattr("fire_fs_defense")) * (1 - self:getattr("fire_fs_kang"))
	elseif damage.type == "water_fs_atk" then
		damage.valid_value = (damage.value - self:getattr("water_fs_defense")) * (1 - self:getattr("water_fs_kang"))
	elseif damage.type == "ice_fs_atk" then
		damage.valid_value = (damage.value - self:getattr("ice_fs_defense")) * (1 - self:getattr("ice_fs_kang"))
	elseif damage.type == "poison_fs_atk" then
		damage.valid_value = (damage.value - self:getattr("poison_fs_defense")) * (1 - self:getattr("poison_fs_kang"))
	elseif damage.type == "abs_fire_fs_atk" or
		   damage.type == "abs_water_fs_atk" or
		   damage.type == "abs_ice_fs_atk" or
		   damage.type == "abs_poison_fs_atk" then
		-- 绝对法术伤害: 无视法术防御+法术抗性
		damage.valid_value = damage.value
	else
		error("invalid damage.type:" .. tostring(damage.type))
	end
	if self:getstate("defense") then
		damage.valid_value = damage.valid_value * (1 - 0.2)
	end
	damage.value = math.floor(damage.value)
	damage.valid_value = math.max(0,math.floor(damage.valid_value))
	if damage.valid_value > 0 then
		self:addattr("hp",-damage.valid_value)
	end
	war:sendpackage(war:all_warobj(),"war_damage",{
		objid = self.objid,
		source_type = source.type,
		damage = damage,
		hp = self:getattr("hp"),
	})
end

-- 治疗
function cwarobj:cure(source,cure)
	assert(cure.value > 0)
	cure = deepcopy(cure)
	cure.value = cure.value * (math.random(1,150)/100 + 0.9)
	if cure.type == "cure" then
		-- 普通加血
		cure.valid_value = cure.value * (1 - self:getattr("hp_deaddn"))
	elseif cure.type == "abs_cure" then
		-- 绝对加血: 无视治疗抑制
		cure.valid_value = cure.value
	else
		error("invalid cure.type:" .. tostring(cure.type))
	end
	cure.value = math.floor(cure.value)
	cure.valid_value = math.max(0,math.floor(cure.valid_value))
	if cure.valid_value > 0 then
		self:addattr("hp",cure.valid_value)
	end
	war:sendpackage(war:all_warobj(),"war_cure",{
		objid = self.objid,
		source_type = source.type,
		cure = cure,
		hp = self:getattr("hp"),
	})
end

function cwarobj:ready_round(round)
	self.attrs.sp = self.baseattrs.sp * math.random(90,105) / 100
	self.attrs.sp = math.floor(self.attrs.sp)

	war:sendpackage({self},"war_ready_round",{
		objid = self.objid,
		sp = self.attrs.sp,
	})
	

	if war.wartype == 0 then
		if not table.isempty(self.skills.skills) then
			local skillid = randlist(self.skills.skills)
			local skill = self.skills:get(skillid)
			if skill.use_effect then
				if istrue(skill.use_effect.can_select_target) then
					local focus
					local targets = cselector.new(self:enemys())
										:not_die()
										:result()
					if not table.isempty(targets) then
						targets = shuffle(targets)
						for i,target in ipairs(targets) do
							if skill:can_use(target) then
								focus = target
								break
							end
						end
					end
					if focus then
						self:push_op({cmd="use_skill",request={skillid=skillid,focus=focus.objid}})
					end
				else
					if skill:can_use() then
						self:push_op({cmd="use_skill",request={skillid=skillid,focus=nil}})
					end
				end
			end
		end
	end
end

function cwarobj:begin_round(round)
	war:sendpackage({self},"war_begin_round",{})
	self.event:send("before_begin_round",round)
	self.event:send("after_begin_round",round)
end

function cwarobj:end_round(round)
	--war:sendpackage({self},"war_end_round",{})
	self.event:send("before_end_round",round)
	self.buffs:check_buff()
	self.aura_buffs:check_buff()
	for i,skillid in ipairs(self.skills.skills) do
		local skill = self.skills:get(skillid)
		skill.auras:check_aura()
	end
	self.event:send("after_end_round",round)
end

function cwarobj:enemys()
	local war = self.owner
	return war:enemys(self)
end

function cwarobj:is_player()
	if self.kind == "hero" and
		not self.is_ai then
		return true
	end
end

function cwarobj:push_op(op)
	table.insert(self.op_queue,op)
end

function cwarobj:pop_op()
	if #self.op_queue >= 1 then
		return table.remove(self.op_queue,1)
	end
end

function cwarobj:do_op(op)
	local cmd = assert(op.cmd)
	local request = assert(op.request)
	if cmd == "use_skill" then
		local skillid = assert(request.skillid)
		local focus = request.focus
		self:use_skill(skillid,focus)
	end
end

function cwarobj:pack()
	return {
		pid = self.pid,
		objid = self.objid,
		pos = self.pos,
		kind = self.kind,
		lv = self.lv,
		is_attacker = self.is_attacker,
		is_die = self.is_die,

		attrs = self.attrs,
		state = self.state,
		buffs = self.buffs:pack(),
		aura_buffs = self.aura_buffs:pack(),
		skills = self.skills:pack(),
	}
end

function cwarobj:pack4leave()
	return {
		pid = self.pid,
		objid = self.objid,
		pos = self.pos,
	}
end

return cwarobj
