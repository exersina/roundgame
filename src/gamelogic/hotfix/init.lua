local skynet = skynet or require "skynet"
local patten = "../src/?.lua"

local ignore_module = {
	"gamelogic%.service%.loggerd",
}

hotfix = hotfix or {}

function hotfix.hotfix(modname)
	local start = modname:sub(1,4)
	if start == "src/" or start == "src." then
		modname = modname:sub(5)
	end
	local address = skynet.address(skynet.self())
	local is_gamelogic = modname:sub(1,9) == "gamelogic"
	-- 只允许游戏逻辑+协议更新
	if not is_gamelogic then
		logger.logf("warning","hotfix","op=hotfix,address=%s,module=%s,fail=cann't hotfix non-script code",address,modname)
		return
	end
	local suffix = modname:sub(-4,-1)
	if suffix == ".lua" then
		modname = modname:sub(1,-5)
	end
	for i,pat in ipairs(ignore_module) do
		if modname == string.match(modname,pat) then
			return
		end
	end
	modname = string.gsub(modname,"/",".")
	modname = string.gsub(modname,"\\",".")
	skynet.cache.clear()
	local chunk,err
	local errlist = {}
	local env = _ENV or _G
	env.__hotfix = nil
	local name = string.gsub(modname,"%.","/")
	for pat in string.gmatch(patten,"[^;]+") do
		local filename = string.gsub(pat,"?",name)
		chunk,err = loadfile(filename,"bt",env)
		if chunk then
			break
		else
			table.insert(errlist,err)
		end
	end
	if not chunk then
		local msg = string.format("op=hotfix,address=%s,module=%s,fail=%s",address,modname,table.concat(errlist,"\n"))
		logger.log("error","hotfix",msg)
		skynet.error(msg)
		print(msg)
		return
	end
	local msg = string.format("op=hotfix,address=%s,module=%s",address,modname)
	logger.log("info","hotfix",msg)
	print(msg)
	local oldmod = package.loaded[modname]
	local newmod = chunk()
	if newmod ~= nil then
		package.loaded[modname] = newmod
	else
		package.loaded[modname] = true
	end
	if type(env.__hotfix) == "function" then
		env.__hotfix(oldmod)
	end
	return true
end

return hotfix

