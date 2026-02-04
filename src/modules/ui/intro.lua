local intro = {
    active = false,
    state = "hidden", -- hidden, appearing, waiting, disappearing, done
    timer = 0,
    letters = {},
    fadeProgress = 0,
    letterDelay = 0.2, -- задержка между появлением букв
    waitDuration = 2,   -- время ожидания после появления
    disappearDuration = 1.5 -- время исчезновения
}

local TARGET_WORD = "DREAMSPIRE"
local FONT_SIZE = 80

function intro:init()
    self.timer = 0
    self.state = "hidden"
    self.fadeProgress = 0
    self.letters = {}
    
    local font = resources.fonts.LEXIPA and resources.fonts.LEXIPA(FONT_SIZE) 
                or love.graphics.newFont(FONT_SIZE)
    
    local totalWidth = 0
    for i = 1, #TARGET_WORD do
        totalWidth = totalWidth + font:getWidth(TARGET_WORD:sub(i, i))
    end
    
    local letterSpacing = 10
    local startX = (love.graphics.getWidth() - (totalWidth + (letterSpacing * (#TARGET_WORD - 1)))) / 2
    local startY = love.graphics.getHeight() / 2 - FONT_SIZE / 2
    
    for i = 1, #TARGET_WORD do
        local letter = TARGET_WORD:sub(i, i)
        local letterWidth = font:getWidth(letter)
        
        self.letters[i] = {
            char = letter,
            text = libs.effects.glitch_text.new(letter, font, startX, startY),
            x = startX,
            y = startY,
            alpha = 0,
            visible = false,
            glitchIntensity = 0,
            flickerTimer = 0,
            flickerSpeed = math.random(0.05, 0.15),
            isFlickering = false,
            disappearProgress = 0, -- прогресс исчезновения (0-1)
            disappearDelay = (i-1) * 0.05, -- задержка исчезновения для каждой буквы
            pixelGrid = self:_createPixelGrid(letter, font, startX, startY)
        }
        
        -- Настройка glitch эффекта для каждой буквы
        self.letters[i].text:setEffect("complex")
        self.letters[i].text:setIntensity(0)
        self.letters[i].text:setColor(1, 1, 1, 0)
        
        startX = startX + letterWidth + letterSpacing
    end
end

-- Создание пиксельной сетки для эффекта исчезновения
function intro:_createPixelGrid(letter, font, x, y)
    local grid = {}
    local width = font:getWidth(letter)
    local height = font:getHeight()
    local pixelSize = 4 -- размер "пикселя" для эффекта
    
    -- Создаем сетку пикселей
    for px = 0, width, pixelSize do
        for py = 0, height, pixelSize do
            if math.random() < 0.7 then -- не все пиксели активны для более органичного вида
                table.insert(grid, {
                    x = x + px,
                    y = y + py,
                    size = pixelSize,
                    alpha = 0,
                    delay = math.random() * 0.5,
                    speed = math.random(0.5, 1.5)
                })
            end
        end
    end
    
    return grid
end

-- Запуск интро
function intro:show(_onEnd)
    self.active = true
    self.state = "appearing"
    self.timer = 0
    self.fadeProgress = 0
    self._onEnd = _onEnd or nil
end

-- Обновление интро
function intro:update(dt)
    if not self.active then return end
    
    self.timer = self.timer + dt
    
    if self.state == "appearing" then
        self:_updateAppearing(dt)
    elseif self.state == "waiting" then
        self:_updateWaiting(dt)
    elseif self.state == "disappearing" then
        self:_updateDisappearing(dt)
    end
    
    -- Обновляем все активные буквы
    for i, letter in ipairs(self.letters) do
        if letter.text then
            letter.text:update(dt)
            
            -- Обновление мерцания
            letter.flickerTimer = letter.flickerTimer + dt
            if letter.flickerTimer >= letter.flickerSpeed then
                letter.flickerTimer = 0
                letter.isFlickering = not letter.isFlickering
            end
            
            -- Обновление glitch интенсивности
            if letter.visible then
                local targetIntensity = letter.isFlickering and 3 or 1.5
                letter.glitchIntensity = letter.glitchIntensity + (targetIntensity - letter.glitchIntensity) * dt * 10
                letter.text:setIntensity(letter.glitchIntensity)
            end
        end
    end
end

-- Обновление фазы появления
function intro:_updateAppearing(dt)
    self.fadeProgress = math.min(1, self.timer / (#self.letters * self.letterDelay + 0.5))
    
    -- Постепенное появление букв
    for i, letter in ipairs(self.letters) do
        local letterStartTime = (i-1) * self.letterDelay
        
        if self.timer >= letterStartTime then
            local letterProgress = math.min(1, (self.timer - letterStartTime) / 0.3)
            
            -- Плавное появление с небольшим "подпрыгиванием"
            letter.alpha = letterProgress
            letter.visible = true
            
            -- Эффект подпрыгивания при появлении
            local bounce = math.sin(letterProgress * math.pi) * 10
            letter.text:setPosition(letter.x, letter.y - bounce)
            
            -- Обновление цвета с альфой
            local r = 0.8 + math.sin(self.timer * 2 + i) * 0.2
            local g = 0.8 + math.cos(self.timer * 3 + i) * 0.2
            local b = 1.0
            letter.text:setColor(r, g, b, letter.alpha)
            
            -- Включаем glitch эффект
            if not letter.text.active then
                letter.text:setActive(true)
            end
        end
    end
    
    -- Переход к ожиданию после появления всех букв
    if self.timer >= (#self.letters * self.letterDelay + 0.5) then
        self.state = "waiting"
        self.timer = 0
    end
end

-- Обновление фазы ожидания
function intro:_updateWaiting(dt)
    -- Мигание букв во время ожидания
    for i, letter in ipairs(self.letters) do
        if letter.visible then
            -- Случайное изменение интенсивности glitch
            local targetIntensity = 1 + math.sin(self.timer * 2 + i) * 1.5
            letter.glitchIntensity = letter.glitchIntensity + (targetIntensity - letter.glitchIntensity) * dt * 5
            letter.text:setIntensity(letter.glitchIntensity)
            
            -- Случайное изменение цвета
            if math.random() < 0.02 then
                local r = 0.7 + math.random() * 0.3
                local g = 0.7 + math.random() * 0.3
                local b = 0.9 + math.random() * 0.1
                letter.text:setColor(r, g, b, letter.alpha)
            end
        end
    end
    
    -- Переход к исчезновению
    if self.timer >= self.waitDuration then
        self.state = "disappearing"
        self.timer = 0
    end
end

-- Обновление фазы исчезновения
function intro:_updateDisappearing(dt)
    local totalDisappearTime = self.disappearDuration
    
    for i, letter in ipairs(self.letters) do
        if letter.visible then
            local letterDisappearTime = letter.disappearDelay
            local letterProgress = 0
            
            if self.timer >= letterDisappearTime then
                letterProgress = math.min(1, (self.timer - letterDisappearTime) / (totalDisappearTime - letterDisappearTime))
            end
            
            letter.disappearProgress = letterProgress
            
            -- Эффект "заливки черными пикселями"
            for _, pixel in ipairs(letter.pixelGrid) do
                if letterProgress >= pixel.delay then
                    local pixelProgress = math.min(1, (letterProgress - pixel.delay) * pixel.speed)
                    pixel.alpha = pixelProgress
                end
            end
            
            -- Уменьшение видимости текста по мере "заливки"
            local textAlpha = math.max(0, 1 - letterProgress * 1.5)
            letter.alpha = textAlpha
            
            -- Увеличение glitch эффекта перед исчезновением
            local glitchBoost = math.min(1, letterProgress * 3)
            letter.text:setIntensity(letter.glitchIntensity + glitchBoost * 5)
            
            -- Обновление цвета с учетом альфы
            local currentColor = {letter.text:getColor()}
            letter.text:setColor(currentColor[1], currentColor[2], currentColor[3], letter.alpha)
        end
    end
    
    -- Завершение интро
    if self.timer >= totalDisappearTime then
        self.state = "done"
        self.active = false
        if self._onEnd and type(self._onEnd) == "function" then self._onEnd() end
    end
end

-- Отрисовка интро
function intro:draw()
    if not self.active then return end
    
    -- Черный фон
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Рисуем буквы
    for i, letter in ipairs(self.letters) do
        if letter.visible and letter.text then
            -- Рисуем glitch текст
            letter.text:draw()
            
            -- Рисуем эффект "черных пикселей" для исчезновения
            if self.state == "disappearing" and letter.disappearProgress > 0 then
                love.graphics.setColor(0, 0, 0)
                for _, pixel in ipairs(letter.pixelGrid) do
                    if pixel.alpha > 0 then
                        love.graphics.setColor(0, 0, 0, pixel.alpha)
                        love.graphics.rectangle("fill", pixel.x, pixel.y, pixel.size, pixel.size)
                    end
                end
            end
        end
    end
    
    -- Дополнительные эффекты для фона (опционально)
    if self.state == "appearing" or self.state == "disappearing" then
        self:_drawBackgroundEffects()
    end
end

-- Дополнительные фоновые эффекты
function intro:_drawBackgroundEffects()
    love.graphics.setBlendMode("add")
    
    -- Случайные вспышки на фоне
    for i = 1, 5 do
        if math.random() < 0.1 then
            local size = math.random(20, 100)
            local alpha = math.random(0.1, 0.3)
            local x = math.random(0, love.graphics.getWidth())
            local y = math.random(0, love.graphics.getHeight())
            
            love.graphics.setColor(0.1, 0.1, 0.3, alpha)
            love.graphics.circle("fill", x, y, size)
        end
    end
    
    -- Сканирующие линии (только во время glitch эффектов)
    if self.state == "disappearing" then
        local scanY = love.graphics.getHeight() * (self.timer / self.disappearDuration)
        love.graphics.setColor(0, 0.5, 1, 0.1)
        love.graphics.rectangle("fill", 0, scanY, love.graphics.getWidth(), 2)
    end
    
    love.graphics.setBlendMode("alpha")
end

-- Проверка, завершено ли интро
function intro:isDone()
    return self.state == "done" or not self.active
end

-- Получение текущего состояния
function intro:getState()
    return self.state
end

-- Получение прогресса (0-1)
function intro:getProgress()
    if self.state == "appearing" then
        return self.fadeProgress
    elseif self.state == "waiting" then
        return 1
    elseif self.state == "disappearing" then
        return 1 + (self.timer / self.disappearDuration)
    else
        return 0
    end
end

return intro