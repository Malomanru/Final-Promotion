local player = {}
player.__index = player

function player.new(params)
    local self = setmetatable({}, player)
    params = params or {}

    self.x, self.y = params.x or 0, params.y or 0
    self.dirX, self.dirY = 0, 0
    self.speed = 35
    self.action, self.direction = "idle", "down" 

    self.sprite = libs.utils.resources.loadAndProcessAsset(params.sprite or 'src/assets/sprites/humans/human1.png')

    self.path = {}
    self.pathIndex = 1
    self.targetX, self.targetY = nil, nil
    self.moveThreshold = 5

    -- { Animations } --

    self.grid =  libs.anim8.newGrid(16, 16, self.sprite:getWidth(), self.sprite:getHeight())
    self.animations_speed = 0.2

    self.animations = {
        idle_up = libs.anim8.newAnimation(self.grid('1-2', 1), 0.45),
        idle_down = libs.anim8.newAnimation(self.grid('1-4', 2), 0.2),
        idle_left = libs.anim8.newAnimation(self.grid('1-4', 3), 0.2),
        idle_right = libs.anim8.newAnimation(self.grid('1-4', 4), 0.2),

        walk_up = libs.anim8.newAnimation(self.grid('9-12', 1), 0.2),
        walk_down = libs.anim8.newAnimation(self.grid('9-12', 2), 0.2),
        walk_left = libs.anim8.newAnimation(self.grid('9-12', 3), 0.2),
        walk_right = libs.anim8.newAnimation(self.grid('9-12', 4), 0.2),
    }

    self.current_animation = self.animations.idle_down

    -- { Physics } --
    self.collider = libs.physics:newCollider{
        shape = "bsg_rectangle",
        x = self.x, y = self.y,
        width = 10, height = 7,
        fixed_rotation = true,
        linear_damping = self.baseDamping,
        mass = 0.2,
        collision_class = "Player",
        properties = {
            corners = 2,
            type = "dynamic",
        }
    }

    self.flags = {
        can_move = params.flags and params.flags.can_move or true,
    }

    if _G.game.game_map and not _G.game.game_map.players[self] then table.insert(_G.game.game_map.players, self) end

    return self
end

function player:update(dt)
    -- { Movement } --
    self.dirX, self.dirY = 0, 0
    self.x, self.y = self.collider:getPosition()

    self:updateMovement(dt)

    if self.flags.can_move then
        if love.keyboard.isScancodeDown("d") then self.dirX = 1 end
        if love.keyboard.isScancodeDown("a") then self.dirX = -1 end
        if love.keyboard.isScancodeDown("s") then self.dirY = 1 end
        if love.keyboard.isScancodeDown("w") then self.dirY = -1 end
    end

    local moveVec = libs.hump.vector(self.dirX, self.dirY)
    if moveVec:len() > 0 then
        moveVec = moveVec:normalized() * self.speed * (dt * 60)
        self.collider:setLinearVelocity(moveVec.x, moveVec.y)
    else
        self.collider:setLinearVelocity(0,0)
    end
    self.action = moveVec:len() > 0 and "walk" or "idle"
    self.direction = self:resolveDirection(self.dirX, self.dirY)

    -- { Animation } --
    self:updateAnimation(dt)


    -- { NPC } --
    local nearNPC = self:getNearNPC()

    if nearNPC and love.keyboard.isScancodeDown("space") and libs.utils.point.distance(self.x, self.y, nearNPC.x, nearNPC.y) <= nearNPC.active_radius then
        if nearNPC.activate and type(nearNPC.activate) == "function" then nearNPC:activate() end
    end
end

function player:draw()
    self.current_animation:draw(self.sprite, self.x, self.y, nil, 0.95, 0.95, 8, 12)
end

--------------------------

function player:updateAnimation(dt)
    local animKey = self.action .. "_" .. self.direction
    local anim = self.animations[animKey] or self.animations["idle_down"]

    if self.current_animation ~= anim then
        self.current_animation = anim
        self.current_animation:gotoFrame(1)
    end
    self.current_animation:update(dt)
end

