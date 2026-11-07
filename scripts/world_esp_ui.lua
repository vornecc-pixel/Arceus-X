--[[
    ARC3USX chams ESP — UI only (Octohook library).

    Features live in scripts/world_esp.lua and contain no UI; this file builds the
    menu and wires every control to that module. Nothing here draws in the world.

    Run standalone:
        loadstring(game:HttpGet(ROOT .. "scripts/world_esp_ui.lua"))()

    Or inject both halves:
        local handle = loadstring(source)({ Library = octohookLibrary, WorldESP = featuresModule })
        handle.Destroy()

    Re-executing destroys the previous menu first: the library has an unload function
    but does not unload itself when the script runs again.
]]

local context = ...
if type(context) ~= "table" then context = nil end

local environment = type(getgenv) == "function" and getgenv() or _G
local BASE = type(environment.ARC3USX_RAW_ROOT) == "string"
    and environment.ARC3USX_RAW_ROOT
    or "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/d7cd4b6e-arceus-x/"
local FEATURES_URL = BASE .. "scripts/world_esp.lua"
local LIBRARY_URL = "https://raw.githubusercontent.com/i77lhm/Libraries/refs/heads/main/Octohook/Library.lua"

local StarterGui = game:GetService("StarterGui")

local function notify(text)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Chams ESP", Text = tostring(text), Duration = 5 })
    end)
end

local function isColor(value)
    if type(value) == "table" or type(value) == "userdata" then
        return value.R ~= nil and value.G ~= nil and value.B ~= nil
    end
    return false
end

------------------------------------------------------------------------
-- clean up a previous run
------------------------------------------------------------------------

local previous = environment.ARC3USX_WORLD_ESP_UI
if type(previous) == "table" and type(previous.Destroy) == "function" then
    pcall(previous.Destroy)
end
environment.ARC3USX_WORLD_ESP_UI = nil

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

local WorldESP = context and context.WorldESP or nil
if not WorldESP then
    local ok, result = pcall(function()
        local chunk = assert(loadstring(game:HttpGet(FEATURES_URL)))
        return chunk()
    end)
    if not ok or type(result) ~= "table" or type(result.new) ~= "function" then
        notify("Chams ESP features failed to load: " .. tostring(result))
        if ownsLibrary then pcall(function() Library:Unload() end) end
        return nil, tostring(result)
    end
    WorldESP = result
end

local esp = WorldESP.new({ enabled = false })

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

local Holder = Library:Window({ Name = "Chams ESP" })
local Window = Holder:Panel({
    Name = "Menu",
    ButtonName = "Menu",
    Size = UDim2.fromOffset(PANEL_WIDTH, PANEL_HEIGHT),
    Position = centered(Vector2.new(PANEL_WIDTH, PANEL_HEIGHT)),
})

if type(Holder.ChangeMenuTitle) == "function" then
    pcall(function()
        Holder.ChangeMenuTitle(string.format("%s - chams esp - %s", Holder.Name or "Chams ESP", os.date("%b. %d %Y")))
    end)
end

local Tabs = {
    Targets = Window:Tab({ Name = "Targets" }),
    Visuals = Window:Tab({ Name = "Visuals" }),
    Colors = Window:Tab({ Name = "Colors" }),
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
        Default = esp:Get(key) == true,
        Tooltip = tooltip,
        Callback = function(value) esp:Set(key, value) end,
    })
end

local function slider(section, name, key, minimum, maximum, step, suffix)
    local value = esp:Get(key)
    if type(value) ~= "number" then value = minimum end
    return section:Slider({
        Name = name,
        Min = minimum,
        Max = maximum,
        Decimal = step or 1,
        Default = value,
        Suffix = suffix,
        Callback = function(newValue) esp:Set(key, newValue) end,
    })
end

local function dropdown(section, name, key, labels, values)
    local current = esp:Get(key)
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
            if mapped then esp:Set(key, mapped) end
        end,
    })
end

