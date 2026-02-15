local M = {
    init = {}
}

function M.init.game(args)
    libs.window:setSize(true)
    libs.physics:init()
    libs.cam:updateScale(libs.window)
    libs.translation:loadFile("src/lang.txt")
    
    _G.game.game_path = libs.data_manager.createGameDirectory("finalpromotion")
    _G.game.settings = init.init.settings()
    init.init.ui(args)
end

function M.init.settings()
    local default_settings = {
        volume = {
            general = 100,
            music = 50,
            sfx = 70
        },
        language = "EN"
    }
    return libs.data_manager:load_data(_G.game.game_path..'/options.json') or default_settings
end

function M.init.ui(args)
    for _, v in pairs(ui) do
        if (type(v) ~= "function") and v.init then v:init() end
    end
    
    if not libs.args_handler.has(libs.args_handler.process(args), "--nointro") then
        ui.intro:show(init.show_menu)
    else
        init.show_menu()
    end
end

function M.show_menu()
    ui.intro.active = false
    ui.menu.active = true
    ui.menu:show("down", 0.5)
end

return M