local physics = {}

local collisionClasses = {
    {name = "Player", ignores = {}},
    {name = "npc", ignores = {}},
    {name = "item", ignores = {"Player", "item"}},
}

local worlds = {
    default = libs.windfield.newWorld(0,0),
    items = libs.windfield.newWorld(0,5)
}

function physics:init()
    self.world = worlds.default
    self.normalizeArgs = {}

    for _, class in pairs(collisionClasses) do
        self.world:addCollisionClass(class.name, {ignores = class.ignores})
    end
end

function physics:update(dt)
    if self.world then self.world:update(dt) end
end

function physics:draw(alpha, worldName)
    self[worldName]:draw(alpha or 1)
end

-----------------------------------------------------------------------
function physics:getColliderFromShape(shape, args)
    if args.world then
        self.world = worlds[args.world]
    end

    if shape == "rectangle" then
        return self.world:newRectangleCollider(args.x, args.y, args.width, args.height, {collision_class = args.collision_class})

    elseif shape == "circle" then
        return self.world:newCircleCollider(args.x, args.y, args.radius, {collision_class = args.collision_class})

    elseif shape == "polygon" then
        local poly = {}

        for _, point in pairs(args.polygon) do
            table.insert(poly, point.x)
            table.insert(poly, point.y)
        end

        return self.world:newPolygonCollider(poly, {collision_class = args.collision_class})
    elseif shape == "bsg_rectangle" then
        return self.world:newBSGRectangleCollider(args.x, args.y, args.width, args.height, args.corners, {collision_class = args.collision_class})
    else
        return self.world:newRectangleCollider(args.x, args.y, args.width, args.height, {collision_class = args.collision_class})
    end
end

function physics:newCollider(args)
    self.normalizeArgs = {
        x = args.x or 0,
        y = args.y or 0,
        radius = args.radius or 10,
        rotation = args.rotation or 0,
        width = args.width or 10,
        height = args.height or 10,
        shape = args.shape or nil,
        corners = args.properties and args.properties.corners or 5,
        polygon = args.polygon or {},
        type = args.properties and args.properties.type or "static",
        collision_class = args.collision_class or "Default",
        friction = args.friction or 0,
        fixed_rotation = args.fixed_rotation or false,
        mass = args.mass or 1,
        linear_damping = args.linear_damping or 0,
        density = args.density or 0,
        restitution = args.restitution or 0,

        world = args.world or "default"
    }

    local collider = self:getColliderFromShape(self.normalizeArgs.shape, self.normalizeArgs)

    if collider then
        collider:setType(self.normalizeArgs.type)
        collider:setFriction(self.normalizeArgs.friction)
        collider:setRestitution(self.normalizeArgs.restitution)
        collider:setDensity(self.normalizeArgs.density)
        collider:setCollisionClass(self.normalizeArgs.collision_class)
        collider:setMass(self.normalizeArgs.mass)
        collider:setLinearDamping(self.normalizeArgs.linear_damping)
        collider:setFixedRotation(self.normalizeArgs.fixed_rotation)
    end

    if _G.game and _G.game.game_map and _G.game.game_map.colliders then
        table.insert(_G.game.game_map.colliders, collider)
    end

    return collider
end


return physics