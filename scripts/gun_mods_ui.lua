--[[
    ARC3USX gun mods — UI only (Octohook library).

    Features live in scripts/gun_mods.lua and contain no UI; this file builds the menu
    and wires every control to that module.

    Run standalone:
        loadstring(game:HttpGet(ROOT .. "scripts/gun_mods_ui.lua"))()

    Or inject both halves:
        local handle = loadstring(source)({ Library = octohookLibrary, GunMods = featuresModule })
        handle.Destroy()
]]

local context = ...
if type(context) ~= "table" then context = nil end

local environment = type(getgenv) == "function" and getgenv() or _G
local BASE = type(environment.ARC3USX_RAW_ROOT) == "string"
    and environment.ARC3USX_RAW_ROOT
    or "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/d7cd4b6e-arceus-x/"
local FEATURES_URL = BASE .. "scripts/gun_mods.lua"
local LIBRARY_URL = "https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/Octohook/Library.lua"

local StarterGui = game:GetService("StarterGui")

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Mods", Text = tostring(text), Duration = 5 })
    end)
end

------------------------------------------------------------------------
-- clean up a previous run
------------------------------------------------------------------------

local previous = environment.ARC3USX_GUN_MODS_UI
if type(previous) == "table" and type(previous.Destroy) == "function" then
    pcall(previous.Destroy)
end
environment.ARC3USX_GUN_MODS_UI = nil

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

local GunMods = context and context.GunMods or nil
if not GunMods then
    local ok, result = pcall(function()
        local chunk = assert(loadstring(game:HttpGet(FEATURES_URL)))
        return chunk()
    end)
    if not ok or type(result) ~= "table" or type(result.new) ~= "function" then
        notify("Gun mods features failed to load: " .. tostring(result))
        if ownsLibrary then pcall(function() Library:Unload() end) end
        return nil, tostring(result)
    end
    GunMods = result
end

local mods = GunMods.new({ enabled = false })

------------------------------------------------------------------------
-- window
------------------------------------------------------------------------

local camera = workspace.CurrentCamera
local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
local PANEL_WIDTH, PANEL_HEIGHT = 500, 560

local function centered(size)
    local x = math.max(0, math.floor((viewport.X - size.X) / 2))
    local y = math.max(0, math.floor((viewport.Y - size.Y) / 2))
    return UDim2.new(0, x, 0, y)
end

local Holder = Library:Window({ Name = "Mods" })
local Window = Holder:Panel({
    Name = "Menu",
    ButtonName = "Menu",
    Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT),
    Position = centered(Vector2.new(PANEL_WIDTH, PANEL_HEIGHT)),
})

if type(Holder.ChangeMenuTitle) == "function" then
    pcall(function()
        Holder.ChangeMenuTitle(string.format("%s - gun mods - %s", Holder.Name or "Mods", os.date("%b. %d %Y")))
    end)
end

local Tabs = {
    Mods = Window:Tab({ Name = "Mods" }),
    Settings = Window:Tab({ Name = "Settings" }),
}

------------------------------------------------------------------------
-- control helpers
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
        Default = mods:Get(key) == true,
        Tooltip = tooltip,
        Callback = function(value) mods:Set(key, value) end,
    })
end

local function slider(section, name, key, minimum, maximum, step, suffix)
    local value = mods:Get(key)
    if type(value) ~= "number" then value = minimum end
    return section:Slider({
        Name = name,
        Min = minimum,
        Max = maximum,
        Decimal = step or 1,
        Default = value,
        Suffix = suffix,
        Callback = function(newValue) mods:Set(key, newValue) end,
    })
end

local function setToggleState(element, value)
    if not element then return end
    if element.Enabled == value then return end
    element.Enabled = value
    if type(element.Set) == "function" then pcall(function() element:Set(value) end) end
end

------------------------------------------------------------------------
-- Mods tab
------------------------------------------------------------------------

local modsTab = Tabs.Mods
local left = modsTab:Column({})
local right = modsTab:Column({})

local masterSection = left:Section({ Name = "Gun Mods" })
local enabledToggle = toggle(masterSection, "Enabled", "enabled", {
    Title = "Gun Mods",
    Text = "Cancels camera recoil and the crosshair bloom, both client-side.",
    Width = 200,
})

