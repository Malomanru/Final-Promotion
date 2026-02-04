_G.game = {
    game_path = nil,
    player = nil,
    game_map = nil,
}

local function init_settings()
    local default_settings = {
        volume = {
            general = 100,
            music = 50,
            sfx = 70
        }
    }
    return libs.data_manager:load_data(_G.game.game_path..'/options.json') or default_settings
end

local function show_menu()
    ui.intro.active = false
    ui.menu.window.flags.is_visible = true
    for _, v in pairs(ui.menu.window.content) do
        v:setActive(true)
    end
end

function love.load(args)
    require('src.require')(args)
    
    libs.window:setSize(true)
    libs.physics:init()
    libs.cam:updateScale(libs.window)
    
    _G.game.game_path = libs.data_manager.createGameDirectory("finalpromotion")
    _G.game.settings = init_settings()
    
    map:load('nil')
    
    for _, v in pairs(ui) do
        if v.init then v:init() end
    end
    
    if not libs.args_handler.has(libs.args_handler.process(args), "--nointro") then
        ui.intro:show(show_menu)
    else
        show_menu()
    end
end

function love.update(dt)
    collectgarbage("collect", 200)
    
    libs.physics:update(dt)
    libs.tween.updateAll(dt)
    libs.timer:updateAll(dt)
    libs.ui:update(dt)
    
    for _, v in pairs(ui) do
        if v.update then v:update(dt) end
    end
end

function love.draw()
    draw.BeforeCamera()
    
    libs.cam:attach()
    draw.Camera()
    libs.cam:detach()
    
    draw.AfterCamera()
end

function love.keypressed(key, scancode, isrepeat)
    key = scancode
    
    if key == "k" then
        libs.effects.rising_text:create{
            text = "To move press: W A S D",
            x = 115,
            y = 90,
            font = resources.fonts.LEXIPA(12),
            text_duration_before_fade = 5,
            direction = "down"
        }
    elseif key == "r" then
        local myText = libs.effects.glitch_text.new("Hello", resources.fonts.LEXIPA(24), 0, -32)
        myText:setEffect("complex")
        myText:setIntensity(2.5)
    end
    
    for _, v in pairs(ui) do
        if v.keypressed then v:keypressed(key) end
    end
end

function love.keyreleased(key, scancode, isrepeat)
    key = scancode
end

function love.mousepressed(x, y, btn, istouch)
    libs.ui:mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn, istouch)
end

function love.textinput(text)
end

function love.quit()
end