cwar = class("cwar")

function cwar:init(option)
	logger.logf("debug","war","op=cwar:init,option=%s",option)
	self.state = "init"
	self.id = option.warid
	self.round = 0
	self.createtime = os.time()
	self.wartype = option.wartype
	self:init_by_wartype(option)

	objmgr:add("cwar",self)

	self.signals = {}
	self.pos_warobj = {}
	self.escape_warobjs = {}
	self.attackers = {}
	self.defensers = {}
	self.attacker_watchers = {}
	self.defenser_watchers = {}
	if not table.isempty(option.attackers) then
		for i,attacker_data in ipairs(option.attackers) do
			local kind = assert(attacker_data.kind)
			local attacker
			if kind == "hero" then
				attacker = self:new_hero(attacker_data,true)
			else
				assert(kind == "monster")
				attacker = self:new_warobj(attacker_data,kind,true)
			end
			self:add_warobj(attacker)
		end
	end
	if not table.isempty(option.defensers) then
		for i,defenser_data in ipairs(option.defensers) do
			local kind = assert(defenser_data.kind)
			local defenser
			if kind == "hero" then
				defenser = self:new_hero(defenser_data,false)
			else
				assert(kind == "monster")
				defenser = self:new_warobj(defenser_data,kind,false)
			end
			self:add_warobj(defenser)
		end
	end
	-- 伤害/治疗统计
	if option.stat then
		self.stat = {}
	end
end

function cwar:init_by_wartype(option)
	-- read from data config
	local warconfig = {}
	self.wait_run_round = 1
	self.wait_begin_round = 1
	self.wait_end_round = 1

	self.ban_watch = option.ban_watch or warconfig.ban_watch or false
	self.max_round = option.max_round or warconfig.max_round or 30
	self.watch_limit = option.watch_limit or warconfig.watch_limit or 10
end

function cwar:choose_pos(kind,is_attacker)
	if is_attacker then
		if kind == "hero" then
			for pos=1,5 do
				if not self.pos_warobj[pos] then
					return pos
				end
			end
		elseif kind == "pet" then
			for pos=11,15 do
				if not self.pos_warobj[pos] then
					return pos
				end
			end
		elseif kind == "monster" then
		end
	else
		if kind == "hero" then
			for pos=-1,-5,-1 do
				if not self.pos_warobj[pos] then
					return pos
				end
			end
		elseif kind == "pet" then
			for pos=-11,-15,-1 do
				if not self.pos_warobj[pos] then
					return pos
				end
			end
		elseif kind == "monster" then
		end
	end
end

function cwar:new_hero(hero_data,is_attacker)
	local hero = self:new_warobj(hero_data,"hero",is_attacker)
	hero.pets = {}
	if not table.isempty(hero_data.pets) then
		for i,pet_data in ipairs(hero_data.pets) do
			local pet = self:new_warobj(pet_data,"pet",is_attacker)
			pet.master = hero
			hero.pets[hero.pets+1] = pet
			if pet.readywar then
				hero.readywar_pet = pet
			end
		end
	end
	-- items ?
	return hero
end

function cwar:new_warobj(warobj_data,kind,is_attacker)
	warobj_data.is_attacker = is_attacker
	warobj_data.kind = kind
	warobj_data.owner = self
	local warobj = cwarobj.new(warobj_data)
	return warobj
end

function cwar:add_warobj(warobj)
	local id = warobj.objid
	if warobj.is_attacker then
		table.insert(self.attackers,id)
	else
		table.insert(self.defensers,id)
	end
end

function cwar:get_warobj(id)
	return objmgr:getby("cwarobj",id)
end

function cwar:get_warobj_bypos(pos)
	local id = self.pos_warobj[pos]
	if id then
		return self:get_warobj(id)
	end
end

function cwar:del_warobj(id)
	return objmgr:delby("cwarobj",id)
end

