--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000013 = class("cskill1000013",super,{
	type = 1000013,
	name = "火球术",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000013,
	_passive_effects = {},
	desc = "对单个目标造成$damge点火系伤害,并有$ratio几率让命中目标进入灼烧状态,持续$lifetime回合",
})

function cskill1000013:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000013:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local damage = {
			type = "fire_fs_atk",
		}
		local base_damage = self:base_damage()
		damage.value = base_damage * (1 + caster:getattr("fire_fs_atk_addn"))
		local bj = caster:getattr("bj")
		if ishit2(bj) then
			damage.value = self:bj_damage(damage.type,damage.value)
			damage.bj = true
		end
		damage.value = math.floor(damage.value)
		target:damage(effect,damage)
		local ratio = self:ratio()
		if ishit2(ratio) then
			local buff = helper.new_buff({
				type = helper.buff_type("灼烧状态"),
				source = self,
				owner = target,
			})
			assert(buff.lifetime > 0)
			local buff_damage = math.floor(damage.value / buff.lifetime)
			if buff_damage > 0 then
				buff.data = {
					state = {fire=true},
					damage = {type="abs_fire_fs_atk",value=buff_damage},
				}
				target.buffs:add(buff)
			end
		end
	end
end

function cskill1000013:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

function cskill1000013:ratio()
	local caster = self.owner
	return (0.05 + 0.1 * caster.lv / 100)
end

return cskill1000013
