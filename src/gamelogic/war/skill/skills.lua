cskills = class("cskills")

function cskills:init(option)
	self.source = option.source
	self.owner = option.owner
	self.skills = {}
end

function cskills:get(id)
	return objmgr:getby("cskill",id)
end

function cskills:add(skill)
	assert(skill.source)
	assert(skill.owner)
	table.insert(self.skills,skill.objid)
end

function cskills:del(id)
	local pos = table.find(self.skills,id)
	if pos then
		table.remove(self.skills,pos)
		return objmgr:delby("cskill",id)
	end
end

function cskills:pack()
	local skills = {}
	for i,id in ipairs(self.skills) do
		local skill = objmgr:getby("cskill",id)
		skills[#skills+1] = skill:pack()
	end
	return skills
end

function cskills:destroy()
	local skills = deepcopy(self.skills)
	for i,id in ipairs(skills) do
		self:del(id)
	end
end

return cskills