addOn(enabledToggle, masterSection, "Keybind", {
    Name = "Toggle Key",
    Mode = "Toggle",
    Key = Enum.KeyCode.N,
    Active = false,
    Callback = function(active) setToggleState(enabledToggle, active == true) end,
})

local recoilSection = left:Section({ Name = "No Recoil" })
local recoilToggle = toggle(recoilSection, "Enabled", "noRecoil", {
    Title = "No Recoil",
    Text = "Restores the mouse-driven pitch/yaw every frame, cancelling the kick.",
    Width = 200,
})
slider(recoilSection, "Mouse Grace", "recoilGrace", 0, 0.5, 0.005, "s")
slider(recoilSection, "Pitch Tolerance", "recoilPitchEps", 0, 0.05, 0.0005, "rad")
slider(recoilSection, "Yaw Tolerance", "recoilYawEps", 0, 0.05, 0.0005, "rad")
addOn(recoilSection, nil, "Label", { Name = "Higher grace = smoother aim, lower = stronger lock." })

local bloomSection = right:Section({ Name = "Crosshair" })
local bloomToggle = toggle(bloomSection, "No Bloom", "noBloom", {
    Title = "No Bloom",
    Text = "Hides the FustGather spread ticks. Server spread is unchanged.",
    Width = 200,
})
slider(bloomSection, "Sweep Rate", "bloomRate", 0.05, 1, 0.05, "s")
addOn(bloomSection, nil, "Label", { Name = "Bullet spread itself is server-side; only the visuals change." })

local spreadSection = right:Section({ Name = "Spread Payload" })
local spreadToggle = toggle(spreadSection, "Zero Spread Fields", "zeroSpread", {
    Title = "<font color = '#FFFF00'>WARNING</font>",
    Text = "Needs executor hook functions.\nZeroes spread/bloom numbers in Fust remote payloads.\nMay be detected.",
    Width = 220,
})
addOn(spreadSection, nil, "Label", { Name = "Hooks the RemoteEvent namecall once and restores it on unload." })

------------------------------------------------------------------------
-- Settings tab
------------------------------------------------------------------------

local settingsTab = Tabs.Settings
local settingsColumn = settingsTab:Column({})
local statusSection = settingsColumn:Section({ Name = "Status" })
local recoilLabel = addOn(statusSection, nil, "Label", { Name = "Recoil: -" })
local bloomLabel = addOn(statusSection, nil, "Label", { Name = "Bloom: -" })
local hookLabel = addOn(statusSection, nil, "Label", { Name = "Hook: -" })

local destroyed = false

local function destroy()
    if destroyed then return end
    destroyed = true
    pcall(function() mods:Unload() end)
    if ownsLibrary then pcall(function() Library:Unload() end) end
    if environment.ARC3USX_GUN_MODS_UI and environment.ARC3USX_GUN_MODS_UI.Destroy == destroy then
        environment.ARC3USX_GUN_MODS_UI = nil
    end
end

addOn(statusSection, nil, "Button", { Name = "Unload Mods", Callback = destroy })

pcall(function() Library:Configs(Holder, settingsTab) end)

------------------------------------------------------------------------
-- status loop
------------------------------------------------------------------------

task.spawn(function()
    while not destroyed do
        local status = mods:GetStatus()

        if recoilLabel and type(recoilLabel.Set) == "function" then
            pcall(function()
                recoilLabel:Set(string.format("Recoil: %s (%d cancelled)",
                    status.running and status.noRecoil and "on" or "off", status.recoilUndos))
            end)
        end
        if bloomLabel and type(bloomLabel.Set) == "function" then
            pcall(function()
                bloomLabel:Set(string.format("Bloom: %s (%d ticks hidden)",
                    status.running and status.noBloom and "on" or "off", status.bloomHidden))
            end)
        end
        if hookLabel and type(hookLabel.Set) == "function" then
            pcall(function()
                local text
                if not status.zeroSpread then
                    text = "Hook: off"
                elseif status.hookInstalled then
                    text = "Hook: installed"
                else
                    text = "Hook: " .. tostring(status.hookError or "not installed")
                end
                hookLabel:Set(text)
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
    Mods = mods,
    GunMods = GunMods,
    Destroy = destroy,
    OwnsLibrary = ownsLibrary,
}
environment.ARC3USX_GUN_MODS_UI = handle

notify("Mods menu loaded")

return handle
