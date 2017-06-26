--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000012 = class("cskill1000012",super,{
	type = 1000012,
	name = "偷袭",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000012,
	_passive_effects = {},
	desc = "偷袭目标,造成$damage物理伤害,如果是在潜行状态下施加,则触发暴击,如果目标死亡,继续偷袭下一个目标",
})

function cskill1000012:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000012:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local damage = {
			type = "atk",
		}
		local base_damage = self:base_damage()
		damage.value = base_damage * (1 + caster:getattr("atk_addn"))
		local bj = caster:getattr("bj")
		if caster:getstate("sneak") or ishit2(bj) then
			damage.value = self:bj_damage(damage.type,damage.value)
			damage.bj = true
		end
		damage.value = math.floor(damage.value)
		target:damage(effect,damage)
		if target.is_die then
			local targets = cselector.new(caster:enemys())
								:not_die()
								:result()
			if #targets > 0 then
				local target = randlist(targets)
				self:do_effect(effect,target,focus)
			end
		end
	end
end

function cskill1000012:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

return cskill1000012
