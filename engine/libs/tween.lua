local Tween = {}
Tween.__index = Tween

local ease = {}
local Tweens = {}

ease.linear = function(t) return t end

ease.inQuad = function(t) return t * t end
ease.outQuad = function(t) return t * (2 - t) end
ease.inOutQuad = function(t)
    t = t * 2
    if t < 1 then return 0.5 * t * t end
    t = t - 1
    return -0.5 * (t * (t - 2) - 1)
end

ease.inCubic = function(t) return t * t * t end
ease.outCubic = function(t) t = t - 1; return t * t * t + 1 end
ease.inOutCubic = function(t)
    t = t * 2
    if t < 1 then return 0.5 * t * t * t end
    t = t - 2
    return 0.5 * (t * t * t + 2)
end

ease.inQuart = function(t) return t^4 end
ease.outQuart = function(t) return 1 - (t - 1)^4 end
ease.inOutQuart = function(t)
    t = t * 2
    if t < 1 then return 0.5 * t^4 end
    t = t - 2
    return -0.5 * (t^4 - 2)
end

ease.inQuint = function(t) return t^5 end
ease.outQuint = function(t) return (t - 1)^5 + 1 end
ease.inOutQuint = function(t)
    t = t * 2
    if t < 1 then return 0.5 * t^5 end
    t = t - 2
    return 0.5 * (t^5 + 2)
end

ease.inSine = function(t) return 1 - math.cos((t * math.pi) / 2) end
ease.outSine = function(t) return math.sin((t * math.pi) / 2) end
ease.inOutSine = function(t) return -0.5 * (math.cos(math.pi * t) - 1) end

ease.inExpo = function(t) return (t == 0) and 0 or 2^(10 * (t - 1)) end
ease.outExpo = function(t) return (t == 1) and 1 or 1 - 2^(-10 * t) end
ease.inOutExpo = function(t)
    if t == 0 then return 0 end
    if t == 1 then return 1 end
    t = t * 2
    if t < 1 then return 0.5 * 2^(10 * (t - 1)) end
    return 0.5 * (2 - 2^(-10 * (t - 1)))
end

ease.inCirc = function(t) return 1 - math.sqrt(1 - t * t) end
ease.outCirc = function(t) return math.sqrt(1 - (t - 1)^2) end
ease.inOutCirc = function(t)
    t = t * 2
    if t < 1 then return -0.5 * (math.sqrt(1 - t * t) - 1) end
    t = t - 2
    return 0.5 * (math.sqrt(1 - t * t) + 1)
end

ease.outBack = function(t)
    local c1, c3 = 1.70158, 1.70158 + 1
    return 1 + c1 * (t - 1)^3 + c3 * (t - 1)^2
end
ease.inBack = function(t)
    local c1 = 1.70158
    return c1 * t^3 - c1 * t^2
end
ease.inOutBack = function(t)
    local c1 = 1.70158 * 1.525
    t = t * 2
    if t < 1 then
        return 0.5 * (t^2 * ((c1 + 1) * t - c1))
    else
        t = t - 2
        return 0.5 * (t^2 * ((c1 + 1) * t + c1) + 2)
    end
end

function Tween.new(duration, obj, properties, mode, onComplete)
    local self = setmetatable({}, Tween)
    self.target = obj
    self.duration = duration
    self.time = 0
    self.mode = ease[mode] or ease.linear
    self.finished = false
    
    self.initialValues = {}
    self.targetValues = {}
    
    for property, targetValue in pairs(properties) do
        self.initialValues[property] = obj[property]
        self.targetValues[property] = targetValue
    end
    
    self.OnComplete = onComplete or nil

    table.insert(Tweens, self)

    return self
end

function Tween:delete()
    for i, tween in ipairs(Tweens) do
        if tween == self then
            table.remove(Tweens, i)
            break
        end
    end
end

function Tween:update(dt)
    if self.finished then return end
    
    self.time = self.time + dt
    local t = math.min(self.time / self.duration, 1)
    local k = self.mode(t)
    
    -- Update all properties
    for property, initialValue in pairs(self.initialValues) do
        local targetValue = self.targetValues[property]
        self.target[property] = initialValue + (targetValue - initialValue) * k
    end
    
    if self.time >= self.duration then
        self.finished = true
        
        -- Ensure final values are exact
        for property, targetValue in pairs(self.targetValues) do
            self.target[property] = targetValue
        end
        
        if self.OnComplete then
            self.OnComplete()
            self.OnComplete = nil
            self:delete()
            if self.finished then
                Tweens[self] = nil
            end
        end
    end
end

function Tween.updateAll(dt)
    for i = #Tweens, 1, -1 do
        local tween = Tweens[i]
        tween:update(dt)
        if tween.finished then
            table.remove(Tweens, i)
        end
    end
end

function Tween:isFinished()
    return self.finished
end

function Tween:getValue(property)
    return self.target[property]
end

return Tween