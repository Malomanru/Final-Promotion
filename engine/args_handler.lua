local args_handler = {}

-- Таблица обработчиков аргументов
args_handler.handlers = {
    ["--debug"] = function(value)
        if libs and libs.utils and libs.utils.debug then
            libs.utils.debug.active = true
            libs.utils.debug.log("DEBUG", "cyan", "Debug mode enabled.")
        end
    end,
    
    ["--nointro"] = function(value)
        
    end,
    
    ["--help"] = function(value)
        print("Available arguments:")
        print("  --debug      Enable debug mode")
        print("  --nointro    Skip introduction screen")
        print("  --config=<file>  Load configuration from file")
        print("  --level=<n>      Start at level n")
    end,
    
    ["--config"] = function(value)
        if value then
            print("[CONFIG] Loading configuration from: " .. value)
        else
            print("[ERROR] --config requires a filename")
        end
    end,
    
    ["--level"] = function(value)
        if value and tonumber(value) then
            local level = tonumber(value)
            print("[LEVEL] Starting at level: " .. level)
        else
            print("[ERROR] --level requires a number")
        end
    end
}

-- Парсинг аргументов
function args_handler.parse(args)
    local parsed = {}
    
    for i = 1, #args do
        local arg = args[i]
        local key, value = arg:match("^(%-%-[^=]+)=(.+)$")
        
        if key then
            parsed[key] = value
        elseif arg:sub(1, 2) == "--" then
            if i < #args and args[i + 1]:sub(1, 2) ~= "--" then
                parsed[arg] = args[i + 1]
            else
                parsed[arg] = true
            end
        end
    end
    
    return parsed
end

-- Выполнения обработчиков
function args_handler.execute(parsed_args)
    for arg, value in pairs(parsed_args) do
        local handler = args_handler.handlers[arg]
        if handler then
            handler(value)
        else
            print("[WARNING] Unknown argument: " .. arg)
        end
    end
end

-- Основная обработка аргументов
function args_handler.process(args)
    local parsed = args_handler.parse(args)
    args_handler.execute(parsed)
    return parsed
end

-- Проверка для часто используемых аргументов
function args_handler.has(parsed_args, arg_name)
    return parsed_args[arg_name] ~= nil
end

function args_handler.get(parsed_args, arg_name, default)
    return parsed_args[arg_name] or default
end

return args_handler