--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000011 = class("cskill1000011",super,{
	type = 1000011,
	name = "消失",
	canuse = 0,
	cd = 0,
	use_max_cnt = -1,
	_use_effect = 4000011,
	_passive_effects = {},
	desc = "被动:进场第一回合进入潜行状态,每次偷袭目标有$ratio几率进入潜行状态",
})

function cskill1000011:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000011:on_add()
	cskill.on_add(self)
	local owner = self.owner
	self.event:listen(owner,"after_enter_war")
	self.event:listen(owner,"after_use_skill")
end

function cskill1000011:after_enter_war(session)
	local buff = helper.new_buff({
		type = helper.buff_type("潜行状态"),
		source = self,
		owner = self.owner,
	})
	self.owner.buffs:add(buff)
end

function cskill1000011:after_use_skill(session,skillid,focus)
	local skill = objmgr:getby("cskill",skillid)
	if skill.type == helper.skill_type("偷袭") then
		local ratio = self:ratio()
		if ishit2(ratio) then
			local buff = helper.new_buff({
				type = helper.buff_type("潜行状态"),
				source = self,
				owner = self.owner,
			})
			self.owner.buffs:add(buff)
		end
	end
end

function cskill1000011:ratio()
	local caster = self.owner
	return (0.1 + 0.1 * caster.lv / 100)
end

return cskill1000011
