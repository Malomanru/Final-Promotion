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
    socialButtons = {}
}

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
        {"PLAY", function() map:load("map2") _G.game.player = player.new() _G.game.player:setPosition(100, 100) self.active = false end},
        {"SETTINGS", function()
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
        {"QUIT", function()
            for _, btn in pairs(self.window.content) do
                btn:setActive(false)
            end
            ui.modalWindow:show{
                text = "Are you sure you want to quit?",
                _onClick_OK = function() love.event.quit() end,
                _onClick_Cancel = function() 
                    ui.modalWindow:hide()
                    for _, btn in pairs(self.window.content) do
                        btn:setActive(true)
                    end
                end
            }
        end},
    }

    for i, config in pairs(buttons_config) do
        local btn = self.window:addContent(libs.ui:newElement("button", {
            parent = self.window,
            text = config[1],
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
                font = resources.fonts.LEXIPA(20),
                text_color = {1, 1, 1, 1}
            }
        }))
        
        btn.slideX = (i % 2 == 1) and -love.graphics.getWidth() or love.graphics.getWidth()
        btn.hoverAlpha = 0
        btn.appearAlpha = 0
        btn.appearDelay = i * 0.2
        
        local originalUpdate = btn.update
        btn.update = function(self, dt)
            if originalUpdate then originalUpdate(self, dt) end
        end
        
        btn:onMouseEnter(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 1}, 'linear')
        end)
        
        btn:onMouseLeave(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 0}, 'linear')
        end)
        
        local originalDraw = btn.draw
        btn.draw = function(self)
            if self.appearAlpha <= 0 and math.abs(self.slideX) < love.graphics.getWidth() then return end
            
            love.graphics.push()
            love.graphics.translate(self.slideX, 0)
            
            love.graphics.setFont(self.visual.font)
            love.graphics.setColor(self.visual.bg_color[1], self.visual.bg_color[2], self.visual.bg_color[3], self.visual.bg_color[4] * self.appearAlpha)
            love.graphics.rectangle("fill", self.x_global, self.y_global, self.width, self.height)
            
            if self.hoverAlpha > 0 then
                love.graphics.setColor(1, 1, 1, self.hoverAlpha * 0.1 * self.appearAlpha)
                love.graphics.rectangle("fill", self.x_global, self.y_global, self.width, self.height)
                
                love.graphics.setColor(1, 1, 1, self.hoverAlpha * 0.8 * self.appearAlpha)
                love.graphics.rectangle("fill", self.x_global, self.y_global, 3, self.height)
                love.graphics.rectangle("fill", self.x_global + self.width - 3, self.y_global, 3, self.height)
            end
            
            love.graphics.setColor(self.visual.border_color[1], self.visual.border_color[2], self.visual.border_color[3], self.visual.border_color[4] * self.appearAlpha)
            love.graphics.setLineWidth(self.visual.border_width)
            love.graphics.rectangle("line", self.x_global, self.y_global, self.width, self.height)
            
            if self.hoverAlpha > 0 then
                love.graphics.setColor(1, 1, 1, self.hoverAlpha * 0.5 * self.appearAlpha)
                love.graphics.rectangle("line", self.x_global - 2, self.y_global - 2, self.width + 4, self.height + 4)
            end
            
            love.graphics.setColor(self.visual.text_color[1], self.visual.text_color[2], self.visual.text_color[3], self.visual.text_color[4] * self.appearAlpha)
            local tw = self.visual.font:getWidth(self.text)
            local th = self.visual.font:getHeight()
            love.graphics.print(self.text, self.x_global + (self.width - tw) / 2, self.y_global + (self.height - th) / 2)
            
            if self.hoverAlpha > 0 then
                love.graphics.setColor(1, 1, 1, self.hoverAlpha * 0.6 * self.appearAlpha)
                love.graphics.print(">", self.x_global + 15, self.y_global + (self.height - th) / 2)
                love.graphics.print("<", self.x_global + self.width - 25, self.y_global + (self.height - th) / 2)
            end
            
            love.graphics.pop()
        end
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

function menu:hide(direction, time)
    self.window.flags.is_visible = false
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
        local subtitle = "Press any key"
        local smallFont = resources.fonts.LEXIPA(14)
        love.graphics.setFont(smallFont)
        local stw = smallFont:getWidth(subtitle)
        local pulse = math.sin(self.time * 2) * 0.3 + 0.7
        love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.5 * pulse)
        love.graphics.print(subtitle, -stw/2, 60)
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
end

return menu
