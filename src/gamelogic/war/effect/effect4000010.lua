--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000010 = class("ceffect4000010",super,{
	type = 4000010,
	name = "潜行",
	skill_type = 1000010,
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
	desc = "进入潜行状态,持续$lifetime回合,期间进行任何动作潜行将消失",
})

function ceffect4000010:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000010
