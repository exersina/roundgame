--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000018 = class("ceffect4000018",super,{
	type = 4000018,
	name = "暴风雪",
	skill_type = 1000018,
	damage_type = "ice_fs_atk",
	event = "使用技能",
	can_select_target = 1,
	target_limit = {
		ally = 0,
		enemy = 1,
		hero = 1,
		pet = 1,
		monster = 1,
	},
	target_max_num = 5,
	cmd = "none",
	args = 0,
	desc = "对$num目标造成$damage点冰系伤害,如果命中目标处于冰冻状态,有$ratio几率延长1回合持续时间",
})

function ceffect4000018:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000018
