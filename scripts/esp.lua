-- ARC3USX ESP: player, NPC, resource, helicopter and staff overlays.
-- Run directly for the standalone UI, or pass a shared UI context from main.lua.

local context = ...
if type(context) ~= "table" then context = nil end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local STUD_TO_METER = 0.28

local function report(message)
    warn("[ARC3USX ESP] " .. tostring(message))
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "ARC3USX ESP", Text = tostring(message), Duration = 6 })
    end)
end

local environment = type(getgenv) == "function" and getgenv() or _G
if type(environment.ARC3USX_ESP_UNLOAD) == "function" then
    pcall(environment.ARC3USX_ESP_UNLOAD)
end

local drawing = Drawing or environment.Drawing
if not drawing or type(drawing.new) ~= "function" then
    report("Drawing API is unavailable in this environment.")
    return
end

-- Square and Line are deliberately tested separately: a Quad has a different API.
for _, class in ipairs({ "Square", "Line", "Text" }) do
    local ok, object = pcall(drawing.new, class)
    if not ok or not object then
        report("Drawing API does not support " .. class .. ".")
        return
    end
    pcall(function() object:Remove() end)
end

local ownsLibrary = not context
local Library, Window, Mix
if ownsLibrary then
    if type(environment.ARC3USX_MAIN_UNLOAD) == "function" then pcall(environment.ARC3USX_MAIN_UNLOAD) end
    local cancelled, startupLibrary = false, nil
    local function cancelStartup()
        cancelled = true
        if startupLibrary then pcall(function() startupLibrary:Unload() end) end
        if environment.ARC3USX_ESP_UNLOAD == cancelStartup then environment.ARC3USX_ESP_UNLOAD = nil end
    end
    environment.ARC3USX_ESP_UNLOAD = cancelStartup
    local ok, ui, failure = pcall(function()
        local url = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/da1d5ede-arceus-x/scripts/ui_bootstrap.lua"
        local bootstrap = assert(loadstring(game:HttpGet(url)))()
        return bootstrap({
            Name = "ARC3USX.EXE — ESP",
            OnLibrary = function(library) startupLibrary = library; library.OnUnload = cancelStartup end,
            IsCancelled = function() return cancelled end,
        })
    end)
    if not ok or not ui then
        cancelStartup()
        if failure ~= "cancelled" then report("Could not load the UI: " .. tostring(failure or ui)) end
        return
    end
    Library, Window, Mix = ui.Library, ui.Window, ui.Mix
else
    Library, Window = context.Library, context.Window
    if type(Library) ~= "table" or not Window then report("Invalid shared UI context."); return end
end
local Visuals = context and context.Visuals or Window:AddTab("ESP / World")
local Misc = context and context.Misc or Window:AddTab("Misc")
local Colors = {
    plr_box = Color3.new(1, 1, 1), plr_name = Color3.new(1, 1, 1),
    plr_dist = Color3.new(1, 1, 1), plr_weapon = Color3.fromRGB(0, 255, 255),
    plr_skel = Color3.new(1, 1, 1), plr_hp_high = Color3.fromRGB(0, 255, 0),
    plr_hp_low = Color3.fromRGB(255, 0, 0), plr_vis = Color3.fromRGB(0, 255, 255),
    plr_occ = Color3.fromRGB(255, 50, 80), npc_box = Color3.new(1, 1, 1),
    npc_name = Color3.new(1, 1, 1), npc_dist = Color3.new(1, 1, 1),
    npc_weapon = Color3.fromRGB(255, 180, 60), npc_vis = Color3.fromRGB(60, 255, 120),
    npc_occ = Color3.fromRGB(255, 50, 80), npc_skel = Color3.new(1, 1, 1),
    npc_hp_high = Color3.fromRGB(0, 255, 0), npc_hp_low = Color3.fromRGB(255, 0, 0),
    plr_tracer = Color3.fromRGB(152, 188, 255), npc_tracer = Color3.fromRGB(255, 180, 60),
}
local ORE_COLORS = {
    Cactus = Color3.fromRGB(0, 200, 80), MetalNode = Color3.fromRGB(180, 180, 180),
    SulfurNode = Color3.fromRGB(255, 230, 0), Tree = Color3.fromRGB(120, 70, 30),
    Meteor = Color3.fromRGB(180, 80, 255), StoneNode = Color3.fromRGB(160, 160, 160),
}
local ORE_DROPS = { MetalNode = "metal_ore", SulfurNode = "sulfur_ore", StoneNode = "stones", Tree = "wood" }
local ORE_ABBR = { metal_ore = "MO", sulfur_ore = "SO", stones = "ST", wood = "WD", cloth = "CL" }
local function colorToggle(group, name, flag, defaults, callback, default)
    group:AddToggle({ Name = name, Flag = flag, Default = default ~= false, Colors = defaults, ColorCallback = callback })
end
local function commonGroup(group, prefix, title, max, defaultDistance)
    group:AddToggle({ Name = "Master Enable (" .. title .. ")", Flag = prefix .. "_master", Default = true })
    group:AddToggle({ Name = title .. " ESP Toggle", Flag = prefix .. "_enabled", Default = false })
    group:AddSlider({ Name = "Max Distance", Flag = prefix .. "_max_dist", Min = 10, Max = max, Default = defaultDistance, Suffix = "m" })
