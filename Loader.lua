local REPO   = "vornecc-pixel/Arceus-X"
local BRANCH = "main"

local UI_URL  = ("https://raw.githubusercontent.com/%s/%s/UI.lua"):format(REPO, BRANCH)

local success, response = pcall(function()
    return game:HttpGet(UI_URL)
end)

if not success or response == "404: Not Found" then
    error("Could not load UI.lua! Check your repo name and make sure UI.lua exists and is capitalized.")
end

local func, err = loadstring(response)
if not func then
    error("Syntax Error in UI.lua: " .. tostring(err))
end

func()
