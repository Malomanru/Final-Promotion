local modalWindow = {
    text = "",
    wrappedText = {},

    window = nil,
    on_tween = {
        _onStart_show = nil,
        _onEnd_show = nil,
        _onStart_hide = nil,
        _onEnd_hide = nil,
    }
}

function modalWindow:init()
    self.window = libs.ui:newElement("window", {
        width = 800, height = 280,
        x = love.graphics.getWidth()/2 - 400,
        y = love.graphics.getHeight()/2 - 200,

        flags = {
            can_move = false,
            can_resize = false,
            is_visible = false,
        },
        visual = {
            bg_color = libs.utils.rgb(24,24,24, 0.8),
            border_radius = 10,
            border_color = {1,1,1,1}
        },
    })
end


function modalWindow:show(args)
    self.text = tostring(args.text) or ""
    self.wrappedText = libs.utils.text.wrap(self.text, resources.fonts.LEXIPA(34), 780)
    self.window.flags.is_visible = true

    self.window.content = {}
    self.window.y = -love.graphics.getHeight()

    self.on_tween = {
        _onStart_show = args._onStart_show,
        _onEnd_show  = args._onEnd_show,
        _onStart_hide = args._onStart_hide,
        _onEnd_hide = args._onEnd_hide,
    }

    libs.tween.new(0.5, self.window, {y = love.graphics.getHeight()/2 - 140}, "inOutBack", function()
        if self.on_tween._onEnd and type(self.on_tween._onEnd) == "function" then self.on_tween._onEnd_show() end
    end)

    local buttons_config = {
        {"Cancel", args._onClick_Cancel},
        {"OK", args._onClick_OK},
    }

    for i, config in ipairs(buttons_config) do
        local btn = self.window:addContent(libs.ui:newElement("button", {
            parent = self.window,
            text = config[1],
            width = 280, height = 80,
            x = i * 320 - 220,
            y = self.window.height + 20,
            callbacks = {onClick = config[2]},
            visual = {
                bg_color = libs.utils.rgb(24, 24, 24, 0.8),
                border_color = {1,1,1,1},
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

function modalWindow:hide(_OnTweenEnd)
    libs.tween.new(0.5, self.window, {y = -love.graphics.getHeight() - self.window.height}, "inOutBack", function()
        self.window.flags.is_visible = false
        if self.on_tween._onEnd_hide and type(self.on_tween._onEnd_hide) == "function" then self.on_tween._onEnd_hide() end
    end)
end

function modalWindow:draw()
    if not self.window.flags.is_visible then return end

    love.graphics.setFont(resources.fonts.LEXIPA(34))

    for i, line in ipairs(self.wrappedText) do
        local lineWidth = love.graphics.getFont():getWidth(line)
        local lineX = self.window.x + (self.window.width - lineWidth) / 2
        love.graphics.print(line, lineX, (self.window.y + (self.window.height - (#self.wrappedText * love.graphics.getFont():getHeight() or 16)) / 2) + (i - 1) * love.graphics.getFont():getHeight() or 16)
    end
end

return modalWindow