end
local function humanGroup(group, prefix, title)
    commonGroup(group, prefix, title, 2000, 500)
    group:AddDropdown({ Name = "Box Style", Flag = prefix .. "_style", Options = { "Corners", "Full" }, Default = "Corners" })
    for _, key in ipairs({ "box", "name", "dist", "weapon" }) do
        local label = ({ box = "Box", name = "Name", dist = "Distance", weapon = "Weapon" })[key]
        local colorKey = prefix .. "_" .. key
        colorToggle(group, label, colorKey, { Colors[colorKey] }, function(_, color) Colors[colorKey] = color end)
    end
    colorToggle(group, "Health Bar", prefix .. "_health", { Colors[prefix .. "_hp_high"], Colors[prefix .. "_hp_low"] }, function(i, c)
        Colors[prefix .. (i == 1 and "_hp_high" or "_hp_low")] = c
    end)
    colorToggle(group, "Skeleton", prefix .. "_skel", { Colors[prefix .. "_skel"] }, function(_, c) Colors[prefix .. "_skel"] = c end)
    colorToggle(group, "Tracers", prefix .. "_tracer", { Colors[prefix .. "_tracer"] }, function(_, c) Colors[prefix .. "_tracer"] = c end, false)
    group:AddToggle({ Name = "Visible Only", Flag = prefix .. "_visible_only", Default = false })
    if prefix == "plr" then group:AddToggle({ Name = "Hide Teammates", Flag = "plr_ignore_team", Default = false }) end
    colorToggle(group, "Chams", prefix .. "_chams", { Colors[prefix .. "_vis"], Colors[prefix .. "_occ"] }, function(i, c)
        Colors[prefix .. (i == 1 and "_vis" or "_occ")] = c
    end)
end
local globalGroup = Visuals:AddGroup("Overlay Settings", "Left")
globalGroup:AddToggle({ Name = "Show ESP", Flag = "esp_master", Default = true })
globalGroup:AddSlider({ Name = "Updates Per Second", Flag = "esp_rate", Min = 5, Max = 60, Default = 30, Suffix = " Hz" })
humanGroup(Visuals:AddGroup("Player ESP", "Left"), "plr", "Players")
humanGroup(Visuals:AddGroup("NPC ESP", "Right"), "npc", "NPCs")
local oreGroup = Visuals:AddGroup("Ore ESP", "Left")
commonGroup(oreGroup, "ore", "Ores", 2000, 300)
oreGroup:AddToggle({ Name = "Show Name", Flag = "ore_name", Default = true })
oreGroup:AddToggle({ Name = "Show Item Icon", Flag = "ore_marker", Default = true })
oreGroup:AddToggle({ Name = "Show Distance", Flag = "ore_dist", Default = true })
for _, name in ipairs({ "Cactus", "MetalNode", "SulfurNode", "Tree", "Meteor", "StoneNode" }) do
    oreGroup:AddToggle({ Name = name, Flag = "ore_" .. name, Default = true })
end
local heliGroup = Visuals:AddGroup("Heli ESP", "Right")
commonGroup(heliGroup, "heli", "Heli", 5000, 2000)
heliGroup:AddDropdown({ Name = "Box Style", Flag = "heli_style", Options = { "Corners", "Full" }, Default = "Full" })
heliGroup:AddToggle({ Name = "Chams", Flag = "heli_chams", Default = true })
heliGroup:AddToggle({ Name = "Show Distance", Flag = "heli_dist", Default = true })
local lootGroup = Visuals:AddGroup("Loot ESP", "Left")
commonGroup(lootGroup, "loot", "Loot", 2000, 300)
lootGroup:AddToggle({ Name = "Show Name", Flag = "loot_name", Default = true })
lootGroup:AddToggle({ Name = "Show Distance", Flag = "loot_dist", Default = true })
lootGroup:AddToggle({ Name = "Highlight", Flag = "loot_chams", Default = true })
local depGroup = Visuals:AddGroup("Deployables ESP", "Right")
commonGroup(depGroup, "dep", "Deployables", 2000, 300)
depGroup:AddToggle({ Name = "Turrets", Flag = "dep_turret", Default = true })
depGroup:AddToggle({ Name = "Sleeping Bags / Beds", Flag = "dep_bag", Default = true })
depGroup:AddToggle({ Name = "Tool Cupboards", Flag = "dep_cupboard", Default = true })
depGroup:AddToggle({ Name = "Other Deployables", Flag = "dep_other", Default = true })
depGroup:AddToggle({ Name = "Show Name", Flag = "dep_name", Default = true })
depGroup:AddToggle({ Name = "Show Distance", Flag = "dep_dist", Default = true })
depGroup:AddToggle({ Name = "Highlight", Flag = "dep_chams", Default = true })
local preview = Visuals:AddGroup("ESP Preview", "Right")
pcall(function()
    preview:AddESPPreview({ Height = 280, PlayerName = "Target", Elements = {
        Box = "plr_box", BoxStyle = "plr_style", Name = "plr_name", Health = "plr_health",
        Distance = "plr_dist", Tool = "plr_weapon", Skeleton = "plr_skel", Chams = "plr_chams",
    } })
end)
local staffGroup = Misc:AddGroup("Staff Detection", "Left")
staffGroup:AddToggle({ Name = "Enable Staff Monitor", Flag = "staff_monitor", Default = false })
staffGroup:AddToggle({ Name = "Highlight Staff", Flag = "staff_esp", Default = false })
local staffLabel = staffGroup:AddLabel("Staff scan inactive.")
local systemGroup = ownsLibrary and Misc:AddGroup("System", "Right") or nil
if ownsLibrary then
    if Mix then pcall(function() Mix.AddTab(Library, Window) end) end
    pcall(function() Window:AddSettingsTab() end)
