return function(args)
    require("engine.init")()

    resources = require('src.resources')

    prop = require("src.modules.prop")
    map = require("src.modules.map")
    player = require("src.modules.player")
    npc = require("src.modules.npc")

    draw = require("src.draw")

    ui = {}
    ui.menu = require('src.modules.ui.menu')
    ui.settings = require('src.modules.ui.settings')
    ui.dialog = require("src.modules.ui.dialog")
    ui.modalWindow = require('src.modules.ui.modalWindow')
    ui.intro = require('src.modules.ui.intro')
end