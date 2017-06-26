--<<skill 导表开始>>
local super = require "gamelogic.war.skill.skill"
cskill1000003 = class("cskill1000003",super,{
	type = 1000003,
	name = "防御",
	canuse = 1,
	cd = 1,
	use_max_cnt = -1,
	_use_effect = 4000003,
	_passive_effects = {},
	desc = "进入防御状态",
})

function cskill1000003:init(option)
	super.init(self,option)
--<<skill 导表结束>>

end --导表生成

function cskill1000003:do_effect(effect,target,focus)
	if self.use_effect == effect then
		self.owner:setstate("defense",true)
	end
end

return cskill1000003
