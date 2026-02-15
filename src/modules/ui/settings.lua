local settings = {
    window = nil,
    active = false,
    priority = 1,
    time = 0,
    titleAlpha = 0,
    titleScale = 0.8
}

local volume_map = {
    general_volume = "general",
    music_volume = "music",
    sfx_volume = "sfx"
}

local languages = { "EN", "RU" }

function settings:init()
    self.window = libs.ui:newElement("window", {
        x = (love.graphics.getWidth()/2) - 400,
        y = (love.graphics.getHeight()/2) - 400,
        width = 800,
        height = 600,
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

    local sliders = {
        {"general_volume", 150, _G.game.settings.volume.general, libs.translation.settings.volume.general},
        {"music_volume", 250, _G.game.settings.volume.music, libs.translation.settings.volume.music},
        {"sfx_volume", 350, _G.game.settings.volume.sfx, libs.translation.settings.volume.sfx},
    }

    for i, sliderData in ipairs(sliders) do
        local label = self.window:addContent(libs.ui:newElement("label", {
            parent = self.window,
            text = sliderData[4][_G.game.settings.language],
            x = 30,
            y = sliderData[2] - 50,
            visual = { 
                font = resources.fonts.pressStart2P(12),
                text_color = {1, 1, 1, 1}
            }
        }))
        
        local slider = self.window:addContent(libs.ui:newElement("slider", {
            parent = self.window,
            value = {current = sliderData[3]},
            name = sliderData[1],
            width = 600,
            x = 100,
            y = sliderData[2],
            callbacks = {
                onValueChanged = function(sliderElement)
                    local value = sliderElement:getValue("current")
                    local volume_key = volume_map[sliderData[1]]
                    _G.game.settings.volume[volume_key] = value
                end
            }
        }))
        
        slider.slideX = (i % 2 == 1) and -love.graphics.getWidth() or love.graphics.getWidth()
        slider.appearAlpha = 0
        slider.appearDelay = i * 0.15
        
        label.slideX = slider.slideX
        label.appearAlpha = 0
        label.appearDelay = slider.appearDelay
        label.changeLang = function()
            label:setText(sliderData[4][_G.game.settings.language])
        end
    end

    ----------------------------------------------------------------
    -- LANGUAGE SELECTOR                                          --
    ----------------------------------------------------------------

    local langY = 430

    local langLabel = self.window:addContent(libs.ui:newElement("label", {
        parent = self.window,
        text = libs.translation.settings.language[_G.game.settings.language],
        x = 30,
        y = langY - 50,
        visual = {
            font = resources.fonts.pressStart2P(18),
            text_color = {1, 1, 1, 1}
        }
    }))
    langLabel.changeLang = function() langLabel:setText(libs.translation.settings.language[_G.game.settings.language]) end

    local langIndex = 1

    for i, lang in ipairs(languages) do
        if lang == (_G.game.settings.language or "EN") then
            langIndex = i
            break
        end
    end

    local langDisplay = self.window:addContent(libs.ui:newElement("label", {
        parent = self.window,
        text = languages[langIndex],
        x = 350,
        y = langY,
        visual = {
            font = resources.fonts.pressStart2P(28),
            text_color = {1,1,1,1}
        }
    }))
    langDisplay.changeLang = function() langDisplay:setText(languages[langIndex]) end

    for i = 1, 2 do
        local btn = self.window:addContent(libs.ui:newElement("button", {
            parent = self.window,
            text = (i == 1) and "<" or ">",
            width = 60,
            height = 60,
            x = (i == 1) and 240 or 500,
            y = 420,
            flags = { is_active = false },
            visual = {
                bg_color = {0.05, 0.05, 0.05, 0.9},
                border_color = {1, 1, 1, 0.3},
                border_width = 2,
                font = resources.fonts.pressStart2P(20),
                text_color = {1, 1, 1, 1}
            },
            callbacks = {
                onClick = function()
                    if i == 1 then
                        langIndex = langIndex - 1
                        if langIndex < 1 then langIndex = #languages end
                    else
                        langIndex = langIndex + 1
                        if langIndex > #languages then langIndex = 1 end
                    end
                    libs.utils.game.updateLanguage(languages[langIndex])
                    _G.game.settings.language = languages[langIndex]
                end,
            }
        }))

        btn.slideX = 0
        btn.appearAlpha = 0
        btn.appearDelay = 0.6
        btn.hoverAlpha = 0

        btn:onMouseEnter(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 1}, 'linear')
        end)
        
        btn:onMouseLeave(function()
            libs.tween.new(0.2, btn, {hoverAlpha = 0}, 'linear')
        end)

        btn.draw = ui.custom.button.draw
    end

    for _, element in ipairs({langLabel, langDisplay, leftArrow, rightArrow}) do
        element.slideX = love.graphics.getWidth()
        element.appearAlpha = 0
        element.appearDelay = 0.45
    end

    ----------------------------------------------------------------
    -- BACK BUTTON                                                --
    ----------------------------------------------------------------
    local backBtn = self.window:addContent(libs.ui:newElement("button", {
        parent = self.window,
        text = libs.translation.menu.back[_G.game.settings.language],
        callbacks = {
            onClick = function()
                libs.data_manager:save_data(_G.game.game_path..'/options.json', _G.game.settings)
                self:hide()
                ui.menu.window:setActiveElements("button", true)
            end
        },
        width = 400,
        height = 60,
        x = 200,
        y = 500,
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

function settings:show()
    ui.menu.active = false
    self.active = true
    self.window.flags.is_visible = true
    self.titleAlpha = 0
    self.titleScale = 0.8
    
    libs.tween.new(0.6, self, {titleAlpha = 1, titleScale = 1}, 'outElastic')
    
    for i, element in pairs(self.window.content) do
        element.appearAlpha = 0
        local dummyDelay = {t = 0}
        element.delayTween = libs.tween.new(element.appearDelay, dummyDelay, {t = 1}, 'linear', function()
            element.moveTween = libs.tween.new(0.8, element, {appearAlpha = 1}, 'outCubic')
        end)
        if element.type == "button" then
            element:setActive(true)
        end
    end
end

function settings:hide()
    libs.tween.new(0.4, self, {titleAlpha = 0, titleScale = 0.8}, 'inQuad')
    
    for _, element in pairs(self.window.content) do
        if element.type == "button" then
            element:setActive(false)
        end
        
        local targetX = (element.slideX == 0) and love.graphics.getWidth() or element.slideX
        if element.slideX == 0 then
            targetX = love.graphics.getWidth()
        elseif element.slideX < 0 then
            targetX = -love.graphics.getWidth()
        end
        
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

function settings:update(dt)
    if not self.active then return end
    self.time = self.time + dt
end

function settings:draw()
    if not self.active then return end
    
    ui.background:draw()
    
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, 80)
    love.graphics.scale(self.titleScale, self.titleScale)
    
    local title = libs.translation.settings.language[_G.game.settings.language]
    local font = resources.fonts.pressStart2P(42)
    love.graphics.setFont(font)
    local tw = font:getWidth(title)
    
    love.graphics.setColor(1, 1, 1, 0.15 * self.titleAlpha)
    love.graphics.print(title, -tw/2 + 3, 3)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha)
    love.graphics.print(title, -tw/2, 0)
    
    love.graphics.setColor(1, 1, 1, 0.6 * self.titleAlpha)
    love.graphics.setLineWidth(2)
    love.graphics.line(-tw/2 - 30, 30, -tw/2 - 10, 30)
    love.graphics.line(tw/2 + 10, 30, tw/2 + 30, 30)
    
    love.graphics.pop()
    
    if self.window.flags.is_visible then
        self.window:draw()
    end
end

function settings:keypressed(key)
    if not self.active then return end
    
    if key == "escape" then
        libs.data_manager:save_data(_G.game.game_path..'/options.json', _G.game.settings)
        self:hide()
    end
end

return settings
