cluster = require "skynet.cluster"
require "gamelogic.base.util.init"
require "gamelogic.logger.init"
require "gamelogic.hotfix.init"
require "gamelogic.war.warmgr"
require "gamelogic.test.init"

game = game or {}

function game.init()
	logger.init()
	warmgr.init()
end

function game.startgame()
	logger.logf("info","game","op=startgame")
	local port = skynet.getenv("debug_console")
	if port then
		skynet.newservice("debug_console",port)
	end
	if not skynet.getenv "daemon" then
		console.init()
	end
	skynet.name(".MAINSRV",skynet.self())
	skynet.dispatch("lua",warmgr.dispatch)
	cluster.open(skynet.getenv("srvname"))
end

function game.shutdown(reason)
	logger.logf("info","game","op=shutdown")
	warmgr.clear()
	skynet.timeout(300,logger.shutdown)
	skynet.timeout(500,os.exit)
end

return game
