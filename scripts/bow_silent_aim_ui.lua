--[[
    ARC3USX bow silent aim — UI only (Octohook library).

    The features live in scripts/bow_silent_aim.lua and contain no UI; this file
    builds the menu and wires every control to that module. It is separate from
    scripts/silent_aim_ui.lua, which drives the gun silent aim.

    Run standalone:
        loadstring(game:HttpGet(ROOT .. "scripts/bow_silent_aim_ui.lua"))()

    Or inject both halves:
        local handle = loadstring(source)({ Library = octohookLibrary, BowSilentAim = featuresModule })
        handle.Destroy()
]]

local context = ...
if type(context) ~= "table" then context = nil end

local environment = type(getgenv) == "function" and getgenv() or _G
local BASE = type(environment.ARC3USX_RAW_ROOT) == "string"
    and environment.ARC3USX_RAW_ROOT
    or "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/d7cd4b6e-arceus-x/"
local FEATURES_URL = BASE .. "scripts/bow_silent_aim.lua"
local LIBRARY_URL = "https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/Octohook/Library.lua"

local StarterGui = game:GetService("StarterGui")

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Bow Silent Aim", Text = tostring(text), Duration = 5 })
    end)
end

local function isColor(value)
    if type(value) == "table" or type(value) == "userdata" then
        return value.R ~= nil and value.G ~= nil and value.B ~= nil
    end
    return false
end

------------------------------------------------------------------------
-- clean up a previous run (this library does not unload itself)
------------------------------------------------------------------------

local previous = environment.ARC3USX_BOW_SILENT_AIM_UI
if type(previous) == "table" and type(previous.Destroy) == "function" then
    pcall(previous.Destroy)
end
environment.ARC3USX_BOW_SILENT_AIM_UI = nil

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

local BowSilentAim = context and context.BowSilentAim or nil
if not BowSilentAim then
    local ok, result = pcall(function()
        local chunk = assert(loadstring(game:HttpGet(FEATURES_URL)))
        return chunk()
    end)
    if not ok or type(result) ~= "table" or type(result.new) ~= "function" then
        notify("Bow silent aim features failed to load: " .. tostring(result))
        if ownsLibrary then pcall(function() Library:Unload() end) end
        return nil, tostring(result)
    end
    BowSilentAim = result
end

local aim = BowSilentAim.new({ enabled = false })

------------------------------------------------------------------------
-- window
------------------------------------------------------------------------

local camera = workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local PANEL_WIDTH, PANEL_HEIGHT = 540, 680

local function centered(size)
    local x = math.max(0, math.floor((viewport.X - size.X) / 2))
    local y = math.max(0, math.floor((viewport.Y - size.Y) / 2))
    return UDim2.new(0, x, 0, y)
end

local Holder = Library:Window({ Name = "Bow Aim" })
local Window = Holder:Panel({
    Name = "Menu",
    ButtonName = "Menu",
    Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT),
    Position = centered(Vector2.new(PANEL_WIDTH, PANEL_HEIGHT)),
})

if type(Holder.ChangeMenuTitle) == "function" then
    pcall(function()
        Holder.ChangeMenuTitle(string.format("%s - bow aim - %s", Holder.Name or "Bow Aim", os.date("%b. %d %Y")))
    end)
end

