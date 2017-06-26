--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000007 = class("cskill1000007",super,{
	type = 1000007,
	name = "背刺",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000007,
	_passive_effects = {},
	desc = "对目标造成$damage点物理伤害",
})

function cskill1000007:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000007:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local damage = {
			type = "atk",
		}
		local base_damage = self:base_damage()
		damage.value = base_damage * (1 + caster:getattr("atk_addn"))
		local bj = caster:getattr("bj")
		if ishit2(bj) then
			damage.value = self:bj_damage(damage.type,damage.value)
			damage.bj = true
		end
		damage.value = math.floor(damage.value)
		target:damage(effect,damage)
	end
end

function cskill1000007:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

return cskill1000007
