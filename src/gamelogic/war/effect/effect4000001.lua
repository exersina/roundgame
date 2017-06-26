--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000001 = class("ceffect4000001",super,{
	type = 4000001,
	name = "治疗",
	skill_type = 1000001,
	damage_type = "cure",
	event = "使用技能",
	can_select_target = 1,
	target_limit = {
		ally = 1,
		enemy = 1,
		hero = 1,
		pet = 1,
		monster = 1,
	},
	target_max_num = 1,
	cmd = "none",
	args = 0,
	desc = "None",
})

function ceffect4000001:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000001
