--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000008 = class("cskill1000008",super,{
	type = 1000008,
	name = "闷棍",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000008,
	_passive_effects = {},
	desc = "被莫名棒子击中,造成大脑震荡,进入混乱状态,持续$lifetime回合",
})

function cskill1000008:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000008:do_effect(effect,target,focus)
	if self.use_effect == effect then
		local buff = helper.new_buff({
			type = helper.buff_type("混乱状态"),
			owner = target,
			source = self,
		})
		buff.data = {
			state = {chaos=true},
		}
		target.buffs:add(buff)
	end
end

return cskill1000008
