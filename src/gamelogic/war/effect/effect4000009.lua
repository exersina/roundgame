--<<effect 导表开始>>
local super = require "gamelogic.war.effect.effect"
ceffect4000009 = class("ceffect4000009",super,{
	type = 4000009,
	name = "肾击",
	skill_type = 1000009,
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
	desc = "对目标造成$damage点物理伤害,如果目标处于混乱状态,继续对下一目标施加肾击",
})

function ceffect4000009:init(option)
	super.init(self,option)
--<<effect 导表结束>>

end --导表生成


return ceffect4000009
