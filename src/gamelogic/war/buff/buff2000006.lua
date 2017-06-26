--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000006 = class("cbuff2000006",super,{
	type = 2000006,
	name = "狂暴状态",
	debuff = 0,
	dotbuff = 0,
	cover_max = 1,
	cover_kind = "none",
	lifetime = 3,
	data = {state={rage=true}},
	desc = "None",
})

function cbuff2000006:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成


return cbuff2000006
