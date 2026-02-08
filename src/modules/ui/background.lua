local background = {
    particles = {},
    time = 0,
    scanLineY = 0
}

function background:init()
    for i = 1, 80 do
        table.insert(self.particles, {
            x = math.random(0, love.graphics.getWidth()),
            y = math.random(0, love.graphics.getHeight()),
            size = math.random(1, 4),
            speed = math.random(5, 25),
            alpha = math.random(20, 80) / 100,
            pulseSpeed = math.random(1, 3),
            pulseOffset = math.random() * math.pi * 2
        })
    end
end

function background:update(dt)
    self.time = self.time + dt
    self.scanLineY = (self.scanLineY + 100 * dt) % love.graphics.getHeight()
    
    for _, p in ipairs(self.particles) do
        p.y = p.y + p.speed * dt
        if p.y > love.graphics.getHeight() then
            p.y = -10
            p.x = math.random(0, love.graphics.getWidth())
        end
    end
end

function background:draw()
    love.graphics.setColor(0, 0, 0, 0.98)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    for _, p in ipairs(self.particles) do
        local pulse = math.sin(self.time * p.pulseSpeed + p.pulseOffset) * 0.3 + 0.7
        love.graphics.setColor(1, 1, 1, p.alpha * 0.4 * pulse)
        love.graphics.circle("fill", p.x, p.y, p.size * pulse)
    end
    
    love.graphics.setColor(1, 1, 1, 0.03)
    love.graphics.rectangle("fill", 0, self.scanLineY, love.graphics.getWidth(), 3)

    love.graphics.setColor(1, 1, 1, 0.2)
    love.graphics.setFont(resources.fonts.LEXIPA(12))
    love.graphics.print("Created by DREAMSPRITE Studio. All rights reserved.", 5, love.graphics.getHeight() - 30)
end

return background
