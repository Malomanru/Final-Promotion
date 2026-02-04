local button = {}
button.__index = button

function button.new(params)
    local self = setmetatable({}, button)

    self.parent = params.parent or nil
    self.name = tostring("button"..#self.parent.content)
    self.id = params.id or #self.parent.content
    self.text = params.text or "Button"

    self.type = "button"

    self.x_local = params.x or 0
    self.y_local = params.y or 0
    
    self.x_global = 0
    self.y_global = 0

    self.width, self.height = params.width or 100, params.height or 50

    self.flags = {
        hovered = false,
        is_visible = (params.flags and params.flags.is_visible) ~= false,
        is_active = (params.flags and params.flags.is_active) ~= false,
        was_pressed = false,
        was_hovered_last_frame = false,
    }
    
    self.callbacks = {
        onClick = (params.callbacks and params.callbacks.onClick) or nil,
        onMouseEnter = (params.callbacks and params.callbacks.onMouseEnter) or nil,
        onMouseLeave = (params.callbacks and params.callbacks.onMouseLeave) or nil,
    }

    self.visual = {
        bg_color = (params.visual and params.visual.bg_color) or libs.utils.rgb(140, 140, 140),
        text_color = (params.visual and params.visual.text_color) or libs.utils.rgb(255, 255, 255),
        border_color = (params.visual and params.visual.border_color) or libs.utils.rgb(0,0,0,0),
        border_width = (params.visual and params.visual.border_width) or 2,
        border_radius = (params.visual and params.visual.border_radius) or 0,
        font = (params.visual and params.visual.font) or love.graphics.getFont(),
    }

    if self.parent then
        self.x_global = self.parent.x + self.x_local
        self.y_global = self.parent.y + self.y_local
    else
        self.x_global = self.x_local
        self.y_global = self.y_local
    end

    return self
end

function button:update(dt)
    if self.parent then
        self.x_global = self.parent.x + self.x_local
        self.y_global = self.parent.y + self.y_local
    else
        self.x_global = self.x_local
        self.y_global = self.y_local
    end

    local was_hovered_last_frame = self.flags.was_hovered_last_frame
    self.flags.hovered = libs.utils.cursor.inRect(self.x_global, self.y_global, self.width, self.height)
    
    if not was_hovered_last_frame and self.flags.hovered and self.callbacks.onMouseEnter then
        self.callbacks.onMouseEnter()
    elseif was_hovered_last_frame and not self.flags.hovered and self.callbacks.onMouseLeave then
        self.callbacks.onMouseLeave()
    end
    
    self.flags.was_hovered_last_frame = self.flags.hovered

    if self.flags.is_active and self.flags.hovered then
        if love.mouse.isDown(1) then
            self.flags.was_pressed = true
        elseif self.flags.was_pressed and not love.mouse.isDown(1) then
            self.flags.was_pressed = false
            if self.callbacks.onClick then
                self.callbacks.onClick()
            end
        end
    else
        self.flags.was_pressed = false
    end
end

function button:mousepressed(x, y, btn)
    if not self.flags.is_active then return end
    if btn == 1 and self.flags.hovered then
        self.flags.was_pressed = true
    end
end

function button:mousereleased(x, y, btn)
    if not self.flags.is_active then return end
    if btn == 1 and self.flags.was_pressed and self.flags.hovered then
        if self.callbacks.onClick then
            self.callbacks.onClick()
        end
    end
    self.flags.was_pressed = false
end

function button:draw()
    if not self.flags.is_visible then return end

    love.graphics.setFont(self.visual.font)
    love.graphics.setColor(self.visual.bg_color)
    love.graphics.rectangle("fill", self.x_global, self.y_global, self.width, self.height, self.visual.border_radius)
    
    love.graphics.setColor(self.visual.border_color)
    love.graphics.rectangle("line", self.x_global, self.y_global, self.width, self.height, self.visual.border_radius)
    
    love.graphics.setColor(self.visual.text_color)
    love.graphics.printf(self.text, self.x_global, self.y_global + (self.height/2 - self.visual.font:getHeight()/2), self.width, "center")
end

function button:setPosition(x_local, y_local)
    self.x_local = x_local or self.x_local
    self.y_local = y_local or self.y_local
end

function button:getLocalPosition()
    return self.x_local, self.y_local
end

function button:getGlobalPosition()
    return self.x_global, self.y_global
end

function button:setActive(value)
    self.flags.is_active = value
end

function button:onClick(func)
    if func and type(func) == "function" then
        self.callbacks.onClick = func
    end
end

function button:onMouseEnter(func)
    if func and type(func) == "function" then
        self.callbacks.onMouseEnter = func
    end
end

function button:onMouseLeave(func)
    if func and type(func) == "function" then
        self.callbacks.onMouseLeave = func
    end
end

return button