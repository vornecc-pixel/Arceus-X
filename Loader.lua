local REPO   = "vornecc-pixel/Arceus-X"
local BRANCH = "main"
local CACHE_BUSTER = "?v=" .. tostring(math.random(1, 999999))
local UI_URL  = ("https://raw.githubusercontent.com/%s/%s/UI.lua%s"):format(REPO, BRANCH, CACHE_BUSTER)
loadstring(game:HttpGet(UI_URL))()
