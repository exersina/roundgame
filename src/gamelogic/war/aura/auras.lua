cauras = class("cauras")

function cauras:init(option)
	self.owner = option.owner
	self.auras = {}
end

function cauras:enter_war()
	for i,aura in ipairs(self.auras) do
		aura:enter_war()
	end
end

function cauras:leave_war()
	for i,aura in ipairs(self.auras) do
		aura:leave_war()
	end
end

function cauras:get(id)
	return objmgr:getby("caura",id)
end

function cauras:add(aura)
	assert(aura.source)
	assert(aura.owner)
	table.insert(self.auras,aura.objid)
	aura:on_add()
end

function cauras:del(id)
	local pos = table.find(self.auras,id)
	if pos then
		local aura = self:get(id)
		aura:on_del()
		table.remove(self.auras,pos)
		return objmgr:delby("caura",id)
	end
end

-- 检查过期光环
function cauras:check_aura()
	for i=#self.auras,1,-1 do
		local id = self.auras[i]
		local aura = self:get(id)
		if aura.lifetime ~= -1 and
			aura.lifetime + aura.create_round - 1 <= war.round then
			aura:on_finish()
		end
	end
end

function cauras:pack()
	local auras = {}
	for i,id in ipairs(self.auras) do
		local aura = objmgr:getby("caura",id)
		auras[#auras+1] = aura:pack()
	end
	return auras
end

function cauras:destroy()
	local auras = deepcopy(self.auras)
	for i,id in ipairs(auras) do
		self:del(id)
	end
end

return cauras
