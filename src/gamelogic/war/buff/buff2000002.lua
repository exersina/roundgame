--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000002 = class("cbuff2000002",super,{
	type = 2000002,
	name = "睡眠状态",
	debuff = 1,
	dotbuff = 0,
	cover_max = 1,
	cover_kind = "none",
	lifetime = 2,
	data = {state={sleep=true}},
	desc = "None",
})

function cbuff2000002:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成


return cbuff2000002
