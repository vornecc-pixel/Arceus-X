-- ═══════════════════════════════════════════════════════════════
-- MAIN SCRIPT (Atlanta UI + i77lhm's Official ESP)
-- ═══════════════════════════════════════════════════════════════

local ESP_LIB_URL = "https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/ESP/Library.lua"

local library, themes = loadstring(game:HttpGet("https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/Atlanta/Library.lua"))()

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
local ESP_Features = loadstring(game:HttpGet(ESP_LIB_URL))()

local esp_column = ESP:column()
local main_section = esp_column:section({name = "Main ESP", toggle = false})

-- This table maps YOUR UI flags to i77lhm's ESP flags
local esp_config = {
    Enabled = "Enabled",
    Names = "Names",
    Name_Color = "Name_Color",
    Boxes = "Boxes",
    Box_Type = "Box_Type",
    Box_Color = "Box_Color",
    Healthbar = "Healthbar",
    Health_High = "Health_High",
    Health_Low = "Health_Low",
    Distance = "Distance",
    Distance_Color = "Distance_Color",
    Weapon = "Weapon",
    Weapon_Color = "Weapon_Color",
    Skeletons = "Skeletons",
    Skeletons_Color = "Skeletons_Color"
}

main_section:toggle({name = "Enabled", flag = esp_config.Enabled, callback = function()
    ESP_Features:Update(library.flags)
end})

main_section:toggle({name = "Names", flag = esp_config.Names, callback = function()
    ESP_Features:Update(library.flags)
end})
    :colorpicker({flag = esp_config.Name_Color, callback = function()
        ESP_Features:Update(library.flags)
    end})

local box_toggle = main_section:toggle({name = "Boxes", flag = esp_config.Boxes, callback = function()
    ESP_Features:Update(library.flags)
end})
main_section:dropdown({name = "Box Type", flag = esp_config.Box_Type, items = {"Corner", "Full"}, default = "Corner", callback = function()
    ESP_Features:Update(library.flags)
end})
box_toggle:colorpicker({name = "Box Color", flag = esp_config.Box_Color, callback = function()
    ESP_Features:Update(library.flags)
end})

local health_toggle = main_section:toggle({name = "Healthbar", flag = esp_config.Healthbar, callback = function()
    ESP_Features:Update(library.flags)
end})
health_toggle:colorpicker({name = "High HP Color", flag = esp_config.Health_High, callback = function()
    ESP_Features:Update(library.flags)
end})
health_toggle:colorpicker({name = "Low HP Color", flag = esp_config.Health_Low, callback = function()
    ESP_Features:Update(library.flags)
end})

main_section:toggle({name = "Distance", flag = esp_config.Distance, callback = function()
    ESP_Features:Update(library.flags)
end})
    :colorpicker({name = "Distance Color", flag = esp_config.Distance_Color, callback = function()
        ESP_Features:Update(library.flags)
    end})

main_section:toggle({name = "Weapon", flag = esp_config.Weapon, callback = function()
    ESP_Features:Update(library.flags)
end})
    :colorpicker({name = "Weapon Color", flag = esp_config.Weapon_Color, callback = function()
        ESP_Features:Update(library.flags)
    end})

main_section:toggle({name = "Skeletons", flag = esp_config.Skeletons, callback = function()
    ESP_Features:Update(library.flags)
end})
    :colorpicker({name = "Skeleton Color", flag = esp_config.Skeletons_Color, callback = function()
        ESP_Features:Update(library.flags)
    end})

-- Init ESP
ESP_Features:Init(library.flags)

-- Unload button
local unload_section = esp_column:section({name = "Danger Zone", toggle = false})
unload_section:button_holder({}) 
unload_section:button({name = "Destroy ESP", callback = function()
    ESP_Features:Unload()
    for _, gui in library.guis do gui:Destroy() end 
    for _, connection in library.connections do connection:Disconnect() end
end})

Aiming.open_tab()

-- init
library:config_list_update()
for index, value in themes.preset do
    pcall(function() library:update_theme(index, value) end)
end
task.wait()
library.old_config = library:get_config()
