local http = libs.https
local github = {}
local version = "Loading..."

function github:getLatestVersion()
    local response = {}

    local body, code = https.request{
        url = "https://api.github.com/repos/Malomanru/Final-Promotion",
        headers = {
            ["User-Agent"] = "LOVE2D"
        }
    }

    if code == 200 then
        local data = libs.json.decode(body)
        version = data.pushed_at
    else
        version = "Error"
    end

    return version
end

return github