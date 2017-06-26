cbuff = class("cbuff")

function cbuff:init(option)
	objmgr:add("cbuff",self)
	-- owner: cwarobj
	self.owner = option.owner
	-- source: cwarobj/cskill/caura
	self.source = option.source
	self.create_round = war.round
end

function cbuff:del_from_owner()
	local owner = self.owner
	local source = self.source
	if source.objtype == "caura" then
		owner.aura_buffs:del(self.objid)
	else
		owner.buffs:del(self.objid)
	end
end

function cbuff:lifetime_diff(other)
	local diff = (self.create_round + self.lifetime) - (other.create_round + other.lifetime)
	return diff
end

-- 可重写
function cbuff:on_add()
	if war.state ~= "init" and war.state ~= "gameover" then
		war:sendpackage(war:all_warobj(),"war_add_buff",{
			buff = self:pack(),
		})
	end
end

-- 可重写
function cbuff:on_del()
	if war.state ~= "init" and war.state ~= "gameover" then
		war:sendpackage(war:all_warobj(),"war_del_buff",{
			buff = self:pack4del(),
		})
	end
end

-- 可重写
function cbuff:on_finish()
	self:del_from_owner()
end

-- 可重写
function cbuff:on_cover(old)
	if self.cover_kind == "first" then
		return false
	elseif self.cover_kind == "last" then
	elseif self.cover_kind == "min" then
		if self.data.add and old.data.add then
			for k,v in pairs(self.data.add) do
				if old.data.add[k] and old.data.add[k] < v then
					self.data.add[k] = old.data.add[k]
				end
			end
			local diff = self:lifetime_diff(old)
			if diff < 0 then
				self.lifetime = self.lifetime - diff
			end
		end
	elseif self.cover_kind == "max" then
		if self.data.add and old.data.add then
			for k,v in pairs(self.data.add) do
				if old.data.add[k] and old.data.add[k] > v then
					self.data.add[k] = old.data.add[k]
				end
			end
			local diff = self:lifetime_diff(old)
			if diff < 0 then
				self.lifetime = self.lifetime - diff
			end
		end
	end
	return true
end

function cbuff:pack()
	return {
		source = self.source.objid,
		owner = self.owner.objid,
		objid = self.objid,
		type = self.type,
		data = self.data,
	}
end

function cbuff:pack4del()
	return {
		source = self.source.objid,
		owner = self.owner.objid,
		objid = self.objid,
	}
end

return cbuff
