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
local ESP      = window:tab({name = "ESP"}) -- Renamed from Visuals

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
    if esp and esp.refresh_elements then
        esp:refresh_elements()
    end
end

local esp_column = ESP:column()
local section = esp_column:section({name = "General", toggle = false})

section:toggle({name = "Enabled", flag = "Enabled", callback = update_elements})
section:slider({name = "Max Distance", min = 100, max = 5000, default = 1000, interval = 50, flag = "MaxDistance", callback = update_elements})
section:toggle({name = "Team Check", flag = "Team_Check", callback = update_elements})

local box_toggle = section:toggle({name = "Boxes", flag = "Boxes", callback = update_elements})
box_toggle:colorpicker({name = "Box Color", flag = "Box_Color", callback = update_elements})

local name_toggle = section:toggle({name = "Names", flag = "Names", callback = update_elements})
name_toggle:colorpicker({name = "Name Color", flag = "Name_Color", callback = update_elements})

local dist_toggle = section:toggle({name = "Distances", flag = "Distances", callback = update_elements})
dist_toggle:colorpicker({name = "Distance Color", flag = "Distance_Color", callback = update_elements})

local health_toggle = section:toggle({name = "Health Bars", flag = "HealthBars", callback = update_elements})
health_toggle:colorpicker({name = "Health Color", flag = "Health_Color", callback = update_elements})

local tracer_toggle = section:toggle({name = "Tracers", flag = "Tracers", callback = update_elements})
tracer_toggle:colorpicker({name = "Tracer Color", flag = "Tracer_Color", callback = update_elements})

local dot_toggle = section:toggle({name = "Head Dots", flag = "HeadDots", callback = update_elements})
dot_toggle:colorpicker({name = "Dot Color", flag = "Dot_Color", callback = update_elements})

local skeleton_toggle = section:toggle({name = "Skeletons", flag = "Skeleton", callback = update_elements})
skeleton_toggle:colorpicker({name = "Skeleton Color", flag = "Skeleton_Color", callback = update_elements})
section:toggle({name = "Skeleton on Team", flag = "SkeletonOnTeam", callback = update_elements})

esp_column = ESP:column()
local chams_section = esp_column:section({name = "Chams", toggle = false})

chams_section:toggle({name = "Enabled", flag = "Chams", callback = update_elements})
chams_section:toggle({name = "Chams on Team", flag = "ChamsOnTeam", callback = update_elements})

local vis_chams = chams_section:toggle({name = "Visible Chams", flag = "VisibleChams", callback = update_elements})
vis_chams:colorpicker({name = "Visible Color", flag = "Chams_Visible_Color", callback = update_elements})

local hid_chams = chams_section:toggle({name = "Hidden Chams", flag = "HiddenChams", callback = update_elements})
hid_chams:colorpicker({name = "Hidden Color", flag = "Chams_Hidden_Color", callback = update_elements})

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
