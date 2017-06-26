--<<aura 导表开始>>
local super = require "gamelogic.war.aura.aura"
caura3000001 = class("caura3000001",super,{
	type = 3000001,
	name = "防御光环",
	buff_type = 2000009,
	lifetime = -1,
	desc = "给友方增加$defense物理防御",
})

function caura3000001:init(option)
	super.init(self,option)
--<<aura 导表结束>>

end --导表生成

function caura:enter_war()
	local master = self.owner.owner
	local allys = cselector.new(war:all_warobj())
					:is_ally(master)
					:result()
	for i,warobj in ipairs(allys) do
		self:add_buff(warobj)
	end
end

function caura:on_see(who)
	local master = self.owner.owner
	local is_ally = who.is_attacker == master.is_attacker
	if is_ally then
		self:add_buff(warobj)
	end
end

return caura3000001
