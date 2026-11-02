local REPO   = "vornecc-pixel/Arceus-X"
local BRANCH = "main"

local UI_URL  = ("https://raw.githubusercontent.com/%s/%s/UI.lua?v=" .. tostring(math.random(1, 999999))):format(REPO, BRANCH)

loadstring(game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/main/UI.lua"))()
