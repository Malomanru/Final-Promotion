local timers = {}
local Timer = {}
Timer.__index = Timer

-- Создает новый таймер
function Timer.new(timeout, timeout_function)
    local self = setmetatable({}, Timer)
    self.co = nil
    self.running = false
    self.timeout = 0
    self.startTime = 0
    

    self.onTimeout = timeout_function or nil
    self:start(timeout)

    table.insert(timers, self)
    return self
end

local function timerCoroutine(timeout)
    local startTime = os.time()
    local diff = os.difftime(os.time(), startTime)
    
    while diff < timeout do
        coroutine.yield(diff)
        diff = os.difftime(os.time(), startTime)
    end
    
    return diff, true
end

function Timer:start(timeout)
    self.timeout = timeout
    self.startTime = os.time()
    self.co = coroutine.create(timerCoroutine)
    self.running = true
    
    return coroutine.resume(self.co, timeout)
end

function Timer:update(dt)
    if self.running and self.co then
        local status = coroutine.status(self.co)
        
        if status == "suspended" then
            local success, diff, finished = coroutine.resume(self.co)
            
            if success then
                if finished then
                    self.running = false
                    if self.onTimeout then self:onTimeout() end
                else
                    self:onTick(diff)
                end
            else
                self.running = false
                print("Timer error: " .. tostring(diff))
            end
        elseif status == "dead" then
            self.running = false
        end
    end
end

-- Возвращает прошедшее время
function Timer:getElapsed()
    if not self.running then return 0 end
    return os.difftime(os.time(), self.startTime)
end

-- Возвращает оставшееся время
function Timer:getRemaining()
    if not self.running then return 0 end
    return math.max(0, self.timeout - self:getElapsed())
end

function Timer:stop()
    self.running = false
    self.co = nil
end

function Timer:isRunning()
    return self.running
end

function Timer:isFinished()
    return not self.running and self.co ~= nil and coroutine.status(self.co) == "dead"
end

function Timer:onTick(elapsed)
    -- Переопределите этот метод для обработки тиков таймера
end

function Timer:onTimeout()
    --print('Timer timed out at ' .. self.timeout .. ' seconds!')
    return
end

function Timer.updateAll(dt)
    for i = #timers, 1, -1 do
        if timers[i].update then timers[i]:update() end
        if timers[i].running == false then table.remove(timers, i) end
    end
end

return Timer