local Tabs = {
    Aim = Window:Tab({ Name = "Aim" }),
    Exploits = Window:Tab({ Name = "Exploits" }),
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
    return section:Toggle({
        Name = name,
        Default = aim:Get(key) == true,
        Tooltip = tooltip,
        Callback = function(value) aim:Set(key, value) end,
    })
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
    local labelForValue, valueForLabel = {}, {}
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

local masterSection = left:Section({ Name = "Bow Silent Aim" })
local enabledToggle = toggle(masterSection, "Enabled", "enabled", {
    Title = "Bow Silent Aim",
    Text = "Rewrites the arrow payload so it flies at the picked target part.",
    Width = 240,
})

addOn(enabledToggle, masterSection, "Keybind", {
    Name = "Toggle Key",
    Mode = "Toggle",
    Key = Enum.KeyCode.J,
    Active = false,
    Callback = function(active) setToggleState(enabledToggle, active == true) end,
})

addOn(enabledToggle, masterSection, "Keybind", {
    Name = "Manual Shot Key",
    Mode = "Always",
    Key = Enum.KeyCode.E,
    Callback = function() pcall(function() aim:ManualShoot() end) end,
})

toggle(masterSection, "Aim Payload", "aimPayload", {
    Title = "Aim Payload",
    Text = "Off = do not touch dir/origin, the other payload options still apply.",
    Width = 220,
})

local targetSection = left:Section({ Name = "Targeting" })
slider(targetSection, "FOV Radius", "fov", 0, 800, 1, "px")
slider(targetSection, "Distance Limit", "distance", 0, 1000, 1, " (0 = off)")
dropdown(targetSection, "Target Part", "targetPart",
    { "Head", "Torso", "HumanoidRootPart", "Random" },
    { "Head", "Torso", "HumanoidRootPart", "Random" })
slider(targetSection, "Random Re-roll", "randomPartLifetime", 0.1, 5, 0.1, "s")

local filterSection = right:Section({ Name = "Filters" })
toggle(filterSection, "Wall Check", "wallCheck")
toggle(filterSection, "Team Check", "teamCheck")
toggle(filterSection, "Target NPCs", "targetNpcs")

local payloadSection = right:Section({ Name = "Payload" })
local chargeToggle = toggle(payloadSection, "Override Charge", "overrideCharge")
slider(payloadSection, "Charge", "chargeOverride", 0, 1, 0.05, "")
toggle(payloadSection, "Wallbang Origin", "wallbang")
slider(payloadSection, "Rapid Fire", "rapidFire", 1, 5, 1, " shots")
toggle(payloadSection, "Reuse Shot Id (probe)", "dedupeProbe")
toggle(payloadSection, "Force World Mode (probe)", "modeProbe")

------------------------------------------------------------------------
-- Exploits tab
------------------------------------------------------------------------

local exploitsTab = Tabs.Exploits
local exploitsLeft = exploitsTab:Column({})
local exploitsRight = exploitsTab:Column({})

local patchSection = exploitsLeft:Section({ Name = "Bow Patches" })
toggle(patchSection, "Instant Charge", "instaCharge")
toggle(patchSection, "No Client Fire Rate", "noClientRate")
toggle(patchSection, "Crossbow Always Loaded", "noReloadCrossbow")
toggle(patchSection, "Airborne Bypass", "airborneBypass")
addOn(patchSection, nil, "Label", { Name = "Patches need getgc tables; they revert when disabled." })

local ammoSection = exploitsLeft:Section({ Name = "Ammo" })
toggle(ammoSection, "Infinite Arrows", "infiniteArrows")
slider(ammoSection, "Arrow Count", "ammoAmount", 1, 99999, 1, "")

local fakeSection = exploitsRight:Section({ Name = "Fake Hits" })
toggle(fakeSection, "Fake Hits", "fakeHits")
slider(fakeSection, "Fake Damage", "fakeDamage", 1, 100000, 1, "")
dropdown(fakeSection, "Hit Region", "fakeRegion", { "head", "torso", "limb" }, { "head", "torso", "limb" })
toggle(fakeSection, "Request Kill", "fakeKill")
addOn(fakeSection, nil, "Label", { Name = "Only does anything if the game trusts client hit registration." })

------------------------------------------------------------------------
-- Visuals tab
------------------------------------------------------------------------

local visualsTab = Tabs.Visuals
local visualsLeft = visualsTab:Column({})

local fovSection = visualsLeft:Section({ Name = "FOV Circle" })
local showFovToggle = toggle(fovSection, "Show FOV", "showFov")
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
local statusLabel = addOn(infoSection, nil, "Label", { Name = "Off" })
local tableLabel = addOn(infoSection, nil, "Label", { Name = "Tables: --" })
local hookLabel = addOn(infoSection, nil, "Label", { Name = "Hook: --" })

------------------------------------------------------------------------
-- Settings tab
------------------------------------------------------------------------

local settingsTab = Tabs.Settings
local settingsColumn = settingsTab:Column({})
local helpSection = settingsColumn:Section({ Name = "Bow Silent Aim" })

addOn(helpSection, nil, "Label", { Name = "Features: bow_silent_aim.lua / UI: bow_silent_aim_ui.lua" })
addOn(helpSection, nil, "Label", { Name = "Separate from the gun silent aim in the Combat tab." })

local destroyed = false
local function destroy()
    if destroyed then return end
    destroyed = true
    pcall(function() aim:Unload() end)
    if ownsLibrary then pcall(function() Library:Unload() end) end
    if environment.ARC3USX_BOW_SILENT_AIM_UI and environment.ARC3USX_BOW_SILENT_AIM_UI.Destroy == destroy then
        environment.ARC3USX_BOW_SILENT_AIM_UI = nil
    end
end

addOn(helpSection, nil, "Button", { Name = "Unload Bow Aim", Callback = destroy })

pcall(function() Library:Configs(Holder, settingsTab) end)

------------------------------------------------------------------------
-- status loop
------------------------------------------------------------------------

task.spawn(function()
    while not destroyed do
        local status = aim:GetStatus()

        local text
        if not status.running then
            text = "Off"
        elseif status.target ~= "" then
            text = string.format("On -> %s (%d shots)", status.target, status.shots)
        else
            text = string.format("On - searching (%d shots)", status.shots)
        end

        if statusLabel and type(statusLabel.Set) == "function" then
            pcall(function() statusLabel:Set(text) end)
        end
        if tableLabel and type(tableLabel.Set) == "function" then
            pcall(function()
                tableLabel:Set(string.format("Tables: bow %s / draw %s / gun %s%s",
                    status.rows and "ok" or "--",
                    status.draw and "ok" or "--",
                    status.gun and "ok" or "--",
                    status.tableError and (" (" .. status.tableError .. ")") or ""))
            end)
        end
        if hookLabel and type(hookLabel.Set) == "function" then
            pcall(function()
                hookLabel:Set("Hook: " .. (status.hookInstalled and "installed" or tostring(status.hookError or "off")))
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
    BowSilentAim = BowSilentAim,
    Destroy = destroy,
    OwnsLibrary = ownsLibrary,
}
environment.ARC3USX_BOW_SILENT_AIM_UI = handle

notify("Bow aim menu loaded")

return handle
