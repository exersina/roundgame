--<<buff 导表开始>>
local super = require "gamelogic.war.buff.buff"
cbuff2000009 = class("cbuff2000009",super,{
	type = 2000009,
	name = "防御光环",
	debuff = 0,
	dotbuff = 0,
	cover_max = 3,
	cover_kind = "none",
	lifetime = -1,
	data = {add={defense=100}},
	desc = "None",
})

function cbuff2000009:init(option)
	super.init(self,option)
--<<buff 导表结束>>

end --导表生成


return cbuff2000009
