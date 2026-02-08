local GlitchText = {}
GlitchText.__index = GlitchText

GlitchText.EFFECTS = {
    SIMPLE = "simple",
    CHANNEL_SPLIT = "channel_split",
    JITTER = "jitter",
    SCANLINE = "scanline",
    COMPLEX = "complex"
}

-- Создание нового glitch-объекта
function GlitchText.new(text, font, x, y)
    local self = setmetatable({}, GlitchText)
    
    self.text = text or "test"
    self.font = font or love.graphics.getFont()
    self.x = x or 0
    self.y = y or 0
    
    -- Настройки по умолчанию
    self.effect = GlitchText.EFFECTS.CHANNEL_SPLIT
    self.active = true
    self.intensity = 3.0
    self.speed = 1.0
    self.color = {1, 1, 1, 1} -- Основной цвет текста
    
    -- Внутренние переменные для анимации
    self.time = 0
    self.jitterOffset = {x = 0, y = 0}
    self.glitchActive = false
    self.glitchTimer = 0
    
    -- Настройки для разных эффектов
    self.settings = {
        -- Общие настройки
        maxOffset = 5,
        layerAlpha = 0.7,
        
        -- Для CHANNEL_SPLIT
        redOffset = {2, 0},
        greenOffset = {-2, 1},
        blueOffset = {0, -2},
        
        -- Для JITTER
        jitterFrequency = 0.05,
        jitterAmplitude = 2,
        
        -- Для SCANLINE
        scanlineChance = 0.1,
        scanlineColor = {0, 1, 0, 0.3},
        scanlineHeight = 1,
        
        -- Для COMPLEX
        artifactChance = 0.2,
        maxArtifacts = 3
    }

    return self
end

-- Обновление эффекта
function GlitchText:update(dt)
    if _G.game.game_map then _G.game.game_map.effects[self] = self end
    if not self.active then return end
    
    self.time = self.time + dt * self.speed
    
    -- Обновление эффекта дрожания
    if self.effect == GlitchText.EFFECTS.JITTER or 
       self.effect == GlitchText.EFFECTS.COMPLEX then
        self:_updateJitter(dt)
    end
    
    -- Обновление таймера glitch-вспышек
    if self.effect == GlitchText.EFFECTS.COMPLEX then
        self:_updateGlitchTimer(dt)
    end
end

-- Внутренний метод для обновления дрожания
function GlitchText:_updateJitter(dt)
    if self.time % self.settings.jitterFrequency < dt then
        self.jitterOffset.x = math.random(-self.settings.jitterAmplitude, 
                                         self.settings.jitterAmplitude)
        self.jitterOffset.y = math.random(-self.settings.jitterAmplitude, 
                                         self.settings.jitterAmplitude)
    end
end

-- Внутренний метод для обновления таймера glitch
function GlitchText:_updateGlitchTimer(dt)
    self.glitchTimer = self.glitchTimer - dt
    
    if self.glitchTimer <= 0 then
        self.glitchActive = not self.glitchActive
        
        if self.glitchActive then
            self.glitchTimer = math.random(0.05, 0.15)
        else
            self.glitchTimer = math.random(0.3, 1.5)
        end
    end
end

-- Установка позиции
function GlitchText:setPosition(x, y)
    self.x = x
    self.y = y
end

-- Установка текста
function GlitchText:setText(text)
    self.text = text
end

-- Включение/выключение эффекта
function GlitchText:setActive(state)
    self.active = state
end

-- Установка типа эффекта
function GlitchText:setEffect(effectType)
    self.effect = effectType or GlitchText.EFFECTS.CHANNEL_SPLIT
end

-- Установка интенсивности
function GlitchText:setIntensity(value)
    self.intensity = math.max(0, value)
end

-- Установка скорости анимации
function GlitchText:setSpeed(value)
    self.speed = math.max(0, value)
end

-- Установка основного цвета
function GlitchText:setColor(r, g, b, a)
    self.color = {r or 1, g or 1, b or 1, a or 1}
end

-- Отрисовка текста с эффектом
function GlitchText:draw()
    if not self.active then
        love.graphics.setColor(self.color)
        love.graphics.setFont(self.font)
        love.graphics.print(self.text, self.x, self.y)
        return
    end
    
    love.graphics.setFont(self.font)
    
    -- Выбор метода отрисовки в зависимости от эффекта
    if self.effect == GlitchText.EFFECTS.SIMPLE then
        self:_drawSimple()
    elseif self.effect == GlitchText.EFFECTS.CHANNEL_SPLIT then
        self:_drawChannelSplit()
    elseif self.effect == GlitchText.EFFECTS.JITTER then
        self:_drawJitter()
    elseif self.effect == GlitchText.EFFECTS.SCANLINE then
        self:_drawScanline()
    elseif self.effect == GlitchText.EFFECTS.COMPLEX then
        self:_drawComplex()
    end
