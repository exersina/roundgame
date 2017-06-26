cselector = class("cselector")

function cselector:init(list)
	local warobjs = {}
	for i,id in ipairs(list) do
		local warobj
		if type(id) == "number" then
			warobj = objmgr:getby("cwarobj",id)
		else
			warobj = id
		end
		table.insert(warobjs,warobj)
	end
	self.warobjs = warobjs
end

function cselector:result()
	return self.warobjs
end

function cselector:exclude(exclude)
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if not table.find(exclude,warobj.id) then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self

end

function cselector:is_ally(who)
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if warobj.is_attacker == who.is_attacker then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:is_enemy(who)
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if warobj.is_attacker ~= who.is_attacker then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:is_pet()
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if warobj.kind == "pet" then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:is_hero()
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if warobj.kind == "hero" then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:is_monster()
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if warobj.kind == "monster" then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:is_player()
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if warobj:is_player() then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end


function cselector:kind_of(...)
	local all_kind = {...}
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if table.find(all_kind,warobj.kind) then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:pos_in(range)
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if table.find(range,warobj.pos) then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:around(focus)
	if #self.warobjs == 0 then
		return self
	end
	local around_pos = {
				focus.pos,
				focus.pos-1,
				focus.pos+1,
				focus.pos+10,
				focus.pos-10,
				focus.pos+9,
				focus.pos-9,
				focus.pos+11,
				focus.pos-11,
			}
	return self:pos_in(around_pos)
end

function cselector:is_die()
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if warobj.is_die then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:not_die()
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if not warobj.is_die then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

function cselector:filter(func)
	if #self.warobjs == 0 then
		return self
	end
	local warobjs = {}
	for i,warobj in ipairs(self.warobjs) do
		if func(warobj) then
			warobjs[#warobjs+1] = warobj
		end
	end
	self.warobjs = warobjs
	return self
end

return cselector
