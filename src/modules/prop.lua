local prop = {}
prop.__index = prop

function prop.new(params)
    local self = setmetatable({}, prop)

    self.sprite =  libs.utils.resources.loadAndProcessAsset(params.sprite) or libs.utils.resources.loadAndProcessAsset("src/assets/sprites/props/street_lamp.png")

    self.x, self.y, self.add_y = params.x or 0, params.y or 0, params.add_y or 0
    self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight()

    self.direction = params.direction or "right"

    self.flags = {
        player_inside = false,
        transparency_when_inside = (params.flags and params.flags.transparency_when_inside) or false
    }

    self.visual = {
        transparency = 1,
    }

    return self
end

function prop:update(dt)
    self.flags.player_inside = _G.game.player and libs.utils.point.inRect(self.x - self.w/2, self.y - self.h/2, self.w, self.h, _G.game.player.x, _G.game.player.y)
end

function prop:draw()
    if self.flags.player_inside and self.flags.transparency_when_inside then
        love.graphics.setColor(1, 1, 1, (not self.flags.player_inside and self.visual.transparency) or 0.5)
    end

    local scaleX = self.direction == "right" and 1 or -1
    love.graphics.draw(self.sprite, scaleX == 1 and (self.x - self.w/2) or (self.x + self.w/2), self.y - self.h/2, 0, scaleX, 1)

    love.graphics.setColor(1,1,1,1)
end

return prop