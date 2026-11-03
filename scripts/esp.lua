-- ARC3USX ESP: player, NPC, resource, helicopter and staff overlays.
-- This is a standalone ESP script; it does not include the combat mods.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local STUD_TO_METER = 0.28
local UPDATE_INTERVAL = 1 / 30

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

local ok, Library = pcall(function()
    local source = game:HttpGet("https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/main/ARC3USX.lua")
    return assert(loadstring(source))()
end)
if not ok or type(Library) ~= "table" then
    report("Could not load the UI library: " .. tostring(Library))
    return
end

local Window = Library:CreateWindow({ Name = "ARC3USX.EXE — ESP", Size = Vector2.new(750, 600), Intro = false, Theme = "Purple", MenuKey = Enum.KeyCode.RightShift })
local Visuals = Window:AddTab("ESP / World")
local Misc = Window:AddTab("Misc")
local Colors = {
    plr_box = Color3.new(1, 1, 1), plr_name = Color3.new(1, 1, 1),
    plr_dist = Color3.new(1, 1, 1), plr_weapon = Color3.fromRGB(0, 255, 255),
    plr_skel = Color3.new(1, 1, 1), plr_hp_high = Color3.fromRGB(0, 255, 0),
    plr_hp_low = Color3.fromRGB(255, 0, 0), plr_vis = Color3.fromRGB(0, 255, 255),
    plr_occ = Color3.fromRGB(255, 50, 80), npc_box = Color3.new(1, 1, 1),
    npc_name = Color3.new(1, 1, 1), npc_dist = Color3.new(1, 1, 1),
    npc_weapon = Color3.fromRGB(255, 180, 60), npc_vis = Color3.fromRGB(60, 255, 120),
    npc_occ = Color3.fromRGB(255, 50, 80),
}
local ORE_COLORS = {
    Cactus = Color3.fromRGB(0, 200, 80), MetalNode = Color3.fromRGB(180, 180, 180),
    SulfurNode = Color3.fromRGB(255, 230, 0), Tree = Color3.fromRGB(120, 70, 30),
    Meteor = Color3.fromRGB(180, 80, 255), StoneNode = Color3.fromRGB(160, 160, 160),
}
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
    if prefix == "plr" then
        colorToggle(group, "Health Bar", "plr_health", { Colors.plr_hp_high, Colors.plr_hp_low }, function(i, c)
            if i == 1 then Colors.plr_hp_high = c else Colors.plr_hp_low = c end
        end)
        colorToggle(group, "Skeleton", "plr_skel", { Colors.plr_skel }, function(_, c) Colors.plr_skel = c end)
    end
    colorToggle(group, "Chams", prefix .. "_chams", { Colors[prefix .. "_vis"], Colors[prefix .. "_occ"] }, function(i, c)
        Colors[prefix .. (i == 1 and "_vis" or "_occ")] = c
    end)
end
humanGroup(Visuals:AddGroup("Player ESP", "Left"), "plr", "Players")
humanGroup(Visuals:AddGroup("NPC ESP", "Right"), "npc", "NPCs")
local oreGroup = Visuals:AddGroup("Ore ESP", "Left")
commonGroup(oreGroup, "ore", "Ores", 2000, 300)
oreGroup:AddToggle({ Name = "Show Distance", Flag = "ore_dist", Default = true })
for _, name in ipairs({ "Cactus", "MetalNode", "SulfurNode", "Tree", "Meteor", "StoneNode" }) do
    oreGroup:AddToggle({ Name = name, Flag = "ore_" .. name, Default = true })
end
local heliGroup = Visuals:AddGroup("Heli ESP", "Right")
commonGroup(heliGroup, "heli", "Heli", 5000, 2000)
heliGroup:AddDropdown({ Name = "Box Style", Flag = "heli_style", Options = { "Corners", "Full" }, Default = "Full" })
heliGroup:AddToggle({ Name = "Chams", Flag = "heli_chams", Default = true })
heliGroup:AddToggle({ Name = "Show Distance", Flag = "heli_dist", Default = true })
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
local systemGroup = Misc:AddGroup("System", "Right")
pcall(function() Window:AddSettingsTab() end)

local alive = true
local connections = {}
local entries = { plr = {}, npc = {}, ore = {}, heli = {} }
local playerConnections = {}
local staffHighlights, staffSeen = {}, {}
local staffState, adminPerms
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
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
end
local function destroy(entry)
    if not entry then return end
    for _, object in ipairs(entry.drawings) do removeDrawing(object) end
    if entry.highlight then entry.highlight:Destroy() end
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
    object.Transparency = 1
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
local function updateHighlight(entry, camera, root, enabled, visibleColor, occludedColor)
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
    if os.clock() >= entry.visibleAt then
        entry.visibleAt = os.clock() + 0.2
        local ignore = { entry.model }
        if LocalPlayer.Character then table.insert(ignore, LocalPlayer.Character) end
        rayParams.FilterDescendantsInstances = ignore
        local direction = root.Position - camera.CFrame.Position
        entry.visible = direction.Magnitude < 0.1 or not workspace:Raycast(camera.CFrame.Position, direction, rayParams)
    end
    local color = entry.visible and visibleColor or occludedColor
    entry.highlight.FillColor, entry.highlight.OutlineColor = color, color
    entry.highlight.Enabled = true
end

