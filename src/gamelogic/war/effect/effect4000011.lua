--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000011 = class("ceffect4000011",super,{
	type = 4000011,
	name = "消失",
	skill_type = 1000011,
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
	desc = "被动:进场第一回合进入潜行状态,每次偷袭目标有$ratio几率进入潜行状态",
})

function ceffect4000011:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000011
