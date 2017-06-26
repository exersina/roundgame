--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000017 = class("cskill1000017",super,{
	type = 1000017,
	name = "冰锥术",
	canuse = 1,
	cd = 2,
	use_max_cnt = -1,
	_use_effect = 4000017,
	_passive_effects = {},
	desc = "对焦点周围最多$num目标造成$damage点冰系伤害,并有$ratio几率让命中目标进入冰冻状态,持续$lifetime回合",
})

function cskill1000017:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成


function cskill1000017:get_targets(focus)
	local caster = self.owner
	local targets = cselector.new(caster:enemys())
						:around(focus)
						:not_die()
						:result()
	local limit = self.use_effect.target_max_num
	targets = self:sort_targets(targets,limit)
	return targets
end

function cskill1000017:do_effect(effect,target,focus)
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
		local ratio = self:ratio()
		if ishit2(ratio) then
			local buff = helper.new_buff({
				type = helper.buff_type("冰冻状态"),
				source = self,
				owner = target,
			})
			buff.data = {
				state = {freeze=true},
			}
			target.buffs:add(buff)
		end
	end
end

function cskill1000017:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

function cskill1000017:ratio()
	local caster = self.owner
	return (0.1 + 0.2 * caster.lv / 100)
end

return cskill1000017
