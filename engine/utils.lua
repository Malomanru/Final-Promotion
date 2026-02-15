local utils = {}

function utils.rgb(r, g, b, a)
    return {r/255, g/255, b/255, a or 1}
end

-- { Debug } --
utils.debug = {
    active = false,
    colors = {
        red = "\x1b[31m",
        green = "\x1b[32m",
        yellow = "\x1b[33m",
        blue = "\x1b[34m",
        magenta = "\x1b[35m",
        cyan = "\x1b[36m",
        white = "\x1b[37m",
        orange = "\x1b[38;5;208m",
        reset = "\x1b[0m"
    }
}

function utils.debug.log(type, color, msg)
    if not utils.debug.active then return end
    
    io.write(utils.debug.colors[color] .. "\n["..type.."]: ".. utils.debug.colors.reset .. msg)
    io.flush()
end

function utils.debug.draw()
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.rectangle("fill", 5, 5, 200, 100)
    love.graphics.setColor(1,1,1,1)

    love.graphics.setFont(love.graphics.newFont(12))

    love.graphics.print(string.format(tostring("Memory Usage: %.3f MB"), collectgarbage("count")/1024), 10, 10)
end

-- { Cursor } --
utils.cursor = {}

function utils.cursor.inRect(x, y, w, h)
    local mx, my = love.mouse.getPosition()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

function utils.cursor.inCircle(x, y, r)
    local mx, my = love.mouse.getPosition()
    return (mx - x) ^ 2 + (my - y) ^ 2 <= r ^ 2
end

function utils.cursor.inEllipse(x, y, rx, ry)
    local mx, my = love.mouse.getPosition()
    return ((mx - x) / rx) ^ 2 + ((my - y) / ry) ^ 2 <= 1
end

function utils.cursor.inPolygon(x, y, points)
    local intersections = 0
    local mx, my = love.mouse.getPosition()
    local n = #points
    for i = 1, n do
        local x1, y1 = points[i][1], points[i][2]
        local x2, y2 = points[i % n + 1][1], points[i % n + 1][2]
        if ((y1 > my) ~= (y2 > my)) and (mx < (x2 - x1) * (my - y1) / (y2 - y1) + x1) then
            intersections = intersections + 1
        end
    end
    return intersections % 2 == 1
end

-- { Point } --
utils.point = {}
function utils.point.inRect(x, y, w, h, px, py)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

function utils.point.inCircle(x, y, r, px, py)
    return (px - x) ^ 2 + (py - y) ^ 2 <= r ^ 2
end

function utils.point.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function utils.point.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

function utils.point.project(x, y, angle, distance)
    return x + math.cos(angle) * distance, y + math.sin(angle) * distance
end

function utils.point.rotate(x, y, cx, cy, angle)
    local s, c = math.sin(angle), math.cos(angle)
    x, y = x - cx, y - cy
    return cx + x * c - y * s, cy + x * s + y * c
end

-- { Resources } --
utils.resources = {
    load = {},
    cache = {
        images = {},
        sounds = {},
        fonts = {},
        data = {}
    }
}

function utils.resources.load.image(path, filter1, filter2)
    local image = love.graphics.newImage(path)
    image:setFilter(filter1 or "nearest", filter2 or "nearest")
    utils.resources.cache.images[path] = image
    return image
end

function utils.resources.load.sound(path, type)
    local sound = love.audio.newSource(path, type or "static")
    utils.resources.cache.sounds[path] = sound
    return sound
end

function utils.resources.load.font(path, size)
    local font = love.graphics.newFont(path, size or 12)
    utils.resources.cache.fonts[path] = font
    return font
end

