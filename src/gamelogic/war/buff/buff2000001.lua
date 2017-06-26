--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000001 = class("cbuff2000001",super,{
	type = 2000001,
	name = "防御状态",
	debuff = 0,
	dotbuff = 0,
	cover_max = 1,
	cover_kind = "none",
	lifetime = -1,
	data = {state={defense=true}},
	desc = "None",
})

function cbuff2000001:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成


return cbuff2000001
