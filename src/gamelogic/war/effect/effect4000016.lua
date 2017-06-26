--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000016 = class("ceffect4000016",super,{
	type = 4000016,
	name = "寒冰箭",
	skill_type = 1000016,
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
	target_max_num = 1,
	cmd = "none",
	args = 0,
	desc = "对单个目标造成$damage点冰系伤害，如果对方处于冰冻状态,则增加$addn%点冰系伤害",
})

function ceffect4000016:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000016
