local dialog = {
    active = false,
    priority = 2,
    text = "",
    x = 0, y = 0,
    w = 800, h = 180,
    queue = {},
    choices = {},
    index = 1,
    wrappedText = {},
    cam = {x = 0, y = 0, zoom = 8, locked = false},
    type_delay = 0,
}

function dialog:show(replics, camX, camY, zoom)
    self.index = 1
    self.queue = replics
    self.type_delay = 0
    self.typing_active = true
    self.current_typed_text = ""
    self.full_text = replics[self.index]
    
    self.text = self.current_typed_text
    libs.utils.text.wrap(self.text, resources.fonts.LEXIPA(34), 780)
    
    self.cam.x, self.cam.y = camX, camY
    self.active = true
    self.y = love.graphics.getHeight()
    
    libs.tween.new(0.25, self.cam, {zoom = zoom or 10}, "inOutBack")
    libs.tween.new(0.25, self, {y = love.graphics.getHeight() - 200}, "inOutBack", function ()
        self.cam.locked = true
    end)
    
    _G.game.player.flags.can_move = false
end

function dialog:hide()
    libs.tween.new(0.25, self.cam, {zoom = 8}, "inOutBack")
    libs.tween.new(0.25, self, {y = love.graphics.getHeight()}, "inOutBack",
    function()
        self.active = false
        self.cam.locked = false
        self.index = 1
        self.queue = {}
        self.text = ""
        self.wrappedText = {}
        self.typing_active = false
        self.current_typed_text = ""
        self.full_text = ""
        _G.game.player.flags.can_move = true
    end)
end

function dialog:draw()
    if not self.active then return end
    
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 10, 10)
    love.graphics.rectangle("fill", self.x + self.w + 15, self.y, self.w/4, self.h, 10, 10)
    love.graphics.setColor(libs.utils.rgb(140, 140, 140))

    love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 10, 10)
    love.graphics.rectangle("line", self.x + self.w + 15, self.y, self.w/4, self.h, 10, 10)

    love.graphics.setColor(1, 1, 1, 1)
    
    local font = resources.fonts.LEXIPA(34)
    local lineHeight = font:getHeight() or 16
    
    love.graphics.setFont(resources.fonts.LEXIPA(34))

    for i, line in ipairs(self.wrappedText) do
        local lineWidth = font:getWidth(line)
        local lineX = self.x + (self.w - lineWidth) / 2
        love.graphics.print(line, lineX, (self.y + (self.h - (#self.wrappedText * lineHeight)) / 2) + (i - 1) * lineHeight)
    end
end

function dialog:update(dt)
    self.x = love.graphics.getWidth()/2 - 500
    libs.cam:setZoom(self.cam.zoom)

    if self.cam.locked then
        libs.cam:lockPosition(self.cam.x, self.cam.y)
    end
    
    if self.active and self.typing_active then
        self.type_delay = self.type_delay + dt
        
        if self.type_delay >= 0.05 then
            self.type_delay = 0
            
            local next_char_index = #self.current_typed_text + 1
            if next_char_index <= #self.full_text then
                self.current_typed_text = self.full_text:sub(1, next_char_index)
                self.text = self.current_typed_text
                libs.utils.text.wrap(self.text, resources.fonts.LEXIPA(34), 780)
            else
                self.typing_active = false
            end
        end
    end
end

function dialog:next()
    if self.typing_active then
        self.typing_active = false
        self.current_typed_text = self.full_text
        self.text = self.current_typed_text
        libs.utils.text.wrap(self.text, resources.fonts.LEXIPA(34), 780)
        return
    end
    
    self.index = self.index + 1
    
    if self.index <= #self.queue then
        self.type_delay = 0
        self.typing_active = true
        self.current_typed_text = ""
        self.full_text = self.queue[self.index]
        self.text = self.current_typed_text
        libs.utils.text.wrap(self.text, resources.fonts.LEXIPA(34), 780)
    else
        self:hide()
    end
end

function dialog:prev()
    if self.index > 1 then
        self.index = self.index - 1
        self.type_delay = 0
        self.typing_active = true
        self.current_typed_text = ""
        self.full_text = self.queue[self.index]
        self.text = self.current_typed_text
        libs.utils.text.wrap(self.text, resources.fonts.LEXIPA(34), 780)
    end
end

function dialog:keypressed(key)
    if not self.active then return end
    
    if key == "space" then
        self:next()
    end
end

function dialog:typeText(text, delay)
    delay = delay or 0.05
    local current_index = 0
    
    return function()
        current_index = current_index + 1
        if current_index <= #text then
            return text:sub(1, current_index)
        else
            return text
        end
    end
end

function dialog:load(name)
    if not name then return end

    local file = io.open('src/assets/dialogs/'..name..'.en')
    if file then
        local content = file:read("*all")
        file:close()
        
        local lines = {}
        for line in content:gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end
        
        return lines
    else
        return {}
    end
end

return dialog