Atlas = {}
Atlas.__index = Atlas

function Atlas.new(imagePath, tileW, tileH)
    local self = setmetatable({}, Atlas)

    self.image = love.graphics.newImage(imagePath)
    self.tileW, self.tileH = tileW, tileH

    local imgW, imgH = self.image:getWidth(), self.image:getHeight()
    self.cols = math.floor(imgW / tileW)
    self.rows = math.floor(imgH / tileH)

    self.quads = {}

    local id = 1
    for y = 0, self.rows - 1 do
        for x = 0, self.cols - 1 do
            self.quads[id] = love.graphics.newQuad(
                x * tileW, y * tileH,
                tileW, tileH,
                imgW, imgH
            )
            id = id + 1
        end
    end

    return self
end

function Atlas:get(id)
    return self.quads[id]
end

function Atlas:draw(id, x, y, r, sx, sy)
    local quad = self.quads[id]
    if quad then
        love.graphics.draw(self.image, quad, x, y, r or 0, sx or 1, sy or 1)
    else
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("line", x, y, self.tileW, self.tileH)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Atlas
