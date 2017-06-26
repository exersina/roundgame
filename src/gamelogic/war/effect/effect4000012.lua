--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000012 = class("ceffect4000012",super,{
	type = 4000012,
	name = "偷袭",
	skill_type = 1000012,
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
	desc = "偷袭目标,造成$damage物理伤害,如果是在潜行状态下施加,则触发暴击,如果目标死亡,继续偷袭下一个目标",
})

function ceffect4000012:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000012
