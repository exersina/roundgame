--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000003 = class("cbuff2000003",super,{
	type = 2000003,
	name = "眩晕状态",
	debuff = 1,
	dotbuff = 0,
	cover_max = 1,
	cover_kind = "none",
	lifetime = 2,
	data = {state={dizzy=true}},
	desc = "None",
})

function cbuff2000003:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成


return cbuff2000003