end

local alive = true
local connections = {}
local entries = { plr = {}, npc = {}, ore = {}, heli = {}, loot = {}, dep = {} }
local playerConnections = {}
local staffHighlights, staffSeen = {}, {}
local staffState, adminPerms
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

-- The supplied ItemIcons module builds 3D models, not image asset IDs. Load only
-- the two known modules asynchronously; never execute arbitrary Fust descendants.
local itemsModule, itemIcons, moduleLoadBusy, moduleRetryRequested
local function tryGameModules()
    if not alive then return end
    if moduleLoadBusy then moduleRetryRequested = true; return end
    moduleLoadBusy = true
    task.spawn(function()
        local ok, err = pcall(function()
            local fust = ReplicatedStorage:FindFirstChild("Fust")
            if not fust then return end
            local items = fust:FindFirstChild("Items")
            local icons = fust:FindFirstChild("ItemIcons")
            if not itemsModule and items and items:IsA("ModuleScript") then
                local success, result = pcall(require, items)
                if alive and success and type(result) == "table" then itemsModule = result end
            end
            if not itemIcons and icons and icons:IsA("ModuleScript") then
                local success, result = pcall(require, icons)
                if alive and success and type(result) == "table" and type(result.Get) == "function" then itemIcons = result end
            end
        end)
        moduleLoadBusy = false
        if not ok and alive then warn("[ARC3USX ESP] Optional item modules: " .. tostring(err)) end
        if moduleRetryRequested and alive then moduleRetryRequested = false; tryGameModules() end
    end)
end
if ReplicatedStorage.DescendantAdded then
    connect(ReplicatedStorage.DescendantAdded, function(object)
        if object.Name == "Fust" or object.Name == "Items" or object.Name == "ItemIcons" or object.Name == "Models" then tryGameModules() end
    end)
end
tryGameModules()
local iconScreen, iconCount, iconBudget = nil, 0, 0
local iconData, iconPending, iconRetryAt = {}, {}, {}
local MAX_ORE_ICONS = 24
local function releaseIcon(entry)
    if entry.icon then
        pcall(function() entry.icon:Destroy() end)
        entry.icon, entry.iconId = nil, nil
        iconCount = math.max(0, iconCount - 1)
    end
end
local function requestIcon(id)
    if not id or not itemIcons or iconData[id] or iconPending[id] or (iconRetryAt[id] and os.clock() < iconRetryAt[id]) then return end
    iconPending[id] = true
    task.spawn(function()
        local ok, data = pcall(itemIcons.Get, id)
        iconPending[id] = nil
        if alive and ok and type(data) == "table" and data.model and data.camCF then
            iconData[id], iconRetryAt[id] = data, nil
        else
            iconRetryAt[id] = os.clock() + 10
        end
    end)
end
local function oreIcon(entry, id, x, y)
    if entry.icon and entry.iconId ~= id then releaseIcon(entry) end
    if not entry.icon and id then
        requestIcon(id)
        local data = iconData[id]
        if data and iconCount < MAX_ORE_ICONS and iconBudget > 0 and (not entry.iconRetryAt or os.clock() >= entry.iconRetryAt) then
            iconBudget = iconBudget - 1
            local viewport
            local ok = pcall(function()
                if not iconScreen or not iconScreen.Parent then
                    if iconScreen then pcall(function() iconScreen:Destroy() end) end
                    iconScreen = Instance.new("ScreenGui")
                    iconScreen.Name = "ARC3USX_OreIcons"
                    iconScreen.ResetOnSpawn = false
                    iconScreen.IgnoreGuiInset = true
                    iconScreen.DisplayOrder = 999
                    iconScreen.Parent = (Library.Gui and Library.Gui.Parent) or CoreGui
                end
                viewport = Instance.new("ViewportFrame")
                viewport.Name = "OreIcon"
                viewport.BackgroundTransparency = 1
                viewport.BorderSizePixel = 0
                viewport.Size = UDim2.fromOffset(30, 30)
                viewport.Ambient = Color3.fromRGB(150, 145, 138)
                viewport.LightColor = Color3.fromRGB(255, 244, 226)
                viewport.LightDirection = Vector3.new(-1, -1.4, -0.6)
                viewport.Parent = iconScreen
                local cam = Instance.new("Camera")
                cam.FieldOfView = tonumber(itemIcons.FOV) or 30
                cam.CFrame = data.camCF
                cam.Parent = viewport
                viewport.CurrentCamera = cam
                data.model:Clone().Parent = viewport
            end)
            if ok and viewport then
                entry.icon, entry.iconId, entry.iconRetryAt = viewport, id, nil
                iconCount = iconCount + 1
            else
                entry.iconRetryAt = os.clock() + 5
                if viewport then pcall(function() viewport:Destroy() end) end
            end
        end
    end
    if entry.icon then
        entry.icon.Position = UDim2.fromOffset(math.floor(x - 15), math.floor(y - 15))
        entry.icon.Visible = true
        return true
    end
    return false
