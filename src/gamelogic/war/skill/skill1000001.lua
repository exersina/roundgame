--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000001 = class("cskill1000001",super,{
	type = 1000001,
	name = "治疗",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000001,
	_passive_effects = {},
	desc = "给单个目标$addhp点治疗",
})

function cskill1000001:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000001:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local cure = {
			type = "cure",
		}
		local base_addhp = self:base_addhp()
		cure.value = base_addhp * ( 1 + caster:getattr("hp_addn"))
		cure.value = math.floor(cure.value)
		target:cure(effect,cure)
	end
end

function cskill1000001:base_addhp()
	local caster = self.owner
	return caster.lv * 100
end

return cskill1000001