function cwar:enter(warobj)
	if not warobj.pos then
		local pos = self:choose_pos(warobj.kind,warobj.is_attacker)
		assert(pos)
		warobj.pos = pos
	end
	local pos = assert(warobj.pos)
	local id = assert(warobj.objid)
	assert(self.pos_warobj[pos] == nil)
	self.pos_warobj[pos] = id
	logger.logf("info","war","op=cwar:enter,warid=%s,objid=%s,pos=%s,pid=%s,kind=%s",self.id,warobj.objid,warobj.pos,warobj.pid,warobj.kind)
	warobj:enter_war()
	if warobj.readywar_pet then
		assert(warobj.kind == "hero")
		self:enter(warobj.readywar_pet)
	end
end

function cwar:leave(warobj)
	local id = assert(warobj.objid)
	local pos = assert(warobj.pos)
	logger.logf("info","war","op=cwar:leave,warid=%s,objid=%s,pos=%s,pid=%s,kind=%s",self.id,warobj.objid,warobj.pos,warobj.pid,warobj.kind)
	self.pos_warobj[pos] = nil
	if warobj.is_attacker then
		table.remove_val(self.attackers,id)
	else
		table.remove_val(self.defensers,id)
	end
	warobj:leave_war()
	if warobj.readywar_pet then
		assert(warobj.kind == "hero")
		self:leave(warobj.readywar_pet)
	end
end

function cwar:ready()
	self.state = "ready"
	local players = cselector.new(self:all_warobj())
						:is_player()
						:result()
	local war = self:pack4ready()
	self:sendpackage(players,"war_ready",{war=war})
	for i,id in ipairs(self.attackers) do
		local attacker = self:get_warobj(id)
		self:enter(attacker)
	end
	for i,id in ipairs(self.defensers) do
		local defenser = self:get_warobj(id)
		self:enter(defenser)
	end
end

function cwar:start()
	self:ready()
	self:wait("run_round",self.wait_run_round)
	self.state = "start"
	self.round_state = "end_round"
	self:run_round()
end

function cwar:run_round()
	self.round = self.round + 1
	self:ready_round()
	self:wait("begin_round",self.wait_begin_round)
	self:begin_round()
end

function cwar:ready_round()
	assert(self.state == "start")
	assert(self.round_state == "end_round")
	logger.logf("info","war","op=ready_round,warid=%s,round=%s",self.id,self.round)
	self.round_state = "ready_round"
	for i,id in ipairs(self.attackers) do
		local attacker = self:get_warobj(id)
		attacker:ready_round(self.round)
	end
	for i,id in ipairs(self.defensers) do
		local defenser = self:get_warobj(id)
		defenser:ready_round(self.round)
	end
end


