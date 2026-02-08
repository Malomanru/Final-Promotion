local intro = {
    active = false,
    priority = 3,
    time = 0,
    titleAlpha = 0,
    titleScale = 0.8,
    _onEnd = nil,
    mainTitleAlpha = 1,
}

function intro:init()
end

function intro:show(_onEnd)
    self.active = true
    self.time = 0
    self.titleAlpha = 0
    self.titleScale = 0.8
    self._onEnd = _onEnd
    
    libs.tween.new(1.0, self, {titleAlpha = 1, titleScale = 1}, 'outElastic')
    
    local hideDelay = {t = 0}
    libs.tween.new(3.0, hideDelay, {t = 1}, 'linear', function()
        libs.tween.new(0.5, self, {titleAlpha = 0, titleScale = 0.8}, 'inQuad', function()
            self.active = false
            if self._onEnd and type(self._onEnd) == "function" then
                self._onEnd()
            end
        end)
    end)
end

function intro:update(dt)
    if not self.active then return end
    self.time = self.time + dt
end

function intro:draw()
    if not self.active then return end
    
    ui.background:draw()
    
    love.graphics.push()
    love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.scale(self.titleScale, self.titleScale)
    
    local title = "DREAMSPIRE"
    local font = resources.fonts.LEXIPA(80)
    love.graphics.setFont(font)
    local tw = font:getWidth(title)
    
    if self.glitchActive then
        love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.5 * self.mainTitleAlpha)
        love.graphics.print(title, -tw/2 + math.random(-3, 3), math.random(-2, 2))
    end
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.15 * self.mainTitleAlpha)
    love.graphics.print(title, -tw/2 + 4, -34)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * self.mainTitleAlpha)
    love.graphics.print(title, -tw/2, -30)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.6 * self.mainTitleAlpha)
    love.graphics.setLineWidth(2)
    love.graphics.line(-tw/2 - 40, 35, -tw/2 - 10, 35)
    love.graphics.line(tw/2 + 10, 35, tw/2 + 40, 35)
    
    love.graphics.setColor(1, 1, 1, self.titleAlpha * 0.4 * self.mainTitleAlpha)
    love.graphics.circle("fill", -tw/2 - 45, 35, 3)
    love.graphics.circle("fill", tw/2 + 45, 35, 3)

    love.graphics.pop()
end

function intro:isDone()
    return not self.active
end

function intro:getState()
    return self.active and "showing" or "done"
end

return intro
