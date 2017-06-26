--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000003 = class("ceffect4000003",super,{
	type = 4000003,
	name = "防御",
	skill_type = 1000003,
	damage_type = "none",
	event = "使用技能",
	can_select_target = 0,
	target_limit = {
		ally = 0,
		enemy = 0,
		hero = 0,
		pet = 0,
		monster = 0,
	},
	target_max_num = 0,
	cmd = "none",
	args = 0,
	desc = "None",
})

function ceffect4000003:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000003
