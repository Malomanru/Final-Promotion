return function ()
    libs = {}
    local paths = {'engine', 'engine/libs', 'engine/effects'}

    libs.windfield = require('engine/libs/windfield')
    libs.sti = require('engine.libs.sti')
    libs.AStar = require('engine.libs.AStar')
    libs.ui = require('engine/libs/ui/init')

    libs.hump = {
        vector = require('engine/libs/hump/vector')
    }

    for _, path in ipairs(paths) do
        local files = love.filesystem.getDirectoryItems(path)
        for _, file in ipairs(files) do
            if string.match(file, "%.lua$") and file ~= "init.lua" then
                local name = string.sub(file, 1, -5)
                local modulePath = path .. '/' .. name
                
                -- Создаем вложенную структуру только для effects
                if path == 'engine/effects' then
                    libs.effects = libs.effects or {}
                    libs.effects[name] = require(modulePath)
                else
                    -- Для остальных путей сохраняем плоскую структуру
                    libs[name] = require(modulePath)
                end
            end
        end
    end

    return libs
end