function utils.resources.load.asset(path)
    local file = io.open(path, "rb")

    if file then 
        local content = file:read("*all")
        file:close()
        
        local fileInfo = utils.resources.detectFileType(path, content)
        fileInfo.content = content
        
        utils.debug.log("INFO", "green", 
            string.format("Loaded asset: %s (%d bytes, type: %s)", 
            path, #content, fileInfo.type))
        
        return fileInfo
    else
        utils.debug.log("WARN", "orange", "Failed to load asset: " .. path)
        return nil
    end
end

function utils.resources.detectFileType(path, content)
    local info = {
        path = path,
        name = path:match("([^/\\]+)$"),
        extension = path:lower():match("%.([^%.]+)$") or "",
        size = #content
    }
    info.mimeType = utils.resources.getMimeTypeBySignature(content)
    
    if info.mimeType == "application/octet-stream" and info.extension ~= "" then
        info.mimeType = utils.resources.getMimeTypeByExtension(info.extension)
    end
    
    info.type = utils.resources.getGeneralType(info.mimeType)
    
    return info
end

function utils.resources.getMimeTypeBySignature(content)
    if #content < 4 then return "application/octet-stream" end
    
    local signature = content:sub(1, 4)
    
    local signatures = {
        -- Изображения
        ["\137\080\078\071"] = "image/png",      -- PNG
        ["\255\216\255"] = "image/jpeg",         -- JPEG
        ["\071\073\070\056"] = "image/gif",      -- GIF
        ["\066\077"] = "image/bmp",              -- BMP
        ["\082\073\070\070"] = function(c)       -- RIFF
            if #c >= 12 and c:sub(8, 12) == "\087\069\066\080" then
                return "image/webp"
            elseif #c >= 12 and c:sub(8, 12) == "\087\065\086\069" then
                return "audio/wav"
            end
            return "application/octet-stream"
        end,
        
        -- Аудио
        ["\079\103\103\083"] = "audio/ogg",      -- OGG
        ["\070\076\065\067"] = "audio/flac",     -- FLAC
        
        -- Шрифты
        ["\000\001\000\000"] = "font/ttf",       -- TTF
        ["\079\084\084\079"] = "font/otf",       -- OTF
        
        -- Архивы
        ["\080\075\003\004"] = "application/zip", -- ZIP
        ["\082\097\114\033"] = "application/x-rar", -- RAR
        
        -- PDF
        ["%PDF%-"] = "application/pdf",
    }
    
    local handler = signatures[signature]
    if handler then
        if type(handler) == "function" then
            return handler(content)
        end
        return handler
    end
    
    if not content:find("[\0-\8\14-\31]") then -- нет управляющих символов
        local first100 = content:sub(1, 100)
        
        if first100:match("^%s*[{%[]") then
            return "application/json"
        end
        
        if first100:match("^%s*<") then
            if first100:match("^%s*<[Hh][Tt][Mm][Ll]") or 
               first100:match("^%s*<!DOCTYPE") then
                return "text/html"
            end
            return "text/xml"
        end
        
        if first100:match("^%s*function") or 
           first100:match("^%s*local") or 
           first100:match("^%s*--") then
            return "text/x-lua"
        end
        
        return "text/plain"
    end
    
    return "application/octet-stream"
end

function utils.resources.getMimeTypeByExtension(extension)
    local mimeTypes = {
        -- Изображения
        ["png"] = "image/png",
        ["jpg"] = "image/jpeg",
        ["jpeg"] = "image/jpeg",
        ["gif"] = "image/gif",
        ["bmp"] = "image/bmp",
        ["webp"] = "image/webp",
        ["svg"] = "image/svg+xml",
        ["ico"] = "image/x-icon",
        ["tga"] = "image/x-tga",
        
        -- Аудио
        ["wav"] = "audio/wav",
        ["ogg"] = "audio/ogg",
        ["mp3"] = "audio/mpeg",
        ["flac"] = "audio/flac",
        
        -- Видео
        ["mp4"] = "video/mp4",
        ["webm"] = "video/webm",
        ["ogv"] = "video/ogg",
        
        -- Шрифты
        ["ttf"] = "font/ttf",
        ["otf"] = "font/otf",
        ["woff"] = "font/woff",
        ["woff2"] = "font/woff2",
        
        -- Текст
        ["txt"] = "text/plain",
        ["lua"] = "text/x-lua",
        ["json"] = "application/json",
        ["xml"] = "text/xml",
        ["html"] = "text/html",
        ["htm"] = "text/html",
        ["css"] = "text/css",
        ["js"] = "application/javascript",
        ["md"] = "text/markdown",
        ["csv"] = "text/csv",
        
        -- Данные
        ["json"] = "application/json",
        ["yaml"] = "application/x-yaml",
        ["yml"] = "application/x-yaml",
        ["toml"] = "application/toml",
        
        -- Архивы
        ["zip"] = "application/zip",
        ["rar"] = "application/x-rar-compressed",
        ["7z"] = "application/x-7z-compressed",
        ["tar"] = "application/x-tar",
        ["gz"] = "application/gzip",
    }
    
    return mimeTypes[extension] or "application/octet-stream"
end

function utils.resources.getGeneralType(mimeType)
    if mimeType:match("^image/") then return "image"
    elseif mimeType:match("^audio/") then return "audio"
    elseif mimeType:match("^video/") then return "video"
    elseif mimeType:match("^font/") then return "font"
    elseif mimeType:match("^text/") or 
           mimeType == "application/json" or
           mimeType == "application/x-yaml" or
           mimeType == "application/toml" then
        return "text"
    else
        return "binary"
    end
end

function utils.resources.loadAndProcessAsset(path)
    local asset = utils.resources.load.asset(path)
    
    if not asset then 
        return nil 
    end
    
    -- Проверяем кэш
    if asset.type == "image" and utils.resources.cache.images[path] then
        utils.debug.log("DEBUG", "cyan", "Using cached image: " .. path)
        return utils.resources.cache.images[path]
    elseif asset.type == "audio" and utils.resources.cache.sounds[path] then
        utils.debug.log("DEBUG", "cyan", "Using cached sound: " .. path)
        return utils.resources.cache.sounds[path]
    end
    
    if asset.type == "image" then
        local tempPath = "temp_" .. asset.name
        local success = love.filesystem.write(tempPath, asset.content)
        
        if success then
            local image = utils.resources.load.image(tempPath)
            love.filesystem.remove(tempPath)
            return image
        end
        
    elseif asset.type == "audio" then
        local tempPath = "temp_" .. asset.name
        local success = love.filesystem.write(tempPath, asset.content)
        
        if success then
            local sound = utils.resources.load.sound(tempPath)
            love.filesystem.remove(tempPath)
            return sound
        end
        
    elseif asset.type == "font" then
        local tempPath = "temp_" .. asset.name
        local success = love.filesystem.write(tempPath, asset.content)
        
        if success then
            local font = utils.resources.load.font(tempPath)
            love.filesystem.remove(tempPath)
            return font
        end
        
    elseif asset.type == "text" then
        if asset.mimeType == "application/json" then
            local success, data = pcall(json.decode, asset.content)
            if success then
                utils.resources.cache.data[path] = data
                return data
            end
        elseif asset.mimeType == "text/x-lua" then
            local chunk, err = load(asset.content, asset.name)
            if chunk then
                return chunk
            else
                utils.debug.log("ERROR", "red", "Failed to load Lua: " .. err)
            end
        end
        
        return asset.content
        
    elseif asset.type == "binary" then
        return asset.content
    end
    
    return asset.content
end

-- Утилиты для работы с кэшем
function utils.resources.clearCache(type)
    if type then
        if utils.resources.cache[type] then
            utils.resources.cache[type] = {}
            utils.debug.log("INFO", "green", "Cleared " .. type .. " cache")
        end
    else
        for cacheType, _ in pairs(utils.resources.cache) do
            utils.resources.cache[cacheType] = {}
        end
        utils.debug.log("INFO", "green", "Cleared all caches")
    end
end

function utils.resources.getCachedAsset(path, type)
    if not type then
        local ext = path:lower():match("%.([^%.]+)$") or ""
        if ext:match("^(png|jpg|jpeg|gif|bmp|webp)$") then
            type = "images"
        elseif ext:match("^(wav|ogg|mp3|flac)$") then
            type = "sounds"
        elseif ext:match("^(ttf|otf|woff|woff2)$") then
            type = "fonts"
        else
            type = "data"
        end
    end
    
    return utils.resources.cache[type] and utils.resources.cache[type][path]
end

-- { Other }

function getFileTypeBySignature(content)
    if #content < 4 then return "unknown" end
    local signature = content:sub(1, 4)
    
    local signatures = {
        ["\137\080\078\071"] = "image/png",         -- PNG
        ["\255\216\255"] = "image/jpeg",            -- JPEG
        ["\071\073\070\056"] = "image/gif",         -- GIF
        ["\066\077"] = "image/bmp",                 -- BMP
        ["\082\073\070\070"] = {                    -- RIFF (может быть WAV, AVI, WEBP)
            check = function(c)
                local sub = c:sub(8, 12)
                if sub == "\087\069\066\080" then return "image/webp" end
                if sub == "\087\065\086\069" then return "audio/wav" end
                return "binary"
            end
        },
        ["%<%?%x%m%l"] = "text/xml",                -- XML
        ["%[%]"] = "application/json",              -- JSON (часто начинается с { или [)
    }
    
    local sigType = signatures[signature]
    
    if type(sigType) == "function" then
        return sigType(content)
    elseif sigType then
        return sigType
    end
    
    if content:match("^%s*{") or content:match("^%s*%[") then
        return "application/json"
    elseif content:match("^%s*%<") then
        return "text/html"
    elseif not content:find("[\0-\8\14-\31]") then
        return "text/plain"
    end
    
    return "application/octet-stream"
end

utils.text = {}

function utils.text.wrap(text, font, maxWidth)
    font = font or love.graphics.getFont()
    maxWidth = maxWidth or 100
    font:setFilter("nearest", "nearest")

    local wrappedText = {}

    if not text or text == "" then
        return wrappedText
    end

    local remainingText = text

    while #remainingText > 0 do
        local line = ""
        local i = 1
        local chars = {}
        for c in remainingText:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
            table.insert(chars, c)
        end

        -- собираем строку символ за символом
        while i <= #chars do
            local testLine = table.concat(chars, "", 1, i)
            local success, width = pcall(function() return font:getWidth(testLine) end)
            if not success then
                chars[i] = "" -- удаляем проблемный символ
                width = font:getWidth(table.concat(chars, "", 1, i))
            end

            if width > maxWidth then
                break
            end
            i = i + 1
        end

        -- ищем последний пробел для переноса
        local splitAt = i - 1
        for j = i - 1, 1, -1 do
            if chars[j]:match("%s") then
                splitAt = j
                break
            end
        end

        line = table.concat(chars, "", 1, splitAt)
        table.insert(wrappedText, line)

        remainingText = table.concat(chars, "", splitAt + 1, #chars):gsub("^%s+", "")
    end

    return wrappedText
end

-- { For this game } --
utils.game = {}

utils.game.updateLanguage = function(lang)
    _G.game.settings.language = lang

    for _, v in pairs(ui) do
        if (type(v) ~= "function") and v.window then for _, element in pairs(v.window.content) do
            if type(element) ~= "function" and element.changeLang then element:changeLang() end
            end
        end
    end
end

return utils