end

local function removeDrawing(object)
    if object then pcall(function() object:Remove() end) end
end
local function hide(entry)
    if not entry then return end
    for _, object in ipairs(entry.drawings) do
        pcall(function() object.Visible = false end)
    end
    if entry.highlight then entry.highlight.Enabled = false end
    releaseIcon(entry)
end
local function destroy(entry)
    if not entry then return end
    for _, object in ipairs(entry.drawings) do removeDrawing(object) end
    if entry.highlight then entry.highlight:Destroy() end
    releaseIcon(entry)
end
local function removeEntry(kind, object)
    local entry = entries[kind][object]
    if entry then
        entries[kind][object] = nil
        destroy(entry)
    end
end
local function newEntry(kind, model, player)
    if entries[kind][model] then
        if player then entries[kind][model].player = player end
        return
    end
    entries[kind][model] = { model = model, player = player, drawings = {}, parts = {}, visibleAt = 0, visible = false }
end
local function draw(entry, key, class)
    if entry.parts[key] then return entry.parts[key] end
    local object = drawing.new(class)
    if not object then error("Drawing.new(" .. class .. ") returned nil") end
    -- Register before configuring so an error still gets cleaned up.
    table.insert(entry.drawings, object)
    object.Visible = false
    -- Drawing.Transparency is OPACITY: 1 = fully visible, 0 = invisible.
    -- Setting this to 0 hides every box/label/tracer/skeleton while Highlight
    -- chams keep rendering, which looks like "only chams works".
    pcall(function() object.Transparency = 1 end)
    if class == "Text" then
        object.Size = 14
        object.Center = true
        object.Outline = true
    elseif class == "Line" then
        object.Thickness = 1
    elseif class == "Square" then
        object.Thickness = 1
        object.Filled = false
    end
    entry.parts[key] = object
    return object
end
local function setHidden(entry, key)
    local part = entry.parts[key]
    if part then part.Visible = false end
end
local function text(entry, key, value, color, x, y)
    local part = draw(entry, key, "Text")
    part.Text = value
    part.Color = color
    part.Position = Vector2.new(x, y)
    part.Visible = true
end
local function square(entry, key, x, y, w, h, color, filled)
    local part = draw(entry, key, "Square")
    part.Position = Vector2.new(x, y)
    part.Size = Vector2.new(math.max(w, 0), math.max(h, 0))
    part.Color = color
    part.Filled = filled
    part.Visible = true
end
local function line(entry, key, x1, y1, x2, y2, color)
    local part = draw(entry, key, "Line")
    part.From, part.To = Vector2.new(x1, y1), Vector2.new(x2, y2)
    part.Color = color
    part.Visible = true
end
local function box(entry, left, top, right, bottom, style, color)
    if style == "Full" then
        square(entry, "box", left, top, right - left, bottom - top, color, false)
        for i = 1, 8 do setHidden(entry, "corner" .. i) end
    else
        setHidden(entry, "box")
        local width, height = right - left, bottom - top
        local dx, dy = width * 0.25, height * 0.2
        local corners = {
            {left, top, left + dx, top}, {left, top, left, top + dy},
            {right, top, right - dx, top}, {right, top, right, top + dy},
            {left, bottom, left + dx, bottom}, {left, bottom, left, bottom - dy},
            {right, bottom, right - dx, bottom}, {right, bottom, right, bottom - dy},
        }
        for i, c in ipairs(corners) do line(entry, "corner" .. i, c[1], c[2], c[3], c[4], color) end
    end
end
local function hideBox(entry)
    setHidden(entry, "box")
    for i = 1, 8 do setHidden(entry, "corner" .. i) end
end
local bonesR15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"UpperTorso", "RightUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
    {"LowerTorso", "RightUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"}, {"RightLowerLeg", "RightFoot"},
}
local bonesR6 = {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}
local function rootOf(object)
    if object:IsA("BasePart") then return object end
    if not object:IsA("Model") then return nil end
    local root = object:FindFirstChild("HumanoidRootPart") or object.PrimaryPart or object:FindFirstChild("Head") or object:FindFirstChildWhichIsA("BasePart", true)
    if root and root:IsA("BasePart") then return root end
end
local function project(camera, position)
    local point = camera:WorldToViewportPoint(position)
    return point.X, point.Y, point.Z
