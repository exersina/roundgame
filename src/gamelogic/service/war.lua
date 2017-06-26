require "gamelogic.base.init"
require "gamelogic.logger.init"
require "gamelogic.hotfix.init"
require "gamelogic.helper.init"
require "gamelogic.event.init"
require "gamelogic.war.init"

service_war = service_war or {}
service_war.CMD = service_war.CMD or {}
local CMD = service_war.CMD
war = war or nil

function CMD.rpc(cmd,...)
	return exec(_G,cmd,...)
end

function CMD.exec(cmd)
	local chunk = load(cmd,"=(load)","bt",_G)
	if chunk then
		return chunk()
	end
end

function CMD.echo(request)
	return request
end


--[[
-- 准备开始一场战斗
function CMD.readywar(request)
end

-- 增加战斗玩家
function CMD.addplayer(request)
end
]]

-- 更新战斗玩家
function CMD.updateplayer(request)
end

-- 战斗数据准备完毕，正式开始战斗
function CMD.startwar(request)
	local wardata = request
	war = cwar.new(wardata)
	war:start()
end

function CMD.run_round(request)
	local objid = assert(request.objid)
	local round = assert(request.round)
	if war.state ~= "ready" then
		return
	end
	if round ~= war.round then
		return
	end
	local warobj = war:get_warobj(objid)
	if warobj.is_quit or
		not warobj:is_player() or
		warobj.onlinestate ~= "online" then
		return
	end
	warobj.wakeup = "run_round"
	local warobjs = cselector.new(war:all_warobj())
						:filter(function (warobj)
							if warobj:is_player() and
								warobj.onlinestate == "online" then
								return true
							end
						end)
						:result()
	local wakeup = true
	for i,warobj in ipairs(warobjs) do
		if warobj.wakeup ~= "run_round" then
			wakeup = false
			break
		end
	end
	if wakeup then
		war:wakeup("run_round")
	end
end

function CMD.begin_round(request)
	local objid = assert(request.objid)
	local round = assert(request.round)
	if not (war.state == "start" and
		war.round_state == "ready_round") then
		return
	end
	if round ~= war.round then
		return
	end
	local warobj = war:get_warobj(objid)
	if warobj.is_quit or
		not warobj:is_player() or
		warobj.onlinestate ~= "online" then
		return
	end
	warobj.wakeup = "begin_round"
	local warobjs = cselector.new(war:all_warobj())
						:filter(function (warobj)
							if warobj:is_player() and
								warobj.onlinestate == "online" then
								return true
							end
						end)
						:result()
	local wakeup = true
	for i,warobj in ipairs(warobjs) do
		if warobj.wakeup ~= "begin_round" then
			wakeup = false
			break
		end
	end
	if wakeup then
		war:wakeup("begin_round")
	end
end

function CMD.end_round(request)
	local objid = assert(request.objid)
	local round = assert(request.round)
	if not (war.state == "start" and
		war.round_state == "begin_round") then
		return
	end
	if round ~= war.round then
		return
	end
	local warobj = war:get_warobj(objid)
	if warobj.is_quit or
		not warobj:is_player() or
		warobj.onlinestate ~= "online" then
		return
	end
	warobj.wakeup = "end_round"
	local warobjs = cselector.new(war:all_warobj())
						:filter(function (warobj)
							if warobj:is_player() and
								warobj.onlinestate == "online" then
								return true
							end
						end)
						:result()
	local wakeup = true
	for i,warobj in ipairs(warobjs) do
		if warobj.wakeup ~= "end_round" then
			wakeup = false
			break
		end
	end
	if wakeup then
		war:wakeup("end_round")
	end
end

-- 强制结束战斗
function CMD.endwar(request)
	--local _,result = war:judge_result()
	local result = assert(request.result)
	war:gameover(result,"forceend")
end

-- 退出战斗(逃跑)
function CMD.quitwar(request)
	local objid = assert(request.objid)
	local warobj = war:get_warobj(objid)
	if not warobj then
		return
	end
	return war:quit(warobj)
end

-- [中途]加入战斗
function CMD.joinwar(request)
	local player = assert(request.player)
	local pid = player.pid
	local warobj = war:get_warobj_bypid(pid)
	if warobj then
		-- 禁止: 重复加入战斗/逃跑后加入战斗
		return
	end
	warobj = war:new_warobj(player,"hero",player.is_attacker)
	return war:join(warobj)
end

-- 观战
function CMD.watchwar(request)
	local player = assert(request.player)
	return war:watch(player)
end

-- 取消观战
function CMD.unwatchwar(request)
	local pid = assert(request.pid)
	return war:unwatch(pid)
end

-- 玩家操作
function CMD.use_skill(request)
	local objid = assert(request.objid)
	local skillid = assert(request.skillid)
	local focus = request.focus
	local warobj = war:get_warobj(objid)
	if not warobj then
		return
	end
	-- one round one op
	if #warobj.op_queue > 0 then
		return
	end
	if not objmgr:getby("cskill",skillid) then
		return
	end
	if focus and not objmgr:getby("cwarobj",focus) then
		return
	end
	warobj:push_op({cmd="use_skill",request=request})
end

function CMD.use_item(request)
end

function CMD.summon_pet(request)
end

function CMD.unsummon_pet(request)
end


local mode,warid = ...
if mode == "newservice" then
	skynet.init(function ()
		logger._init()
		objmgr = cobjmgr.new(warid)
	end)
	skynet.start(function ()
		skynet.dispatch("lua",function (session,source,cmd,...)
			local method = CMD[cmd]
			if session ~= 0 then
				skynet.response()(xpcall(method,onerror,...))
			else
				xpcall(method,onerror,...)
			end
		end)
	end)
end
