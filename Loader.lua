-- ═══════════════════════════════════════════════════════════════
-- LOADER — the only thing users execute
-- ═══════════════════════════════════════════════════════════════

local REPO   = "YOUR_USER/YOUR_REPO"
local BRANCH = "main"

local UI_URL  = ("https://raw.githubusercontent.com/%s/%s/ui.lua"):format(REPO, BRANCH)
local ESP_URL = ("https://raw.githubusercontent.com/%s/%s/esp.lua"):format(REPO, BRANCH)

loadstring(game:HttpGet(UI_URL))(ESP_URL)