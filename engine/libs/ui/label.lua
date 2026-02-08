local label = {}
label.__index = label

function label.new(params)
    local self = setmetatable({}, label)

    self.parent = params.parent or nil
    self.name = tostring("label"..#self.parent.content)
    self.id = params.id or #self.parent.content
    self.text = params.text or "Label"

    self.type = "label"

    self.x_local = params.x or 0
    self.y_local = params.y or 0
    
    self.x_global = 0
    self.y_global = 0

    self.width, self.height = params.width or 100, params.height or 50

    self.flags = {
        is_visible = (params.flags and params.flags.is_visible) or true,
    }

    self.visual = {
        bg_color = (params.visual and params.visual.bg_color) or libs.utils.rgb(140, 140, 140),
        text_color = (params.visual and params.visual.text_color) or libs.utils.rgb(255, 255, 255),
        border_color = (params.visual and params.visual.border_color) or libs.utils.rgb(0,0,0,0),
        border_width = (params.visual and params.visual.border_width) or 2,
        border_radius = (params.visual and params.visual.border_radius) or 0,
        font = (params.visual and params.visual.font) or love.graphics.getFont(),
    }

    self.wrappedText = libs.utils.text.wrap(self.text, self.visual.font, 780)

    return self
end

function label:update(dt)
    if self.parent then
        self.x_global = self.parent.x + self.x_local
        self.y_global = self.parent.y + self.y_local
    else
        self.x_global = self.x_local
        self.y_global = self.y_local
    end
end

function label:draw()
    local alpha = self.appearAlpha or 1
    if alpha <= 0 then return end
    if not self.flags.is_visible then return end

    love.graphics.setFont(self.visual.font)

    for i, line in ipairs(self.wrappedText) do
        local lineWidth = love.graphics.getFont():getWidth(line)
        local lineX = self.x_global + (self.width - lineWidth) / 2
        love.graphics.setColor(self.visual.text_color[1], self.visual.text_color[2], self.visual.text_color[3], (self.visual.text_color[4] or 1) * alpha)
        love.graphics.print(line, lineX, (self.y_global + (self.height - (#self.wrappedText * love.graphics.getFont():getHeight() or 16)) / 2) + (i - 1) * love.graphics.getFont():getHeight() or 16)
    end
end

return label