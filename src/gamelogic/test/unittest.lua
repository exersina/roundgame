unittest = unittest or {}

function unittest.testall(verbose)
	local stat = {
		fails = 0,
		sum = 0,
		detail = {},
	}
	for name,method in pairs(unittest) do
		if name ~= "testall" and
			type(method) == "function" then
			local isok,errmsg = pcall(method)
			if not isok then
				stat.fails = stat.fails + 1
			end
			stat.sum = stat.sum + 1
			stat.detail[name] = {
				method = tostring(method),
				isok = isok,
				errmsg = errmsg,
			}
		end
	end
	if verbose then
		print(table.dump(stat))
	end
	return stat
end

return unittest
