-- ═══════════════════════════════════════════════════════════════
--  ARC3USX.EXE — ULTIMATE OPTIMIZED HUB
--  SMOOTH ESP + LIBRARY LOADING SCREEN
--
--  Entry point for the hub. The UI library lives in ARC3USX.lua at the
--  repository root; everything below is the hub's feature set.
-- ═══════════════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- Load the library from THIS branch: the animated loading screen is embedded
-- in ARC3USX.lua here, so main's copy (which the hub used before) is not used.
local LIBRARY_URL = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/6af703ac-arceus-x/ARC3USX.lua"
local libraryOk, Library = pcall(function()
    return assert(loadstring(game:HttpGet(LIBRARY_URL)))()
end)
if not libraryOk or type(Library) ~= "table" then
    error("[ARC3USX] Could not load the UI library: " .. tostring(Library))
end

local STUD_TO_METER = 0.28
local METER_TO_STUD = 1 / STUD_TO_METER
local unloaded = false

-- Every connection made by the hub is tracked so "Unload Script & Clear Memory"
-- can actually disconnect them.
local connections = {}
local function connect(signal, fn)
    local connection = signal:Connect(fn)
    table.insert(connections, connection)
    return connection
end

-- ═══════════════════════════════════════════════════════════════
--  ITEM ICONS MODULE
-- ═══════════════════════════════════════════════════════════════
local ItemIcons = nil
do
    local Fust = ReplicatedStorage:FindFirstChild("Fust") or ReplicatedStorage:WaitForChild("Fust", 10)
    if Fust then
        local mod = Fust:FindFirstChild("ItemIcons")
        if mod and mod:IsA("ModuleScript") then
            local ok, result = pcall(require, mod)
            if ok and type(result) == "table" then
                ItemIcons = result
            end
        end
    end
end

local OreItemMap = {
    Cactus      = "cloth",
    MetalNode   = "metal_ore",
    SulfurNode  = "sulfur_ore",
    Tree        = "wood",
    Meteor      = "hqm_ore",
    StoneNode   = "stones",
}

-- ═══════════════════════════════════════════════════════════════
--  UI ESP ENGINE
-- ═══════════════════════════════════════════════════════════════
local espGui = Instance.new("ScreenGui")
espGui.Name = "ARC3USX_ESP_UI"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 999
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
espGui.Parent = CoreGui

local function createText(z)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextStrokeTransparency = 0.3
    lbl.TextStrokeColor3 = Color3.new(0,0,0)
    lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.Visible = false
    lbl.ZIndex = z or 3
    lbl.Parent = espGui
    return lbl
end

local function createLine(z)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(1,1,1)
    frame.BorderSizePixel = 0
    frame.AnchorPoint = Vector2.new(0, 0.5)
    frame.Visible = false
    frame.ZIndex = z or 2
    frame.Parent = espGui
    return frame
end

local function createBox(z)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.BorderColor3 = Color3.new(1,1,1)
    frame.BorderSizePixel = 1
    frame.Visible = false
    frame.ZIndex = z or 1
    frame.Parent = espGui
    return frame
end

-- Scratch tables are reused every frame so box drawing never allocates.
local boxCorners = {}
for i = 1, 8 do boxCorners[i] = { 0, 0, 0, 0 } end

-- An overlay is "seen" only when something was actually drawn for it this frame.
-- Anything not seen at the end of a frame is hidden exactly once, so no ESP can
-- stay stuck on screen after a target dies, leaves, goes out of range or is
-- disabled.
local currentFrame = 0

