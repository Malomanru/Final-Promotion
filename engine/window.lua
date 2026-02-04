local window = {
    fullscreen = false,
    vertical = false,
    width = 1920,
    height = 1080,
    scale = 1,
    baseAspect = 1920 / 1080,
    showFPS = false,
    vsync = 1,
}

function window:setSize(full, width, height)
    self.fullscreen = full or self.fullscreen
    if full then
        love.window.setFullscreen(true)
        self.width = love.graphics.getWidth()
        self.height = love.graphics.getHeight()
    else
        self.width = width or self.width
        self.height = height or self.height

        local aspect = self.vertical and (9 / 16) or (16 / 9)
        local newAspect = self.width / self.height

        if newAspect > aspect then
            self.width = math.floor(self.height * aspect)
        else
            self.height = math.floor(self.width / aspect)
        end

        love.window.setFullscreen(false)
        love.window.setMode(self.width, self.height, {resizable = true})
    end
    self:updateScale()
end

function window:updateScale()
    local base = self.vertical and 7 or 7.3
    self.scale = (base / 2) * (self.height / 1080)

    if cam and cam.updateScale then
        cam:updateScale(self)
    end
end

function window:checkSize()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    if w ~= self.width or h ~= self.height then
        self.width, self.height = w, h
        self:updateScale()
    end
end

function window:toggleFullscreen()
    self:setSize(not self.fullscreen)
end

function window:setVertical(isVertical)
    self.vertical = isVertical
    if self.vertical then
        self:setSize(false, 1080, 1920)
    else
        self:setSize(false, 1920, 1080)
    end
end

function window:toggleVertical()
    self:setVertical(not self.vertical)
end

function window:toggleFPS()
    self.showFPS = not self.showFPS
end

function window:drawFPS()
    local prevFont = love.graphics.getFont()
    if self.showFPS then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(resources.fonts.LEXIPA_12)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
        love.graphics.setFont(prevFont)
    end
end

return window