--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000018 = class("cskill1000018",super,{
	type = 1000018,
	name = "暴风雪",
	canuse = 1,
	cd = 3,
	use_max_cnt = -1,
	_use_effect = 4000018,
	_passive_effects = {},
	desc = "对$num目标造成$damage点冰系伤害,如果命中目标处于冰冻状态,有$ratio几率延长1回合持续时间",
})

function cskill1000018:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000018:get_targets(focus)
	local caster = self.owner
	local targets = cselector.new(caster:enemys())
						:not_die()
						:result()
	local limit = self.use_effect.target_max_num
	targets = self:sort_targets(targets,limit)
	return targets
end

function cskill1000018:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local damage = {
			type = "ice_fs_atk",
		}
		local base_damage = self:base_damage()
		damage.value = base_damage * (1 + caster:getattr("ice_fs_atk_addn"))
		local bj = caster:getattr("ice_fs_bj")
		if ishit2(bj) then
			damage.value = self:bj_damage(damage.type,damage.value)
			damage.bj = true
		end
		damage.value = math.floor(damage.value)
		target:damage(effect,damage)
		local found_buff
		for i,id in ipairs(target.buffs.buffs) do
			local buff = target.buffs:get(id)
			if buff.name == "冰冻状态" then
				found_buff = buff
				break
			end
		end
		if found_buff then
			found_buff.lifetime = found_buff.lifetime + 1
		end
	end
end

function cskill1000018:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

function cskill1000018:ratio()
	local caster = self.owner
	return (0.1 + 0.1 * caster.lv / 100)
end


return cskill1000018
