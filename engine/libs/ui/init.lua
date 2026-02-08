local ui = {
    modules = {},
    windows = {},
    modal_active = false,
}

ui.modules['window'] = require("engine/libs/ui/window")
ui.modules['button'] = require("engine/libs/ui/button")
ui.modules['imageButton'] = require("engine/libs/ui/imageButton")
ui.modules['label'] = require("engine/libs/ui/label")
ui.modules['slider'] = require("engine/libs/ui/slider")

function ui:newElement(elementName, params)
    return self.modules[elementName].new(params)
end

function ui:update(dt)
    for _, w in pairs(self.windows) do
        if w.update then w:update(dt) end
    end
end

function ui:draw()
    for _, w in pairs(self.windows) do
        if self.modal_active then
            if w.flags.is_modal then love.graphics.setColor(1,1,1,1) w:draw() else w:draw() end
        else
            w:draw()
        end
    end
end

function ui:mousepressed(x, y, btn)
    for _, w in pairs(self.windows) do
        if w.mousepressed then w:mousepressed(x, y, btn) end
    end
end

function ui:mousereleased(x, y, btn)
    for _, w in pairs(self.windows) do
        if w.mousereleased then w:mousereleased(x, y, btn) end
    end
end

function ui:keypressed(key)
    for _, w in pairs(self.windows) do
        if w.keypressed then w:keypressed(key) end
    end
end



function ui:textinput(text)
    for _, w in pairs(self.windows) do
        if w.textinput then w:textinput(text) end
    end
end

return ui