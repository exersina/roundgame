skynet = require "skynet.manager"
socket = require "skynet.socket"
require "gamelogic.game"
require "gamelogic.console.init"


skynet.init(game.init)

skynet.start(game.startgame)
