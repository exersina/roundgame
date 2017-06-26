--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000015 = class("cskill1000015",super,{
	type = 1000015,
	name = "烈焰风暴",
	canuse = 1,
	cd = 3,
	use_max_cnt = -1,
	_use_effect = 4000015,
	_passive_effects = {},
	desc = "对$num个目标造成$damage点火系伤害",
})

function cskill1000015:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成


function cskill1000015:get_targets(focus)
	local caster = self.owner
	local targets = cselector.new(caster:enemys())
						:not_die()
						:result()
	local limit = self.use_effect.target_max_num
	targets = self:sort_targets(targets,limit)
	return targets
end

function cskill1000015:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local damage = {
			type = "fire_fs_atk",
		}
		local base_damage = self:base_damage()
		damage.value = base_damage * (1 + caster:getattr("fire_fs_atk_addn"))
		local bj = caster:getattr("fire_fs_bj")
		if ishit2(bj) then
			damage.value = self:bj_damage(damage.type,damage.value)
			damage.bj = true
		end
		damage.value = math.floor(damage.value)
		target:damage(effect,damage)
	end
end

function cskill1000015:base_damage()
	local caster = self.owner
	return caster.lv * 100
end


return cskill1000015
