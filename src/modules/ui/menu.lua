local menu = {
    window = nil,
    active = true,
    priority = 0,
    time = 0,
    titleAlpha = 0,
    titleScale = 0.5,
    glitchActive = false,
    state = "title",
    buttonsAlpha = 0,
    mainTitleAlpha = 1,
    socialButtons = {},
}

function menu:confirmExit(text)
    ui.modalWindow:show{
        text = libs.translation.menu.confirmexit[_G.game.settings.language],
        _onClick_OK = function() love.event.quit() end,
        _onClick_Cancel = function() 
            ui.modalWindow:hide()
            self.window:setActiveElements("button", true)
        end
    }
end

function menu:startGame()
    _G.game.player = player.new()
    map:load("map2") _G.game.player:setPosition(100, 100) 
    self:hide()
    self.window:setActiveElements("button", false)
end

function menu:init()
    self.window = libs.ui:newElement("window", {
        x = (love.graphics.getWidth()/2) - 250, y = (love.graphics.getHeight()/2) - 200,
        width = 500, height = 400,
        flags = {
            can_resize = false,
            can_move = false,
            is_visible = false
        },
        visual = {
            bg_color = {0,0,0,0},
            title_color = {0,0,0,0},
            border_color = {0,0,0,0},
        },
    })
    
    local buttons_config = {
        {libs.translation.menu.play, function() ui.load_game:show() self:hide() self.window:setActiveElements("button", false) end},
        {libs.translation.menu.settings, function()
            libs.tween.new(0.4, self, {mainTitleAlpha = 0}, 'outQuad')
            for _, btn in pairs(self.window.content) do
                btn:setActive(false)
                btn.slideX = (btn.appearDelay < 0.3) and -love.graphics.getWidth() or love.graphics.getWidth()
                btn.appearAlpha = 0
            end
            local showDelay = {t = 0}
            libs.tween.new(0.5, showDelay, {t = 1}, 'linear', function()
                ui.settings:show()
            end)
        end},
        {libs.translation.menu.exit, function()
            self.window:setActiveElements("button", false)
            self:confirmExit()
        end},
    }

    for i, config in pairs(buttons_config) do
        local btn = self.window:addContent(libs.ui:newElement("button", {
            parent = self.window,
            text = config[1][_G.game.settings.language],
            callbacks = {onClick = config[2]},
            width = 400,
            height = 60,
            x = 50,
            y = 100 + (i - 1) * 80,
            flags = {is_active = false},
            visual = {
                bg_color = {0.05, 0.05, 0.05, 0.9},
                border_color = {1, 1, 1, 0.3},
                border_width = 2,
                font = resources.fonts.pressStart2P(20),
                text_color = {1, 1, 1, 1}
            }
        }))
        
        btn.slideX = (i % 2 == 1) and -love.graphics.getWidth() or love.graphics.getWidth()
        btn.hoverAlpha = 0
        btn.appearAlpha = 0
        btn.appearDelay = i * 0.2
        btn.show_arrows = true
        btn.changeLang = function()
            btn.text = config[1][_G.game.settings.language]
        end
        
        btn:onMouseEnter(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 1}, 'linear')
        end)
        
        btn:onMouseLeave(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 0}, 'linear')
        end)

        btn.draw = ui.custom.button.draw
    end
    
    local socialIcons = {
        {name = "discord", url = "https://discord.gg/yourserver", icon = "src/assets/sprites/ui/icons/discord.png"},
        {name = "github", url = "https://github.com/malomanru", icon = "src/assets/sprites/ui/icons/github.png"},
    }
    
    for i, social in ipairs(socialIcons) do
        local icon = libs.utils.resources.loadAndProcessAsset(social.icon)
        local btn = libs.ui:newElement("imageButton", {
            parent = {x = 0, y = 0, content = {}},
            image = icon,
            width = 50,
            height = 50,
            x = love.graphics.getWidth() - 70 - (i - 1) * 60,
            y = love.graphics.getHeight() - 70,
            callbacks = {
                onClick = function()
                    love.system.openURL(social.url)
                end
            },
            flags = {is_active = false}
        })
        
        btn:onMouseEnter(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 1}, 'linear')
        end)
        
        btn:onMouseLeave(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 0}, 'linear')
        end)
        
        table.insert(self.socialButtons, btn)
    end
