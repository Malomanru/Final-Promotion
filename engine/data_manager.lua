local data_manager = {}

function data_manager.createGameDirectory(name)
    local userDir = os.getenv("USERPROFILE") or os.getenv("HOME")
    local path = userDir .. "/" .. name

    local logs = path .. "/logs"
    local saves = path .. "/saves"

    if love.system.getOS() == "Windows" then
        os.execute('if not exist "' .. logs .. '" mkdir "' .. logs .. '"')
        os.execute('if not exist "' .. saves .. '" mkdir "' .. saves .. '"')
    else
        os.execute('[ ! -d "' .. logs .. '" ] && mkdir -p "' .. logs .. '"')
        os.execute('[ ! -d "' .. saves .. '" ] && mkdir -p "' .. saves .. '"')
    end

    return path
end

function data_manager:save_data(filename, data)
    local json = libs.json
    local file = io.open(filename, "w")
    if file then
        file:write(json.encode(data))
        file:close()
    end
end

function data_manager:load_data(filename)
    local json = libs.json
    local file = io.open(filename, "r")
    if file then
        local data = file:read("*all")
        file:close()
        return json.decode(data)
    else
        return nil
    end
end

return data_manager