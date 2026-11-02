-- ═══════════════════════════════════════════════════════════════
-- LOADER — the only thing users execute
-- ═══════════════════════════════════════════════════════════════

local REPO = "vornecc-pixel/Arceus-X"
local BRANCH = "main"

local UI_URL  = ("https://raw.githubusercontent.com/%s/%s/UI.lua"):format(REPO, BRANCH)
local ESP_URL = ("https://raw.githubusercontent.com/%s/%s/esp.lua"):format(REPO, BRANCH)

loadstring(game:HttpGet(UI_URL))(ESP_URL)
