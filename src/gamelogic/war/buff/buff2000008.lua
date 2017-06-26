--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000008 = class("cbuff2000008",super,{
	type = 2000008,
	name = "中毒状态",
	debuff = 1,
	dotbuff = 1,
	cover_max = 3,
	cover_kind = "none",
	lifetime = 2,
	data = {state={poison=true}},
	desc = "None",
})

function cbuff2000008:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成

function cbuff2000008:on_add()
	cbuff.on_add(self)
	local owner = self.owner
	self.event:listen(owner,"before_end_round",function (session,round)
		self:on_tick(session,round)
	end)
end

function cbuff2000008:on_tick(session,round)
	local damage = self.data.damage
	self.owner:damage(self,damage)
end

return cbuff2000008
