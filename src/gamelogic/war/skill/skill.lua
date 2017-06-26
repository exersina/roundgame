cskill = class("cskill")

function cskill:init(option)
	objmgr:add("cskill",self)
	--self.name = option.name
	self.owner = option.owner
	self.source = option.source
	self.use_cnt = 0
	self.use_round = nil
	if self._use_effect ~= 0 then
		self.use_effect = helper.new_effect({
			type = self._use_effect,
			owner = self,
		})
	end
	if not table.isempty(self._passive_effects) then
		self.passive_effects = {}
		for i,effect_type in ipairs(self._passive_effects) do
			self.passive_effects[#self.passive_effects+1] = helper.new_effect({
				type = effect_type,
				owner = self,
			})
		end
	end
	self.auras = cauras.new({owner=self})
end

-- 可重写
function cskill:on_add()
	if war.state ~= "init" and war.state ~= "gameover" then
		war:sendpackage(war:all_warobj(),"war_add_skill",{
			skill = self:pack(),
		})
	end
end

-- 可重写
function cskill:on_del()
	if war.state ~= "init" and war.state ~= "gameover" then
		war:sendpackage(war:all_warobj(),"war_del_skill",{
			skill = self:pack4del(),
		})
	end
end

function cskill:can_use(focus)
	if not istrue(self.canuse) or not self.use_effect then
		return false,"非主动技能"
	end
	if self.use_max_cnt ~= -1 and self.use_cnt >= self.use_max_cnt then
		return false,"使用次数达到上限"
	end
	if self.use_round then
		if self.use_round + self.cd > war.round then
			return false,"CD"
		end
	end
	local effect = self.use_effect
	if istrue(effect.can_select_target) and focus then
		local is_ally = (focus.is_attacker == self.owner.is_attacker)
		if not ((is_ally and istrue(effect.target_limit.ally)) or
			(not is_ally and istrue(effect.target_limit.enemy))) then
			return false,"无效目标"
		end
		local kind = focus.kind
		if not istrue(effect.target_limit[kind]) then
			return false,"无效目标"
		end
	end
	return true
end

function cskill:use(focus)
	local effect = self.use_effect
	local targets = self:get_targets(focus)
	if not table.isempty(targets) then
		local targets_id = table.map(function (target) return target.objid end,targets)
		local focus_id = focus and focus.objid
		logger.logf("info","war","op=use_skill,warid=%s,caster=%s,caster_pid=%s,skillid=%s,skilltype=%s,focus=%s,targets=%s",war.id,self.owner.objid,self.owner.pid,self.objid,self.type,focus_id,targets_id)
		self.use_cnt = self.use_cnt + 1
		self.use_round = war.round
		war:sendpackage(war:all_warobj(),"war_use_skill",{
			caster = self.owner.objid,
			skillid = self.objid,
			skilltype = self.type,
			focus = focus_id,
			targets = targets_id,
			use_cnt = self.use_cnt,
			use_round = self.use_round,
		})
		self.owner.event:send("before_use_skill",self,focus,targets)
		for i,target in ipairs(targets) do
			-- TODO: 转换目标
			self:do_effect(effect,target,focus)
		end
		self.owner.event:send("after_use_skill",self,focus,targets)
	end
end

function cskill:do_effect(effect,target,focus)
end

-- 可重写
function cskill:get_targets(focus)
	return {focus}
end

function cskill:sort_targets(targets,limit)
	local len = #targets
	local loopcnt = math.min(len,limit)
	for i=1,loopcnt do
		for j=i,len-1 do
			local sp1 = targets[j]:getattr("sp")
			local sp2 = targets[j+1]:getattr("sp")
			if sp1 > sp2 then
				targets[j],targets[j+1] = targets[j+1],targets[j]
			end
		end
	end
	local result = {}
	for i=1,loopcnt do
		result[#result+1] = targets[len-i+1]
	end
	return result
end

function cskill:lj_damages(damage,ljcnt)
	local scales = {0.5,0.3,0.2,0.1,0.05,0.01}
	local damages = {}
	for i=1,ljcnt do
		local scale = scales[i] or scales[#scales]
		local dmg = math.floor(damage * scale)
		dmg = math.max(1,dmg)
		damages[#damages+1] = dmg
	end
	return damages
end

function cskill:bj_damage(damage_type,damage)
	if damage_type == "atk" then
		damage = damage * 3.0
	end
	return damage
end

function cskill:pack()
	return {
		source = self.source.objid,
		owner = self.owner.objid,
		objid = self.objid,
		type = self.type,
		use_cnt = self.use_cnt,
		use_round = self.use_round,
		auras = self.auras:pack(),
	}
end

function cskill:pack4del()
	return {
		source = self.source.objid,
		owner = self.owner.objid,
		objid = self.objid,
		type = self.type,
	}
end

function cskill:destroy()
	self.auras:destroy()
end

return cskill
