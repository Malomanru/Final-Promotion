local Translation = {}
Translation.data = {}

local function createPath(root, path)
    local current = root

    for part in path:gmatch("[^%.]+") do
        current[part] = current[part] or {}
        current = current[part]
    end

    return current
end

function Translation:loadFile(filename)
    local file = io.open(filename, "r")
    if not file then
        error("Cannot open translation file: " .. filename)
    end

    local currentBlock = nil

    for line in file:lines() do
        line = line:match("^%s*(.-)%s*$")

        if line ~= "" then
            if line == "}" then
                currentBlock = nil

            else
                local keyPath = line:match("^([%w%.]+)%s*{%s*$")
                if keyPath then
                    currentBlock = createPath(self.data, keyPath)

                elseif currentBlock then
                    local lang, text = line:match("^(%w+)%s*:%s*(.-)%s*$")
                    if lang and text then
                        currentBlock[lang:lower()] = text
                    end
                end
            end
        end
    end

    file:close()
end

local function makeProxy(tbl)
    return setmetatable({}, {
        __index = function(_, key)
            local value = tbl[key]

            if type(value) == "table" then
                return makeProxy(value)
            end

            if tbl[string.lower(key)] then
                return tbl[string.lower(key)]
            end

            return value or ""
        end
    })
end

setmetatable(Translation, {
    __index = function(t, key)
        if t.data[key] then
            return makeProxy(t.data[key])
        end
    end
})

return Translation