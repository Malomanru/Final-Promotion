local Camera = require("engine.libs.hump.camera")

local cam = Camera(0, 0)
cam.smoother = Camera.smooth.damped(8)
cam.zoomLevel = 1
cam.baseHeight = 1080
cam.minZoom, cam.maxZoom = 0.25, 15

function cam:setZoom(level)
    self.zoomLevel = math.max(self.minZoom, math.min(level, self.maxZoom))
    self:zoomTo(self.zoomLevel)
    
    -- После изменения зума нужно обновить позицию камеры с учетом новых границ
    if self.x and self.y then
        self:update(0, self.x, self.y)
    end
end

function cam:zoomOut()
    self:setZoom(self.zoomLevel - 0.25)
end

function cam:zoomIn()
    self:setZoom(self.zoomLevel + 0.25)
end

function cam:updateScale(window)
    local ratio = window.height / self.baseHeight
    self.zoomLevel = math.max(self.minZoom, math.min(ratio, self.maxZoom))
    self:zoomTo(self.zoomLevel)
    
    -- Также обновить позицию после изменения масштаба
    if self.x and self.y then
        self:update(0, self.x, self.y)
    end
end

function cam:update(dt, x, y)
    local camX, camY = x or self.x, y or self.y
    local w = love.graphics.getWidth() / self.zoomLevel
    local h = love.graphics.getHeight() / self.zoomLevel

    if _G.game.game_map and _G.game.game_map.currentMap then
        local mapW = _G.game.game_map.currentMap.width * 16
        local mapH = _G.game.game_map.currentMap.height * 16
        local halfW, halfH = w / 2, h / 2
        
        camX = math.max(halfW, math.min(camX, mapW - halfW))
        camY = math.max(halfH, math.min(camY, mapH - halfH))
    end

    if not ui.dialog.active then self:lockPosition(camX, camY, self.smoother) end
end

return cam