local function colorpicker(section, name, key)
    return addOn(section, nil, "Colorpicker", {
        Name = name,
        Color = esp:Get(key),
        Alpha = 1,
        Callback = function(first, second)
            local color = isColor(first) and first or (isColor(second) and second or nil)
            if color then esp:Set(key, color) end
        end,
    })
end

local function textbox(section, name, key, placeholder)
    return addOn(section, nil, "Textbox", {
        Name = name,
        Default = esp:Get(key),
        PlaceHolder = placeholder,
        Callback = function(value) esp:Set(key, value) end,
    })
end

local function setToggleState(element, value)
    if not element then return end
    if element.Enabled == value then return end
    element.Enabled = value
    if type(element.Set) == "function" then pcall(function() element:Set(value) end) end
end

------------------------------------------------------------------------
-- Targets tab
------------------------------------------------------------------------

local targetsTab = Tabs.Targets
local targetsLeft = targetsTab:Column({})
local targetsRight = targetsTab:Column({})

local masterSection = targetsLeft:Section({ Name = "Chams ESP" })
local enabledToggle = toggle(masterSection, "Enabled", "enabled", {
    Title = "Chams ESP",
    Text = "Boxes, skeletons and chams for players, NPCs and resource nodes.",
    Width = 200,
})

addOn(enabledToggle, masterSection, "Keybind", {
    Name = "Toggle Key",
    Mode = "Toggle",
    Key = Enum.KeyCode.B,
    Active = false,
    Callback = function(active) setToggleState(enabledToggle, active == true) end,
})

local categorySection = targetsLeft:Section({ Name = "Categories" })
toggle(categorySection, "Players", "players")
toggle(categorySection, "NPCs", "npcs")
toggle(categorySection, "Resource Nodes", "nodes")

local filterSection = targetsRight:Section({ Name = "Filters" })
slider(filterSection, "Max Distance", "maxDistance", 0, 2000, 10, " (0 = off)")
slider(filterSection, "Update Rate", "updateRate", 0, 60, 1, " Hz (0 = every frame)")

local whitelistSection = targetsRight:Section({ Name = "Whitelists" })
textbox(whitelistSection, "NPC Names", "npcWhitelist", "Guard, Soldier")
textbox(whitelistSection, "Node Names", "nodeWhitelist", "MetalNode, Tree")
addOn(whitelistSection, nil, "Label", { Name = "Comma separated. Models with the Scavenger attribute also count as NPCs." })

------------------------------------------------------------------------
-- Visuals tab
------------------------------------------------------------------------

local visualsTab = Tabs.Visuals
local visualsLeft = visualsTab:Column({})
local visualsRight = visualsTab:Column({})

local elementSection = visualsLeft:Section({ Name = "Elements" })
toggle(elementSection, "Chams (highlight)", "chams")
toggle(elementSection, "Occluded Chams (visible check)", "chamsVisibleCheck",
    { Title = "Visible Check", Text = "Targets behind walls use the occluded cham colour.", Width = 220 })
toggle(elementSection, "Skeleton", "skeleton")
toggle(elementSection, "Health Bar", "healthBar")
toggle(elementSection, "Name", "name")
toggle(elementSection, "Distance", "distance")
toggle(elementSection, "Weapon", "weapon")

local chamsSection = visualsRight:Section({ Name = "Chams" })
slider(chamsSection, "Fill Transparency", "chamsFillTransparency", 0, 1, 0.05, "")
slider(chamsSection, "Outline Transparency", "chamsOutlineTransparency", 0, 1, 0.05, "")
addOn(chamsSection, nil, "Label", { Name = "Nodes are drawn as a dot, name and distance only." })

