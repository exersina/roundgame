--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000005 = class("cbuff2000005",super,{
	type = 2000005,
	name = "灼烧状态",
	debuff = 1,
	dotbuff = 1,
	cover_max = 1,
	cover_kind = "max",
	lifetime = 2,
	data = {state={fire=true}},
	desc = "None",
})

function cbuff2000005:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成

function cbuff2000005:on_add()
	cbuff.on_add(self)
	self.event:listen(self.owner,"before_end_round",function (session,round)
		self:on_tick(session,round)
	end)
end

function cbuff2000005:on_tick(session,round)
	local damage = self.data.damage
	self.owner:damage(self,damage)
end

return cbuff2000005
