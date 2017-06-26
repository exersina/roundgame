
logger = logger or {}
function logger.write(filename,msg)
	skynet.send(logger.service,"lua","write",filename,msg)
end

function logger.debug(filename,...)
	logger.log("DEBUG",filename,...)
end

function logger.info(filename,...)
	logger.log("INFO",filename,...)
end

function logger.warning(filename,...)
	logger.log("WARNING",filename,...)
end

function logger.error(filename,...)
	logger.log("ERROR",filename,...)
end

function logger.critical(filename,...)
	logger.log("CRITICAL",filename,...)
end

function logger.log(name,filename,...)
	name = string.upper(name)
	local loglevel = assert(logger.LOGLEVEL[name])
	if logger.loglevel > loglevel then
		return
	end
	local msg = string.format("[%s] %s\n",name,table.concat({...},"\t"))
	logger.write(filename,msg)
end

function logger.logf(name,filename,fmt,...)
	name = string.upper(name)
	local loglevel = assert(logger.LOGLEVEL[name])
	if logger.loglevel > loglevel then
		return
	end
	local msg = format("[%s] " .. fmt .. "\n",name,...)
	logger.write(filename,msg)
end


function logger.sendmail(to_list,subject,content)
	skynet.send(logger.service,"lua","sendmail",to_list,subject,content)
end

-- console/print
function logger.print(...)
	if logger.loglevel > logger.LOGLEVEL.DEBUG then
		return
	end
	print(string.format("[%s]",os.date("%Y-%m-%d %H:%M:%S")),...)
end

function logger.pprintf(fmt,...)
	if logger.loglevel > logger.LOGLEVEL.DEBUG then
		return
	end
	pprintf(string.format("[%s] %s",os.date("%Y-%m-%d %H:%M:%S"),fmt),...)
end

function logger.setloglevel(loglevel)
	print(skynet.address(skynet.self()),"logger.setloglevel",loglevel)
	if type(loglevel) == "string" then
		loglevel = string.upper(loglevel)
		loglevel = logger.LOGLEVEL[loglevel]
	end
	if not (logger.LOGLEVEL.DEBUG <= loglevel and loglevel <= logger.LOGLEVEL.CRITICAL) then
		error("invalid loglevel:" .. tostring(loglevel))
	end
	logger.loglevel = loglevel
end

logger.LOGLEVEL = {
	DEBUG = 1,
	INFO = 2,
	WARNING = 3,
	ERROR = 4,
	CRITICAL = 5,
}

function logger._init()
	logger.setloglevel(skynet.getenv("loglevel"))
	if not logger.service then
		logger.service = skynet.uniqueservice("gamelogic/service/loggerd")
	end
end

function logger.init()
	logger._init()
	skynet.call(logger.service,"lua","start")
end

function logger.shutdown()
	skynet.send(logger.service,"lua","shutdown")
end
return logger
