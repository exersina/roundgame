--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000006 = class("cskill1000006",super,{
	type = 1000006,
	name = "刀扇",
	canuse = 1,
	cd = 3,
	use_max_cnt = -1,
	_use_effect = 4000006,
	_passive_effects = {},
	desc = "发出一片扇形带毒暗器,对命中敌军造成$damage毒系伤害,并让其进入中毒状态,持续$lifetime回合",
})

function cskill1000006:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成


function cskill1000006:get_targets(focus)
	local caster = self.owner
	local targets = cselector.new(caster:enemys())
						:not_die()
						:result()
	local limit = self.use_effect.target_max_num
	targets = self:sort_targets(targets,limit)
	return targets
end

function cskill1000006:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local damage = {
			type = "poison_fs_atk",
		}
		local base_damage = self:base_damage()
		damage.value = base_damage * (1 + caster:getattr("poison_fs_atk_addn"))
		if target ~= focus then
			damage.value = damage.value * 0.8
		end
		damage.value = math.floor(damage.value)
		target:damage(effect,damage)
		local buff = helper.new_buff({
			type = helper.buff_type("中毒状态"),
			source = self,
			owner = target,
		})
		assert(buff.lifetime > 0)
		local buff_damage = math.floor(damage.value / buff.lifetime)
		if buff_damage > 0 then
			buff.data = {
				state = {poison = true},
				damage = {type="abs_poison_fs_atk",value=buff_damage},
			}
			target.buffs:add(buff)
		end
	end
end

function cskill1000006:base_damage()
	local caster = self.owner
	return caster.lv * 100
end


return cskill1000006
