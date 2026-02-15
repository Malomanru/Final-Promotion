local dialogue = {
    lines = {},
    currentLine = 1,
    currentChar = 1,
    queue = {},
    isPrinting = false,
    printSpeed = 0.05,
    timer = 0,
    window = nil,
    font = resources.fonts.pressStart2P(24),
    fullTextChars = {}
}

function dialogue:init()
    self.window = libs.ui:newElement("window", {
        x = 0, y = 0,
        width = 800, height = 200,
        flags = {
            can_resize = false,
            can_move = false,
            is_visible = false,
            show_title = false,
        },
        visual = {
            bg_color = {0.05,0.05,0.05,0.9},
            border_color = {1,1,1,0.3},
            border_width = 2,
            title_color = {0,0,0,0},
        },
    })
end

function dialogue:load(filename)
    local result = {}
    local file = io.open(filename, "r")
    if not file then return nil, "Cannot open file: " .. filename end

    local lineNumber = 1
    for line in file:lines() do
        result["line"..lineNumber] = line
        lineNumber = lineNumber + 1
    end

    file:close()
    self.lines = result
    self.currentLine = 1
    self.currentChar = 1
    self.queue = {}
    self.isPrinting = false
end

function dialogue:show(name)
    local path = "src/assets/dialogues/" .. name .. "." .. _G.game.settings.language
    self:load(path)
    self.currentLine = 1
    self.currentChar = 1
    self:prepareLine()
    
    self.window:setPosition((love.graphics.getWidth() - self.window.width)/2, love.graphics.getHeight() + self.window.height)
    self.window.flags.is_visible = true
    libs.tween.new(0.25, self.window, {y = love.graphics.getHeight() - self.window.height - 50}, 'quad')
end

function dialogue:prepareLine()
    local line = self.lines["line"..self.currentLine] or ""
    self.queue = libs.utils.text.wrap(line, self.font, self.window.width - 10)
    -- создаём массив символов UTF-8
    self.fullTextChars = {}
    for c in table.concat(self.queue, "\n"):gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(self.fullTextChars, c)
    end
    self.currentChar = 1
    self.isPrinting = true
end

function dialogue:next()
    self.currentLine = self.currentLine + 1
    local line = self.lines["line"..self.currentLine]
    if line then
        self:prepareLine()
    else
        self.isPrinting = false
    end
end

function dialogue:update(dt)
    if not self.isPrinting then return end
    self.timer = self.timer + dt
    if self.timer >= self.printSpeed then
        self.timer = self.timer - self.printSpeed
        self.currentChar = self.currentChar + 1
        if self.currentChar > #self.fullTextChars then
            self.currentChar = #self.fullTextChars
            self.isPrinting = false
        end
    end
end

function dialogue:keypressed(key)
    if key == "space" then
        if self.isPrinting then
            self.isPrinting = false
            self.currentChar = #self.fullTextChars
        elseif not self.isPrinting then
            self:next()
        end
    end
end

function dialogue:draw()
    love.graphics.setFont(self.font)
    local visibleChars = {}
    for i = 1, math.min(self.currentChar, #self.fullTextChars) do
        table.insert(visibleChars, self.fullTextChars[i])
    end
    local textToDraw = table.concat(visibleChars)

    -- разбиваем на строки с переносом
    local lines = {}
    for line in textToDraw:gmatch("[^\n]+") do
        local wrapped = libs.utils.text.wrap(line, self.font, self.window.width - 10)
        for _, wline in ipairs(wrapped) do
            table.insert(lines, wline)
        end
    end

    -- центрируем по вертикали
    local totalHeight = #lines * self.font:getHeight()
    local startY = self.window.y + (self.window.height - totalHeight)/2

    for i, line in ipairs(lines) do
        local lineWidth = self.font:getWidth(line)
        local startX = self.window.x + (self.window.width - lineWidth)/2
        love.graphics.print(line, startX, startY + (i-1)*self.font:getHeight())
    end
end

return dialogue
