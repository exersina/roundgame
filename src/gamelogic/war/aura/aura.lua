caura = class("caura")

function caura:init(option)
	objmgr:add("caura",self)
	self.owner = option.owner
	self.source = option.source
	self.aura_to = {}	-- 光环影响到的对象
end

function caura:enter_war()
end

function caura:leave_war()
	for id in pairs(self.aura_to) do
		local warobj = war:get_warobj(id)
		self:del_buff(warobj)
	end
end

function caura:on_see(who)
end

function caura:on_finish()
	self:del_from_owner()
end

function caura:on_add()
	if war.state ~= "init" and war.state ~= "gameover" then
		war:sendpackage(war:all_warobj(),"war_add_aura",{
			aura = self:pack(),
		})
	end
end

function caura:on_del()
	self:leave_war()
	if war.state ~= "init" and war.state ~= "gameover" then
		war:sendpackage(war:all_warobj(),"war_del_aura",{
			aura = self:pack4del(),
		})
	end
end

function caura:del_from_owner()
	local owner = self.owner
	owner.auras:del(self.objid)
end

function caura:add_buff(warobj)
	local objid = warobj.objid
	if not self.aura_to[objid] then
		self.aura_to[objid] = true
		local buff = helper.new_buff({
			type = self.buff_type,
			source = self,
			owner = warobj,
		})
		warobj.aura_buffs:add(buff)
	end
end

function caura:del_buff(warobj)
	local objid = warobj.objid
	if self.aura_to[objid] then
		self.aura_to[objid] = nil
		local del_buffs = {}
		for i,id in ipairs(warobj.aura_buffs.buffs) do
			local buff = warobj.aura_buffs:get(id)
			if buff.source == self then
				del_buffs[#del_buffs+1] = id
			end
		end
		for i,id in ipairs(del_buffs) do
			warobj.aura_buffs:del(id)
		end
	end
end

function caura:destroy()
	local aura_to = self.aura_to
	self.aura_to = {}
	for objid in pairs(aura_to) do
		local warobj = objmgr:getby("cwarobj",objid)
		self:del_buff(warobj)
	end
end

function caura:pack()
	return {
		source = self.source.objid,
		owner = self.owner.objid,
		objid = self.objid,
		type = self.type,
	}
end

function caura:pack4del()
	return {
		source = self.source.objid,
		owner = self.owner.objid,
		objid = self.objid,
	}
end

return caura
