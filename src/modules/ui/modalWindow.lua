local modalWindow = {
    text = "",
    wrappedText = {},
    window = nil,
    active = false,
    priority = -1,
    bgAlpha = 0,
    contentAlpha = 0,
    on_tween = {
        _onStart_show = nil,
        _onEnd_show = nil,
        _onStart_hide = nil,
        _onEnd_hide = nil,
    }
}

function modalWindow:init()
    self.window = libs.ui:newElement("window", {
        width = 600, height = 250,
        x = love.graphics.getWidth()/2 - 300,
        y = love.graphics.getHeight()/2 - 125,
        flags = {
            can_move = false,
            can_resize = false,
            is_visible = false,
            show_title = false,
        },
        visual = {
            bg_color = {0,0,0,0},
            border_color = {0,0,0,0}
        },
    })
end

function modalWindow:show(args)
    self.text = tostring(args.text) or ""
    self.wrappedText = libs.utils.text.wrap(self.text, resources.fonts.pressStart2P(24), 550)
    self.window.flags.is_visible = true
    self.active = true
    self.bgAlpha = 0
    self.contentAlpha = 0
    
    self.window.content = {}
    
    self.on_tween = {
        _onStart_show = args._onStart_show,
        _onEnd_show  = args._onEnd_show,
        _onStart_hide = args._onStart_hide,
        _onEnd_hide = args._onEnd_hide,
    }
    
    libs.tween.new(0.3, self, {bgAlpha = 1}, 'outQuad')
    
    local contentDelay = {t = 0}
    libs.tween.new(0.2, contentDelay, {t = 1}, 'linear', function()
        libs.tween.new(0.5, self, {contentAlpha = 1}, 'outCubic')
    end)

    local buttons_config = {
        {libs.translation.menu.cancel, args._onClick_Cancel},
        {libs.translation.menu.ok, args._onClick_OK},
    }

    for i, config in ipairs(buttons_config) do
        local btn = self.window:addContent(libs.ui:newElement("button", {
            parent = self.window,
            text = config[1][_G.game.settings.language],
            width = 250, height = 60,
            x = ((i == 1) and 40) or 310,
            y = 160,
            callbacks = {onClick = config[2]},
            flags = {is_active = false},
            visual = {
                bg_color = {0.05, 0.05, 0.05, 0.9},
                border_color = {1, 1, 1, 0.3},
                border_width = 2,
                font = resources.fonts.pressStart2P(20),
                text_color = {1, 1, 1, 1}
            }
        }))
        
        btn.hoverAlpha = 0
        btn.appearAlpha = 0
        btn.appearDelay = 0.3 + i * 0.15
        btn.show_arrows = true
        btn.changeLang = function() btn.text = config[1][_G.game.settings.language]  end
        
        btn:onMouseEnter(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 1}, 'linear')
        end)
        
        btn:onMouseLeave(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 0}, 'linear')
        end)
        
        local dummyDelay = {t = 0}
        libs.tween.new(btn.appearDelay, dummyDelay, {t = 1}, 'linear', function()
            libs.tween.new(0.5, btn, {appearAlpha = 1}, 'outCubic', function()
                if i == #buttons_config then
                    for _, b in ipairs(self.window.content) do
                        if b.setActive then b:setActive(true) end
                    end
                end
            end)
        end)
        
        btn.draw = ui.custom.button.draw
    end
end

function modalWindow:hide()
    for _, btn in pairs(self.window.content) do
        if btn.setActive then
            btn:setActive(false)
        end
    end
    
    libs.tween.new(0.3, self, {contentAlpha = 0, bgAlpha = 0}, 'inQuad', function()
        self.active = false
        self.window.flags.is_visible = false
        if self.on_tween._onEnd_hide and type(self.on_tween._onEnd_hide) == "function" then 
            self.on_tween._onEnd_hide() 
        end
    end)
end

function modalWindow:update(dt)
    if not self.active then return end
    
    for _, element in pairs(self.window.content) do
        if element.update then
            element:update(dt)
        end
    end
end

function modalWindow:draw()
    if not self.active then return end
    
    love.graphics.setColor(0, 0, 0, 0.7 * self.bgAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(0.05, 0.05, 0.05, 0.95 * self.contentAlpha)
    love.graphics.rectangle("fill", self.window.x, self.window.y, self.window.width, self.window.height)
    
    love.graphics.setColor(1, 1, 1, 0.3 * self.contentAlpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", self.window.x, self.window.y, self.window.width, self.window.height)
    
    love.graphics.setFont(resources.fonts.pressStart2P(24))
    for i, line in ipairs(self.wrappedText) do
        local lineWidth = love.graphics.getFont():getWidth(line)
        local lineX = self.window.x + (self.window.width - lineWidth) / 2
        local lineY = self.window.y + 40 + (i - 1) * 30
        love.graphics.setColor(1, 1, 1, self.contentAlpha)
        love.graphics.print(line, lineX, lineY)
    end
    
    if self.window.flags.is_visible then
        self.window:draw()
    end
end

return modalWindow
