--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000019 = class("ceffect4000019",super,{
	type = 4000019,
	name = "细水长流",
	skill_type = 1000019,
	damage_type = "water_fs_atk",
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
	desc = "对单个目标造成$damage点水系伤害,并有$ratio几率在其他$num目标之间弹射",
})

function ceffect4000019:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000019
