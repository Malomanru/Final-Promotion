local AStar = {}

function AStar.findPath(grid, startX, startY, endX, endY)
    if not grid or not grid[1] then
        return nil
    end

    local openSet = {}
    local closedSet = {}
    local cameFrom = {}
    local gScore = {}
    local fScore = {}

    local function heuristic(x1, y1, x2, y2)
        return math.abs(x1 - x2) + math.abs(y1 - y2)
    end

    local function getNeighbors(x, y)
        return {
            {x-1, y}, {x+1, y}, {x, y-1}, {x, y+1}
        }
    end

    local function isValid(x, y)
        return x > 0 and y > 0 and x <= #grid[1] and y <= #grid and grid[y][x] == 0
    end

    local function reconstructPath(current)
        local path = {current}
        while cameFrom[current[1]..","..current[2]] do
            current = cameFrom[current[1]..","..current[2]]
            table.insert(path, 1, current)
        end
        return path
    end

    local start = {startX, startY}
    local goal = {endX, endY}

    openSet[start[1]..","..start[2]] = start
    gScore[start[1]..","..start[2]] = 0
    fScore[start[1]..","..start[2]] = heuristic(start[1], start[2], goal[1], goal[2])

    while next(openSet) do
        local current = nil
        local lowestF = math.huge

        for key, node in pairs(openSet) do
            if fScore[key] < lowestF then
                lowestF = fScore[key]
                current = node
            end
        end

        if current[1] == goal[1] and current[2] == goal[2] then
            return reconstructPath(current)
        end

        local currentKey = current[1]..","..current[2]
        openSet[currentKey] = nil
        closedSet[currentKey] = true

        for _, neighbor in ipairs(getNeighbors(current[1], current[2])) do
            local nx, ny = neighbor[1], neighbor[2]
            local neighborKey = nx..","..ny

            if isValid(nx, ny) and not closedSet[neighborKey] then
                local tentativeG = gScore[currentKey] + 1

                if not openSet[neighborKey] then
                    openSet[neighborKey] = {nx, ny}
                elseif tentativeG >= (gScore[neighborKey] or math.huge) then
                    goto continue
                end

                cameFrom[neighborKey] = current
                gScore[neighborKey] = tentativeG
                fScore[neighborKey] = tentativeG + heuristic(nx, ny, goal[1], goal[2])
            end
            ::continue::
        end
    end

    return nil
end

function AStar:worldToGrid(x, y)
    local gridX = math.floor((x) / _G.game.game_map.tileSize) + 1
    local gridY = math.floor((y) / _G.game.game_map.tileSize) + 1
    return gridX, gridY
end

return AStar