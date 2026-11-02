-- ═══════════════════════════════════════════════════════════════
-- UI MODULE
-- ═══════════════════════════════════════════════════════════════

local ESP_URL = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/main/esp.lua"

local library, themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/Atlanta/Library.lua"))()

local dim2 = UDim2.new
local hex = Color3.fromHex

local window = library:window({name = os.date('Atlanta |  - %b %d %Y'), size = dim2(0, 750, 0, 782)})

local Aiming   = window:tab({name = "Aiming"})
local Misc     = window:tab({name = "Misc"})
local Visuals  = window:tab({name = "Visuals"})

-- ── Aiming tab ─────────────────────────────────────────────────
-- (Keep your existing aiming code exactly as it is)
local aim_column = Aiming:column()
local selec, lock = aim_column:multi_section({names = {"Selection", "Lock"}})
-- ... [your aiming code] ...
library.config_flags["fov"](false)

-- ── Visuals tab ────────────────────────────────────────────────
local esp
local esp_preview

local function update_elements()
    if esp and esp.refresh_elements then
        esp:refresh_elements()
    end
end

local visual_column = Visuals:column()

-- SECTION 1: General
local section = visual_column:section({name = "General", toggle = false})
section:toggle({name = "Enabled", flag = "Enabled", callback = update_elements})
section:toggle({name = "Names", flag = "Names", callback = update_elements})
    :colorpicker({flag = "Name_Color", callback = update_elements})

local box_toggle = section:toggle({name = "Boxes", flag = "Boxes", callback = update_elements})
section:dropdown({name = "Box Type", flag = "Box_Type", items = {"Corner", "Full"}, default = "Corner", callback = update_elements})
box_toggle:colorpicker({name = "Box Color", flag = "Box_Color", callback = update_elements})

local health_toggle = section:toggle({name = "Healthbar", flag = "Healthbar", callback = update_elements})
health_toggle:colorpicker({name = "High HP Color", flag = "Health_High", callback = update_elements})
health_toggle:colorpicker({name = "Low HP Color",  flag = "Health_Low",  callback = update_elements})

section:toggle({name = "Distance", flag = "Distance", callback = update_elements})
    :colorpicker({name = "Distance Color", flag = "Distance_Color", callback = update_elements})

section:toggle({name = "Weapon", flag = "Weapon", callback = update_elements})
    :colorpicker({name = "Weapon Color", flag = "Weapon_Color", callback = update_elements})

section:toggle({name = "Skeletons", flag = "Skeletons", callback = update_elements})
    :colorpicker({name = "Skeleton Color", flag = "Skeletons_Color", callback = update_elements})

-- SECTION 2: Advanced (NEW)
local advanced_section = visual_column:section({name = "Advanced", toggle = false})

advanced_section:toggle({name = "Team Check", flag = "Team_Check", callback = update_elements})
advanced_section:toggle({name = "Rainbow Effects", flag = "Rainbow", callback = update_elements})

-- Chams
local chams_toggle = advanced_section:toggle({name = "Chams", flag = "Chams", callback = update_elements})
chams_toggle:colorpicker({name = "Chams Fill", flag = "Chams_Color", callback = update_elements})
chams_toggle:colorpicker({name = "Chams Outline", flag = "Chams_Outline", callback = update_elements})
advanced_section:dropdown({name = "Chams Mode", flag = "Chams_Mode", items = {"AlwaysOnTop", "Occluded"}, default = "AlwaysOnTop", callback = update_elements})
advanced_section:toggle({name = "Health Chams", flag = "Health_Chams", callback = update_elements})

-- Head Dot
local dot_toggle = advanced_section:toggle({name = "Head Dot", flag = "Head_Dot", callback = update_elements})
dot_toggle:colorpicker({name = "Dot Color", flag = "Head_Dot_Color", callback = update_elements})

-- Tracers
local tracer_toggle = advanced_section:toggle({name = "Tracers", flag = "Tracers", callback = update_elements})
tracer_toggle:colorpicker({name = "Tracer Color", flag = "Tracer_Color", callback = update_elements})

esp_preview = window.esp_section:esp_preview({})

Aiming.open_tab()

-- init
library:config_list_update()
for index, value in themes.preset do
    pcall(function()
        library:update_theme(index, value)
    end)
end
task.wait()
library.old_config = library:get_config()

esp = loadstring(game:HttpGet(ESP_URL))()
esp:init({ flags = library.flags })
