local rising_text = {}
rising_text.__index = rising_text

function rising_text:create(params)
    local self = setmetatable({}, rising_text)

    self.x, self.y = params.x or 0, params.y or 0
    self.add_y = 15

    self.text = params.text or ""

    self.direction = params.direction or "up"

    self.options = {
        text_move_up_time = params.text_move_up_time or 1,
        text_move_up_distance = params.text_move_up_distance or 15,
        text_duration_before_fade = params.text_duration_before_fade or 2,
        text_time_to_fade = params.text_time_to_fade or 2,

    }

    self.visual = {
        font = params.font or love.graphics.getFont(),
        transparency = params.transparency or 0,
    }

    _G.game.game_map.effects[self] = self

    local to_y = (self.direction == "up" and self.y - self.options.text_move_up_distance) or (self.direction == "down" and self.y + self.options.text_move_up_distance ) or self.y - self.options.text_move_up_distance
    local to_x = (self.direction == "left" and self.x - self.options.text_move_up_distance) or (self.direction == "right" and self.x + self.options.text_move_up_distance) or self.x

    libs.tween.new(self.options.text_time_to_fade/2, self.visual, {transparency = 1}, "linear")
    libs.tween.new(self.options.text_move_up_time, self, {y = to_y, x = to_x}, "outQuad", function ()
        libs.timer.new(self.options.text_duration_before_fade, function()
            libs.tween.new(self.options.text_time_to_fade, self.visual, {transparency = 0}, "linear",
            function () _G.game.game_map.effects[self] = nil end)
        end)
    end)

    return self
end

function rising_text:draw()
    local text_w, text_h = self.visual.font:getWidth(self.text), self.visual.font:getHeight(self.text)

    if self.visual.font then love.graphics.setFont(self.visual.font) self.visual.font:setFilter("nearest", "nearest") end
    love.graphics.setColor(1,1,1, self.visual.transparency)
    love.graphics.print(self.text, self.x - text_w/2, self.y - text_h/2)
    love.graphics.setColor(1,1,1,1)
end

return rising_text