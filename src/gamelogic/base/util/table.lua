-- 扩展表功能
function table.any(set,func)
	for k,v in pairs(set) do
		if func(k,v) then
			return true,k,v
		end
	end
	return false
end

function table.all(set,func)
	for k,v in pairs(set) do
		if not func(k,v) then
			return false,k,v
		end
	end
	return true
end

function table.filter(tbl,func)
	local newtbl = {}
	for k,v in pairs(tbl) do
		if func(k,v) then
			newtbl[k] = v
		end
	end
	return newtbl
end

function table.max(func,...)
	if not func then
		return math.max(...)
	end
	local args = table.pack(...)
	local max
	for i,arg in ipairs(args) do
		local val = func(arg)
		if not max or val > max then
			max = val
		end
	end
	return max
end

function table.min(func,...)
	if not func then
		return math.min(...)
	end
	local args = table.pack(...)
	local min
	for i,arg in ipairs(args) do
		local val = func(arg)
		if not min or val < min then
			min = val
		end
	end
	return min
end

function table.map(func,...)
	local args = table.pack(...)
	assert(#args >= 1)
	func = func or function (...)
		return {...}
	end
	local maxn = table.max(function (tbl)
			return #tbl
		end,...)
	local len = #args
	local newtbl = {}
	for i=1,maxn do
		local list = {}
		for j=1,len do
			table.insert(list,args[j][i])
		end
		local ret = func(table.unpack(list))
		table.insert(newtbl,ret)
	end
	return newtbl
end

function table.find(tbl,func)
	local isfunc = type(func) == "function"
	for k,v in pairs(tbl) do
		if isfunc then
			if func(k,v) then
				return k,v
			end
		else
			if func == v then
				return k,v
			end
		end
	end
end

function table.keys(t)
	local ret = {}
	for k,v in pairs(t) do
		table.insert(ret,k)
	end
	return ret
end

function table.values(t)
	local ret = {}
	for k,v in pairs(t) do
		table.insert(ret,v)
	end
	return ret
end

function table.dump(t,space,name)
	if type(t) ~= "table" then
		return tostring(t)
	end
	space = space or ""
	name = name or ""
	local cache = { [t] = "."}
	local function _dump(t,space,name)
		local temp = {}
		for k,v in pairs(t) do
			local key = tostring(k)
			if cache[v] then
				table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
			elseif type(v) == "table" then
				local new_key = name .. "." .. key
				cache[v] = new_key
				table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key),new_key))
			else
				table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
			end
		end
		return table.concat(temp,"\n"..space)
	end
	return _dump(t,space,name)
end

function table.getattr(tbl,attr)
	local attrs = type(attr) == "table" and attr or string.split(attr,".")
	local root = tbl
	for i,attr in ipairs(attrs) do
		root = root[attr]
	end
	return root
end

function table.hasattr(tbl,attr)
	local attrs = type(attr) == "table" and attr or string.split(attr,".")
	local root = tbl
	local len = #attrs
	for i,attr in ipairs(attrs) do
		if not root[attr] then
			return false
		end
		root = root[attr]
		if i ~= len and type(root) ~= "table" then
			return false
		end
	end
	return true,root
end

function table.setattr(tbl,attr,val)
	local attrs = type(attr) == "table" and attr or string.split(attr,".")
	local lastkey = table.remove(attrs)
	local root = tbl
	for i,attr in ipairs(attrs) do
		if not root[attr] then
			root[attr] = {}
		end
		root = root[attr]
	end
	local oldval = root[lastkey]
	root[lastkey] = val
	return oldval
end

function table.query(tbl,attr,default)
	local exist = table.hasattr(tbl,attr)
	if exist then
		return table.getattr(tbl,attr)
	end
	return default
end

function table.isempty(tbl)
	if cjson and cjson.null == tbl then -- int64:0x0
		return true
	end
	if not tbl or not next(tbl) then
		return true
	end
	return false
end

-- 递归整个表,嵌套的空表，包括值为0/""的都是空值
function table.isempty_ex(tbl)
	if table.isempty(tbl) then
		return true
	end
	local isempty = true
	for k,v in pairs(tbl) do
		local typ = type(v)
		if typ == "table" then
			if not table.isempty_ex(v) then
				isempty = false
			end
		elseif typ == "string" then
			if v ~= "" then
				isempty = false
			end
		elseif typ == "number" then
			if v ~= 0 and v ~= 0.0 then
				isempty = false
			end
		else
			isempty = false
		end
	end
	return isempty
