local menu = {
    window = nil,
}

function menu:init()
    self.window = libs.ui:newElement("window", {
        x = (love.graphics.getWidth()/2) - 200, y = (love.graphics.getHeight()/2) - 250,
        width = 400, height = 500,
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
        {"Play", function() map:load("map2") end},
        {"Settings", function()
            self.window:setActiveElements("button", false)
            libs.tween.new(0.5, self.window, {y = love.graphics.getHeight()}, "inOutBack", function() self.window.flags.is_visible = false end)
            ui.settings:show()
        end},
        {"Quit", function()
            self.window:setActiveElements("button", false)
            self:hide("down", 0.5)
            ui.modalWindow:show{
                text = "Are you sure you want to quit the game?",
                _onClick_OK = function() love.event.quit() end,
                _onClick_Cancel = function() ui.modalWindow:hide() self:show("down", 0.5) end,
                _onEnd_hide = function() self.window.flags.is_visible = true self.window:setActiveElements("button", true) end}
        end},
    }

    for i, config in pairs(buttons_config) do
        local btn = self.window:addContent(libs.ui:newElement("button", {
            parent = self.window,
            text = config[1],
            callbacks = {onClick = config[2]},
            width = 380,
            x = 10,
            y = i * 100 + 10,
            flags = {
                is_active = false
            },
            visual = {
                bg_color = libs.utils.rgb(24, 24, 24, 0.8),
                border_color = {1, 1, 1, 1},
                border_radius = 10,
                font = resources.fonts.LEXIPA(24),
            }
        }))

        btn.original = {
            width = btn.width,
            height = btn.height,
            x_local = btn.x_local,
            y_local = btn.y_local,
            x_global = btn.x_global,
            y_global = btn.y_global
        }

        btn:onMouseEnter(function()
            local width_increase = 10
            local height_increase = 10
            
            local new_x = btn.original.x_local - (width_increase / 2)
            local new_y = btn.original.y_local - (height_increase / 2)
            
            libs.tween.new(0.25, btn, {
                width = btn.original.width + width_increase,
                height = btn.original.height + height_increase,
                x_local = new_x,
                y_local = new_y
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
end

function menu:show(direction, time)
    local dirs = {
        up = -love.graphics.getHeight(),
        down = love.graphics.getHeight(),
    }
    self.window.flags.is_visible = true
    self.window.y = dirs[direction]
    libs.tween.new(time or 0.5, self.window, {y = (love.graphics.getHeight()/2) - 250}, "inOutBack")
end

function menu:hide(direction, time)
    local dirs = {
        up = -love.graphics.getHeight(),
        down = love.graphics.getHeight(),
    }
    libs.tween.new(time or 0.5, self.window, {y = dirs[direction] or dirs["down"]}, "inOutBack", function() self.window.flags.is_visible = false end)
end

function menu:update(dt)
    libs.cam:lockPosition(0,0)
end

return menu