end

function menu:show(direction, time)
    self.window.flags.is_visible = true
    libs.tween.new(0.8, self, {titleAlpha = 1, titleScale = 1}, "outElastic")
end

function menu:showButtons()
    self.window.flags.is_visible = true
    libs.tween.new(0.4, self, {mainTitleAlpha = 1}, 'outQuad')
    for i, btn in pairs(self.window.content) do
        btn.slideX = (i % 2 == 1) and -love.graphics.getWidth() or love.graphics.getWidth()
        btn.appearAlpha = 0
        local dummyDelay = {t = 0}
        btn.delayTween = libs.tween.new(btn.appearDelay, dummyDelay, {t = 1}, 'linear', function()
            btn.appearAlpha = 0.01
            btn.moveTween = libs.tween.new(0.8, btn, {slideX = 0, appearAlpha = 1}, 'outCubic', function()
                btn:setActive(true)
            end)
        end)
    end
    
    for _, socialBtn in ipairs(self.socialButtons) do
        socialBtn.flags.is_active = true
    end
end

function menu:hide()
    self.active = false
    self.window.flags.is_visible = false
    self.window:setActiveElements("button", false)
    self.window:setActiveElements("imageButton", false)
end

function menu:update(dt)
    if not self.active then return end
    libs.cam:lockPosition(0,0)
    
    self.time = self.time + dt
    
    if math.floor(self.time) % 3 == 0 and math.floor(self.time * 10) % 10 == 0 then
        self.glitchActive = true
    elseif self.glitchActive and math.floor(self.time * 10) % 10 > 1 then
        self.glitchActive = false
    end
    
    for _, socialBtn in ipairs(self.socialButtons) do
        if socialBtn.update then socialBtn:update(dt) end
    end
end

function menu:draw()
    if not self.active then return end
    
    ui.background:draw()
    
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, 150)
    love.graphics.scale(self.titleScale, self.titleScale)
    
    -- { Title } --

    local title = "FINAL PROMOTION"
    local font = resources.fonts.LEXIPA(48)
    love.graphics.setFont(font)
    local tw = font:getWidth(title)
    
    if self.glitchActive then
        love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.5 * self.mainTitleAlpha)
        love.graphics.print(title, -tw/2 + math.random(-3, 3), math.random(-2, 2))
    end
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.15 * self.mainTitleAlpha)
    love.graphics.print(title, -tw/2 + 4, 4)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * self.mainTitleAlpha)
    love.graphics.print(title, -tw/2, 0)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.6 * self.mainTitleAlpha)
    love.graphics.setLineWidth(2)
    love.graphics.line(-tw/2 - 40, 35, -tw/2 - 10, 35)
    love.graphics.line(tw/2 + 10, 35, tw/2 + 40, 35)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.4 * self.mainTitleAlpha)
    love.graphics.circle("fill", -tw/2 - 45, 35, 3)
    love.graphics.circle("fill", tw/2 + 45, 35, 3)
    
    -- { Subtitle } --

    if self.state == "title" then
        local subtitle = libs.translation.menu.subtitle[_G.game.settings.language]
        local smallFont = resources.fonts.pressStart2P(14)
        love.graphics.setFont(smallFont)
        local stw = smallFont:getWidth(subtitle)
        local pulse = math.sin(self.time * 2) * 0.3 + 0.7
        love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.5 * pulse)
        love.graphics.print(subtitle, -stw/2, 70)
    end
    
    love.graphics.pop()
    
    if self.state == "menu" and self.window.flags.is_visible and not ui.settings.active then
        self.window:draw()
        
        for _, socialBtn in ipairs(self.socialButtons) do
            if socialBtn.draw then socialBtn:draw() end
        end
    end
end

function menu:keypressed(key)
    if not self.active or ui.intro.active then return end
    if self.state == "title" then
        self.state = "menu"
        self:showButtons()
    end
    if self.state == "menu" then
        if key == "escape" then
            self:confirmExit()
        end
    end
end

return menu
