--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000007 = class("cbuff2000007",super,{
	type = 2000007,
	name = "冰冻状态",
	debuff = 1,
	dotbuff = 0,
	cover_max = 1,
	cover_kind = "none",
	lifetime = 2,
	data = {state={freeze=true}},
	desc = "None",
})

function cbuff2000007:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成


return cbuff2000007
