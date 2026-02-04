local settings = {
    window = nil,
    active = false,
    buttons = {},
}

local volume_map = {
    general_volume = "general",
    music_volume = "music",
    sfx_volume = "sfx"
}

function settings:init()
    self.window = libs.ui:newElement("window", {
        x = (love.graphics.getWidth()/2) - 400,
        y = (love.graphics.getHeight()/2) - 400,
        width = 800,
        height = 900,
        flags = {
            can_resize = false,
            can_move = false,
            is_visible = false
        },
        visual = {
            bg_color = libs.utils.rgb(24,24,24, 0.8),
            border_radius = 10,
            border_color = {1,1,1,1}
        },
    })

    table.insert(self.window:addContent(libs.ui:newElement("button", {
        parent = self.window,
        text = "Back",
        callbacks = {
            onClick = function()
                libs.data_manager:save_data(_G.game.game_path..'/options.json', _G.game.settings)
                self:hide()
                ui.menu:show("down")
                ui.menu.window:setActiveElements('button', true)
            end
        },
        width = 380,
        x = self.window.width/2 - 190,
        y = self.window.height - 80,
        flags = { is_active = true },
        visual = {
            bg_color = libs.utils.rgb(24, 24, 24, 0.8),
            border_color = {1, 1, 1, 1},
            border_radius = 10,
            font = resources.fonts.LEXIPA(24),
        }
    })), self.buttons)

    for _, btn in pairs(self.buttons) do
        btn:onMouseEnter(function()
            local increase = 10
            libs.tween.new(0.25, btn, {
                width = btn.original.width + increase,
                height = btn.original.height + increase,
                x_local = btn.original.x_local - (increase / 2),
                y_local = btn.original.y_local - (increase / 2)
            }, 'inOutBack')
        end)

        btn:onMouseLeave(function()
            libs.tween.new(0.25, btn, {
                width = btn.original.width,
                height = btn.original.height,
                x_local = btn.original.x_local,
                y_local = btn.original.y_local
            }, 'inOutBack')
        end)
    end

    local sliders = {
        {"general_volume", 75, _G.game.settings.volume.general},
        {"music_volume", 170, _G.game.settings.volume.music},
        {"sfx_volume", 240, _G.game.settings.volume.sfx},
    }

    local labels = {
        {"Settings", self.window.width/2 - 50, -self.window.y + 60},
        {"General Volume: ", 130, 50},
        {"Music Volume: ", 110, 120},
        {"SFX Volume: ", 90, 190},
    }

    for _, label in pairs(labels) do
        self.window:addContent(libs.ui:newElement("label", {
            parent = self.window,
            text = label[1],
            x = label[2],
            y = label[3],
            visual = { font = resources.fonts.LEXIPA(36) }
        }))
    end

    for _, sliderData in ipairs(sliders) do
        self.window:addContent(libs.ui:newElement("slider", {
            parent = self.window,
            value = {current = sliderData[3]},
            name = sliderData[1],
            width = 300,
            x = 400,
            y = sliderData[2],
            callbacks = {
                onValueChanged = function(sliderElement)
                    local value = sliderElement:getValue("current")
                    local volume_key = volume_map[sliderData[1]]
                    _G.game.settings.volume[volume_key] = value
                    libs.utils.debug.log("DEBUG", "cyan", sliderElement.name .. ": " .. tostring(value))
                end
            }
        }))
    end
end

function settings:show()
    self.window.y = -love.graphics.getHeight()
    self.window.flags.is_visible = true
    libs.tween.new(0.5, self.window, {y = (love.graphics.getHeight()/2) - 450}, "inOutBack", function() self.active = true end)
end

function settings:hide()
    libs.tween.new(0.5, self.window, {y = -love.graphics.getHeight()}, "inOutBack", function() self.window.flags.is_visible = false end)
end

function settings:keypressed(key)
    if not self.active then return end

    if key == "escape" then
        self.active = false
        self:hide()
    end
end

return settings