cevent = class("cevent")

cevent.id = cevent.id or 0

function cevent:init()
	self.name_sessions = {}
	self.id_session = {}
end

function cevent:genid()
	if cevent.id >= MAX_NUMBER then
		cevent.id = 0
	end
	cevent.id = cevent.id + 1
	return cevent.id
end

function cevent:register(name,callback)
	if not self.name_sessions[name] then
		self.name_sessions[name] = {}
	end
	local id = self:genid()
	local session = {
		id = id,
		name = name,
		callback = callback,
	}
	self.id_session[id] = session
	table.insert(self.name_sessions[name],session)
	return id
end

function cevent:unregister(id)
	local session = self.id_session[id]
	if session then
		self.id_session[id] = nil
		local sessions = self.name_sessions[session.name]
		for i,session in ipairs(sessions) do
			if session.id == id then
				table.remove(sessions,i)
				break
			end
		end
		return session
	end
end

function cevent:send(name,...)
	local sessions = self.name_sessions[name]
	if sessions then
		sessions = deepcopy(sessions)
		for i,session in ipairs(sessions) do
			local method
			if type(session.callback) == "string" then
				method = triggermgr[session.callback]
			else
				method = session.callback
			end
			local result = method(session,...)
			if result == "break" then
				break
			end
		end
	end
end

-- helper function
function cevent:bind(owner)
	assert(self.owner == nil)
	self.owner = owner
	self.listen_events = {}
end

function cevent:listen(obj2,method_name,callback)
	local obj1 = self.owner
	if not callback then
		assert(obj1[method_name])
		callback = function (session,...)
			local func = obj1[method_name]
			return func(obj1,session,...)
		end
	end
	local id = obj2.event:register(method_name,callback)
	local session = obj2.event.id_session[id]
	session.objid1 = obj1.objid
	session.objid2 = obj2.objid
	table.insert(obj1.event.listen_events,session)
	return id
end

function cevent:unlisten(id)
	local pos = table.find(self.listen_events,function (i,session)
		return session.id == id
	end)
	if pos then
		local session = self.listen_events[pos]
		table.remove(self.listen_events,pos)
		local obj2 = objmgr:get(session.objid2)
		obj2.event:unregister(session.id)
	end
end

function cevent:destroy()
	for pos=#self.listen_events,1,-1 do
		local session = self.listen_events[pos]
		self:unlisten(session.id)
	end

	for id,session in pairs(self.id_session) do
		local obj1 = objmgr:get(session.objid1)
		obj1.event:unlisten(id)
	end
end

return cevent
