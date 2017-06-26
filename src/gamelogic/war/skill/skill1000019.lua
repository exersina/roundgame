--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000019 = class("cskill1000019",super,{
	type = 1000019,
	name = "细水长流",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000019,
	_passive_effects = {},
	desc = "对单个目标造成$damage点水系伤害,并有$ratio几率在其他$num目标之间弹射",
})

function cskill1000019:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000019:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		self:_do_effect(effect,target,focus)
		local ratio = self:ratio()
		if ishit2(ratio) then
			local target_num = self:target_num()
			local targets = cselector.new(caster:enemys())
								:not_die()
								:exclude({target.id})
								:result()
			if #targets > 0 then
				targets = shuffle(targets,nil,target_num)
				for i,target in ipairs(targets) do
					self:_do_effect(effect,target,focus)
				end
			end
		end
	end
end

function cskill1000019:_do_effect(effect,target,focus)
	local caster = self.owner
	local damage = {
		type = "water_fs_atk",
	}
	local base_damage = self:base_damage()
	damage.value = base_damage * (1 + caster:getattr("water_fs_atk_addn"))
	local bj = caster:getattr("water_fs_bj")
	if ishit2(bj) then
		damage.value = self:bj_damage(damage.type,damage.value)
		damage.bj = true
	end
	damage.value = math.floor(damage.value)
	target:damage(effect,damage)
end

function cskill1000019:base_damage()
	local caster = self.owner
	return caster.lv * 100
end

function cskill1000019:ratio()
	local caster = self.owner
	return (0.1 + 0.2 * caster.lv / 100)
end

function cskill1000019:target_num()
	local caster = self.owner
	local num = 1 + 2 * (caster.lv / 100)
	return math.floor(num)
end


return cskill1000019
