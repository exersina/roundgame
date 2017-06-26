--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000005 = class("cskill1000005",super,{
	type = 1000005,
	name = "刺骨",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000005,
	_passive_effects = {},
	desc = "对单个目标造成$damage物理伤害,有$ratio几率给其施加流血buff",
})

function cskill1000005:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000005:do_effect(effect,target,focus)
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
		local ratio = self:ratio()
		if ishit2(ratio) then
			local buff = helper.new_buff({
				type = helper.buff_type("流血"),
				owner = target,
				source = self,
			})
			assert(buff.lifetime > 0)
			local buff_damage = math.floor(damage.value / buff.lifetime)
			if buff_damage > 0 then
				buff.data = {
					damage = {type="abs_atk",value=buff_damage},
				}
				target.buffs:add(buff)
			end
		end
	end
end

function cskill1000005:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

function cskill1000005:ratio()
	local caster = self.owner
	return (0.1 + 0.2 * caster.lv /100)
end

return cskill1000005
