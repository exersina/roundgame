cbuffs = class("cbuffs")

function cbuffs:init(option)
	self.owner = option.owner
	self.buffs = {}
end

function cbuffs:get(id)
	return objmgr:getby("cbuff",id)
end

function cbuffs:max_lifetime(buff,lifetime,round)
	if buff.create_round + buff.lifetime > lifetime + round then
		return buff.create_round + buff.lifetime - round
	else
		return lifetime
	end
end

function cbuffs:add(buff)
	assert(buff.source)
	assert(buff.owner)
	local round = war.round
	local cnt = 0
	for i=#self.buffs,1,-1 do
		local id = self.buffs[i]
		old = self:get(id)
		if old.type == buff.type and (old.source == buff.source or buff.cover_global) then
			if buff.cover_max == 1 then
				if buff:on_cover(old) then
					self:del(old.objid)
				else
					return
				end
			else
				cnt = cnt + 1
			end
		end
	end
	if cnt < buff.cover_max then
		table.insert(self.buffs,buff.objid)
		buff:on_add()
		return true
	else
		--objmgr:del(buff.objid)
	end
	return false
end

function cbuffs:del(id)
	local pos = table.find(self.buffs,id)
	if pos then
		local buff = self:get(id)
		buff:on_del()
		table.remove(self.buffs,pos)
		return objmgr:delby("cbuff",id)
	end
end

function cbuffs:check_buff()
	for i=#self.buffs,1,-1 do
		local id = self.buffs[i]
		local buff = self:get(id)
		if buff.lifetime ~= -1 and
			buff.lifetime + buff.create_round - 1 <= war.round then
			buff:on_finish()
		end
	end
end

function cbuffs:destroy()
	local buffs = deepcopy(self.buffs)
	for i,id in ipairs(buffs) do
		self:del(id)
	end
end

function cbuffs:pack()
	local buffs = {}
	for i,id in ipairs(self.buffs) do
		local buff = objmgr:getby("cbuff",id)
		buffs[#buffs+1] = buff:pack()
	end
	return buffs
end

return cbuffs
