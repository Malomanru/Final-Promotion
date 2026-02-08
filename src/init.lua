local init = {
    init = {}
}

function init.init.game(args)
    libs.window:setSize(true)
    libs.physics:init()
    libs.cam:updateScale(libs.window)
    
    _G.game.game_path = libs.data_manager.createGameDirectory("finalpromotion")
    _G.game.settings = init.init.settings()
    init.init.ui(args)
end

function init.init.settings()
    local default_settings = {
        volume = {
            general = 100,
            music = 50,
            sfx = 70
        }
    }
    return libs.data_manager:load_data(_G.game.game_path..'/options.json') or default_settings
end

function init.init.ui(args)
    for _, v in pairs(ui) do
        if v.init then v:init() end
    end
    
    if not libs.args_handler.has(libs.args_handler.process(args), "--nointro") then
        ui.intro:show(init.show_menu)
    else
        init.show_menu()
    end
end

function init.show_menu()
    ui.intro.active = false
    ui.menu.active = true
    ui.menu:show("down", 0.5)
end

return init