--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000004 = class("cskill1000004",super,{
	type = 1000004,
	name = "割裂",
	canuse = 1,
	cd = 3,
	use_max_cnt = -1,
	_use_effect = 4000004,
	_passive_effects = {},
	desc = "对单个目标造成$damge点物理伤害,如果触发连击则给目标一个流血buff",
})

function cskill1000004:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000004:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local base_damage = self:base_damage()
		local damage = self:_do_effect(effect,target,focus,base_damage)
		local ljcnt = caster:getattr("ljcnt")
		if ljcnt > 0 then
			local lj = caster:getattr("lj")
			if ishit2(lj) then
				local dmgs = self:lj_damages(base_damage,ljcnt)
				for i,dmg in ipairs(dmgs) do
					self:_do_effect(effect,target,focus,dmg)
				end
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
end

function cskill1000004:_do_effect(effect,target,focus,base_damage)
	local damage = {
		type = "atk",
	}
	local caster = self.owner
	damage.value = base_damage * (1 + caster:getattr("atk_addn"))
	local bj = caster:getattr("bj")
	if ishit2(bj) then
		damage.value = self:bj_damage(damage.type,damage.value)
		damage.bj = true
	end
	damage.value = math.floor(damage.value)
	target:damage(effect,damage)
	return damage
end

function cskill1000004:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

return cskill1000004