end
-- Project all corners; reject objects behind the camera and objects outside the viewport.
local function bounds(camera, model)
    local cf, size = model:GetBoundingBox()
    local left, top, right, bottom = math.huge, math.huge, -math.huge, -math.huge
    for _, x in ipairs({ -0.5, 0.5 }) do
        for _, y in ipairs({ -0.5, 0.5 }) do
            for _, z in ipairs({ -0.5, 0.5 }) do
                local sx, sy, depth = project(camera, cf:PointToWorldSpace(Vector3.new(size.X * x, size.Y * y, size.Z * z)))
                if depth <= 0.1 then return nil end
                left, right = math.min(left, sx), math.max(right, sx)
                top, bottom = math.min(top, sy), math.max(bottom, sy)
            end
        end
    end
    local viewport = camera.ViewportSize
    if right < 0 or bottom < 0 or left > viewport.X or top > viewport.Y then return nil end
    return left, top, right, bottom
end
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
local function visibleFromCamera(entry, camera, root)
    if entry.visibilityCamera ~= camera or os.clock() >= entry.visibleAt then
        entry.visibilityCamera = camera
        entry.visibleAt = os.clock() + 0.2
        local ignore = { entry.model }
        if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
        rayParams.FilterDescendantsInstances = ignore
        local direction = root.Position - camera.CFrame.Position
        entry.visible = direction.Magnitude < 0.1 or not workspace:Raycast(camera.CFrame.Position, direction, rayParams)
    end
    return entry.visible
end
local function updateHighlight(entry, enabled, visibleColor, occludedColor, isVisible)
    if not enabled then
        if entry.highlight then entry.highlight.Enabled = false end
        return
    end
    if not entry.highlight then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ARC3USX_ESP"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = entry.model
        highlight.Parent = CoreGui
        entry.highlight = highlight
    end
    local color = isVisible and visibleColor or occludedColor
    entry.highlight.FillColor, entry.highlight.OutlineColor = color, color
    entry.highlight.Enabled = true
end

local function prettyItem(id)
    if type(id) ~= "string" or id == "" then return nil end
    local def = itemsModule and type(itemsModule.Defs) == "table" and itemsModule.Defs[id]
    if type(def) == "table" and type(def.name) == "string" and def.name ~= "" then return def.name end
    return (id:gsub("_", " "))
end
local EQUIPMENT_ATTRS = { "EquippedItemId", "EquippedWeaponId", "EquippedToolId", "HeldItemId", "WeaponId", "WeaponName", "CurrentWeapon", "Weapon", "EquippedItem", "EquippedTool", "HeldItem", "HeldWeapon" }
local function equipmentName(entry)
    if entry.weaponAt and os.clock() < entry.weaponAt then return entry.weaponName end
    entry.weaponAt = os.clock() + 0.35
    local model = entry.model
    local tool = model:FindFirstChildWhichIsA("Tool")
    local name
    if tool then name = prettyItem(tool:GetAttribute("ItemId")) or prettyItem(tool.Name) end
    if not name then
        for _, attribute in ipairs(EQUIPMENT_ATTRS) do
            name = prettyItem(model:GetAttribute(attribute))
            if name then break end
        end
    end
    if not name then
        for _, child in ipairs(model:GetChildren()) do
            local lower = child.Name:lower()
            if (child:IsA("StringValue") or child:IsA("ObjectValue")) and (lower == "weapon" or lower == "equippeditem" or lower == "equippedtool" or lower == "helditem" or lower == "currentweapon" or lower == "heldweapon") then
                local value = child.Value
                if type(value) == "string" then name = prettyItem(value)
                elseif value and type(value.GetAttribute) == "function" then name = prettyItem(value:GetAttribute("ItemId")) or prettyItem(value.Name) end
            elseif child:IsA("Model") then
                local id = child:GetAttribute("ItemId")
                local def = type(id) == "string" and itemsModule and type(itemsModule.Defs) == "table" and itemsModule.Defs[id]
                local knownWeapon = type(def) == "table" and (def.weapon == "gun" or def.weapon == "bow" or def.weapon == "tool" or def.kind == "gun" or def.kind == "bow" or def.kind == "tool")
                if knownWeapon or lower == "weapon" or lower == "gun" or lower == "helditem" then name = prettyItem(id) end
            end
            if name then break end
        end
    end
    entry.weaponName = name or (entry.player and "Unarmed" or "Weapon unknown")
    return entry.weaponName
