--[[
    ARC3USX silent aim — UI only (Octohook library).

    The features live in scripts/silent_aim.lua and contain no UI at all; this file
    builds the menu and wires every control to that module. Nothing here touches the
    camera, the target list or the Drawing API directly.

    Run standalone:
        loadstring(game:HttpGet(ROOT .. "scripts/silent_aim_ui.lua"))()

    Or inject both halves (used by scripts/main.lua and the mock tests):
        local handle = loadstring(source)({ Library = octohookLibrary, SilentAim = featuresModule })
        handle.Destroy()

    Re-executing the script destroys the previous menu first: the library has an
    unload function but does not unload itself when the script runs again.
]]

local context = ...
if type(context) ~= "table" then context = nil end

local environment = type(getgenv) == "function" and getgenv() or _G
local BASE = type(environment.ARC3USX_RAW_ROOT) == "string"
    and environment.ARC3USX_RAW_ROOT
    or "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/d7cd4b6e-arceus-x/"
local FEATURES_URL = BASE .. "scripts/silent_aim.lua"
local LIBRARY_URL = "https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/Octohook/Library.lua"

local StarterGui = game:GetService("StarterGui")

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Silent Aim", Text = tostring(text), Duration = 5 })
    end)
end

local function isColor(value)
    if type(value) == "table" or type(value) == "userdata" then
        return value.R ~= nil and value.G ~= nil and value.B ~= nil
    end
    return false
end

------------------------------------------------------------------------
-- clean up a previous run (no auto-unload in this library)
------------------------------------------------------------------------

local previous = environment.ARC3USX_SILENT_AIM_UI
if type(previous) == "table" and type(previous.Destroy) == "function" then
    pcall(previous.Destroy)
end
environment.ARC3USX_SILENT_AIM_UI = nil

------------------------------------------------------------------------
-- modules
------------------------------------------------------------------------

local ownsLibrary, Library = false, context and context.Library or nil
if not Library then
    local ok, result = pcall(function()
        local chunk = assert(loadstring(game:HttpGet(LIBRARY_URL)))
        return chunk()
    end)
    if not ok or type(result) ~= "table" then
        notify("Octohook library failed to load: " .. tostring(result))
        return nil, tostring(result)
    end
    Library = result
    ownsLibrary = true
end

local SilentAim = context and context.SilentAim or nil
if not SilentAim then
    local ok, result = pcall(function()
        local chunk = assert(loadstring(game:HttpGet(FEATURES_URL)))
        return chunk()
    end)
    if not ok or type(result) ~= "table" or type(result.new) ~= "function" then
        notify("Silent aim features failed to load: " .. tostring(result))
        if ownsLibrary then pcall(function() Library:Unload() end) end
        return nil, tostring(result)
    end
    SilentAim = result
end

local aim = SilentAim.new({ enabled = false }) -- starts its render steps the moment it is enabled

------------------------------------------------------------------------
-- window
------------------------------------------------------------------------

local camera = workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local PANEL_WIDTH, PANEL_HEIGHT = 520, 660

local function centered(size)
    local x = math.max(0, math.floor((viewport.X - size.X) / 2))
    local y = math.max(0, math.floor((viewport.Y - size.Y) / 2))
    return UDim2.new(0, x, 0, y)
end

local Holder = Library:Window({ Name = "Silent Aim" })
local Window = Holder:Panel({
    Name = "Menu",
    ButtonName = "Menu",
    Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT),
    Position = centered(Vector2.new(PANEL_WIDTH, PANEL_HEIGHT)),
})

if type(Holder.ChangeMenuTitle) == "function" then
    pcall(function()
        Holder.ChangeMenuTitle(string.format("%s - silent aim - %s", Holder.Name or "Silent Aim", os.date("%b. %d %Y")))
    end)
end

local Tabs = {
    Aim = Window:Tab({ Name = "Aim" }),
    Visuals = Window:Tab({ Name = "Visuals" }),
    Settings = Window:Tab({ Name = "Settings" }),
}

------------------------------------------------------------------------
-- control helpers: every control writes straight into the feature module
------------------------------------------------------------------------

local function addOn(primary, fallback, method, args)
    if primary and type(primary[method]) == "function" then
        local ok, result = pcall(function() return primary[method](primary, args) end)
        if ok and result ~= nil then return result end
    end
    if fallback and type(fallback[method]) == "function" then
        local ok, result = pcall(function() return fallback[method](fallback, args) end)
        if ok and result ~= nil then return result end
    end
    return nil
end

local function toggle(section, name, key, tooltip)
    local element = section:Toggle({
        Name = name,
        Default = aim:Get(key) == true,
        Tooltip = tooltip,
        Callback = function(value) aim:Set(key, value) end,
    })
    return element
end

local function slider(section, name, key, minimum, maximum, step, suffix)
    local value = aim:Get(key)
    if type(value) ~= "number" then value = minimum end
    return section:Slider({
        Name = name,
        Min = minimum,
        Max = maximum,
        Decimal = step or 1,
        Default = value,
        Suffix = suffix,
        Callback = function(newValue) aim:Set(key, newValue) end,
    })
end

local function dropdown(section, name, key, labels, values)
    local current = aim:Get(key)
    local labelForValue = {}
    local valueForLabel = {}
    for index, value in ipairs(values) do
        labelForValue[value] = labels[index]
        valueForLabel[labels[index]] = value
    end

    return section:Dropdown({
        Name = name,
        Options = labels,
        Default = labelForValue[current] or labels[1],
        Multi = false,
        Callback = function(option)
            if type(option) == "table" then option = option[1] end
            local mapped = valueForLabel[option]
            if mapped then aim:Set(key, mapped) end
        end,
    })
end

