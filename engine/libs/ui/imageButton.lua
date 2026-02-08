local imageButton = {}
imageButton.__index = imageButton

function imageButton.new(params)
    local self = setmetatable({}, imageButton)

    self.parent = params.parent or nil
    self.name = tostring("imageButton"..#self.parent.content)
    self.id = params.id or #self.parent.content
    self.image = params.image or nil
    if type(self.image) == 'string' then self.image = love.graphics.newImage(params.image) end
    self.type = "imageButton"

    self.x_local = params.x or 0
    self.y_local = params.y or 0
    self.x_global = 0
    self.y_global = 0
    self.width, self.height = params.width or 50, params.height or 50

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
        bg_color = (params.visual and params.visual.bg_color) or {0.05, 0.05, 0.05, 0.9},
        border_color = (params.visual and params.visual.border_color) or {1, 1, 1, 0.3},
        border_width = (params.visual and params.visual.border_width) or 2,
    }

    self.hoverAlpha = 0

    if self.parent then
        self.x_global = self.parent.x + self.x_local
        self.y_global = self.parent.y + self.y_local
    else
        self.x_global = self.x_local
        self.y_global = self.y_local
    end

    return self
end

function imageButton:update(dt)
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

function imageButton:draw()
    if not self.flags.is_visible then return end

    love.graphics.setColor(self.visual.bg_color)
    love.graphics.rectangle("fill", self.x_global, self.y_global, self.width, self.height)
    
    if self.hoverAlpha > 0 then
        love.graphics.setColor(1, 1, 1, self.hoverAlpha * 0.1)
        love.graphics.rectangle("fill", self.x_global, self.y_global, self.width, self.height)
    end
    
    love.graphics.setColor(self.visual.border_color)
    love.graphics.setLineWidth(self.visual.border_width)
    love.graphics.rectangle("line", self.x_global, self.y_global, self.width, self.height)
    
    if self.hoverAlpha > 0 then
        love.graphics.setColor(1, 1, 1, self.hoverAlpha * 0.5)
        love.graphics.rectangle("line", self.x_global - 2, self.y_global - 2, self.width + 4, self.height + 4)
    end
    
    if self.image then
        love.graphics.setColor(1, 1, 1, 1)
        local imgW, imgH = self.image:getWidth(), self.image:getHeight()
        local scale = math.min(self.width / imgW, self.height / imgH)
        local offsetX = (self.width - imgW * scale) / 2
        local offsetY = (self.height - imgH * scale) / 2
        love.graphics.draw(self.image, self.x_global + offsetX, self.y_global + offsetY, 0, scale, scale)
    end
end

function imageButton:setActive(value)
    self.flags.is_active = value
end

function imageButton:onClick(func)
    if func and type(func) == "function" then
        self.callbacks.onClick = func
    end
end

function imageButton:onMouseEnter(func)
    if func and type(func) == "function" then
        self.callbacks.onMouseEnter = func
    end
end

function imageButton:onMouseLeave(func)
    if func and type(func) == "function" then
        self.callbacks.onMouseLeave = func
    end
end

return imageButton