function player:resolveDirection(dx, dy)
    if dx == 0 and dy == 0 then
        return self.direction or "down"
    end

    if math.abs(dx) > math.abs(dy) then
        return dx > 0 and "right" or "left"
    else
        return dy > 0 and "down" or "up"
    end
end

function player:setPosition(x, y)
    self.collider:setPosition(x or self.x, y or self.y)
end

function player:getPosition()
    return self.collider:getPosition()
end

function player:getNearNPC()
    local npcPositions = {}

    for _, npc in pairs(_G.game.game_map.npcs) do
        local npcX, npcY = npc:getPosition()
        local dx = npcX - self.x
        local dy = npcY - self.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance < 50 then
            table.insert(npcPositions, {npc = npc, distance = distance})
        end
    end
    
    table.sort(npcPositions, function(a, b) return a.distance < b.distance end)
    return npcPositions[1] and npcPositions[1].npc or nil
end

-- { AStar } --

function player:findPathTo(targetX, targetY)
    if not _G.game.game_map or not _G.game.game_map.grid then
        return false
    end
    
    local startGridX, startGridY = libs.AStar:worldToGrid(self.x ,self.y)
    local endGridX, endGridY = libs.AStar:worldToGrid(targetX, targetY)
    
    if startGridX < 1 or startGridY < 1 or endGridX < 1 or endGridY < 1 or
       startGridX > _G.game.game_map.gridWidth or startGridY > _G.game.game_map.gridHeight or
       endGridX > _G.game.game_map.gridWidth or endGridY > _G.game.game_map.gridHeight then
        return false
    end
    
    local path = libs.AStar.findPath(_G.game.game_map.grid, startGridX, startGridY, endGridX, endGridY)
    if path and #path > 0 then
        self:followPath(path)
        return true
    end
    return false
end

function player:followPath(path)
    self.path = path or {}
    self.pathIndex = 1
    self.targetX, self.targetY = nil, nil
end

function player:moveToPoint(x, y, teleport)
    if teleport then
        self:setPosition(x, y)
        return
    end
    
    self.targetX, self.targetY = x, y
    self.path = {}
end

function player:updateMovement(dt)
    if type(self.path) ~= "table" then
        self.path = {}
    end
    
    if #self.path > 0 and self.pathIndex <= #self.path then
        local target = self.path[self.pathIndex]
        if not target or not target[1] or not target[2] then
            self.pathIndex = self.pathIndex + 1
            return
        end
        
        local targetX = (target[1] - 1) * _G.game.game_map.tileSize + _G.game.game_map.tileSize/2
        local targetY = (target[2] - 1) * _G.game.game_map.tileSize + _G.game.game_map.tileSize/2
        local dx = targetX - self.x
        local dy = targetY - self.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance < self.moveThreshold then
            self.pathIndex = self.pathIndex + 1
            if self.pathIndex <= #self.path then
                local nextTarget = self.path[self.pathIndex]
                local nextTargetX = (nextTarget[1] - 1) * _G.game.game_map.tileSize + _G.game.game_map.tileSize/2
                local nextTargetY = (nextTarget[2] - 1) * _G.game.game_map.tileSize + _G.game.game_map.tileSize/2
                local nextDx = nextTargetX - self.x
                local nextDy = nextTargetY - self.y
                local nextLen = math.sqrt(nextDx*nextDx + nextDy*nextDy)
                if nextLen > 0.1 then
                    self.dirX = math.max(-1, math.min(1, nextDx / nextLen))
                    self.dirY = math.max(-1, math.min(1, nextDy / nextLen))
                end
            else
                self.dirX, self.dirY = 0, 0
            end
        else
            if distance > 0.1 then
                self.dirX = math.max(-1, math.min(1, dx / distance))
                self.dirY = math.max(-1, math.min(1, dy / distance))
            end
        end
    elseif self.targetX and self.targetY then
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance < self.moveThreshold then
            self.targetX, self.targetY = nil, nil
            self.dirX, self.dirY = 0, 0
        else
            if distance > 0.1 then
                self.dirX = math.max(-1, math.min(1, dx / distance))
                self.dirY = math.max(-1, math.min(1, dy / distance))
            end
        end
    end
end

return player