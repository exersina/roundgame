--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000011 = class("cbuff2000011",super,{
	type = 2000011,
	name = "潜行状态",
	debuff = 0,
	dotbuff = 0,
	cover_max = 1,
	cover_kind = "max",
	lifetime = 4,
	data = {state={sneak=true}},
	desc = "None",
})

function cbuff2000011:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成


return cbuff2000011
