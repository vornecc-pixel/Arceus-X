-- ═══════════════════════════════════════════════════════════════
-- UI MODULE
-- ═══════════════════════════════════════════════════════════════

local ESP_URL = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/main/esp.lua"

-- Assuming you uploaded the provided library code to library.lua on your repo
local library, themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/main/library.lua"))()

local dim2 = UDim2.new
local hex = Color3.fromHex

local window = library:window({name = os.date('Atlanta |  - %b %d %Y'), size = dim2(0, 750, 0, 782)})

local Aiming   = window:tab({name = "Aiming"})
local Misc     = window:tab({name = "Misc"})
local ESP      = window:tab({name = "ESP"}) 

-- ── Aiming tab ─────────────────────────────────────────────────
local aim_column = Aiming:column()
local selec, lock = aim_column:multi_section({names = {"Selection", "Lock"}})

selec:toggle({name = "Enabled", flag = "target_selected", tooltip = "Manages selection of the target"})
    :keybind({name = "Aiming", flag = "target_selected_bind"})
selec:toggle({name = "Auto Select", flag = "auto_select", tooltip = "Selects targets for you."})
selec:toggle({name = "Only Select Enemies", flag = "enemy_priority"})
selec:dropdown({name = "Origin", flag = "distance_priority", items = {"Mouse", "Distance"}, default = "Mouse"})
selec:slider({name = "Delay", min = 0, max = 1000, default = 40, interval = 1, suffix = "ms", flag = "target_selector_refresh_time"})
selec:toggle({name = "Wall Check", flag = "wall_check"})
selec:toggle({name = "Knocked Check", flag = "knocked_check"})
selec:toggle({name = "ForceField Check", flag = "forcefield_check"})
selec:toggle({name = "Distance Check", flag = "distance_check"})
lock:toggle({name = "Enabled", flag = "silent_aim"})
lock:toggle({name = "Auto Shoot", flag = "auto_shoot"})
lock:dropdown({name = "Aim Bone", flag = "silent_aim_bone", items = {"Hrp", "Head"}, default = "Head"})
lock:toggle({name = "Invisible Bullets", flag = "invis_bullet"})

local aim_vis_column = Aiming:column()
local vis_a, other_a = aim_vis_column:multi_section({names = {"Visuals", "Other"}})

other_a:toggle({name = "Look At", flag = "look_at"})
other_a:toggle({name = "Spectate", flag = "spectate"})
vis_a:toggle({name = "Tracer", flag = "snap_line"})
    :colorpicker({name = "Tracer Inline", flag = "snap_line_color", color = hex("#7D0DC3")})
    :colorpicker({flag = "Tracer Outline", color = hex("#000000")})
vis_a:slider({name = "Thickness", min = 1, max = 5, default = 1, interval = 1, suffix = "°", flag = "target_snap_line_thickness"})
vis_a:toggle({name = "Highlight", flag = "target_highlight"})
    :colorpicker({name = "Outline", flag = "target_highlight_settings", color = hex("#000000")})
    :colorpicker({name = "Fill", flag = "target_highlight_settings", color = hex("#000000")})
vis_a:toggle({name = "Field Of View", flag = "fov"})
    :colorpicker({name = "1st Color (Gradient)", flag = "fov_1_settings", color = hex("#7D0DC3"), alpha = 0.5})
    :colorpicker({name = "2nd Color (Gradient)", flag = "fov_2_settings", color = hex("#7D0DC3"), alpha = 0.5})
vis_a:toggle({name = "Outline", flag = "outline_fov"})
    :colorpicker({name = "1st Color (Gradient)", flag = "outline_fov_settings_1", color = hex("#000000"), alpha = 1})
    :colorpicker({name = "2nd Color (Gradient)", flag = "outline_fov_settings_2", color = hex("#000000"), alpha = 1})
vis_a:slider({name = "Radius", min = 0, max = 1000, default = 100, interval = 1, flag = "fov_radius"})
vis_a:slider({name = "Thickness", min = 0, max = 5, default = 1, interval = 1, flag = "outline_thickness_fov"})
vis_a:slider({name = "Custom Rotation", min = -180, max = 180, default = 0, interval = 1, flag = "custom_rotation_fov"})
vis_a:toggle({name = "Spin", flag = "spin_fov"})
vis_a:slider({name = "Rotation Speed", min = 0, max = 100, default = 100, interval = 1, flag = "spin_speed_fov"})
library.config_flags["fov"](false)

-- ── ESP tab ────────────────────────────────────────────────────
local esp
local esp_preview

local function update_elements()
    if esp and esp.refresh_elements then esp:refresh_elements() end
end

-- COLUMN 1: Main ESP Settings
local esp_column = ESP:column()
local section = esp_column:section({name = "Main ESP", toggle = false})

