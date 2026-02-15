local map = {
    colliders = {},
    players = {},
    npcs = {},
    props = {},
    effects = {},
    currentMap = nil,
    grid = {},
    gridWidth = 0,
    gridHeight = 0,
    tileSize = 16,
}

function map:load(name, spawnX, spawnY)
    self.currentMap = libs.sti('src/maps/'..name..".lua")
    _G.game.game_map = self

    self.gridWidth = math.ceil(self.currentMap.width * self.currentMap.tilewidth / self.tileSize)
    self.gridHeight = math.ceil(self.currentMap.height * self.currentMap.tileheight / self.tileSize)
    
    for y = 1, self.gridHeight do
        self.grid[y] = {}
        for x = 1, self.gridWidth do
            self.grid[y][x] = 0
        end
    end

    if self.currentMap.layers["colliders"] then
        for _, collider in ipairs(self.currentMap.layers["colliders"].objects) do
            local properties = {}

            for key, p in pairs(collider) do
                properties[key] = p
            end

            libs.physics:newCollider(properties)
            self:addObstacle(collider.x, collider.y, collider.width, collider.height)
        end
    end

    if self.currentMap.layers["npcs"] then
        for _, v in ipairs(self.currentMap.layers["npcs"].objects) do
            table.insert(self.npcs,
                npc.new{
                    x = v.x, y = v.y,
                    action = v.properties.action,
                    direction = v.properties.direction,
                    sprite = "src/assets/sprites/humans/"..v.type..".png"
                }
            )
        end
    end

    if self.currentMap.layers["props"] then
        for _, v in ipairs(self.currentMap.layers["props"].objects) do
            table.insert(self.props,
                prop.new{
                    sprite = "src/assets/sprites/props/"..v.name..".png",
                    x = v.x, y = v.y,
                    direction = v.properties.direction,
                    add_y = v.properties.add_y,
                    flags = {
                        transparency_when_inside = v.properties.transparency_when_inside == false,
                    },
                }
            )
        end
    end

    if self.currentMap.layers["playerSpawn"] then
        for _, v in ipairs(self.currentMap.layers["playerSpawn"].objects) do
            if not _G.game.player then return end
            _G.game.player:setPosition(v.x, v.y)
            _G.game.player.direction = v.properties.direction or "down"
        end
    end

    libs.window:updateScale()
    
    if (spawnX or spawnY) and _G.game.player then
        _G.game.player:setPosition(spawnX or _G.game.player.x, spawnY or _G.game.player.y)
    end
end

function map:update(dt)
    if self.currentMap then self.currentMap:update(dt) end

    local to_update = {self.npcs, self.colliders, self.props, self.effects,self.players}
    for _, group in pairs(to_update) do
        for _, obj in pairs(group) do
            if obj.update then obj:update(dt) end
        end
    end
end

local layersOrder = {"water", "floor", "hills-1" ,"hills", "decor", "decor1", "decor2"}

function map:draw()
    if not self.currentMap then return end
    
    for _, layerName in ipairs(layersOrder) do
        local layer = self.currentMap.layers[layerName]
        if layer then
            self.currentMap:drawLayer(layer)
        end

        if self.anim then
            self.anim:draw()
        end
    end
    
    -- -- Визуализация сетки препятствий
    -- love.graphics.setColor(0, 1, 0, 0.3)
    -- for y = 1, self.gridHeight do
    --     for x = 1, self.gridWidth do
    --         if self.grid[y] and self.grid[y][x] == 1 then
    --             local worldX = (x - 1) * self.tileSize
    --             local worldY = (y - 1) * self.tileSize
    --             love.graphics.rectangle("fill", worldX, worldY, self.tileSize, self.tileSize)
    --         end
    --     end
    -- end
    love.graphics.setColor(1, 1, 1, 1)
end

function map:destroyAll()
    local groups = {"colliders", "props", "npcs"}

    for _, groupName in pairs(groups) do
        local group = self[groupName]
        for i = #group, 1, -1 do
            local v = group[i]
            if v and v.destroy then
                local ok, err = pcall(function()
                    v:destroy()
                end)
                if not ok then
                    libs.utils.log("WARN", "orange", "Failed to destroy:", err)
                end
            elseif v and v.destroy == nil and v.body and v.body.destroy then
                local ok, err = pcall(function()
                    v:destroy()
                end)
                if not ok then
                    libs.utils.log("WARN", "orange", "Failed to destroy collider:", err)
                end
            end
            group[i] = nil
        end
    end
end

function map:addObstacle(x, y, width, height)
    width = width or self.tileSize
    height = height or self.tileSize
    
    local startX = math.max(1, math.floor(x / self.tileSize) + 1)
    local startY = math.max(1, math.floor(y / self.tileSize) + 1)
    local endX = math.min(self.gridWidth, math.floor((x + width) / self.tileSize) + 1)
    local endY = math.min(self.gridHeight, math.floor((y + height) / self.tileSize) + 1)
    
    for gridY = startY, endY do
        for gridX = startX, endX do
            self.grid[gridY][gridX] = 1
        end
    end
end

function map:removeObstacle(x, y, width, height)
    width = width or self.tileSize
    height = height or self.tileSize
    
    local startX = math.max(1, math.floor(x / self.tileSize) + 1)
    local startY = math.max(1, math.floor(y / self.tileSize) + 1)
    local endX = math.min(self.gridWidth, math.floor((x + width) / self.tileSize) + 1)
    local endY = math.min(self.gridHeight, math.floor((y + height) / self.tileSize) + 1)
    
    for gridY = startY, endY do
        for gridX = startX, endX do
            self.grid[gridY][gridX] = 0
        end
    end
end

function map:setObstacle(gridX, gridY, value)
    if gridX > 0 and gridX <= self.gridWidth and gridY > 0 and gridY <= self.gridHeight then
        self.grid[gridY][gridX] = value or 1
    end
end

function map:getPropOnPosition(x, y)
    for _, prop in ipairs(self.props) do
        if libs.utils.point.inRect(prop.x, prop.y, prop.w, prop.h, x, y) then
            return prop
        end
    end
end

function map:serialize()
    return {
        npcs = table.show(self.npcs),
        props = table.show(self.props),
        effects = table.show(self.effects),
    }
end

return map