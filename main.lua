_G.game = {
    game_path = nil,
    player = nil,
    game_map = nil,
}

function love.load(args)
    io.write("\b")
    require('src.require')(args)

    init.init.game(args)
    
    map:load('nil')
end

function love.update(dt)
    collectgarbage("step", 2048)
    
    libs.physics:update(dt)
    libs.tween.updateAll(dt)
    libs.timer:updateAll(dt)
    libs.ui:update(dt)
    libs.cam:update(dt, ((_G.game.player and _G.game.player.x) or 0), ((_G.game.player and _G.game.player.y) or 0))
    libs.cam:setZoom(8)

    map:update(dt)
    
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
    
    for _, v in pairs(ui) do
        if v.keypressed then v:keypressed(key) end
    end
    
    libs.ui:keypressed(key)
    
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

    if key == "n" then
        ui.dialog:show("act1_scene1_tv1")
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
    libs.data_manager:save_data(_G.game.game_path..'/options.json', _G.game.settings)
end