section:toggle({name = "Enabled", flag = "Enabled", callback = update_elements})
section:toggle({name = "Team Check", flag = "TeamCheck", callback = update_elements})
section:toggle({name = "Show Team", flag = "ShowTeam", callback = update_elements})
section:slider({name = "Max Distance", min = 100, max = 5000, default = 1000, interval = 50, flag = "MaxDistance", callback = update_elements})

section:toggle({name = "Box ESP", flag = "BoxESP", callback = update_elements})
section:dropdown({name = "Box Style", flag = "BoxStyle", items = {"Corner", "Full", "ThreeD"}, default = "Corner", callback = update_elements})

section:toggle({name = "Name ESP", flag = "NameESP", callback = update_elements})
    :colorpicker({name = "Name Color", flag = "NameColor", callback = update_elements})
section:toggle({name = "Show Distance", flag = "ShowDistance", callback = update_elements})
    :colorpicker({name = "Distance Color", flag = "DistanceColor", callback = update_elements})

section:toggle({name = "Health Bar", flag = "HealthESP", callback = update_elements})
section:dropdown({name = "Health Style", flag = "HealthStyle", items = {"Bar", "Text", "Both"}, default = "Bar", callback = update_elements})

section:toggle({name = "Tracer ESP", flag = "TracerESP", callback = update_elements})
section:dropdown({name = "Tracer Origin", flag = "TracerOrigin", items = {"Bottom", "Top", "Mouse", "Center"}, default = "Bottom", callback = update_elements})

-- COLUMN 2: Skeleton & Chams
esp_column = ESP:column()
local adv_section = esp_column:section({name = "Skeleton & Chams", toggle = false})

local skeleton_toggle = adv_section:toggle({name = "Skeleton ESP", flag = "SkeletonESP", callback = update_elements})
skeleton_toggle:colorpicker({name = "Skeleton Color", flag = "SkeletonColor", callback = update_elements})
adv_section:slider({name = "Skeleton Thickness", min = 0.5, max = 5, default = 1.5, interval = 0.1, flag = "SkeletonThickness", callback = update_elements})
adv_section:slider({name = "Skeleton Transparency", min = 0, max = 1, default = 1, interval = 0.1, flag = "SkeletonTransparency", callback = update_elements})

adv_section:toggle({name = "Enable Chams", flag = "ChamsEnabled", callback = update_elements})
local chams_fill = adv_section:colorpicker({name = "Chams Fill", flag = "ChamsFillColor", color = Color3.fromRGB(255,0,0), callback = update_elements})
local chams_outline = adv_section:colorpicker({name = "Chams Outline", flag = "ChamsOutlineColor", color = Color3.fromRGB(255,255,255), callback = update_elements})
adv_section:slider({name = "Chams Fill Transparency", min = 0, max = 1, default = 0.5, interval = 0.1, flag = "ChamsTransparency", callback = update_elements})
adv_section:slider({name = "Chams Outline Transparency", min = 0, max = 1, default = 0, interval = 0.1, flag = "ChamsOutlineTransparency", callback = update_elements})

-- COLUMN 3: Settings & Colors
esp_column = ESP:column()
local colors_section = esp_column:section({name = "Colors", toggle = false})

colors_section:colorpicker({name = "Enemy Color", flag = "EnemyColor", color = Color3.fromRGB(255,25,25), callback = update_elements})
colors_section:colorpicker({name = "Ally Color", flag = "AllyColor", color = Color3.fromRGB(25,255,25), callback = update_elements})
colors_section:colorpicker({name = "Health Color", flag = "HealthColor", color = Color3.fromRGB(0,255,0), callback = update_elements})

local effects_section = esp_column:section({name = "Effects & Performance", toggle = false})
effects_section:toggle({name = "Rainbow Mode", flag = "RainbowEnabled", callback = update_elements})
effects_section:dropdown({name = "Rainbow Parts", flag = "RainbowParts", items = {"All", "Box Only", "Tracers Only", "Text Only"}, default = "All", callback = function(val)
    raw_flags["RainbowBoxes"] = (val == "All" or val == "Box Only")
    raw_flags["RainbowTracers"] = (val == "All" or val == "Tracers Only")
    raw_flags["RainbowText"] = (val == "All" or val == "Text Only")
end})
effects_section:slider({name = "Refresh Rate", min = 30, max = 240, default = 144, interval = 10, flag = "RefreshRate", callback = update_elements})

-- The Fixed Unload Button
local unload_section = esp_column:section({name = "Danger Zone", toggle = false})
unload_section:button_holder({}) 
unload_section:button({name = "Destroy ESP", callback = function()
    -- 1. Unload the ESP module (stops the loop, clears drawings)
    if esp and esp.unload then
        esp:unload()
    end
    -- 2. Destroy the library UI safely
    for _, gui in library.guis do 
        gui:Destroy() 
    end 
    -- 3. Disconnect all library connections
    for _, connection in library.connections do 
        connection:Disconnect() 
    end
end})

-- ESP Preview
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
