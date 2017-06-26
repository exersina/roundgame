--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000014 = class("ceffect4000014",super,{
	type = 4000014,
	name = "龙息术",
	skill_type = 1000014,
	damage_type = "fire_fs_atk",
	event = "使用技能",
	can_select_target = 1,
	target_limit = {
		ally = 0,
		enemy = 1,
		hero = 1,
		pet = 1,
		monster = 1,
	},
	target_max_num = 3,
	cmd = "none",
	args = 0,
	desc = "对焦点周围最多$num目标造成$damage点火系伤害",
})

function ceffect4000014:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000014
