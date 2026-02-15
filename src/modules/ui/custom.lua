local custom = {
    button = {},
    label = {},
}

function custom.button.draw(btn)
    if btn.appearAlpha <= 0 then return end
    
    love.graphics.push()
    love.graphics.translate(btn.slideX or 0, btn.slideY or 0)
    
    love.graphics.setFont(btn.visual.font)
    love.graphics.setColor(btn.visual.bg_color[1], btn.visual.bg_color[2], btn.visual.bg_color[3], btn.visual.bg_color[4] * btn.appearAlpha)
    love.graphics.rectangle("fill", btn.x_global, btn.y_global, btn.width, btn.height)
    
    if btn.hoverAlpha > 0 then
        love.graphics.setColor(1, 1, 1, btn.hoverAlpha * 0.1 * btn.appearAlpha)
        love.graphics.rectangle("fill", btn.x_global, btn.y_global, btn.width, btn.height)
        
        love.graphics.setColor(1, 1, 1, btn.hoverAlpha * 0.8 * btn.appearAlpha)
        love.graphics.rectangle("fill", btn.x_global, btn.y_global, 3, btn.height)
        love.graphics.rectangle("fill", btn.x_global + btn.width - 3, btn.y_global, 3, btn.height)
    end
    
    love.graphics.setColor(btn.visual.border_color[1], btn.visual.border_color[2], btn.visual.border_color[3], btn.visual.border_color[4] * btn.appearAlpha)
    love.graphics.setLineWidth(btn.visual.border_width)
    love.graphics.rectangle("line", btn.x_global, btn.y_global, btn.width, btn.height)
    
    if btn.hoverAlpha > 0 then
        love.graphics.setColor(1, 1, 1, btn.hoverAlpha * 0.5 * btn.appearAlpha)
        love.graphics.rectangle("line", btn.x_global - 2, btn.y_global - 2, btn.width + 4, btn.height + 4)
    end
    
    love.graphics.setColor(btn.visual.text_color[1], btn.visual.text_color[2], btn.visual.text_color[3], btn.visual.text_color[4] * btn.appearAlpha)
    local tw = btn.visual.font:getWidth(btn.text)
    local th = btn.visual.font:getHeight()
    love.graphics.print(btn.text, btn.x_global + (btn.width - tw) / 2, btn.y_global + (btn.height - th) / 2)
    
    if btn.hoverAlpha > 0 and btn.show_arrows then
        love.graphics.setColor(1, 1, 1, btn.hoverAlpha * 0.6 * btn.appearAlpha)
        love.graphics.print(">", btn.x_global + 15, btn.y_global + (btn.height - th) / 2)
        love.graphics.print("<", btn.x_global + btn.width - 25, btn.y_global + (btn.height - th) / 2)
    end
    
    love.graphics.pop()
end

return custom