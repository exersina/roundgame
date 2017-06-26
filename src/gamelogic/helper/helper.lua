helper = helper or {}

function helper.get_buff(typ)
	return buff_class[typ]
end

function helper.new_buff(option)
	local typ = option.type
	local cbuff = helper.get_buff(typ)
	local buff = cbuff.new(option)
	return buff
end

function helper.get_aura(typ)
	return aura_class[typ]
end

function helper.new_aura(option)
	local typ = option.type
	local caura = helper.get_aura(typ)
	return caura.new(option)
end

function helper.get_skill(typ)
	return skill_class[typ]
end

function helper.new_skill(option)
	local typ = option.type
	local cskill = helper.get_skill(typ)
	return cskill.new(option)
end

function helper.get_effect(typ)
	return effect_class[typ]
end

function helper.new_effect(option)
	local typ = option.type
	local ceffect = helper.get_effect(typ)
	return ceffect.new(option)
end
function helper.buff_type(name)
	if not helper._buff_name_type then
		helper._buff_name_type = {}
		for typ,cbuff in pairs(buff_class) do
			helper._buff_name_type[cbuff.name] = typ
		end
	end
	return assert(helper._buff_name_type[name])
end

function helper.buff_name(typ)
	local cbuff = helper.get_buff(typ)
	return cbuff.name
end

function helper.skill_type(name)
	if not helper._skill_name_type then
		helper._skill_name_type = {}
		for typ,cskill in pairs(skill_class) do
			helper._skill_name_type[cskill.name] = typ
		end
	end
	return assert(helper._skill_name_type[name])
end

function helper.skill_name(typ)
	local cskill = helper.get_skill(typ)
	return cskill.name
end

function helper.aura_type(name)
	if not helper._aura_name_type then
		helper._aura_name_type = {}
		for typ,caura in pairs(aura_class) do
			helper._aura_name_type[caura.name] = typ
		end
	end
	return assert(helper._aura_name_type[name])
end

function helper.aura_name(typ)
	local caura = helper.get_aura(typ)
	return caura.name
end


function __hotfix(oldmod)
	helper._buff_name_type = nil
	helper._skill_name_type = nil
	helper._aura_name_type = nil
end

return helper