end

function table.extend(tbl1,tbl2)
	for i,v in ipairs(tbl2) do
		table.insert(tbl1,v)
	end
end

function table.update(tbl1,tbl2)
	for k,v in pairs(tbl2) do
		tbl1[k] = v
	end
end

function table.count(tbl)
	local cnt = 0
	for k,v in pairs(tbl) do
		cnt = cnt + 1
	end
	return cnt
end

function table.del_val(t,val,maxcnt)
	local delkey = {}
	for k,v in pairs(t) do
		if v == val then
			if not maxcnt or #delkey < maxcnt then
				delkey[#delkey] = k
			else
				break
			end
		end
	end
	for _,k in pairs(delkey) do
		t[k] = nil
	end
	return #delkey
end

function table.remove_val(t,val,maxcnt)
	local len = #t
	maxcnt = maxcnt or len
	local delpos = {}
	for pos=len,1,-1 do
		if t[pos] == val then
			table.remove(t,pos)
			table.insert(delpos,pos)
			if #delpos >= maxcnt then
				break
			end
		end
	end
	return delpos
end

function table.tolist(t)
	local ret = {}
	for k,v in pairs(t) do
		ret[#ret+1] = v
	end
	return ret
end

local function less_than(lhs,rhs)
	return lhs < rhs
end

function table.lower_bound(t,val,cmp)
	cmp = cmp or less_than
	local len = #t
	local first,last = 1,len + 1
	while first < last do
		local pos = math.floor((last-first) / 2) + first
		if not cmp(t[pos],val) then
			last = pos
		else
			first = pos + 1
		end
	end
	if last > len then
		return nil
	else
		return last
	end
end

function table.upper_bound(t,val,cmp)
	cmp = cmp or less_than
	local len = #t
	local first,last = 1,len + 1
	while first < last do
		local pos = math.floor((last-first)/2) + first
		if cmp(val,t[pos]) then
			last = pos
		else
			first = pos + 1
		end
	end
	if last > len then
		return nil
	else
		return last
	end
end

function table.equal(lhs,rhs)
	if lhs == rhs then
		return true
	end
	if type(lhs) == "table" and type(rhs) == "table" then
		if table.count(lhs) ~= table.count(rhs) then
			return false
		end
		local issame = true
		for k,v in pairs(lhs) do
			if not table.equal(v,rhs[k]) then
				issame = false
				break
			end
		end
		return issame
	end
	return false
end

-- list[b:e] include 'b' and 'e' pos
function table.slice(list,b,e,step)
	step = step or 1
	if not e then
		e = b
		b = 1
	end
	e = math.min(#list,e)
	local new_list = {}
	local len = #list
	local idx
	for i = b,e,step do
		idx = i >= 0 and i or len + i + 1
		table.insert(new_list,list[idx])
	end
	return new_list
end

-- set

function table.toset(tbl)
	tbl = tbl or {}
	local set = {}
	for i,v in ipairs(tbl) do
		set[v] = true
	end
	return set
end

function table.intersect_set(set1,set2)
	local set = {}
	for k in pairs(set1) do
		if set2[k] then
			set[k] = true
		end
	end
	return set
end


function table.union_set(set1,set2)
	local set = {}
	for k in pairs(set1) do
		set[k] = true
	end
	for k in pairs(set2) do
		if not set1[k] then
			set[k] = true
		end
	end
	return set
end

function table.diff_set(set1,set2)
	local ret = {}
	local set = table.intersect_set(set1,set2)
	for k in pairs(set1) do
		if not set[k] then
			ret[k] = true
		end
	end
	return ret
end

function table.isarray(tbl)
	if type(tbl) ~= "table" then
		return false
	end
	local len = #tbl
	for k,v in pairs(tbl) do
		if type(k) ~= "number" or k > len then
			return false
		end
	end
	return true
end

function table.simplify(o,seen)
	local typ = type(o)
	if typ ~= "table" then return o end
	seen = seen or {}
	if seen[o] then return seen[o] end
	local newtable = {}
	seen[o] = newtable
	for k,v in pairs(o) do
		--k = tostring(k)
		local tbl = table.simplify(v,seen)
		if type(tbl) ~= "table" then
			newtable[k] = tbl
		else
			for k1,v1 in pairs(tbl) do
				newtable[k.."_"..k1] = v1
			end
		end
	end
	return newtable
end

