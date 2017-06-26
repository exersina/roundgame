--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000008 = class("ceffect4000008",super,{
	type = 4000008,
	name = "闷棍",
	skill_type = 1000008,
	damage_type = "none",
	event = "使用技能",
	can_select_target = 1,
	target_limit = {
		ally = 0,
		enemy = 1,
		hero = 1,
		pet = 1,
		monster = 1,
	},
	target_max_num = 1,
	cmd = "none",
	args = 0,
	desc = "被莫名棒子击中,造成大脑震荡,进入混乱状态,持续$lifetime回合",
})

function ceffect4000008:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000008
