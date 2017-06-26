--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000013 = class("ceffect4000013",super,{
	type = 4000013,
	name = "火球术",
	skill_type = 1000013,
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
	target_max_num = 1,
	cmd = "none",
	args = 0,
	desc = "对单个目标造成$damge点火系伤害,并有$ratio几率让命中目标进入灼烧状态,持续$lifetime回合",
})

function ceffect4000013:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000013
