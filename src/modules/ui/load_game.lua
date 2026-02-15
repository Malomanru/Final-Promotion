local load_game = {
    window = nil,
    active = false,
    priority = 1,
    time = 0,
    titleAlpha = 0,
    titleScale = 0.5,
    glitchActive = false,
    buttonsAlpha = 0,
    mainTitleAlpha = 1,
}

function load_game:init()
    self.window = libs.ui:newElement('window', {
        x = (love.graphics.getWidth()/2) - love.graphics.getWidth()/4,
        y = (love.graphics.getHeight()/2) - love.graphics.getHeight()/4,
        width = love.graphics.getWidth()/2,
        height = love.graphics.getHeight()/2,
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

    for i = 1, 3 do
        local btn = self.window:addContent(libs.ui:newElement("button", {
            parent = self.window,
            width = 300,
            height = 500,
            text = "",
            x = -21 + (i - 1) * 350,
            y = 20,
            flags = {is_active = false},
            visual = {
                bg_color = {0.05, 0.05, 0.05, 0.9},
                border_color = {1, 1, 1, 0.3},
                border_width = 2,
                font = resources.fonts.pressStart2P(20),
                text_color = {1, 1, 1, 1}
            }
        }))

        btn.slideY = love.graphics.getHeight()
        btn.hoverAlpha = 0
        btn.appearAlpha = 0
        btn.appearDelay = i * 0.2
        btn.show_arrows = false
        
        btn:onMouseEnter(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 1}, 'linear')
        end)
        
        btn:onMouseLeave(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 0}, 'linear')
        end)
        btn.draw = ui.custom.button.draw

        local label = self.window:addContent(libs.ui:newElement("label", {
            parent = self.window,
            text = "Slot "..i,
            width = 300,
            height = 500,
            x = (btn.x + btn.width/2) - 150,
            y = btn.y,
            flags = {is_active = false, follow_parent = false},
            visual = {
                bg_color = {0,0,0,0},
                font = resources.fonts.pressStart2P(20),
            }
        }))

        label.slideY = love.graphics.getHeight()
        label.hoverAlpha = 0
        label.appearAlpha = 0
        label.appearDelay = i * 0.2
    end


    local backBtn = self.window:addContent(libs.ui:newElement("button", {
        parent = self.window,
        text = libs.translation.menu.back[_G.game.settings.language],
        callbacks = {
            onClick = function()
                self:hide()
                ui.menu.window:setActiveElements("button", true)
            end
        },
        width = 400,
        height = 60,
        x = love.graphics.getWidth()/4 - 200,
        y = 650,
        flags = { is_active = false},
        visual = {
            bg_color = {0.05, 0.05, 0.05, 0.9},
            border_color = {1, 1, 1, 0.3},
            border_width = 2,
            font = resources.fonts.pressStart2P(20),
            text_color = {1, 1, 1, 1}
        }
    }))
    
    backBtn.slideX = 0
    backBtn.appearAlpha = 0
    backBtn.appearDelay = 0.6
    backBtn.hoverAlpha = 0
    backBtn.show_arrows = true
    backBtn.changeLang = function() backBtn.text = libs.translation.menu.back[_G.game.settings.language] end
    
    backBtn:onMouseEnter(function()
        libs.tween.new(0.2, backBtn, {hoverAlpha = 1}, 'linear')
    end)
    
    backBtn:onMouseLeave(function()
        libs.tween.new(0.2, backBtn, {hoverAlpha = 0}, 'linear')
    end)
    
    backBtn.draw = ui.custom.button.draw
end

function load_game:show(direction, time)
    self.active = true
    self.window.flags.is_visible = true
    libs.tween.new(0.8, self, {titleAlpha = 1, titleScale = 1}, "outElastic")
    self:showButtons()
    self:showLabels()
end

function load_game:hide()
    libs.tween.new(0.4, self, {titleAlpha = 0, titleScale = 0.8}, 'inQuad')
    
    for _, element in pairs(self.window.content) do
        if element.type == "button" then
            element:setActive(false)
        end
        
        local targetY = love.graphics.getHeight()
        
        libs.tween.new(0.6, element, {appearAlpha = 0}, 'inCubic')
    end
    
    local hideDelay = {t = 0}
    libs.tween.new(0.8, hideDelay, {t = 1}, 'linear', function()
        self.active = false
        self.window.flags.is_visible = false
        ui.menu.active = true
        ui.menu.state = "menu"
        local showDelay = {t = 0}
        libs.tween.new(0.2, showDelay, {t = 1}, 'linear', function()
            ui.menu:showButtons()
        end)
    end)
end

function load_game:showButtons()
    self.window.flags.is_visible = true
    libs.tween.new(0.4, self, {mainTitleAlpha = 1}, 'outQuad')
    for i, btn in pairs(self.window.content) do
        btn.slideY = 0
        btn.appearAlpha = 0
        local dummyDelay = {t = 0}
        btn.delayTween = libs.tween.new(btn.appearDelay, dummyDelay, {t = 1}, 'linear', function()
            btn.appearAlpha = 0.01
            btn.moveTween = libs.tween.new(0.8, btn, {slideY = 0, appearAlpha = 1}, 'outCubic', function()
                if btn.setActive then btn:setActive(true) end
            end)
        end)
    end
end

function load_game:showLabels()
    for i, label in pairs(self.window.content) do
        if label.type == "label" then
            local labelY = label.y_global
            label.appearAlpha = 0
            local dummyDelay = {t = 0}
            label.delayTween = libs.tween.new(label.appearDelay, dummyDelay, {t = 1}, 'linear', function()
                label.appearAlpha = 0.01
                label.moveTween = libs.tween.new(0.8, label, {y_global = labelY, appearAlpha = 1}, 'outCubic')
            end)
        end
    end
end

function load_game:draw()
    if not self.active then return end
    
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, 150)
    love.graphics.scale(self.titleScale, self.titleScale)
    
    -- { Title } --

    local title = "Start Game"
    local font = resources.fonts.LEXIPA(48)
    love.graphics.setFont(font)
    local tw = font:getWidth(title)
    
    if self.glitchActive then
        love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.5 * self.mainTitleAlpha)
        love.graphics.print(title, -tw/2 + math.random(-3, 3), math.random(-2, 2))
    end
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.15 * self.mainTitleAlpha)
    love.graphics.print(title, -tw/2 + 4, -2)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * self.mainTitleAlpha)
    love.graphics.print(title, -tw/2, -6)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.6 * self.mainTitleAlpha)
    love.graphics.setLineWidth(2)
    love.graphics.line(-tw/2 - 40, 35, -tw/2 - 10, 35)
    love.graphics.line(tw/2 + 10, 35, tw/2 + 40, 35)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.4 * self.mainTitleAlpha)
    love.graphics.circle("fill", -tw/2 - 45, 35, 3)
    love.graphics.circle("fill", tw/2 + 45, 35, 3)
    
    love.graphics.pop()
end

return load_game