--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000005 = class("ceffect4000005",super,{
	type = 4000005,
	name = "刺骨",
	skill_type = 1000005,
	damage_type = "atk",
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
	desc = "对单个目标造成$damage物理伤害,有$ratio几率给其施加流血buff",
})

function ceffect4000005:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000005
