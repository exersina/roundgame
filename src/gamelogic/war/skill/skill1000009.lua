--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000009 = class("cskill1000009",super,{
	type = 1000009,
	name = "肾击",
	canuse = 1,
	cd = 2,
	use_max_cnt = -1,
	_use_effect = 4000009,
	_passive_effects = {},
	desc = "对目标造成$damage点物理伤害,如果目标处于混乱状态,$ratio概率对下一目标施加肾击",
})

function cskill1000009:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000009:do_effect(effect,target,focus)
	local caster = self.owner
	local war = caster.owner
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
		local ratio = self:ratio()
		if ishit2(ratio) and target:getstate("chaos") then
			local targets = cselector.new(caster:enemys())
								:not_die()
								:exclude({target.id})
								:result()
			if #targets > 0 then
				local enemy = randlist(targets)
				self:do_effect(effect,enemy,focus)
			end
		end
	end
end

function cskill1000009:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

function cskill1000009:ratio()
	local caster = self.owner
	return (0.1 + 0.3 * caster.lv/100)
end

return cskill1000009