end

-- Простой эффект (случайные смещения)
function GlitchText:_drawSimple()
    -- Основной текст
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, self.x, self.y)
    
    -- Glitch-слои
    for i = 1, 3 do
        local offset = self.intensity * 0.5
        love.graphics.setColor(
            math.random(),
            math.random(),
            math.random(),
            self.settings.layerAlpha
        )
        love.graphics.print(
            self.text,
            self.x + math.random(-offset, offset),
            self.y + math.random(-offset, offset)
        )
    end
end

-- Эффект разделения RGB-каналов
function GlitchText:_drawChannelSplit()
    local offset = self.intensity
    
    -- Красный канал
    love.graphics.setColor(1, 0, 0, self.settings.layerAlpha)
    love.graphics.print(self.text,
        self.x + self.settings.redOffset[1] * offset,
        self.y + self.settings.redOffset[2] * offset
    )
    
    -- Синий канал
    love.graphics.setColor(0, 0, 1, self.settings.layerAlpha)
    love.graphics.print(self.text,
        self.x + self.settings.blueOffset[1] * offset,
        self.y + self.settings.blueOffset[2] * offset
    )
    
    -- Зеленый канал
    love.graphics.setColor(0, 1, 0, self.settings.layerAlpha)
    love.graphics.print(self.text,
        self.x + self.settings.greenOffset[1] * offset,
        self.y + self.settings.greenOffset[2] * offset
    )
    
    -- Основной текст
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, self.x, self.y)
end

-- Эффект дрожания
function GlitchText:_drawJitter()
    local jitterX = self.jitterOffset.x * self.intensity
    local jitterY = self.jitterOffset.y * self.intensity
    
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, self.x + jitterX, self.y + jitterY)
end

-- Эффект со сканирующими линиями
function GlitchText:_drawScanline()
    -- Случайные сканирующие линии
    if math.random() < self.settings.scanlineChance then
        love.graphics.setColor(self.settings.scanlineColor)
        local width = self.font:getWidth(self.text)
        local height = self.font:getHeight()
        love.graphics.rectangle("fill",
            self.x - 10,
            self.y + math.random(-height/2, height/2),
            width + 20,
            self.settings.scanlineHeight
        )
    end
    
    -- Основной текст с небольшими смещениями
    local offset = self.intensity * 0.3
    
    for i = 1, 2 do
        love.graphics.setColor(
            math.random(0.5, 1),
            math.random(0.5, 1),
            math.random(0.5, 1),
            0.5
        )
        love.graphics.print(self.text,
            self.x + math.random(-offset, offset),
            self.y + math.random(-offset, offset)
        )
    end
    
    -- Основной текст
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, self.x, self.y)
end

-- Комплексный эффект (комбинация всех)
function GlitchText:_drawComplex()
    -- Сканирующие линии (иногда)
    if math.random() < self.settings.scanlineChance / 2 then
        love.graphics.setColor(self.settings.scanlineColor)
        local width = self.font:getWidth(self.text)
        local height = self.font:getHeight()
        love.graphics.rectangle("fill",
            self.x - 10,
            self.y + math.random(-height/2, height/2),
            width + 20,
            self.settings.scanlineHeight
        )
    end
    
    -- Цветные каналы (только во время glitch-вспышки)
    if self.glitchActive then
        local offset = self.intensity
        
        -- Красный канал
        love.graphics.setColor(1, 0.2, 0.2, 0.7)
        love.graphics.print(self.text,
            self.x + offset,
            self.y
        )
        
        -- Синий канал
        love.graphics.setColor(0.2, 0.2, 1, 0.7)
        love.graphics.print(self.text,
            self.x - offset,
            self.y
        )
    end
    
    -- Случайные артефакты
    if math.random() < self.settings.artifactChance then
        love.graphics.setColor(1, 1, 1, 0.4)
        for i = 1, math.random(1, self.settings.maxArtifacts) do
            local fragment = string.sub(self.text,
                math.random(1, #self.text),
                math.random(1, #self.text)
            )
            if #fragment > 0 then
                love.graphics.print(fragment,
                    self.x + math.random(-40, 40),
                    self.y + math.random(-30, 30)
                )
            end
        end
    end
    
    -- Основной текст (с дрожанием)
    local jitterX = self.glitchActive and (self.jitterOffset.x * self.intensity) or 0
    local jitterY = self.glitchActive and (self.jitterOffset.y * self.intensity) or 0
    
    love.graphics.setColor(self.color)
    love.graphics.print(self.text, self.x + jitterX, self.y + jitterY)
end

-- Получение размеров текста
function GlitchText:getWidth()
    return self.font:getWidth(self.text)
end

function GlitchText:getHeight()
    return self.font:getHeight()
end

function GlitchText:getColor()
    return unpack(self.color)
end

return GlitchText