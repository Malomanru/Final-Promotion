local slider = {}
slider.__index = slider

function slider.new(params)
    local self = setmetatable({}, slider)

    self.parent = params.parent or nil
    self.name = tostring("slider"..#self.parent.content)
    self.id = params.id or #self.parent.content

    self.type = "slider"
    self.value = {
        min =       (params.value and params.value.min) or 0,
        max =       (params.value and params.value.max) or 100,
        current =   (params.value and params.value.current ) or 50,
    }

    self.x_local = params.x or 0
    self.y_local = params.y or 0
    
    self.x_global = 0
    self.y_global = 0

    self.width, self.height = params.width or 100, params.height or 10

    self.callbacks = {
        onValueChanged =    (params.callbacks and params.callbacks.onValueChanged)   or nil,
        onMouseDown =       (params.callbacks and params.callbacks.onMouseDown   )   or nil,
        onMouseUp =         (params.callbacks and params.callbacks.onMouseUp     )   or nil,
        onMouseEnter =      (params.callbacks and params.callbacks.onMouseEnter  )   or nil,
        onMouseLeave =      (params.callbacks and params.callbacks.onMouseLeave  )   or nil,
    }

    self.flags = {
        hovered = false,
        down = false,
        is_active = (params.flags and params.flags.is_active) or true,
    }

    self.visual = {
        bg_color =          (params.visual and params.visual.bg_color         ) or  {0,0,0,0},
        knob_color =        (params.visual and params.visual.fg_color         ) or  {100, 100, 200},
        knob_border_size =  (params.visual and params.visual.knob_border_size ) or  2,
        knob_border_color = (params.visual and params.visual.knob_border_color) or  {30, 30, 30},
        bar_height =        (params.visual and params.visual.bar_height       ) or  5,
        bar_color =         (params.visual and params.visual.bar_color        ) or  {60, 60, 60},
        bar_border_size =   (params.visual and params.visual.bar_border_size  ) or  0,
        bar_border_color =  (params.visual and params.visual.bar_border_color ) or  {0, 0, 0},
        bar_radius =        (params.visual and params.visual.bar_radius       ) or  2,
        orientation =       (params.visual and params.visual.orientation      ) or  "horizontal" -- horizontal | vertical
    }

    return self
end

function slider:update(dt)
    if self.parent then
        self.x_global = self.parent.x + self.x_local
        self.y_global = self.parent.y + self.y_local
    else
        self.x_global = self.x_local
        self.y_global = self.y_local
    end

    local mouse_x, mouse_y = love.mouse.getPosition()
    local mouse_in_bounds = (
        mouse_x >= self.x_global and 
        mouse_x <= self.x_global + self.width and 
        mouse_y >= self.y_global and 
        mouse_y <= self.y_global + self.height
    )

    if mouse_in_bounds then
        if not self.flags.hovered then
            self.flags.hovered = true
            if self.callbacks.onMouseEnter then self.callbacks.onMouseEnter(self) end
        end
    else
        if self.flags.hovered then
            self.flags.hovered = false
            if self.callbacks.onMouseLeave then self.callbacks.onMouseLeave(self) end
        end
    end

    if love.mouse.isDown(1) and self.flags.is_active then
        if mouse_in_bounds then
            if not self.flags.down then
                self.flags.down = true
                if self.callbacks.onMouseDown then self.callbacks.onMouseDown(self) end
            end
        end
    else
        if self.flags.down then
            self.flags.down = false
            if self.callbacks.onMouseUp then self.callbacks.onMouseUp(self) end
        end
    end

    if self.flags.down then
        local value_range = self.value.max - self.value.min
        local mouse_pos_normalized
        if self.visual.orientation == "horizontal" then
            mouse_pos_normalized = (mouse_x - self.x_global) / self.width
        else
            mouse_pos_normalized = (mouse_y - self.y_global) / self.height
        end
        self.value.current = math.floor(mouse_pos_normalized * value_range + self.value.min)

        if self.callbacks.onValueChanged then self.callbacks.onValueChanged(self) end
    end

    -- restriction
    if self.value.current < self.value.min then self.value.current = self.value.min end
    if self.value.current > self.value.max then self.value.current = self.value.max end

    -- knob coordinates restriction
    
    local knob_size = self.visual.bar_height * 2
    if self.value.current == self.value.min then
        self.value.current = self.value.min
    elseif self.value.current == self.value.max then
        self.value.current = self.value.max - 1
    end
end

function slider:draw()
    if not self.flags.is_active then return end

    local x, y, w, h = self.x_global, self.y_global, self.width, self.height

    -- background
    love.graphics.setColor(self.visual.bg_color)
    love.graphics.rectangle("fill", x, y, w, h, 2)

    -- bar
    local bar_w, bar_h = w, self.visual.bar_height
    local bar_x, bar_y = x, y + h/2 - self.visual.bar_height/2

    if self.visual.orientation == "vertical" then
        bar_w, bar_h = self.visual.bar_height, h
        bar_x, bar_y = x + w/2 - self.visual.bar_height/2, y
    end

    love.graphics.setColor(self.visual.bar_color)
    love.graphics.rectangle("fill", bar_x, bar_y, bar_w, bar_h, self.visual.bar_radius)

    -- knob
    local knob_size = self.visual.bar_height * 2
    local knob_x, knob_y = bar_x, bar_y
    local value_range = self.value.max - self.value.min
    local value_normalized = (self.value.current - self.value.min) / value_range

    if self.visual.orientation == "horizontal" then
        knob_x = bar_x + value_normalized * (bar_w - knob_size)
        knob_y = bar_y - knob_size/2 + bar_h/2
    else
        knob_x = bar_x - knob_size/2 + bar_w/2
        knob_y = bar_y + value_normalized * (bar_h - knob_size)
    end

    love.graphics.setColor(self.visual.knob_color)
    love.graphics.rectangle("fill", knob_x, knob_y, knob_size, knob_size, knob_size/2)

    love.graphics.setColor(self.visual.knob_border_color)
    love.graphics.setLineWidth(self.visual.knob_border_size)
    love.graphics.rectangle("line", knob_x, knob_y, knob_size, knob_size, knob_size/2)
end

function slider:getValue(type)
    return self.value[type or "current"]
end

function slider:setValue(type, value)
    self.value[type] = value
end

return slider