--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000004 = class("ceffect4000004",super,{
	type = 4000004,
	name = "割裂",
	skill_type = 1000004,
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
	cmd = "add_buff",
	args = 2000010,
	desc = "对单个目标造成$damge点物理伤害,如果触发连击则给目标一个流血buff",
})

function ceffect4000004:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000004
