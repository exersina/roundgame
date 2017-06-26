skynet = require "skynet.manager"

logger = logger or {}
function logger.write(filename,msg)
	assert(string.match(filename,"^[a-z_]+[a-z_0-9/]*$"),"invalid log filename:" .. tostring(filename))
	local now = os.time()
	local date = os.date("%Y-%m-%d %H:%M:%S",now)
	if logger.time.sec ~= now then
		logger.time.sec = now
		logger.time.usec = 0
	end
	logger.time.usec = logger.time.usec + 1
	local fd = logger.gethandle(filename)
	msg = string.format("[%s %06d] %s",date,logger.time.usec,msg)
	fd:write(msg)
	fd:flush()
	return msg
end

function logger.sendmail(to_list,subject,content)
	local function escape(str) 
		local ret = string.gsub(str,"\"","\\\"")
		return ret
	end
	local strsh = string.format("cd ../shell && python sendmail.py %s \"%s\" \"%s\"",to_list,escape(subject),escape(content))
	--os.execute(strsh)
	io.popen(strsh)
end


function logger.gethandle(name)
	if not logger.handles[name] then
		local filename = string.format("%s/%s.log",logger.path,name)
		local parent_path = string.match(name,"(.*)/.*")
		if parent_path then
			os.execute("mkdir -p " .. logger.path .. "/" .. parent_path)
		end
		local fd  = io.open(filename,"a+b")
		assert(fd,"logfile open failed:" .. tostring(filename))
		fd:setvbuf("line")
		logger.handles[name] = fd
	end
	return logger.handles[name]
end

function logger.start()
	if logger.init then
		return
	end
	logger.init = true
	print("logger init")
	logger.handles = {}
	logger.time = {
		sec = 0,
		usec = 0,
	}
	logger.path = skynet.getenv("logpath")
	print("logger.path:",logger.path)
	os.execute(string.format("mkdir -p %s",logger.path))
	os.execute(string.format("ls -R %s > .log.tmp",logger.path))
	local fd = io.open(".log.tmp","r")
	local filename
	local name
	local section = ""
	for line in fd:lines() do
		if line:sub(#line) == ":" then
			if line == logger.path .. ":" then
				section = ""
			else
				section = string.match(line,string.format("%s/([^:]*):",logger.path))
			end
		else
			if line:sub(#line-3) == ".log" then
				if section ~= "" then
					name = section .. "/" .. line:sub(1,#line-4)
				else
					name = line:sub(1,#line-4)
				end
				filename = string.format("%s/%s.log",logger.path,name)
				--print(filename)
				local fd  = io.open(filename,"a+b")
				assert(fd,"logfile open failed:" .. tostring(filename))
				fd:setvbuf("line")
				logger.handles[name] = fd
			end
		end
	end
	fd:close()
	--os.execute("rm -rf .log.tmp")
	os.remove(".log.tmp")
	skynet.retpack(true)
end

function logger.shutdown()
	print("logger shutdown")
	for name,fd in pairs(logger.handles) do
		fd:close()
	end
	logger.handles = {}
	skynet.exit()
end

skynet.start(function ()
	skynet.dispatch("lua",function (session,source,cmd,...)
		local func = logger[cmd]
		if not func then
			error("invalid cmd:" .. tostring(cmd))
		end
		func(...)
	end)
end)

return logger
