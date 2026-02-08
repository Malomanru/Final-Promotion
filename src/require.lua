return function(args)
    require("engine.init")()

    resources = require('src.resources')

    prop = require("src.modules.prop")
    map = require("src.modules.map")
    player = require("src.modules.player")
    npc = require("src.modules.npc")

    ui = {}
    ui.background = require('src.modules.ui.background')
    ui.menu = require('src.modules.ui.menu')
    ui.settings = require('src.modules.ui.settings')
    ui.dialog = require("src.modules.ui.dialog")
    ui.modalWindow = require('src.modules.ui.modalWindow')
    ui.intro = require('src.modules.ui.intro')

    init = require('src.init')
    draw = require("src.draw")
end