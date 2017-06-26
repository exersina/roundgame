warmgr = warmgr or {}

function warmgr.init()
	warmgr.wars = {}
	warmgr.warid = 0
end

function warmgr.genid()
	warmgr.warid = warmgr.warid + 1
	return warmgr.warid
end

function warmgr.getwar(warid)
	return warmgr.wars[warid]
end

function warmgr.delwar(warid)
	warmgr.wars[warid] = nil
end

function warmgr.clear()
	logger.logf("warning","war","op=warmgr.clear,wars=%s",warmgr.wars)
	local wars = warmgr.wars
	warmgr.wars = {}
	for warid,address in pairs(wars) do
		skynet.send(address,"lua","endwar",{result=0})
	end
end

warmgr.CLUSTER_CMD = warmgr.CLUSTER_CMD or {}
local CLUSTER_CMD = warmgr.CLUSTER_CMD

function CLUSTER_CMD.echo(request)
	return request
end

function CLUSTER_CMD.startwar(request)
	local wardata = request
	local warid = assert(wardata.warid)
	assert(warmgr.wars[warid] == nil,"repeat warid:" .. tostring(warid))
	local address = skynet.newservice("gamelogic/service/war","newservice",warid)
	warmgr.wars[warid] = address
	return skynet.call(address,"lua","startwar",wardata)
end

function CLUSTER_CMD.endwar(request)
	local warid = assert(request.warid)
	local address = warmgr.getwar(warid)
	if not address then
		return
	end
	warmgr.delwar(warid)
	return skynet.call(address,"lua","endwar",request)
end

function CLUSTER_CMD.forward(request)
	local warid = assert(request.warid)
	local cmd = assert(request.cmd)
	local request = request.request
	local address = warmgr.getwar(warid)
	if not address then
		return
	end
	return skynet.call(address,"lua",cmd,request)
end

-- control
function CLUSTER_CMD.rpc(cmd,...)
	return exec(_G,cmd,...)
end

function CLUSTER_CMD.exec(cmd)
	local chunk = load(cmd,"=(load)","bt",_G)
	if chunk then
		return chunk()
	end
end

function CLUSTER_CMD.hotfix(modname)
	local list = string.split(modname,",")
	for warid,address in pairs(warmgr.wars) do
		for i,modname in ipairs(list) do
			skynet.send(address,"lua","rpc","hotfix.hotfix",modname)
		end
	end
end


warmgr.SERVICE_CMD = warmgr.SERVICE_CMD or {}
local SERVICE_CMD = warmgr.SERVICE_CMD

function SERVICE_CMD.delwar(warid)
	warmgr.delwar(warid)
end

function warmgr.dispatch(session,source,proto,cmd,...)
	print("warmgr.dispatch",session,source,proto,cmd,...)
	if proto == "cluster" then
		local method = warmgr.CLUSTER_CMD[cmd]
		if session ~= 0 then
			skynet.response()(xpcall(method,onerror,...))
		else
			xpcall(method,onerror,...)
		end
	elseif proto == "service" then
		local method = warmgr.SERVICE_CMD[cmd]
		if session ~= 0 then
			skynet.response()(xpcall(method,onerror,...))
		else
			xpcall(method,onerror,...)
		end
	end
end

return warmgr