function cwar:begin_round()
	assert(self.state == "start")
	assert(self.round_state == "ready_round")
	logger.logf("info","war","op=begin_round,warid=%s,round=%s",self.id,self.round)
	self.round_state = "begin_round"
	for i,id in ipairs(self.attackers) do
		local attacker = self:get_warobj(id)
		attacker:begin_round(self.round)
	end
	for i,id in ipairs(self.defensers) do
		local defenser = self:get_warobj(id)
		defenser:begin_round(self.round)
	end
	-- 根据出手顺序演算本回合战斗
	local warobjs = self:all_warobj()
	table.sort(warobjs,function (warobj1,warobj2)
		local sp1 = warobj1:getattr("sp")
		local sp2 = warobj1:getattr("sp")
		if sp1 > sp2 then
			return true
		elseif sp1 == sp2 then
			if warobj1.objid < warobj2.objid then
				return true
			end
		end
		return false
	end)
	for i,warobj in ipairs(warobjs) do
		local op = warobj:pop_op()
		if not warobj.is_die then
			if op then
				if #warobj.history_op >= 3 then
					table.remove(warobj.history_op,1)
				end
				table.insert(warobj.history_op,op)
				warobj:do_op(op)
			else
				local last_op = warobj.history_op[#warobj.history_op]
				if last_op then
					warobj:do_op(last_op)
				end
			end
			-- check die/alive
			local ids = deepcopy(self.attackers)
			for i,id in ipairs(ids) do
				local attacker = self:get_warobj(id)
				local hp = attacker:getattr("hp")
				if not attacker.is_die then
					if hp <= 0 then
						attacker:die()
					end
				else
					if hp > 0 then
						attacker:alive()
					end
				end
			end
			local ids = deepcopy(self.defensers)
			for i,id in ipairs(ids) do
				local defenser = self:get_warobj(id)
				local hp = defenser:getattr("hp")
				if not defenser.is_die then
					if hp <= 0 then
						defenser:die()
					end
				else
					if hp > 0 then
						defenser:alive()
					end
				end
			end
		end
	end
	self:wait("end_round",self.wait_end_round)
	self:end_round()
end

function cwar:end_round()
	assert(self.state == "start")
	assert(self.round_state == "begin_round")
	logger.logf("info","war","op=end_round,warid=%s,round=%s",self.id,self.round)
	self.round_state = "end_round"
	for i,id in ipairs(self.attackers) do
		local attacker = self:get_warobj(id)
		attacker:end_round(self.round)
	end
	for i,id in ipairs(self.defensers) do
		local defenser = self:get_warobj(id)
		defenser:end_round(self.round)
	end
	local err,result = self:judge_result()
	if not err then
		self:gameover(result,"end_round")
		return
	end
	if self.round >= self.max_round then
		self:gameover(result,"max_round")
		return
	end
	self:run_round()
end

function cwar:gameover(result,reason)
	logger.logf("info","war","op=gameover,warid=%s,round=%s,result=%s,reason=%s",self.id,self.round,result,reason)
	self.state = "gameover"
	self.endtime = os.time()
	self.result = result
	local players = cselector.new(self:all_warobj())
						:is_player()
						:result()
	self:sendpackage(players,"war_gameover",{
		result = result,
		endtime = self.endtime,
		reason = reason,
	})
	objmgr:del(self.objid)
	objmgr:clear()
	skynet.call(".MAINSRV","lua","service","delwar",self.id)
	skynet.fork(skynet.exit)
end

function cwar:judge_result()
	-- >0--attack_win,0--tie,<0--attack_lose
	local err,result
	local attacker_alives = cselector.new(self.attackers)
							:not_die()
							:result()
	local defenser_alives = cselector.new(self.defensers)
							:not_die()
							:result()
	if #attacker_alives == 0 and #defenser_alives == 0 then
		result = 0
	elseif #attacker_alives == 0 then
		result = -1
	elseif #defenser_alives == 0 then
		result = 1
	else
		-- TODO: 更复杂的判定规则?
		result = 0
		err = "unknow result"
	end
	return err,result
end

function cwar:destroy()
	for i,objid in ipairs(self.attackers) do
		objmgr:del(objid)
	end
	for i,objid in ipairs(self.defensers) do
		objmgr:del(objid)
	end
	for i,objid in ipairs(self.escape_warobjs) do
		objmgr:del(objid)
	end
end

function cwar:join(warobj)
	if self.state ~= "start" then
		return false
	end
	self:add_warobj(warobj)
	self:enter(warobj)
	return true
end

function cwar:quit(warobj)
	local id = warobj.objid
	if self.state ~= "start" then
		return false
	end
	local found = false
	if warobj.is_attacker then
		for i,objid in ipairs(self.attackers) do
			if objid == id then
				found = true
				break
			end
		end
	else
		for i,objid in ipairs(self.defensers) do
			if objid == id then
				found = true
				break
			end
		end
	end
	if found then
		-- 逃跑玩家也不del_warobj
		self:leave(warobj)
		table.insert(self.escape_warobjs,id)
		warobj.is_quit = true
		warobj.quit_last_time = os.time()
		local err,result = self:judge_result()
		if not err then
			self:gameover(result,"quit")
		end
		return true
	end
	return false
end

function cwar:watch(player)
	if self.state ~= "start" then
		return false
	end
	if self.ban_watch then
		return false
	end
	if #self.attacker_watch_players + self.defenser_watch_players >= self.watch_limit then
		return false
	end
	if player.watch_attacker then
		local pos = table.find(self.attacker_watch_players,function (k,v)
			return v.pid == player.pid
		end)
		if pos then
			return false
		end
		table.insert(self.attacker_watch_players,player)
		return true
	else
		local pos = table.find(self.defenser_watch_players,function (k,v)
			return v.pid == player.pid
		end)
		if pos then
			return false
		end
		table.insert(self.defenser_watch_players,player)
		return true
	end
end

function cwar:unwatch(pid)
	if self.state ~= "start" then
		return
	end
	for i,player in ipairs(self.attacker_watchers) do
		if player.pid == pid then
			table.remove(self.attacker_watchers,i)
			return player
		end
	end
	for i,player in ipairs(self.defenser_watchers) do
		if player.pid == pid then
			table.remove(self.defenser_watchers,i)
			return player
		end
	end
end

function cwar:get_warobj_bypid(pid)
	for i,id in ipairs(self.attackers) do
		local warobj = self:get_warobj(id)
		if warobj.pid == pid then
			return warobj
		end
	end
	for i,id in ipairs(self.defensers) do
		local warobj = self:get_warobj(id)
		if warobj.pid == pid then
			return warobj
		end
	end

	for i,id in ipairs(self.escape_warobjs) do
		local warobj = self:get_warobj(id)
		if warobj.pid == pid then
			return warobj
		end
	end
end

function cwar:wait(signal,timeout)
	local timer_name = string.format("%s#signal:%s",self.id,signal)
	local co = coroutine.running()
	local timer_id = timer.timeout(timer_name,timeout,function ()
		self.signals[signal] = nil
		skynet.wakeup(co)
	end)
	self.signals[signal] = {
		co = co,
		timer_id = timer_id,
		timer_name,
	}
	skynet.wait(co)
end

function cwar:wakeup(signal)
	local data = self.signals[signal]
	if data then
		timer.deltimer(data.timer_name,data.timer_id)
		skynet.wakeup(data.co)
	end
end

function cwar:enemys(who)
	local list = {}
	if who.is_attacker then
		list = self.defensers
	else
		list = self.attackers
	end
	local ret = {}
	for i,id in ipairs(list) do
		table.insert(ret,self:get_warobj(id))
	end
	return ret
end

function cwar:all_warobj()
	local list = {}
	table.extend(list,self.attackers)
	table.extend(list,self.defensers)
	local ret = {}
	for i,id in ipairs(list) do
		table.insert(ret,self:get_warobj(id))
	end
	return ret
end

function cwar:get_pids(warobjs)
	local pids = {}
	for i,warobj in ipairs(warobjs) do
		pids[#pids+1] = assert(warobj.pid)
	end
end

function cwar:pack_resume()
	return {
		warid = self.id,
		objid = self.objid,
		round = self.round,
	}
end

function cwar:pack4ready()
	return {
		attackers = self.attackers,
		defensers = self.defensers,
		wartype = self.wartype,
		state = self.state,
		createtime = self.createtime,
	}
end

function cwar:gamesrv_pids(warobjs)
	local gamesrv_pids = {}
	for i,warobj in ipairs(warobjs) do
		local gamesrv = assert(warobj.gamesrv)
		local pid = assert(warobj.pid)
		if not gamesrv_pids[gamesrv] then
			gamesrv_pids[gamesrv] = {}
		end
		table.insert(gamesrv_pids[gamesrv],pid)
	end
	return gamesrv_pids
end

function cwar:sendpackage(warobjs,cmd,request)
	request.header = self:pack_resume()
	local package = {
		warid = self.id,
		cmd = cmd,
		request = request,
	}
	local gamesrv_pids = self:gamesrv_pids(warobjs)
	logger.logf("debug","war","op=sendpackage,warid=%s,gamesrv_pids=%s,package=%s",self.id,gamesrv_pids,package)
	--[[
	for gamesrv,pids in pairs(gamesrv_pids) do
		package.pids = pids
		cluster.send(gamesrv,"lua","cluster","forward",package)
	end
	-- attacker_watchers
	local gamesrv_pids = self:gamesrv_pids(self.attacker_watchers)
	for gamesrv,pids in pairs(gamesrv_pids) do
		package.pids = pids
		cluster.send(gamesrv,"lua","cluster","forward",package)
	end
	-- defenser_watchers
	local gamesrv_pids = self:gamesrv_pids(self.defenser_watchers)
	for gamesrv,pids in pairs(gamesrv_pids) do
		package.pids = pids
		cluster.send(gamesrv,"lua","cluster","forward",package)
	end
	]]
end

return cwar