local boxSection = visualsRight:Section({ Name = "Box" })
dropdown(boxSection, "Box Mode", "boxMode", { "Corners", "Full" }, { "corners", "full" })
slider(boxSection, "Corner Size", "cornerFraction", 0.05, 1, 0.05, "x")
slider(boxSection, "Box Thickness", "boxThickness", 1, 4, 1, "px")
slider(boxSection, "Skeleton Thickness", "skelThickness", 1, 4, 1, "px")
slider(boxSection, "Text Size", "textSize", 8, 24, 1, "px")
slider(boxSection, "Studs Per Meter", "studsPerMeter", 0.5, 20, 0.001, "")
slider(boxSection, "Node Dot Size", "nodeDotSize", 1, 16, 1, "px")

------------------------------------------------------------------------
-- Colors tab
------------------------------------------------------------------------

local colorsTab = Tabs.Colors
local colorsLeft = colorsTab:Column({})
local colorsRight = colorsTab:Column({})

local playerColors = colorsLeft:Section({ Name = "Players" })
colorpicker(playerColors, "Box", "playerBoxColor")
colorpicker(playerColors, "Skeleton", "playerSkelColor")
colorpicker(playerColors, "Name", "playerNameColor")
colorpicker(playerColors, "Chams - Visible", "playerChamColor")
colorpicker(playerColors, "Chams - Occluded", "playerChamOccludedColor")

local npcColors = colorsLeft:Section({ Name = "NPCs" })
colorpicker(npcColors, "Box", "npcBoxColor")
colorpicker(npcColors, "Skeleton", "npcSkelColor")
colorpicker(npcColors, "Name", "npcNameColor")
colorpicker(npcColors, "Chams - Visible", "npcChamColor")
colorpicker(npcColors, "Chams - Occluded", "npcChamOccludedColor")

local nodeColors = colorsRight:Section({ Name = "Resource Nodes" })
colorpicker(nodeColors, "Dot", "nodeDotColor")
colorpicker(nodeColors, "Name / Distance", "nodeNameColor")
addOn(nodeColors, nil, "Label", { Name = "Nodes use a dot plus name and distance; no box or highlight." })

------------------------------------------------------------------------
-- Settings tab
------------------------------------------------------------------------

local settingsTab = Tabs.Settings
local settingsColumn = settingsTab:Column({})
local statusSection = settingsColumn:Section({ Name = "Status" })
local statusLabel = addOn(statusSection, nil, "Label", { Name = "Idle" })
local countsLabel = addOn(statusSection, nil, "Label", { Name = "0 tracked" })

local destroyed = false

local function destroy()
    if destroyed then return end
    destroyed = true
    pcall(function() esp:Unload() end)
    if ownsLibrary then pcall(function() Library:Unload() end) end
    if environment.ARC3USX_WORLD_ESP_UI and environment.ARC3USX_WORLD_ESP_UI.Destroy == destroy then
        environment.ARC3USX_WORLD_ESP_UI = nil
    end
end

addOn(statusSection, nil, "Button", { Name = "Unload Chams ESP", Callback = destroy })

pcall(function() Library:Configs(Holder, settingsTab) end)

------------------------------------------------------------------------
-- status loop
------------------------------------------------------------------------

task.spawn(function()
    while not destroyed do
        local status = esp:GetStatus()
        local text
        if not status.enabled then
            text = "Off"
        elseif not status.supported then
            text = "Drawing API unavailable"
        else
            text = string.format("On - %d player(s), %d NPC(s), %d node(s)", status.players, status.npcs, status.nodes)
        end

        if statusLabel and type(statusLabel.Set) == "function" then
            pcall(function() statusLabel:Set(text) end)
        end
        if countsLabel and type(countsLabel.Set) == "function" then
            pcall(function() countsLabel:Set(string.format("%d tracked", status.tracked)) end)
        end

        task.wait(0.5)
    end
end)

local handle = {
    Library = Library,
    Holder = Holder,
    Window = Window,
    Tabs = Tabs,
    Esp = esp,
    WorldESP = WorldESP,
    Destroy = destroy,
    OwnsLibrary = ownsLibrary,
}
environment.ARC3USX_WORLD_ESP_UI = handle

notify("Chams ESP menu loaded")

return handle