local function renderEntry(kind, entry, camera, flags)
    local model = entry.model
    if not model:IsDescendantOf(workspace) then return hide(entry) end
    if not flags[kind .. "_master"] or not flags[kind .. "_enabled"] then return hide(entry) end
    if kind == "ore" and not flags["ore_" .. model.Name] then return hide(entry) end
    local humanoid
    if kind == "plr" or kind == "npc" then
        humanoid = model:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return hide(entry) end
        if kind == "plr" and (not entry.player or entry.player.Character ~= model) then return hide(entry) end
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
        square(entry, "box", x - 3, y - 3, 6, 6, color, true)
        text(entry, "name", model.Name, color, x, y - 18)
        if flags.ore_dist then text(entry, "distance", string.format("%.0fm", distance), Color3.new(1, 1, 1), x, y + 6) else setHidden(entry, "distance") end
        return
    end
    local left, top, right, bottom = bounds(camera, model)
    if not left then return hide(entry) end
    local cx, height = (left + right) / 2, bottom - top
    if kind == "heli" then
        local color = Color3.fromRGB(255, 170, 0)
        updateHighlight(entry, camera, root, flags.heli_chams, color, color)
        box(entry, left, top, right, bottom, flags.heli_style, color)
        if flags.heli_dist then text(entry, "distance", string.format("%.0fm", distance), Color3.new(1, 1, 1), cx, bottom + 2) else setHidden(entry, "distance") end
        return
    end
    updateHighlight(entry, camera, root, flags[kind .. "_chams"], Colors[kind .. "_vis"], Colors[kind .. "_occ"])
    if flags[kind .. "_box"] then box(entry, left, top, right, bottom, flags[kind .. "_style"], Colors[kind .. "_box"]) else hideBox(entry) end
    if flags[kind .. "_name"] then text(entry, "name", entry.player and entry.player.Name or model.Name, Colors[kind .. "_name"], cx, top - 17) else setHidden(entry, "name") end
    if flags[kind .. "_dist"] then text(entry, "distance", string.format("%.0fm", distance), Colors[kind .. "_dist"], cx, bottom + 2) else setHidden(entry, "distance") end
    if flags[kind .. "_weapon"] then
        local tool = model:FindFirstChildWhichIsA("Tool")
        text(entry, "weapon", tool and tool.Name or "Unarmed", Colors[kind .. "_weapon"], cx, bottom + (flags[kind .. "_dist"] and 18 or 2))
    else setHidden(entry, "weapon") end
    if kind == "plr" then
        if flags.plr_health then
            local health = humanoid.MaxHealth > 0 and math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1) or 0
            square(entry, "healthBg", left - 7, top, 4, height, Color3.new(0, 0, 0), true)
            square(entry, "healthFill", left - 6, top + height * (1 - health), 2, height * health, Colors.plr_hp_low:Lerp(Colors.plr_hp_high, health), true)
        else setHidden(entry, "healthBg"); setHidden(entry, "healthFill") end
        local bones = model:FindFirstChild("UpperTorso") and bonesR15 or bonesR6
        for i = 1, #bonesR15 do
            local bone = bones[i]
            local a = bone and model:FindFirstChild(bone[1])
            local b = bone and model:FindFirstChild(bone[2])
            if flags.plr_skel and a and b and a:IsA("BasePart") and b:IsA("BasePart") then
                local x1, y1, z1 = project(camera, a.Position)
                local x2, y2, z2 = project(camera, b.Position)
                if z1 > 0 and z2 > 0 then line(entry, "bone" .. i, x1, y1, x2, y2, Colors.plr_skel) else setHidden(entry, "bone" .. i) end
            else setHidden(entry, "bone" .. i) end
        end
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
local function consider(object)
    if not alive or not object:IsDescendantOf(workspace) then return end
    if (object:IsA("Model") or object:IsA("BasePart")) and ORE_COLORS[object.Name] then
        -- Avoid duplicate labels for a same-named part inside its node model.
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
                    if flags.staff_esp and character and character:IsDescendantOf(workspace) then
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
        if not found[player] or not flags.staff_esp then hl:Destroy(); staffHighlights[player] = nil end
    end
    table.sort(labels)
    staffLabel:SetText((flags.staff_monitor or flags.staff_esp) and (#labels > 0 and table.concat(labels, "\n") or "No staff detected.") or "Staff scan inactive.")
end
staffGroup:AddButton({ Name = "Scan Now", Callback = function()
    -- Manual scan reports roles even while automatic monitoring is disabled.
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
    if elapsed < UPDATE_INTERVAL then return end
    elapsed = elapsed % UPDATE_INTERVAL
    local camera = workspace.CurrentCamera
    if not camera then
        for _, store in pairs(entries) do for _, entry in pairs(store) do hide(entry) end end
        return
    end
    for kind, store in pairs(entries) do
        local active = Library.Flags[kind .. "_master"] and Library.Flags[kind .. "_enabled"]
        if active then
            for _, entry in pairs(store) do
                local success, err = pcall(renderEntry, kind, entry, camera, Library.Flags)
                if not success then
                    hide(entry)
                    if not entry.reportedError then
                        entry.reportedError = true
                        warn("[ARC3USX ESP] " .. kind .. " render error: " .. tostring(err))
                    end
                end
            end
        elseif categoryActive[kind] then
            for _, entry in pairs(store) do hide(entry) end
        end
        categoryActive[kind] = active
    end
    if staffElapsed >= 1 then staffElapsed = 0; scanStaff() end
end)
local function unload()
    if not alive then return end
    alive = false
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, list in pairs(playerConnections) do for _, c in ipairs(list) do c:Disconnect() end end
    for _, store in pairs(entries) do for _, entry in pairs(store) do destroy(entry) end end
    for _, hl in pairs(staffHighlights) do hl:Destroy() end
    if environment.ARC3USX_ESP_UNLOAD == unload then environment.ARC3USX_ESP_UNLOAD = nil end
    pcall(function() Library:Unload() end)
end
environment.ARC3USX_ESP_UNLOAD = unload
systemGroup:AddButton({ Name = "Unload Script & Clear ESP", Callback = unload })