end
local function deployableKind(model)
    local values = { model.Name }
    for _, key in ipairs({ "ItemId", "DeployableId", "DeployType", "Kind", "Type" }) do
        local value = model:GetAttribute(key)
        if type(value) == "string" then values[#values + 1] = value end
    end
    for _, value in ipairs(values) do
        local compact = value:lower():gsub("[^%w]", "")
        if compact:find("turret", 1, true) or compact:find("sentry", 1, true) then return "turret" end
        if compact:find("sleepingbag", 1, true) or compact:find("bedroll", 1, true) or compact:sub(1, 3) == "bed" then return "bag" end
        if compact:find("cupboard", 1, true) then return "cupboard" end
    end
    return "other"
end
local function renderEntry(kind, entry, camera, flags)
    local model = entry.model
    if not model:IsDescendantOf(workspace) then return hide(entry) end
    if not flags[kind .. "_master"] or not flags[kind .. "_enabled"] then return hide(entry) end
    if kind == "ore" and not flags["ore_" .. model.Name] then return hide(entry) end
    if kind == "loot" or kind == "dep" then
        local folder = workspace:FindFirstChild(kind == "loot" and "Loot" or "Deployables")
        if not folder or not model:IsDescendantOf(folder) then return hide(entry) end
        if kind == "dep" and not flags["dep_" .. deployableKind(model)] then return hide(entry) end
    end
    local humanoid
    if kind == "plr" or kind == "npc" then
        humanoid = model:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return hide(entry) end
        if kind == "plr" then
            if not entry.player or entry.player.Character ~= model then return hide(entry) end
            if flags.plr_ignore_team and LocalPlayer.Team and entry.player.Team == LocalPlayer.Team then return hide(entry) end
        end
        if kind == "npc" then
            local folder = workspace:FindFirstChild("Npcs")
            if not folder or not model:IsDescendantOf(folder) or Players:GetPlayerFromCharacter(model) then return hide(entry) end
        end
    end
    local root = rootOf(model)
    if not root then return hide(entry) end
    local distance = (root.Position - camera.CFrame.Position).Magnitude * STUD_TO_METER
    if distance > (tonumber(flags[kind .. "_max_dist"]) or 0) then return hide(entry) end

    if kind == "ore" then
        local x, y, z = project(camera, root.Position)
        local viewport = camera.ViewportSize
        if z <= 0 or x < 0 or y < 0 or x > viewport.X or y > viewport.Y then return hide(entry) end
        local color = ORE_COLORS[model.Name]
        if not color then return hide(entry) end
        local itemId = model:GetAttribute("DropItemId") or model:GetAttribute("ResourceItemId") or model:GetAttribute("YieldItemId") or ORE_DROPS[model.Name]
        if type(itemId) ~= "string" or itemId == "" then itemId = nil end
        if flags.ore_marker then
            if oreIcon(entry, itemId, x, y) then
                setHidden(entry, "iconFallback")
            else
                local abbreviation = ORE_ABBR[itemId] or model.Name:sub(1, 3):upper()
                text(entry, "iconFallback", abbreviation, color, x, y - 7)
            end
        else
            releaseIcon(entry); setHidden(entry, "iconFallback")
        end
        if flags.ore_name then text(entry, "name", model.Name, color, x, y - 34) else setHidden(entry, "name") end
        if flags.ore_dist then text(entry, "distance", string.format("%.0fm", distance), Color3.new(1, 1, 1), x, y + 16) else setHidden(entry, "distance") end
        return
    end
    if kind == "loot" or kind == "dep" then
        local x, y, z = project(camera, root.Position)
        local viewport = camera.ViewportSize
        if z <= 0 or x < 0 or y < 0 or x > viewport.X or y > viewport.Y then return hide(entry) end
        local color = kind == "loot" and Color3.fromRGB(255, 204, 90) or Color3.fromRGB(110, 210, 255)
        updateHighlight(entry, flags[kind .. "_chams"], color, color, true)
        local itemId = model:GetAttribute("ItemId") or model:GetAttribute("DeployableId")
        local label = prettyItem(itemId) or model.Name
        if flags[kind .. "_name"] then text(entry, "name", label, color, x, y - 15) else setHidden(entry, "name") end
        if flags[kind .. "_dist"] then text(entry, "distance", string.format("%.0fm", distance), Color3.new(1, 1, 1), x, y + 2) else setHidden(entry, "distance") end
        return
    end
    local left, top, right, bottom = bounds(camera, model)
    if not left then return hide(entry) end
    local cx, height = (left + right) / 2, bottom - top
    if kind == "heli" then
        local color = Color3.fromRGB(255, 170, 0)
        updateHighlight(entry, flags.heli_chams, color, color, true)
        box(entry, left, top, right, bottom, flags.heli_style, color)
        if flags.heli_dist then text(entry, "distance", string.format("%.0fm", distance), Color3.new(1, 1, 1), cx, bottom + 2) else setHidden(entry, "distance") end
        return
    end
    local isVisible = true
    if flags[kind .. "_visible_only"] or flags[kind .. "_chams"] then isVisible = visibleFromCamera(entry, camera, root) end
    if flags[kind .. "_visible_only"] and not isVisible then return hide(entry) end
    updateHighlight(entry, flags[kind .. "_chams"], Colors[kind .. "_vis"], Colors[kind .. "_occ"], isVisible)
    if flags[kind .. "_tracer"] then
        line(entry, "tracer", camera.ViewportSize.X / 2, camera.ViewportSize.Y, cx, bottom, Colors[kind .. "_tracer"])
    else setHidden(entry, "tracer") end
    if flags[kind .. "_box"] then box(entry, left, top, right, bottom, flags[kind .. "_style"], Colors[kind .. "_box"]) else hideBox(entry) end
    if flags[kind .. "_name"] then text(entry, "name", entry.player and entry.player.Name or model.Name, Colors[kind .. "_name"], cx, top - 17) else setHidden(entry, "name") end
    if flags[kind .. "_dist"] then text(entry, "distance", string.format("%.0fm", distance), Colors[kind .. "_dist"], cx, bottom + 2) else setHidden(entry, "distance") end
    if flags[kind .. "_weapon"] then
        text(entry, "weapon", equipmentName(entry), Colors[kind .. "_weapon"], cx, bottom + (flags[kind .. "_dist"] and 18 or 2))
    else setHidden(entry, "weapon") end
    if flags[kind .. "_health"] then
        local health = humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 0
        square(entry, "healthBg", left - 7, top, 4, height, Color3.new(0, 0, 0), true)
        square(entry, "healthFill", left - 6, top + height * (1 - health), 2, height * health, Colors[kind .. "_hp_low"]:Lerp(Colors[kind .. "_hp_high"], health), true)
    else setHidden(entry, "healthBg"); setHidden(entry, "healthFill") end
    local bones = model:FindFirstChild("UpperTorso") and bonesR15 or bonesR6
    for i = 1, #bonesR15 do
        local bone = bones[i]
        local a = bone and model:FindFirstChild(bone[1])
        local b = bone and model:FindFirstChild(bone[2])
        if flags[kind .. "_skel"] and a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            local x1, y1, z1 = project(camera, a.Position)
            local x2, y2, z2 = project(camera, b.Position)
            if z1 > 0 and z2 > 0 then line(entry, "bone" .. i, x1, y1, x2, y2, Colors[kind .. "_skel"]) else setHidden(entry, "bone" .. i) end
        else setHidden(entry, "bone" .. i) end
    end
end

local function playerAdded(player)
    if player == LocalPlayer or playerConnections[player] then return end
    local own = {}
    playerConnections[player] = own
    local function characterAdded(character)
        if alive then newEntry("plr", character, player) end
    end
    table.insert(own, player.CharacterAdded:Connect(characterAdded))
    table.insert(own, player.CharacterRemoving:Connect(function(character) removeEntry("plr", character) end))
    if player.Character then characterAdded(player.Character) end
end
local function playerRemoving(player)
    for _, c in ipairs(playerConnections[player] or {}) do c:Disconnect() end
    playerConnections[player] = nil
    for model, entry in pairs(entries.plr) do if entry.player == player then removeEntry("plr", model) end end
    if staffHighlights[player] then staffHighlights[player]:Destroy(); staffHighlights[player] = nil end
    staffSeen[player] = nil
end
local function insideNpcFolder(model)
    local folder = workspace:FindFirstChild("Npcs")
    return folder and model:IsDescendantOf(folder)
end
local function topLevelIn(object, folderName)
    local folder = workspace:FindFirstChild(folderName)
    if not folder or object == folder or not object:IsDescendantOf(folder) then return false end
    if not (object:IsA("Model") or object:IsA("BasePart")) then return false end
    local parent = object.Parent
    while parent and parent ~= folder do
        if parent:IsA("Model") or parent:IsA("BasePart") then return false end
        parent = parent.Parent
    end
    return parent == folder
end
local function consider(object)
    if not alive or not object:IsDescendantOf(workspace) then return end
    if topLevelIn(object, "Loot") then newEntry("loot", object) end
    if topLevelIn(object, "Deployables") then newEntry("dep", object) end
    if (object:IsA("Model") or object:IsA("BasePart")) and ORE_COLORS[object.Name] then
        local parent = object.Parent
        if not (parent and parent.Name == object.Name and (parent:IsA("Model") or parent:IsA("BasePart"))) then newEntry("ore", object) end
    end
    if object:IsA("Model") then
        local player = Players:GetPlayerFromCharacter(object)
        if player and player ~= LocalPlayer then newEntry("plr", object, player) end
        if object.Name == "PatrolHeli" then newEntry("heli", object) end
        if insideNpcFolder(object) and object:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(object) then
            newEntry("npc", object)
        end
    elseif object:IsA("Humanoid") then
        local model = object.Parent
        if model and model:IsA("Model") and insideNpcFolder(model) and not Players:GetPlayerFromCharacter(model) then newEntry("npc", model) end
    end
end
connect(Players.PlayerAdded, playerAdded)
connect(Players.PlayerRemoving, playerRemoving)
for _, player in ipairs(Players:GetPlayers()) do playerAdded(player) end
connect(workspace.DescendantAdded, consider)
connect(workspace.DescendantRemoving, function(object)
    for kind in pairs(entries) do removeEntry(kind, object) end
    if object:IsA("Humanoid") and object.Parent then
        removeEntry("npc", object.Parent)
    end
end)
-- Initial discovery is one-time and spread across frames. Later changes are event-driven.
task.spawn(function()
    local descendants = workspace:GetDescendants()
    for i, object in ipairs(descendants) do
        if not alive then return end
        consider(object)
        if i % 300 == 0 then task.wait() end
    end
end)

local roleColors = {
    owner = Color3.fromRGB(255, 215, 0), co_owner = Color3.fromRGB(255, 165, 0),
    lead_admin = Color3.fromRGB(255, 80, 80), admin = Color3.fromRGB(255, 120, 120),
    junior_admin = Color3.fromRGB(255, 160, 80), mod = Color3.fromRGB(80, 200, 255),
    junior_mod = Color3.fromRGB(120, 220, 255), lab = Color3.fromRGB(180, 100, 255),
}
local function safeRequire(module)
    if module and module:IsA("ModuleScript") then
        local success, result = pcall(require, module)
        if success and type(result) == "table" then return result end
    end
end
task.spawn(function()
    local fust = ReplicatedStorage:FindFirstChild("Fust") or ReplicatedStorage:WaitForChild("Fust", 10)
    if fust and alive then
        staffState, adminPerms = safeRequire(fust:FindFirstChild("StaffState")), safeRequire(fust:FindFirstChild("AdminPerms"))
    end
end)
local function roleFor(player)
    if staffState and type(staffState.get) == "function" then
        local success, role = pcall(staffState.get, player, "AdminRole")
        if success and type(role) == "string" and role ~= "" then return role end
    end
    local role = player:GetAttribute("AdminRole")
    if type(role) == "string" and role ~= "" then return role end
end
local function scanStaff()
    local flags, found, labels = Library.Flags, {}, {}
    if flags.staff_monitor or flags.staff_esp then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local role = roleFor(player)
                if role then
                    found[player] = true
                    local label = adminPerms and type(adminPerms.Label) == "table" and adminPerms.Label[role] or role
                    table.insert(labels, player.Name .. " — " .. tostring(label))
                    if flags.staff_monitor and staffSeen[player] ~= role then print("[StaffDetector] " .. player.Name .. " — " .. tostring(label)) end
                    staffSeen[player] = role
                    local character = player.Character
                    if flags.esp_master and flags.staff_esp and character and character:IsDescendantOf(workspace) then
                        local hl = staffHighlights[player]
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "ARC3USX_Staff"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.FillTransparency = 0.55
                            hl.OutlineTransparency = 0
                            hl.Parent = CoreGui
                            staffHighlights[player] = hl
                        end
                        hl.Adornee = character
                        hl.FillColor = roleColors[role] or Color3.fromRGB(200, 200, 200)
                        hl.OutlineColor = hl.FillColor
                        hl.Enabled = true
                    elseif staffHighlights[player] then
                        staffHighlights[player]:Destroy(); staffHighlights[player] = nil
                    end
                end
            end
        end
    end
    for player in pairs(staffSeen) do if not found[player] then staffSeen[player] = nil end end
    for player, hl in pairs(staffHighlights) do
        if not found[player] or not flags.staff_esp or not flags.esp_master then hl:Destroy(); staffHighlights[player] = nil end
    end
    table.sort(labels)
    staffLabel:SetText((flags.staff_monitor or flags.staff_esp) and (#labels > 0 and table.concat(labels, "\n") or "No staff detected.") or "Staff scan inactive.")
end
staffGroup:AddButton({ Name = "Scan Now", Callback = function()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local role = roleFor(player)
            if role then table.insert(names, player.Name .. " — " .. role) end
        end
    end
    table.sort(names)
    staffLabel:SetText(#names > 0 and table.concat(names, "\n") or "No staff detected.")
end })

local elapsed, staffElapsed = 0, 1
local categoryActive = {}
connect(RunService.RenderStepped, function(dt)
    if not alive then return end
    elapsed, staffElapsed = elapsed + dt, staffElapsed + dt
    if not Library.Flags.esp_master then
        for _, highlight in pairs(staffHighlights) do highlight.Enabled = false end
    end
    if staffElapsed >= 1 then staffElapsed = 0; scanStaff() end
    local rate = math.clamp(tonumber(Library.Flags.esp_rate) or 30, 5, 60)
    local interval = 1 / rate
    if elapsed < interval then return end
    elapsed = elapsed % interval
    local camera = workspace.CurrentCamera
    if not camera then
        for _, store in pairs(entries) do for _, entry in pairs(store) do hide(entry) end end
        return
    end
    iconBudget = 2
    for kind, store in pairs(entries) do
        local active = Library.Flags.esp_master and Library.Flags[kind .. "_master"] and Library.Flags[kind .. "_enabled"]
        if active then
            for _, entry in pairs(store) do
                if not entry.retryAt or os.clock() >= entry.retryAt then
                    local success, err = pcall(renderEntry, kind, entry, camera, Library.Flags)
                    if success then
                        entry.retryAt, entry.reportedError = nil, nil
                    else
                        hide(entry)
                        destroy(entry)
                        entry.drawings, entry.parts, entry.highlight = {}, {}, nil
                        entry.retryAt = os.clock() + 2
                        if not entry.reportedError then
                            entry.reportedError = true
                            warn("[ARC3USX ESP] " .. kind .. " render error: " .. tostring(err))
                        end
                    end
                end
            end
        elseif categoryActive[kind] then
            for _, entry in pairs(store) do hide(entry) end
        end
        categoryActive[kind] = active
    end
end)
local function unload()
    if not alive then return end
    alive = false
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, list in pairs(playerConnections) do for _, c in ipairs(list) do c:Disconnect() end end
    for _, store in pairs(entries) do for _, entry in pairs(store) do destroy(entry) end end
    for _, hl in pairs(staffHighlights) do hl:Destroy() end
    if iconScreen then pcall(function() iconScreen:Destroy() end); iconScreen = nil end
    if environment.ARC3USX_ESP_UNLOAD == unload then environment.ARC3USX_ESP_UNLOAD = nil end
    if ownsLibrary then pcall(function() Library:Unload() end) end
end
environment.ARC3USX_ESP_UNLOAD = unload
if ownsLibrary then Library.OnUnload = unload end
if systemGroup then systemGroup:AddButton({ Name = "Unload Script & Clear ESP", Callback = unload }) end
return unload
