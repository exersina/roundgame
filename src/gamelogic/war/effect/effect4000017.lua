--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000017 = class("ceffect4000017",super,{
	type = 4000017,
	name = "冰锥术",
	skill_type = 1000017,
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
	target_max_num = 3,
	cmd = "none",
	args = 0,
	desc = "对焦点周围最多$num目标造成$damage点冰系伤害,并有$ratio几率让命中目标进入冰冻状态,持续$lifetime回合",
})

function ceffect4000017:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000017
