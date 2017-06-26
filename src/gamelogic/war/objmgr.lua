cobjmgr = class("cobjmgr")

function cobjmgr:init(warid)
	self.objid = 0
	self.objs = {}
	self.warid = warid
end

function cobjmgr:genid()
	self.objid = self.objid + 1
	return self.objid
end

function cobjmgr:get(id)
	return self.objs[id]
end

function cobjmgr:add(objtype,obj)
	assert(obj.objid == nil,"exist objid:" .. tostring(obj.objid))
	local id = self:genid()
	obj.objid = id
	logger.logf("info","war","op=cobjmgr:add,warid=%s,objtype=%s,objid=%s,obj=%s",self.warid,objtype,id,tostring(obj))

	self.objs[id] = obj
	obj.objtype = objtype
	obj.event = cevent.new()
	obj.event:bind(obj)
	return id
end

function cobjmgr:del(id)
	local obj = self:get(id)
	if obj then
		-- 清空资源
		if obj.destroy then
			obj:destroy()
		end
		if obj.event then
			obj.event:destroy()
		end
		logger.logf("info","war","op=cobjmgr:del,warid=%s,objtype=%s,objid=%s,obj=%s",self.warid,obj.objtype,obj.objid,tostring(obj))
		self.objs[id] = nil
		return obj
	end
end

function cobjmgr:getby(objtype,id)
	local obj = self:get(id)
	if obj then
		assert(obj.objtype == objtype)
		return obj
	end
end

function cobjmgr:delby(objtype,id)
	local obj = self:get(id)
	if obj then
		assert(obj.objtype == objtype)
		return self:del(id)
	end
end

function cobjmgr:clear()
	for id in pairs(self.objs) do
		self:del(id)
	end
end

return cobjmgr
