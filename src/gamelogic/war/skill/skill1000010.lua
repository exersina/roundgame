--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000010 = class("cskill1000010",super,{
	type = 1000010,
	name = "潜行",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000010,
	_passive_effects = {},
	desc = "进入潜行状态,持续$lifetime回合,期间进行任何动作潜行将消失",
})

function cskill1000010:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000010:do_effect(effect,target,focus)
	local caster = self.owner
	if self.use_effect == effect then
		local buff = helper.new_buff({
			type = helper.buff_type("潜行状态"),
			source = self,
			owner = target,
		})
		buff.data = {
			state = {sneak=true},
		}
		caster.buffs:add(buff)
	end
end

return cskill1000010