-- Roblox Instances reject arbitrary Lua fields ("lastX is not a valid member
-- of Frame"). Keep write caches in a weak-keyed side table keyed by the
-- Instance instead of assigning them onto the Instance itself.
local propCache = setmetatable({}, { __mode = "k" })
local function cached(inst)
    local c = propCache[inst]
    if not c then c = {}; propCache[inst] = c end
    return c
end

local function setFrame(frame, x, y, w, h)
    local c = cached(frame)
    local ox, oy, ow, oh = math.floor(x), math.floor(y), math.floor(w), math.floor(h)
    if c.x ~= ox or c.y ~= oy then
        frame.Position = UDim2.fromOffset(ox, oy)
        c.x, c.y = ox, oy
    end
    if c.w ~= ow or c.h ~= oh then
        frame.Size = UDim2.fromOffset(ow, oh)
        c.w, c.h = ow, oh
    end
end

local function setCentered(frame, x, y, size)
    local c = cached(frame)
    local ox, oy, sz = math.floor(x), math.floor(y), math.floor(size)
    if c.x ~= ox or c.y ~= oy then
        frame.Position = UDim2.fromOffset(ox, oy)
        c.x, c.y = ox, oy
    end
    if c.w ~= sz then
        frame.Size = UDim2.fromOffset(sz, sz)
        c.w = sz
    end
    if not frame.Visible then frame.Visible = true end
end

local function setLabel(lbl, visible, text, color, x, y)
    if not visible then
        if lbl.Visible then lbl.Visible = false end
        return
    end
    local c = cached(lbl)
    if lbl.Text ~= text then lbl.Text = text end
    if lbl.TextColor3 ~= color then lbl.TextColor3 = color end
    local ox, oy = math.floor(x), math.floor(y)
    if c.x ~= ox or c.y ~= oy then
        lbl.Position = UDim2.fromOffset(ox, oy)
        c.x, c.y = ox, oy
    end
    if not lbl.Visible then lbl.Visible = true end
end

local function drawLine(line, fromX, fromY, toX, toY, color)
    if not line then return end
    local c = cached(line)
    local dx, dy = toX - fromX, toY - fromY
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 0.5 then
        if line.Visible then line.Visible = false end
        c.x, c.y = nil, nil
        return
    end
    local ox, oy = math.floor(fromX), math.floor(fromY)
    local len = math.floor(length)
    local angle = math.deg(math.atan(dy, dx))
    if c.x ~= ox or c.y ~= oy then
        line.Position = UDim2.fromOffset(ox, oy)
        c.x, c.y = ox, oy
    end
    if c.len ~= len then
        line.Size = UDim2.fromOffset(len, 1)
        c.len = len
    end
    if c.angle ~= angle then line.Rotation = angle; c.angle = angle end
    if line.BackgroundColor3 ~= color then line.BackgroundColor3 = color end
    if not line.Visible then line.Visible = true end
end

local function buildEsp()
    local esp = {
        box = createBox(1), name = createText(3), distance = createText(3), weapon = createText(3),
        healthBg = createBox(1), healthFill = createBox(1), highlight = nil,
        corners = {}, skeleton = {}, lastHp = -1, lastDist = -1, lastVisible = nil,
        hidden = false, frameId = 0, nextVisCheck = 0,
    }
    esp.healthBg.BackgroundTransparency = 0; esp.healthBg.BorderSizePixel = 0; esp.healthBg.BackgroundColor3 = Color3.new(0,0,0)
    esp.healthFill.BackgroundTransparency = 0; esp.healthFill.BorderSizePixel = 0
    for i = 1, 8 do esp.corners[i] = createLine(2) end
    for i = 1, 15 do esp.skeleton[i] = createLine(2) end
    return esp
end

local function destroyEsp(esp)
    if not esp then return end
    esp.box:Destroy(); esp.name:Destroy(); esp.distance:Destroy(); esp.weapon:Destroy()
    esp.healthBg:Destroy(); esp.healthFill:Destroy()
    if esp.highlight then esp.highlight:Destroy() end
    for _, c in ipairs(esp.corners) do c:Destroy() end
    for _, l in ipairs(esp.skeleton) do l:Destroy() end
end

-- Idempotent: a hidden overlay is left alone, so stale entries cost nothing.
local function hideEsp(esp)
    if not esp or esp.hidden then return end
    esp.hidden = true; esp.frameId = 0
    esp.box.Visible = false; esp.name.Visible = false; esp.distance.Visible = false
    esp.weapon.Visible = false; esp.healthBg.Visible = false; esp.healthFill.Visible = false
    if esp.highlight then esp.highlight.Enabled = false end
    for _, c in ipairs(esp.corners) do c.Visible = false end
    for _, l in ipairs(esp.skeleton) do l.Visible = false end
end

local function markEsp(esp)
    esp.frameId = currentFrame
    esp.hidden = false
end

local function hideBox(esp)
    if esp.box.Visible then esp.box.Visible = false end
    for _, c in ipairs(esp.corners) do if c.Visible then c.Visible = false end end
end

local function drawBox(esp, bLeft, bTop, bRight, bBot, style, color)
    if style == "Full" then
        for _, c in ipairs(esp.corners) do if c.Visible then c.Visible = false end end
        if not esp.box.Visible then esp.box.Visible = true end
        esp.box.BackgroundTransparency = 1
        if esp.box.BorderColor3 ~= color then esp.box.BorderColor3 = color end
        setFrame(esp.box, bLeft, bTop, bRight - bLeft, bBot - bTop)
    else
        if esp.box.Visible then esp.box.Visible = false end
        local w, h = bRight - bLeft, bBot - bTop
        local cl = math.max(w * 0.22, h * 0.14)
        local c = boxCorners
        c[1][1], c[1][2], c[1][3], c[1][4] = bLeft, bTop, bLeft + cl, bTop
        c[2][1], c[2][2], c[2][3], c[2][4] = bLeft, bTop, bLeft, bTop + cl
        c[3][1], c[3][2], c[3][3], c[3][4] = bRight, bTop, bRight - cl, bTop
        c[4][1], c[4][2], c[4][3], c[4][4] = bRight, bTop, bRight, bTop + cl
        c[5][1], c[5][2], c[5][3], c[5][4] = bLeft, bBot, bLeft + cl, bBot
        c[6][1], c[6][2], c[6][3], c[6][4] = bLeft, bBot, bLeft, bBot - cl
        c[7][1], c[7][2], c[7][3], c[7][4] = bRight, bBot, bRight - cl, bBot
        c[8][1], c[8][2], c[8][3], c[8][4] = bRight, bBot, bRight, bBot - cl
        for i = 1, 8 do drawLine(esp.corners[i], c[i][1], c[i][2], c[i][3], c[i][4], color) end
    end
end

local function ensureHighlight(esp, adornee, color)
    if not esp.highlight then
        esp.highlight = Instance.new("Highlight")
        esp.highlight.Name = "ARC3USX_ESP"
        esp.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.highlight.FillTransparency = 0.55
        esp.highlight.OutlineTransparency = 0
        esp.highlight.Parent = CoreGui
        esp.highlight.Adornee = adornee
        esp.highlight.FillColor = color
        esp.highlight.OutlineColor = color
        esp.highlight.Enabled = true
        return
    end
    if not esp.highlight.Enabled then esp.highlight.Enabled = true end
    if esp.highlight.FillColor ~= color then
        esp.highlight.FillColor = color; esp.highlight.OutlineColor = color
    end
    if esp.highlight.Adornee ~= adornee then esp.highlight.Adornee = adornee end
end

-- ═══════════════════════════════════════════════════════════════
--  FLAGS
-- ═══════════════════════════════════════════════════════════════
local function getFlag(name, default)
    local v = Library.Flags[name]
    if v == nil then Library.Flags[name] = default; return default end
    return v
end

-- ═══════════════════════════════════════════════════════════════
--  STORES & HELPERS
-- ═══════════════════════════════════════════════════════════════
local plrStore, npcStore, heliStore = {}, {}, {}
local trackedOres, trackedHelis = {}, {}
local oreIcons = {}

local Colors = {
    plr_box = Color3.new(1,1,1), plr_name = Color3.new(1,1,1), plr_skel = Color3.new(1,1,1), plr_dist = Color3.new(1,1,1),
    plr_wep = Color3.fromRGB(0, 255, 255), plr_chams_vis = Color3.fromRGB(0, 255, 255), plr_chams_occ = Color3.fromRGB(255, 50, 80),
    plr_hp_high = Color3.fromRGB(0, 255, 0), plr_hp_low = Color3.fromRGB(255, 0, 0),
    npc_box = Color3.new(1,1,1), npc_name = Color3.new(1,1,1), npc_dist = Color3.new(1,1,1), npc_wep = Color3.fromRGB(255, 180, 60),
    npc_chams_vis = Color3.fromRGB(60, 255, 120), npc_chams_occ = Color3.fromRGB(255, 50, 80),
    heli = Color3.fromRGB(255, 170, 0), white = Color3.new(1, 1, 1),
}

local function getScreenPos(pos)
    local sp, onScreen = Camera:WorldToViewportPoint(pos)
    if sp.Z <= 0 then onScreen = false end
    return sp.X, sp.Y, onScreen
end

local function nearViewport(x, y)
    local size = Camera.ViewportSize
    return x >= -160 and y >= -160 and x <= size.X + 160 and y <= size.Y + 160
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
local function isVisible(model, root)
    if not root then return false end
    local origin = Camera.CFrame.Position; local dir = root.Position - origin
    if dir.Magnitude < 0.1 then return true end
    local ignore = { model }
    if LocalPlayer.Character then ignore[#ignore + 1] = LocalPlayer.Character end
    rayParams.FilterDescendantsInstances = ignore
    local result = Workspace:Raycast(origin, dir, rayParams)
    return not result or result.Instance:IsDescendantOf(model)
end

local function getRoot(model)
    if model:IsA("BasePart") then return model end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChild("Head") or model:FindFirstChildWhichIsA("BasePart")
end
local bonesR15 = { {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"UpperTorso", "RightUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"}, {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"RightUpperLeg", "RightLowerLeg"} }
local bonesR6 = { {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"} }

-- ─── Ore icon helpers ─────────────────────────────────────────
local function safeIconGet(itemName)
    if not ItemIcons then return nil end
    local ok, data = pcall(function() return ItemIcons.Get(itemName) end)
    if ok then return data end
    return nil
end

local function safeIconAbbr(itemName)
    if ItemIcons and ItemIcons.Abbr then
        local ok, a = pcall(function() return ItemIcons.Abbr(itemName) end)
        if ok and type(a) == "string" then return a end
    end
    return string.upper(string.sub(itemName, 1, 3))
end

local function safeIconColor(itemName)
    if ItemIcons and ItemIcons.Color then
        local ok, c = pcall(function() return ItemIcons.Color(itemName) end)
        if ok and typeof(c) == "Color3" then return c end
    end
    return Color3.new(1,1,1)
end

local function createOreIcon(desc)
    local itemName = OreItemMap[desc.Name] or desc.Name
    local entry = { hidden = false, frameId = 0 }
    local data = safeIconGet(itemName)

    if data and data.model and data.camCF then
        local view = Instance.new("ViewportFrame")
        view.Name = "ARC3USX_OreIcon"
        view.BackgroundTransparency = 1
        view.BorderSizePixel = 0
        view.Ambient = Color3.fromRGB(150, 145, 138)
        view.LightColor = Color3.fromRGB(255, 244, 226)
        view.LightDirection = Vector3.new(-1, -1.4, -0.6)
        view.AnchorPoint = Vector2.new(0.5, 0.5)
        view.Visible = false
        view.Parent = espGui

        local cam = Instance.new("Camera")
        cam.FieldOfView = ItemIcons.FOV or 30
        cam.CFrame = data.camCF
        cam.Parent = view
        view.CurrentCamera = cam

        local clone = data.model:Clone()
        clone.Parent = view
        entry.view = view
    else
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.TextSize = 16
        lbl.Font = Enum.Font.GothamBold
        lbl.TextStrokeTransparency = 0.4
        lbl.AnchorPoint = Vector2.new(0.5, 0.5)
        lbl.Size = UDim2.fromOffset(40, 20)
        lbl.Visible = false
        lbl.Text = safeIconAbbr(itemName)
        lbl.TextColor3 = safeIconColor(itemName)
        lbl.Parent = espGui
        entry.view = lbl
    end

    entry.distLabel = createText(3)
    entry.distLabel.TextSize = 12
    entry.distLabel.Font = Enum.Font.Gotham
    entry.distLabel.TextColor3 = Color3.new(1,1,1)
    entry.distLabel.Visible = false
    return entry
end

local function destroyOreIcon(entry)
    if not entry then return end
    if entry.view then entry.view:Destroy() end
    if entry.distLabel then entry.distLabel:Destroy() end
end

local function hideOreIcon(entry)
    if not entry or entry.hidden then return end
    entry.hidden = true; entry.frameId = 0
    if entry.view then entry.view.Visible = false end
    if entry.distLabel then entry.distLabel.Visible = false end
end

local function markOre(entry)
    entry.frameId = currentFrame
    entry.hidden = false
end

local function trackOre(desc)
    if OreItemMap[desc.Name] and (desc:IsA("BasePart") or desc:IsA("Model")) then
        trackedOres[desc] = true
    end
end
local function trackHeli(desc)
    if desc.Name == "PatrolHeli" and desc:IsA("Model") then trackedHelis[desc] = true end
end

connect(Workspace.DescendantAdded, function(desc) trackOre(desc); trackHeli(desc) end)
connect(Workspace.DescendantRemoving, function(desc)
    if trackedOres[desc] then
        trackedOres[desc] = nil
        local entry = oreIcons[desc]
        if entry then destroyOreIcon(entry); oreIcons[desc] = nil end
    end
    if trackedHelis[desc] then
        trackedHelis[desc] = nil
        if heliStore[desc] then destroyEsp(heliStore[desc]); heliStore[desc] = nil end
    end
end)
task.spawn(function()
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if unloaded then return end
        trackOre(desc); trackHeli(desc)
    end
end)
connect(Players.PlayerRemoving, function(plr)
    local char = plr.Character
    if char and plrStore[char] then destroyEsp(plrStore[char]); plrStore[char] = nil end
end)

-- ═══════════════════════════════════════════════════════════════
--  MAIN RENDER LOOP (throttled, reconciled ESP)
-- ═══════════════════════════════════════════════════════════════
local lastEspTick = 0
local nextPrune = 0
local nextEspWarn = 0

-- If the ScreenGui is removed externally (respawn cleanup, another script),
-- rebuild it and drop all stale overlays instead of drawing into a dead GUI.
local function rebuildEspGui()
    for _, e in pairs(plrStore) do destroyEsp(e) end; table.clear(plrStore)
    for _, e in pairs(npcStore) do destroyEsp(e) end; table.clear(npcStore)
    for _, e in pairs(heliStore) do destroyEsp(e) end; table.clear(heliStore)
    for _, e in pairs(oreIcons) do destroyOreIcon(e) end; table.clear(oreIcons)
    espGui = Instance.new("ScreenGui")
    espGui.Name = "ARC3USX_ESP_UI"
    espGui.ResetOnSpawn = false
    espGui.IgnoreGuiInset = true
    espGui.DisplayOrder = 999
    espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    espGui.Parent = CoreGui
end

connect(RunService.RenderStepped, function(dt)
    if unloaded then return end
    Camera = Workspace.CurrentCamera
    if not Camera then return end

    local now = tick()

    -- One throttled pass drives every ESP category. Flags are read once per
    -- pass rather than once per target, line-of-sight raycasts are cached,
    -- and property writes are skipped when values have not changed.
    local hz = getFlag("player_esp_hz", 60)
    if type(hz) ~= "number" or hz < 15 or hz > 240 then hz = 60 end
    if now - lastEspTick < (1 / hz) then return end
    lastEspTick = now
    currentFrame = currentFrame + 1
    local frame = currentFrame
    if not espGui or not espGui.Parent then pcall(rebuildEspGui) end

    local okEsp, espErr = pcall(function()
        local camPos = Camera.CFrame.Position
        local plrOn  = getFlag("plr_master", true) and getFlag("plr_enabled", false)
        local npcOn  = getFlag("npc_master", true) and getFlag("npc_enabled", false)
        local oreOn  = getFlag("ore_master", true) and getFlag("ore_enabled", false)
        local heliOn = getFlag("heli_master", true) and getFlag("heli_enabled", false)

        -- ─── Players ─────────────────────────────────────────────────
        if plrOn then
            local maxDistStuds = getFlag("plr_max_dist", 500) * METER_TO_STUD
            local boxOn, boxStyle = getFlag("plr_box", true), getFlag("plr_style", "Corners")
            local nameOn, distOn, wepOn = getFlag("plr_name", true), getFlag("plr_dist", true), getFlag("plr_weapon", true)
            local hpOn, skelOn, chamsOn = getFlag("plr_health", true), getFlag("plr_skel", true), getFlag("plr_chams", true)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    local char = plr.Character
                    local hum  = char and char:FindFirstChild("Humanoid")
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if char and char.Parent and hum and root and hum.Health > 0 then
                        local distStuds = (root.Position - camPos).Magnitude
                        if distStuds <= maxDistStuds then
                            local rx, ry, rOn = getScreenPos(root.Position)
                            if rOn and nearViewport(rx, ry) then
                                local cf, size = char:GetBoundingBox()
                                local topX, topY, topOn = getScreenPos(cf.Position + Vector3.new(0, size.Y * 0.5, 0))
                                local botX, botY, botOn = getScreenPos(cf.Position - Vector3.new(0, size.Y * 0.5, 0))
                                if topOn and botOn then
                                    local esp = plrStore[char]
                                    if not esp then esp = buildEsp(); plrStore[char] = esp end
                                    markEsp(esp)
                                    local h = math.max(botY - topY, 1); local w = math.max(h * 0.55, 1)
                                    local bLeft, bRight = topX - w * 0.5, topX + w * 0.5

                                    if chamsOn then
                                        if now >= (esp.nextVisCheck or 0) then
                                            esp.nextVisCheck = now + 0.12
                                            local vis = isVisible(char, root)
                                            if esp.lastVisible ~= vis then
                                                ensureHighlight(esp, char, vis and Colors.plr_chams_vis or Colors.plr_chams_occ)
                                                esp.lastVisible = vis
                                            end
                                        end
                                        if esp.highlight and not esp.highlight.Enabled then esp.highlight.Enabled = true end
                                    elseif esp.highlight and esp.highlight.Enabled then
                                        esp.highlight.Enabled = false
                                    end

                                    if boxOn then drawBox(esp, bLeft, topY, bRight, botY, boxStyle, Colors.plr_box) else hideBox(esp) end
                                    setLabel(esp.name, nameOn, plr.Name, Colors.plr_name, topX, topY - 16)
                                    local meters = math.floor(distStuds * STUD_TO_METER)
                                    esp.lastDist = meters
                                    setLabel(esp.distance, distOn, tostring(meters) .. "m", Colors.plr_dist, topX, botY + 16)
                                    local tool = char:FindFirstChildWhichIsA("Tool")
                                    setLabel(esp.weapon, wepOn, tool and tool.Name or "Unarmed", Colors.plr_wep, topX, botY + 32)

                                    if hpOn then
                                        local hpPerc = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                                        setFrame(esp.healthBg, bLeft - 6, topY, 4, h)
                                        setFrame(esp.healthFill, bLeft - 5, topY + h * (1 - hpPerc), 2, h * hpPerc)
                                        local hpColor = Colors.plr_hp_low:Lerp(Colors.plr_hp_high, hpPerc)
                                        if esp.healthFill.BackgroundColor3 ~= hpColor then esp.healthFill.BackgroundColor3 = hpColor end
                                        if not esp.healthBg.Visible then esp.healthBg.Visible = true end
                                        if not esp.healthFill.Visible then esp.healthFill.Visible = true end
                                    else
                                        if esp.healthBg.Visible then esp.healthBg.Visible = false end
                                        if esp.healthFill.Visible then esp.healthFill.Visible = false end
                                    end

                                    if skelOn then
                                        local activeBones = char:FindFirstChild("UpperTorso") and bonesR15 or bonesR6
                                        for i, bone in ipairs(activeBones) do
                                            local p1, p2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                                            local line = esp.skeleton[i]
                                            if p1 and p2 then
                                                local x1, y1, on1 = getScreenPos(p1.Position)
                                                local x2, y2, on2 = getScreenPos(p2.Position)
                                                if on1 and on2 then drawLine(line, x1, y1, x2, y2, Colors.plr_skel)
                                                elseif line.Visible then line.Visible = false end
                                            elseif line.Visible then line.Visible = false end
                                        end
                                        for i = #activeBones + 1, #esp.skeleton do
                                            if esp.skeleton[i].Visible then esp.skeleton[i].Visible = false end
                                        end
                                    else
                                        for _, l in ipairs(esp.skeleton) do if l.Visible then l.Visible = false end end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- ─── NPCs ────────────────────────────────────────────────────
        if npcOn then
            local maxDistStuds = getFlag("npc_max_dist", 500) * METER_TO_STUD
            local boxOn, boxStyle = getFlag("npc_box", true), getFlag("npc_style", "Corners")
            local nameOn, distOn, wepOn = getFlag("npc_name", true), getFlag("npc_dist", true), getFlag("npc_weapon", true)
            local chamsOn = getFlag("npc_chams", true)
            local npcFolder = Workspace:FindFirstChild("Npcs")
            if npcFolder then
                for _, model in ipairs(npcFolder:GetChildren()) do
                    if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            local root = getRoot(model)
                            local distStuds = root and (root.Position - camPos).Magnitude or math.huge
                            if root and distStuds <= maxDistStuds then
                                local rx, ry, rOn = getScreenPos(root.Position)
                                if rOn and nearViewport(rx, ry) then
                                    local cf, size = model:GetBoundingBox()
                                    local topX, topY, topOn = getScreenPos(cf.Position + Vector3.new(0, size.Y * 0.5, 0))
                                    local botX, botY, botOn = getScreenPos(cf.Position - Vector3.new(0, size.Y * 0.5, 0))
                                    if topOn and botOn then
                                        local esp = npcStore[model]
                                        if not esp then esp = buildEsp(); npcStore[model] = esp end
                                        markEsp(esp)
                                        local h = math.max(botY - topY, 1); local w = math.max(h * 0.55, 1)
                                        local bLeft, bRight = topX - w * 0.5, topX + w * 0.5

                                        if chamsOn then
                                            if now >= (esp.nextVisCheck or 0) then
                                                esp.nextVisCheck = now + 0.12
                                                local vis = isVisible(model, root)
                                                if esp.lastVisible ~= vis then
                                                    ensureHighlight(esp, model, vis and Colors.npc_chams_vis or Colors.npc_chams_occ)
                                                    esp.lastVisible = vis
                                                end
                                            end
                                            if esp.highlight and not esp.highlight.Enabled then esp.highlight.Enabled = true end
                                        elseif esp.highlight and esp.highlight.Enabled then
                                            esp.highlight.Enabled = false
                                        end

                                        if boxOn then drawBox(esp, bLeft, topY, bRight, botY, boxStyle, Colors.npc_box) else hideBox(esp) end
                                        setLabel(esp.name, nameOn, model.Name, Colors.npc_name, topX, topY - 16)
                                        local meters = math.floor(distStuds * STUD_TO_METER)
                                        esp.lastDist = meters
                                        setLabel(esp.distance, distOn, tostring(meters) .. "m", Colors.npc_dist, topX, botY + 16)
                                        local tool = model:FindFirstChildWhichIsA("Tool")
                                        setLabel(esp.weapon, wepOn, tool and tool.Name or "Unarmed", Colors.npc_wep, topX, botY + 32)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        -- ─── Ores (3D ViewportFrame icons) ───────────────────────────
        -- Cap new icons per pass so a batch of nodes entering render distance
        -- cannot spike the frame; the rest appear on the following pass.
        if oreOn then
            local maxDistStuds = getFlag("ore_max_dist", 300) * METER_TO_STUD
            local distOn = getFlag("ore_dist", true)
            local newIcons = 0
            for desc in pairs(trackedOres) do
                if desc.Parent and getFlag("ore_" .. desc.Name, true) then
                    local root = getRoot(desc)
                    if root then
                        local distStuds = (root.Position - camPos).Magnitude
                        if distStuds <= maxDistStuds then
                            local px, py, onScreen = getScreenPos(root.Position)
                            if onScreen and nearViewport(px, py) then
                                local entry = oreIcons[desc]
                                if not entry and newIcons < 2 then
                                    entry = createOreIcon(desc)
                                    oreIcons[desc] = entry
                                    newIcons = newIcons + 1
                                end
                                if entry and entry.view then
                                    markOre(entry)
                                    local size = math.clamp(3000 / math.max(distStuds, 1), 22, 64)
                                    setCentered(entry.view, px, py, size)
                                    local meters = math.floor(distStuds * STUD_TO_METER)
                                    setLabel(entry.distLabel, distOn, tostring(meters) .. "m", Colors.white, px, py + size * 0.5 + 8)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- ─── Helis ───────────────────────────────────────────────────
        if heliOn then
            local maxDistStuds = getFlag("heli_max_dist", 2000) * METER_TO_STUD
            local distOn, chamsOn = getFlag("heli_dist", true), getFlag("heli_chams", true)
            local style = getFlag("heli_style", "Full")
            for desc in pairs(trackedHelis) do
                if desc.Parent then
                    local root = getRoot(desc)
                    if root then
                        local distStuds = (root.Position - camPos).Magnitude
                        if distStuds <= maxDistStuds then
                            local rx, ry, rOn = getScreenPos(root.Position)
                            if rOn and nearViewport(rx, ry) then
                                local cf, size = desc:GetBoundingBox()
                                local topX, topY, topOn = getScreenPos(cf.Position + Vector3.new(0, size.Y * 0.5, 0))
                                local botX, botY, botOn = getScreenPos(cf.Position - Vector3.new(0, size.Y * 0.5, 0))
                                if topOn and botOn then
                                    local esp = heliStore[desc]
                                    if not esp then esp = buildEsp(); heliStore[desc] = esp end
                                    markEsp(esp)
                                    local h = math.max(botY - topY, 1); local w = math.max(h * 0.8, 1)
                                    local bLeft, bRight = topX - w * 0.5, topX + w * 0.5
                                    if chamsOn then ensureHighlight(esp, desc, Colors.heli)
                                    elseif esp.highlight and esp.highlight.Enabled then esp.highlight.Enabled = false end
                                    drawBox(esp, bLeft, topY, bRight, botY, style, Colors.heli)
                                    local meters = math.floor(distStuds * STUD_TO_METER)
                                    esp.lastDist = meters
                                    setLabel(esp.distance, distOn, tostring(meters) .. "m", Colors.white, topX, botY + 16)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- ─── Reconciliation ──────────────────────────────────────────
        -- Anything not drawn this frame (dead, gone, out of range, off screen,
        -- toggled off) is hidden exactly once. Overlays for objects that left
        -- the workspace are destroyed so memory does not grow over time.
        for char, esp in pairs(plrStore) do
            if esp.frameId ~= frame then hideEsp(esp) end
            if not char.Parent then destroyEsp(esp); plrStore[char] = nil end
        end
        for model, esp in pairs(npcStore) do
            if esp.frameId ~= frame then hideEsp(esp) end
            if not model.Parent then destroyEsp(esp); npcStore[model] = nil end
        end
        for desc, esp in pairs(heliStore) do
            if esp.frameId ~= frame then hideEsp(esp) end
            if not desc.Parent then destroyEsp(esp); heliStore[desc] = nil end
        end
        for desc, entry in pairs(oreIcons) do
            if entry.frameId ~= frame then hideOreIcon(entry) end
            if not desc.Parent then destroyOreIcon(entry); oreIcons[desc] = nil end
        end

        if now >= nextPrune then
            nextPrune = now + 0.5
            for desc in pairs(trackedOres) do
                if not desc.Parent then
                    trackedOres[desc] = nil
                    local e = oreIcons[desc]
                    if e then destroyOreIcon(e); oreIcons[desc] = nil end
                end
            end
            for desc in pairs(trackedHelis) do
                if not desc.Parent then
                    trackedHelis[desc] = nil
                    local e = heliStore[desc]
                    if e then destroyEsp(e); heliStore[desc] = nil end
                end
            end
        end
    end)
    if not okEsp then
        for _, e in pairs(plrStore) do hideEsp(e) end
        for _, e in pairs(npcStore) do hideEsp(e) end
        for _, e in pairs(heliStore) do hideEsp(e) end
        for _, e in pairs(oreIcons) do hideOreIcon(e) end
        if now >= nextEspWarn then
            nextEspWarn = now + 1
            warn("[ARC3USX] ESP pass error: " .. tostring(espErr))
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  UI BUILDING
-- ═══════════════════════════════════════════════════════════════
-- Intro = true starts the loading screen that lives inside ARC3USX.lua
-- (compatibility checks, progress bar, ACCESS GRANTED reveal).
local Window = Library:CreateWindow({ Name = "ARC3USX.EXE", Size = Vector2.new(800, 620), Intro = true, Theme = "Purple" })
local Visuals = Window:AddTab("ESP / World")
local MiscTab = Window:AddTab("Misc")

-- PLAYER ESP
local PlayerGroup = Visuals:AddGroup("Player ESP", "Left")
PlayerGroup:AddToggle({ Name = "Master Enable (Players)", Flag = "plr_master", Default = true })
PlayerGroup:AddToggle({ Name = "Player ESP Toggle", Flag = "plr_enabled", Default = false })
PlayerGroup:AddSlider({ Name = "ESP Update Rate (Hz)", Flag = "player_esp_hz", Min = 30, Max = 240, Default = 60, Suffix = " Hz" })
PlayerGroup:AddDropdown({ Name = "Box Style", Flag = "plr_style", Options = {"Corners", "Full"}, Default = "Corners" })
PlayerGroup:AddSlider({ Name = "Max Distance", Flag = "plr_max_dist", Min = 10, Max = 2000, Default = 500, Suffix = "m" })
PlayerGroup:AddToggle({ Name = "Box", Flag = "plr_box", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.plr_box = c end })
PlayerGroup:AddToggle({ Name = "Name", Flag = "plr_name", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.plr_name = c end })
PlayerGroup:AddToggle({ Name = "Health Bar", Flag = "plr_health", Default = true, Colors = { Color3.fromRGB(0,255,0), Color3.fromRGB(255,0,0) }, ColorCallback = function(i, c) if i==1 then Colors.plr_hp_high = c else Colors.plr_hp_low = c end end })
PlayerGroup:AddToggle({ Name = "Distance", Flag = "plr_dist", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.plr_dist = c end })
PlayerGroup:AddToggle({ Name = "Weapon", Flag = "plr_weapon", Default = true, Colors = { Color3.fromRGB(0, 255, 255) }, ColorCallback = function(i, c) Colors.plr_wep = c end })
PlayerGroup:AddToggle({ Name = "Skeleton", Flag = "plr_skel", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.plr_skel = c end })
PlayerGroup:AddToggle({ Name = "Chams", Flag = "plr_chams", Default = true, Colors = { Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 50, 80) }, ColorCallback = function(i, c) if i == 1 then Colors.plr_chams_vis = c else Colors.plr_chams_occ = c end end })

-- NPC ESP
local NPCGroup = Visuals:AddGroup("NPC ESP", "Right")
NPCGroup:AddToggle({ Name = "Master Enable (NPCs)", Flag = "npc_master", Default = true })
NPCGroup:AddToggle({ Name = "NPC ESP Toggle", Flag = "npc_enabled", Default = false })
NPCGroup:AddDropdown({ Name = "Box Style", Flag = "npc_style", Options = {"Corners", "Full"}, Default = "Corners" })
NPCGroup:AddSlider({ Name = "Max Distance", Flag = "npc_max_dist", Min = 10, Max = 2000, Default = 500, Suffix = "m" })
NPCGroup:AddToggle({ Name = "Box", Flag = "npc_box", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.npc_box = c end })
NPCGroup:AddToggle({ Name = "Name", Flag = "npc_name", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.npc_name = c end })
NPCGroup:AddToggle({ Name = "Distance", Flag = "npc_dist", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.npc_dist = c end })
NPCGroup:AddToggle({ Name = "Weapon", Flag = "npc_weapon", Default = true, Colors = { Color3.fromRGB(255, 180, 60) }, ColorCallback = function(i, c) Colors.npc_wep = c end })
NPCGroup:AddToggle({ Name = "Chams", Flag = "npc_chams", Default = true, Colors = { Color3.fromRGB(60, 255, 120), Color3.fromRGB(255, 50, 80) }, ColorCallback = function(i, c) if i == 1 then Colors.npc_chams_vis = c else Colors.npc_chams_occ = c end end })

-- ORE ESP (icon-based)
local OreGroup = Visuals:AddGroup("Ore ESP (Icons)", "Left")
OreGroup:AddToggle({ Name = "Master Enable (Ores)", Flag = "ore_master", Default = true })
OreGroup:AddToggle({ Name = "Ore ESP Toggle", Flag = "ore_enabled", Default = false })
OreGroup:AddSlider({ Name = "Max Distance", Flag = "ore_max_dist", Min = 10, Max = 2000, Default = 300, Suffix = "m" })
OreGroup:AddToggle({ Name = "Show Distance", Flag = "ore_dist", Default = true })
for _, oreName in ipairs({"Cactus", "MetalNode", "SulfurNode", "Tree", "Meteor", "StoneNode"}) do
    OreGroup:AddToggle({ Name = oreName, Flag = "ore_" .. oreName, Default = true })
end

-- HELI ESP
local HeliGroup = Visuals:AddGroup("Heli ESP", "Right")
HeliGroup:AddToggle({ Name = "Master Enable (Heli)", Flag = "heli_master", Default = true })
HeliGroup:AddToggle({ Name = "Heli ESP Toggle", Flag = "heli_enabled", Default = false })
HeliGroup:AddDropdown({ Name = "Box Style", Flag = "heli_style", Options = {"Corners", "Full"}, Default = "Full" })
HeliGroup:AddSlider({ Name = "Max Distance", Flag = "heli_max_dist", Min = 10, Max = 5000, Default = 2000, Suffix = "m" })
HeliGroup:AddToggle({ Name = "Chams", Flag = "heli_chams", Default = true })
HeliGroup:AddToggle({ Name = "Show Distance", Flag = "heli_dist", Default = true })

-- ESP Preview
local Preview = Visuals:AddGroup("ESP Preview", "Right")
pcall(function()
    Preview:AddESPPreview({
        Height = 280, PlayerName = "Target",
        Elements = { Box = "plr_box", BoxStyle = "plr_style", Name = "plr_name", Health = "plr_health", Distance = "plr_dist", Tool = "plr_weapon", Skeleton = "plr_skel", Chams = "plr_chams" }
    })
end)

-- ═══════════════════════════════════════════════════════════════
--  MISC TAB
-- ═══════════════════════════════════════════════════════════════
local MiscGroup = MiscTab:AddGroup("System", "Left")
MiscGroup:AddButton({
    Name = "Unload Script & Clear Memory",
    Callback = function()
        unloaded = true
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        table.clear(connections)
        for _, e in pairs(plrStore) do destroyEsp(e) end; table.clear(plrStore)
        for _, e in pairs(npcStore) do destroyEsp(e) end; table.clear(npcStore)
        for _, e in pairs(heliStore) do destroyEsp(e) end; table.clear(heliStore)
        for _, e in pairs(oreIcons) do destroyOreIcon(e) end; table.clear(oreIcons)
        table.clear(trackedOres); table.clear(trackedHelis)
        if espGui then espGui:Destroy() end
        pcall(function() Library:Unload() end)
    end
})

Window:AddSettingsTab()
