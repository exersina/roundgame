--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000006 = class("ceffect4000006",super,{
	type = 4000006,
	name = "刀扇",
	skill_type = 1000006,
	damage_type = "poison_fs_atk",
	event = "使用技能",
	can_select_target = 0,
	target_limit = {
		ally = 0,
		enemy = 0,
		hero = 0,
		pet = 0,
		monster = 0,
	},
	target_max_num = 3,
	cmd = "add_buff",
	args = 2000008,
	desc = "发出一片扇形带毒暗器,对命中敌军造成$damage毒系伤害,并让其进入中毒状态,持续$lifetime回合",
})

function ceffect4000006:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000006