local function setToggleState(element, value)
    if not element then return end
    if element.Enabled == value then return end
    element.Enabled = value
    if type(element.Set) == "function" then pcall(function() element:Set(value) end) end
end

------------------------------------------------------------------------
-- Aim tab
------------------------------------------------------------------------

local aimTab = Tabs.Aim
local left = aimTab:Column({})
local right = aimTab:Column({})

local masterSection = left:Section({ Name = "Silent Aim" })
local enabledToggle = toggle(masterSection, "Enabled", "enabled", {
    Title = "Silent Aim",
    Text = "Snaps the camera to the closest target for the frame the shot is fired.",
    Width = 200,
})

addOn(enabledToggle, masterSection, "Keybind", {
    Name = "Toggle Key",
    Mode = "Toggle",
    Key = Enum.KeyCode.V,
    Active = false,
    Callback = function(active)
        setToggleState(enabledToggle, active == true)
        -- "Toggle" activation keeps its own armed state; the keybind drives it too.
        if aim:Get("activation") == "Toggle" then aim:SetActive(active == true) end
    end,
})

dropdown(masterSection, "Activation", "activation",
    { "Always", "Hold (RMB)", "Toggle (Key)" },
    { "Always", "Hold", "Toggle" })

local onlyWhileFiring = toggle(masterSection, "Only While Firing (LMB)", "shotOnly")
local predictionToggle = toggle(masterSection, "Prediction", "prediction")

local targetSection = left:Section({ Name = "Targeting" })
slider(targetSection, "Hit Chance", "hitChance", 0, 100, 1, "%")
slider(targetSection, "FOV Radius", "fov", 0, 800, 1, "px")
slider(targetSection, "Distance Limit", "distance", 0, 1000, 1, " (0 = off)")
dropdown(targetSection, "Target Bone", "bone", { "Head", "HumanoidRootPart" }, { "Head", "HumanoidRootPart" })

local filterSection = right:Section({ Name = "Filters" })
local wallToggle = toggle(filterSection, "Wall Check", "wallCheck")
local teamToggle = toggle(filterSection, "Team Check", "teamCheck")
local npcToggle = toggle(filterSection, "Target NPCs", "targetNpcs")

local gunSection = right:Section({ Name = "Gun" })
slider(gunSection, "Bullet Speed Override", "gunSpeed", 0, 6000, 10, " (0 = per gun)")
slider(gunSection, "Snap Cooldown", "cooldown", 0, 1, 0.05, "s")

------------------------------------------------------------------------
-- Visuals tab
------------------------------------------------------------------------

local visualsTab = Tabs.Visuals
local visualsLeft = visualsTab:Column({})

local fovSection = visualsLeft:Section({ Name = "FOV Circle" })
local showFovToggle = toggle(fovSection, "Visualize FOV", "showFov")
addOn(showFovToggle, fovSection, "Colorpicker", {
    Color = aim:Get("fovColor"),
    Alpha = 1,
    Callback = function(first, second)
        local color = isColor(first) and first or (isColor(second) and second or nil)
        if color then aim:Set("fovColor", color) end
    end,
})

toggle(fovSection, "Filled Circle", "fovFilled")
slider(fovSection, "Thickness", "fovThickness", 1, 5, 1, "px")
slider(fovSection, "Transparency", "fovTransparency", 0, 100, 1, "%")

local infoSection = visualsTab:Column({}):Section({ Name = "Status" })
local statusLabel = addOn(infoSection, nil, "Label", { Name = "Idle" })
local gunLabel = addOn(infoSection, nil, "Label", { Name = "Gun: none" })

------------------------------------------------------------------------
-- Settings tab
------------------------------------------------------------------------

local settingsTab = Tabs.Settings
local settingsColumn = settingsTab:Column({})
local helpSection = settingsColumn:Section({ Name = "Silent Aim" })

addOn(helpSection, nil, "Label", { Name = "Features: silent_aim.lua / UI: silent_aim_ui.lua" })
addOn(helpSection, nil, "Label", { Name = "Toggle key flips the feature while in Toggle mode." })

local destroyed = false
local function destroy()
    if destroyed then return end
    destroyed = true
    pcall(function() aim:Unload() end)
    if ownsLibrary then pcall(function() Library:Unload() end) end
    if environment.ARC3USX_SILENT_AIM_UI and environment.ARC3USX_SILENT_AIM_UI.Destroy == destroy then
        environment.ARC3USX_SILENT_AIM_UI = nil
    end
end

addOn(helpSection, nil, "Button", { Name = "Unload Silent Aim", Callback = destroy })

pcall(function() Library:Configs(Holder, settingsTab) end)

------------------------------------------------------------------------
-- status loop
------------------------------------------------------------------------

local statusLoop = task.spawn(function()
    while not destroyed do
        local status = aim:GetStatus()
        local text
        if not status.enabled then
            text = "Off"
        elseif status.target ~= "" then
            text = string.format("%s -> %s", status.activation, status.target)
        elseif status.armed then
            text = string.format("%s - searching", status.activation)
        else
            text = string.format("%s - idle", status.activation)
        end

        if statusLabel and type(statusLabel.Set) == "function" then
            pcall(function() statusLabel:Set(text) end)
        end
        if gunLabel and type(gunLabel.Set) == "function" then
            pcall(function()
                gunLabel:Set(string.format("Gun: %s (%d)", tostring(status.gun or "none"), status.gunSpeed))
            end)
        end

        task.wait(0.5)
    end
end)

local handle = {
    Library = Library,
    Holder = Holder,
    Window = Window,
    Tabs = Tabs,
    Aim = aim,
    SilentAim = SilentAim,
    Destroy = destroy,
    OwnsLibrary = ownsLibrary,
}
environment.ARC3USX_SILENT_AIM_UI = handle

notify("Silent aim menu loaded")

return handle
