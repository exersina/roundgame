--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000016 = class("cskill1000016",super,{
	type = 1000016,
	name = "寒冰箭",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000016,
	_passive_effects = {},
	desc = "对单个目标造成$damage点冰系伤害，如果对方处于冰冻状态,则增加$addn%点冰系伤害",
})

function cskill1000016:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成


function cskill1000016:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local damage = {
			type = "ice_fs_atk",
		}
		local base_damage = self:base_damage()
		local ice_fs_atk_addn = caster:getattr("ice_fs_atk_addn")
		if target:getstate("freeze") then
			ice_fs_atk_addn = ice_fs_atk_addn + self:addn()
		end
		damage.value = base_damage * (1 + ice_fs_atk_addn)
		local bj = caster:getattr("ice_fs_bj")
		if ishit2(bj) then
			damage.value = self:bj_damage(damage.type,damage.value)
			damage.bj = true
		end
		damage.value = math.floor(damage.value)
		target:damage(effect,damage)
	end
end

function cskill1000016:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

function cskill1000016:addn()
	local caster = self.owner
	return (0.1 + 0.2 * caster.lv / 100)
end

return cskill1000016
