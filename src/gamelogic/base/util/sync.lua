sync = sync or {}

sync.once = sync.once or {
	tasks = {},
}

function sync.once.Do(id,func,...)
	local tasks = sync.once.tasks
	local task = tasks[id]
	if not task then
		task = {
			waiting = {},
			result = false,
		}
		tasks[id] = task
		--print("[sync.once.Do] call",id)
		local rettbl = {xpcall(func,onerror,...)}
		local call_ok = table.remove(rettbl,1)
		if call_ok then
			task.result = rettbl
		end
		local waiting = task.waiting
		tasks[id] = nil
		--print("[sync.once.Do] call return",id,call_ok,table.dump(rettbl),table.dump(waiting))
		if next(waiting) then
			for i,co in ipairs(waiting) do
				skynet.wakeup(co)
			end
		end
		assert(call_ok,id)
		return table.unpack(rettbl)
	else
		local co = coroutine.running()
		table.insert(task.waiting,co)
		--print("[sync.once.Do] wait",id)
		skynet.wait(co)
		--print("[sync.once.Do] wait return",id,table.dump(task.result))
		assert(task.result,id)
		return table.unpack(task.result)
	end
end

return sync
