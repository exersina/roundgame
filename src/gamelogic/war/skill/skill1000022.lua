--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000022 = class("cskill1000022",super,{
	type = 1000022,
	name = "专注光环",
	canuse = 0,
	cd = 0,
	use_max_cnt = -1,
	_use_effect = 0,
	_passive_effects = {},
	desc = "提升友方$defense点防御力",
})

function cskill1000022:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000022:on_add()
	cskill.on_add(self)
	local owner = self.owner
	local aura = helper.new_aura({
		type = helper.aura_type("专注光环"),
		source = self,
		owner = owner,
	})
	self.auras:add(aura)
end

return cskill1000022
