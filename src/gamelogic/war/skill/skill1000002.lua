--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000002 = class("cskill1000002",super,{
	type = 1000002,
	name = "普攻",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000002,
	_passive_effects = {},
	desc = "对单个目标造成$damage点物理伤害",
})

function cskill1000002:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000002:do_effect(effect,target,focus)
	if self.use_effect == effect then
		local damage = {
			type = "atk",
		}
		local attacker = self.owner
		local base_damage = self:base_damage()
		damage.value = base_damage * (1 + attacker:getattr("atk_addn"))
		local bj = attacker:getattr("bj")
		if ishit2(bj) then
			damage.value = self:bj_damage(damage.type,damage.value)
			damage.bj = true
		end
		damage.value = math.floor(damage.value)
		target:damage(effect,damage)
	end
end

function cskill1000002:base_damage()
	return self.owner:getattr("atk")
end

return cskill1000002
