local window = {}
window.__index = window

function window.new(params)
    local self = setmetatable({}, window)
    if type(params) ~= "table" then params = {params} end

    self.x, self.y = params.x or 0, params.y or 0
    self.width, self.height = params.width or 250, params.height or 150

    self.name = params.name or tostring('window_'..#libs.ui.windows)
    self.id = #libs.ui.windows
    self.content = {}

    self.flags = {
        can_move = (params.flags and params.flags.can_move) ~= false,
        can_resize = (params.flags and params.flags.can_resize) ~= false,
        is_visible = (params.flags and params.flags.is_visible) ~= false,
        is_modal = (params.flags and params.flags.is_modal),
        title_hovered = false,
        show_title = (params.flags and params.flags.show_title) ~= false,
    }

    self.visual = {
        bg_color = (params.visual and params.visual.bg_color) or libs.utils.rgb(140, 140, 140),
        title_color = (params.visual and params.visual.title_color) or libs.utils.rgb(24, 24, 24),
        title_height = (params.visual and params.visual.title_height) or 20,

        title_text = (params.visual and params.title_text) or "",
        title_text_color = (params.visual and params.visual.title_text_color) or libs.utils.rgb(240, 240, 240),

        border_size = (params.visual and params.visual.border_size) or 1,
        border_radius = (params.visual and params.visual.border_radius) or 0,
        border_color = (params.visual and params.visual.border_color) or libs.utils.rgb(0, 0, 0),
        border_width = (params.visual and params.visual.border_width) or 1,
    }

    table.insert(libs.ui.windows, self)

    return self
end

function window:update(dt)
    self.flags.title_hovered = libs.utils.cursor.inRect(self.x, self.y, self.width, self.visual.title_height)
    local mouseX, mouseY = love.mouse.getPosition()

    if self.flags.can_move and self.flags.title_hovered and love.mouse.isDown(1) then
        self.x, self.y = mouseX - self.width / 2, mouseY - self.visual.title_height / 2
    end
    
    for _, v in pairs(self.content) do
        if v.update then v:update(dt) end
    end
end

function window:draw()
    if not self.flags.is_visible then return end

    love.graphics.setColor(self.visual.bg_color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    if self.flags.show_title then
        love.graphics.setColor(self.visual.title_color)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.visual.title_height)
    end

    love.graphics.setColor(self.visual.title_text_color)
    love.graphics.print(self.visual.title_text, self.x + 5, self.y)

    love.graphics.setColor(self.visual.border_color)
    love.graphics.setLineWidth(self.visual.border_width)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.visual.border_radius)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1,1,1)

    for _, v in pairs(self.content) do
        if v.draw then v:draw() end
    end
end

function window:mousepressed(x, y, btn)
    for _, v in pairs(self.content) do
        if v.mousepressed then v:mousepressed(x, y, btn) end
    end
end

function window:mousereleased(x, y, btn)
    for _, v in pairs(self.content) do
        if v.mousereleased then v:mousereleased(x, y, btn) end
    end
end

function window:keypressed(key)
    for _, v in pairs(self.content) do
        if v.keypressed then v:keypressed(key) end
    end
end

function window:addContent(object)
    table.insert(self.content, object)
    return object
end

function window:setActiveElements(type, value)
    for _, element in pairs(self.content) do
        if element.type and element.type == type then element.flags.is_active = value end
    end
end

function window:getPosition()
    return self.x, self.y
end

function window:setPosition(x, y)
    self.x, self.y = x, y
end

return window