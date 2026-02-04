local M = {}

function M.BeforeCamera() -- background

end

function M.Camera() -- game
    if _G.game.game_map and _G.game.game_map.draw then _G.game.game_map:draw() end
    M:renderALL()

    --libs.physics:draw(0.5, "world")
end

function M.AfterCamera() -- ui
    libs.ui:draw()
    for _, v in pairs(ui) do if v.draw then v:draw() end end

    libs.utils.debug.draw()
end

local RENDER_CONFIG = {
    margin = 10,
    enableCulling = true
}

function M:renderALL(exceptions)
    local renderQueue = {}
    
    -- Нормализуем exceptions в таблицу
    if exceptions then
        if type(exceptions) ~= "table" then
            exceptions = {exceptions}
        end
    else
        exceptions = {}
    end
    
    local camera = libs.cam or {x = 0, y = 0}
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    local to_render = {
        _G.game.game_map.players,   _G.game.game_map.npcs,
        _G.game.game_map.props, _G.game.game_map.effects
    }
    
    for _, objGroup in ipairs(to_render) do
        if not objGroup then goto continue end
        
        -- Безопасная итерация
        if type(objGroup) == "table" then
            for _, o in pairs(objGroup) do
                if o and o.render ~= false then
                    -- Проверяем исключения
                    local skip = false
                    for _, except in ipairs(exceptions) do
                        if except == o then
                            skip = true
                            break
                        end
                    end
                    
                    if not skip then
                        -- Отсечение (culling)
                        if RENDER_CONFIG.enableCulling then
                            local screenX = o.x + camera.x
                            local screenY = o.y + camera.y
                            local margin = RENDER_CONFIG.margin or 50
                            
                            -- Если объект вне экрана с margin, пропускаем
                            if screenX + margin < 0 or
                               screenX - margin > screenWidth or
                               screenY + margin < 0 or
                               screenY - margin > screenHeight then
                                skip = true
                            end
                        end
                        
                        if not skip then
                            table.insert(renderQueue, o)
                        end
                    end
                end
            end
        else
            -- Если objGroup не таблица, а одиночный объект
            if objGroup.render ~= false then
                local skip = false
                for _, except in ipairs(exceptions) do
                    if except == objGroup then
                        skip = true
                        break
                    end
                end
                
                if not skip then
                    table.insert(renderQueue, objGroup)
                end
            end
        end
        
        ::continue::
    end
    
    -- Сортировка по Y координате
    table.sort(renderQueue, function(a, b)
        return (a.y or 0) + (a.add_y or 0) < (b.y or 0) + (b.add_y or 0)
    end)
    
    -- Отрисовка
    for _, obj in ipairs(renderQueue) do
        if obj and obj.draw then
            if type(obj.draw) == "function" then
                obj:draw()
            else
                love.graphics.print("Error: obj.draw is not a function", 10, 10)
            end
        end
    end
end

return M