-- ═══════════════════════════════════════════════════════════════
--  ARC3USX.EXE — ULTIMATE OPTIMIZED HUB
--  SMOOTH ESP + SILENT INSTA-HIT + FUST COMBAT AIM ASSIST
--
--  Entry point for the hub. The UI library lives in ARC3USX.lua at the
--  repository root; everything below is the hub's feature set.
-- ═══════════════════════════════════════════════════════════════

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local LIBRARY_URL = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/main/ARC3USX.lua"
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

local function drawLine(line, fromX, fromY, toX, toY, color)
    if not line then return end
    local dx = toX - fromX
    local dy = toY - fromY
    local length = math.sqrt(dx * dx + dy * dy)
    if length < 0.5 then
        if line.Visible then line.Visible = false end
        return
    end
    local angle = math.deg(math.atan2(dy, dx))
    line.Position = UDim2.fromOffset(math.floor(fromX), math.floor(fromY))
    line.Size = UDim2.fromOffset(math.floor(length), 1)
    line.Rotation = angle
    line.BackgroundColor3 = color
    if not line.Visible then line.Visible = true end
end

local function buildEsp()
    local esp = {
        box = createBox(1), name = createText(3), distance = createText(3), weapon = createText(3),
        healthBg = createBox(1), healthFill = createBox(1), highlight = nil,
        corners = {}, skeleton = {}, lastHp = -1, lastDist = -1, lastVisible = nil
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

local function hideEsp(esp)
    if not esp then return end
    esp.box.Visible = false; esp.name.Visible = false; esp.distance.Visible = false
    esp.weapon.Visible = false; esp.healthBg.Visible = false; esp.healthFill.Visible = false
    if esp.highlight then esp.highlight.Enabled = false end
    for _, c in ipairs(esp.corners) do c.Visible = false end
    for _, l in ipairs(esp.skeleton) do l.Visible = false end
end

local function drawBox(esp, bLeft, bTop, bRight, bBot, style, color)
    if style == "Full" then
        for _, c in ipairs(esp.corners) do c.Visible = false end
        esp.box.Visible = true
        esp.box.BackgroundTransparency = 1
        esp.box.BorderColor3 = color
        esp.box.Position = UDim2.fromOffset(math.floor(bLeft), math.floor(bTop))
        esp.box.Size = UDim2.fromOffset(math.floor(bRight - bLeft), math.floor(bBot - bTop))
    else
        esp.box.Visible = false
        local w = bRight - bLeft; local h = bBot - bTop; local cl = math.max(w * 0.22, h * 0.14)
        local corners = {
            {bLeft, bTop, bLeft + cl, bTop}, {bLeft, bTop, bLeft, bTop + cl},
            {bRight, bTop, bRight - cl, bTop}, {bRight, bTop, bRight, bTop + cl},
            {bLeft, bBot, bLeft + cl, bBot}, {bLeft, bBot, bLeft, bBot - cl},
            {bRight, bBot, bRight - cl, bBot}, {bRight, bBot, bRight, bBot - cl}
        }
        for i, c in ipairs(corners) do drawLine(esp.corners[i], c[1], c[2], c[3], c[4], color) end
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
--  STAFF DETECTOR
-- ═══════════════════════════════════════════════════════════════
local StaffDetector = {
    StaffState = nil, AdminPerms = nil,
    RoleColors = {
        owner = Color3.fromRGB(255, 215, 0), co_owner = Color3.fromRGB(255, 165, 0),
        lead_admin = Color3.fromRGB(255, 80, 80), admin = Color3.fromRGB(255, 120, 120),
        junior_admin = Color3.fromRGB(255, 160, 80), mod = Color3.fromRGB(80, 200, 255),
        junior_mod = Color3.fromRGB(120, 220, 255), lab = Color3.fromRGB(180, 100, 255)
    },
    FallbackLabels = { owner = "Owner", co_owner = "Co-Owner", lead_admin = "Lead Admin", admin = "Admin", junior_admin = "Junior Admin", mod = "Moderator", junior_mod = "Junior Moderator", lab = "AC Lab Tester" },
    FallbackRanks = { owner = 7, co_owner = 6, lead_admin = 5, admin = 4, junior_admin = 3, mod = 2, junior_mod = 1, lab = 2 },
    Highlights = {}, Cache = {}, Connected = {}, MonitorEnabled = false,
}
local function safeRequire(module)
    if module and module:IsA("ModuleScript") then
        local ok, result = pcall(require, module)
        if ok and type(result) == "table" then return result end
    end
    return nil
end

task.spawn(function()
    local Fust = ReplicatedStorage:FindFirstChild("Fust") or ReplicatedStorage:WaitForChild("Fust", 10)
    if Fust then
        StaffDetector.StaffState = safeRequire(Fust:FindFirstChild("StaffState"))
        StaffDetector.AdminPerms = safeRequire(Fust:FindFirstChild("AdminPerms"))
    end
end)

function StaffDetector:GetRole(player)
    if typeof(player) ~= "Instance" or not player:IsA("Player") or player == LocalPlayer then return nil end
    local SS = self.StaffState
    if SS and type(SS.get) == "function" then
        local ok, role = pcall(SS.get, player, "AdminRole")
        if ok and type(role) == "string" and role ~= "" then return role end
    end
    local attr = player:GetAttribute("AdminRole")
    if type(attr) == "string" and attr ~= "" then return attr end
    return nil
end
function StaffDetector:GetLabel(role)
    if not role then return nil end
    local AP = self.AdminPerms
    if AP and type(AP.Label) == "table" and AP.Label[role] then return AP.Label[role] end
    return self.FallbackLabels[role] or role
end
function StaffDetector:GetRank(role)
    if not role then return 0 end
    local AP = self.AdminPerms
    if AP and type(AP.Rank) == "function" then
        local ok, rank = pcall(AP.Rank, role)
        if ok and type(rank) == "number" then return rank end
    end
    return self.FallbackRanks[role] or 0
end
function StaffDetector:GetColor(role) return self.RoleColors[role] or Color3.fromRGB(200, 200, 200) end
function StaffDetector:Scan()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        local role = self:GetRole(plr)
        if role then
            table.insert(list, { player = plr, role = role, label = self:GetLabel(role), rank = self:GetRank(role), color = self:GetColor(role) })
        end
    end
    table.sort(list, function(a, b) return a.rank > b.rank end)
    return list
end
function StaffDetector:ClearESP()
    for _, hl in pairs(self.Highlights) do pcall(function() hl:Destroy() end) end
    self.Highlights = {}
end
function StaffDetector:UpdateESP(enabled)
    self:ClearESP()
    if not enabled then return end
    for _, entry in ipairs(self:Scan()) do
        local char = entry.player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hl = Instance.new("Highlight")
            hl.Name = "FustStaffDetect_" .. entry.player.Name
            hl.Adornee = char
            hl.FillColor = entry.color
            hl.OutlineColor = entry.color
            hl.FillTransparency = 0.55
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = CoreGui
            self.Highlights[entry.player] = hl
        end
    end
end
local notifyFn = function(text) print(string.format("[StaffDetector] %s", text)) end
function StaffDetector:SetNotifier(fn) if type(fn) == "function" then notifyFn = fn end end
function StaffDetector:StartMonitor()
    if self.MonitorEnabled then return end
    self.MonitorEnabled = true
    local seen = self.Cache
    for _, entry in ipairs(self:Scan()) do
        seen[entry.player] = entry.role
        notifyFn(entry.label .. " online: " .. entry.player.Name)
    end
    local SS = self.StaffState
    if SS and type(SS.changed) == "function" then
        local function hook(plr)
            if plr == LocalPlayer or self.Connected[plr] then return end
            local ok, signal = pcall(SS.changed, plr, "AdminRole")
            if not ok or not signal or not signal.Connect then return end
            self.Connected[plr] = signal:Connect(function()
                local role = self:GetRole(plr)
                if role then
                    seen[plr] = role
                    notifyFn("ROLE CHANGE: " .. plr.Name .. " -> " .. self:GetLabel(role))
                else
                    seen[plr] = nil
                end
                if self.EspEnabled then self:UpdateESP(true) end
            end)
        end
        for _, plr in ipairs(Players:GetPlayers()) do hook(plr) end
        self.PlayerAddedConnection = Players.PlayerAdded:Connect(hook)
    end
    task.spawn(function()
        while self.MonitorEnabled do
            task.wait(3)
            local current = {}
            for _, entry in ipairs(self:Scan()) do
                current[entry.player] = entry
                if seen[entry.player] ~= entry.role then
                    seen[entry.player] = entry.role
                    notifyFn("STAFF DETECTED: " .. entry.player.Name .. " — " .. entry.label)
                end
            end
            for plr in pairs(seen) do if not current[plr] then seen[plr] = nil end end
            if self.EspEnabled then self:UpdateESP(true) end
        end
    end)
end
function StaffDetector:StopMonitor()
    self.MonitorEnabled = false
    if self.PlayerAddedConnection then
        pcall(function() self.PlayerAddedConnection:Disconnect() end)
        self.PlayerAddedConnection = nil
    end
    for _, c in pairs(self.Connected) do pcall(function() c:Disconnect() end) end
    self.Connected = {}
    self:ClearESP()
end
connect(Players.PlayerRemoving, function(plr)
    local c = StaffDetector.Connected[plr]
    if c then pcall(function() c:Disconnect() end) end
    StaffDetector.Connected[plr] = nil
    StaffDetector.Cache[plr] = nil
    local hl = StaffDetector.Highlights[plr]
    if hl then pcall(function() hl:Destroy() end) end
    StaffDetector.Highlights[plr] = nil
end)

-- ═══════════════════════════════════════════════════════════════
--  SILENT INSTA-HIT WEAKSPOT (NO CAMERA LOCK)
-- ═══════════════════════════════════════════════════════════════
local NodeNames = { ["Tree"] = true, ["MetalNode"] = true, ["SulfurNode"] = true, ["StoneNode"] = true, ["Cactus"] = true, ["Meteor"] = true }
local WeakspotNames = { "Weakspot", "WeakSpot", "WeakPoint", "Weakpoint", "CriticalSpot", "CriticalPart", "Critical", "CritSpot", "Hitpoint", "HitPoint", "HitSpot", "Mark", "MarkSpot", "Bonus", "BonusSpot" }
local cachedNodes = {}
local lastHitTime = 0
local HIT_COOLDOWN = 0.12

task.spawn(function()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if NodeNames[v.Name] and (v:IsA("Model") or v:IsA("BasePart")) then table.insert(cachedNodes, v) end
    end
    connect(Workspace.DescendantAdded, function(v)
        if NodeNames[v.Name] and (v:IsA("Model") or v:IsA("BasePart")) then table.insert(cachedNodes, v) end
    end)
    connect(Workspace.DescendantRemoving, function(v)
        local i = table.find(cachedNodes, v)
        if i then table.remove(cachedNodes, i) end
    end)
end)

local function getWeakspotPosition(model)
    for _, name in ipairs(WeakspotNames) do
        local child = model:FindFirstChild(name, true)
        if child then
            if child:IsA("BasePart") then return child.Position end
            if child:IsA("Attachment") then return child.WorldPosition end
        end
    end
    return model:GetPivot().Position
end

local function getNearestNodeInRange(maxRange)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, closestDist = nil, maxRange or 50
    for _, node in ipairs(cachedNodes) do
        if node.Parent then
            local pos = getWeakspotPosition(node)
            local dist = (pos - hrp.Position).Magnitude
            if dist < closestDist then
                closestDist = dist
                closest = node
            end
        end
    end
    return closest
end

local function performInstaHit()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local name = tool.Name:lower()
    if not (name:find("pickaxe") or name:find("hatchet") or name:find("rock") or name:find("jackhammer") or name:find("chainsaw")) then return end

    local node = getNearestNodeInRange(50)
    if not node then return end

    local targetPos = getWeakspotPosition(node)
    local camPos = Camera.CFrame.Position
    if (targetPos - camPos).Magnitude < 0.5 then return end

    -- Silent snap: aim → activate → restore in the same tick.
    local savedCFrame = Camera.CFrame
    Camera.CFrame = CFrame.lookAt(camPos, targetPos)
    pcall(function() tool:Activate() end)
    if type(mouse1click) == "function" then pcall(mouse1click) end
    Camera.CFrame = savedCFrame
end

RunService:BindToRenderStep("ARC3USX_InstaHit", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if unloaded or not getFlag("weakspot_enabled", false) then return end
    local now = tick()
    if now - lastHitTime < HIT_COOLDOWN then return end
    lastHitTime = now
    performInstaHit()
end)

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
}

local function getScreenPos(pos)
    local sp, onScreen = Camera:WorldToViewportPoint(pos)
    if sp.Z <= 0 then onScreen = false end
    return sp.X, sp.Y, onScreen
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true
local function isVisible(model, root)
    if not root then return false end
    local origin = Camera.CFrame.Position; local dir = root.Position - origin
    if dir.Magnitude < 0.1 then return true end
    rayParams.FilterDescendantsInstances = { model, LocalPlayer.Character }
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
    local entry = {}
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
    if not entry then return end
    if entry.view then entry.view.Visible = false end
    if entry.distLabel then entry.distLabel.Visible = false end
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
--  FUST COMBAT AIM ASSIST (ported)
-- ═══════════════════════════════════════════════════════════════
local Aimbot
do
    local function createAimbot()
        local P          = game:GetService("Players")
        local RS         = game:GetService("RunService")
        local UIS        = game:GetService("UserInputService")
        local WS         = game:GetService("Workspace")
        local LP         = P.LocalPlayer
        local Cam        = WS.CurrentCamera

        local Config = {
            Enabled         = false,
            ToggleKey       = Enum.KeyCode.Z,
            HoldKey         = Enum.KeyCode.Q,
            CycleModeKey    = Enum.KeyCode.X,
            TargetPart      = "Head",
            FallbackOrder   = {"Head","UpperTorso","Torso","HumanoidRootPart"},
            FOV             = 180,
            MaxDistance     = 600,
            TeamCheck       = true,
            WallCheck       = true,
            Prediction      = 0.12,
            PingComp        = 0.0,
            MaxVel          = 500,
            Smoothness      = 0.10,
            BowAutoLock     = true,
            BowDrawTime     = 0.8,
            BowSpeedBase    = 95,
            BowSpeedCharge  = 125,
            BowGravity      = 50,
            BowMuzzle       = 1,
            BowChargeMode   = "auto",
            BowSmoothness   = 0.05,
            BowFOV          = 180,
            BowMaxDistance  = 300,
            BowSolveIters   = 5,
            ShowFOV         = true,
            ShowTarget      = true,
            ShowInfo        = true,
        }
        local MODES = { "Head", "HumanoidRootPart", "Closest", "Random" }
        local State = { Locked = false, Target = nil, Bow = false }

        local vFOV = Drawing.new("Circle")
        vFOV.Thickness = 1.5; vFOV.NumSides = 64
        vFOV.Color = Color3.fromRGB(255,255,255); vFOV.Filled = false; vFOV.Transparency = 0.7

        local vTarget = Drawing.new("Circle")
        vTarget.Thickness = 2; vTarget.NumSides = 32
        vTarget.Radius = 28; vTarget.Color = Color3.fromRGB(255,60,60); vTarget.Filled = false

        local vInfo = Drawing.new("Text")
        vInfo.Size = 14; vInfo.Center = true; vInfo.Outline = true
        vInfo.Color = Color3.fromRGB(255,255,255)

        local rmbPressTime = nil
        local connections = {}
        local function track(c) table.insert(connections, c); return c end

        track(UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.UserInputType == Enum.UserInputType.MouseButton2 then
                rmbPressTime = os.clock()
            end
        end))
        track(UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton2 then
                rmbPressTime = nil
            end
        end))

        local function isBowActive() return LP:GetAttribute("FustAimBow") == true end

        local function isCrossbow()
            local char = LP.Character
            if not char then return false end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then return false end
            local id = tool:GetAttribute("ItemId")
            if type(id) ~= "string" then return false end
            local lower = string.lower(id)
            return string.find(lower, "crossbow", 1, true) ~= nil or string.find(lower, "xbow", 1, true) ~= nil
        end

        local function getBowSpeed()
            if Config.BowChargeMode == "full" or isCrossbow() then
                return Config.BowSpeedBase + Config.BowSpeedCharge
            end
            local charge = 0
            if rmbPressTime then
                charge = math.clamp((os.clock() - rmbPressTime) / Config.BowDrawTime, 0, 1)
            end
            return Config.BowSpeedBase + Config.BowSpeedCharge * charge
        end

        local function solveBallistic(camPos, targetPos, targetVel, speed, gravity, muzzle, iters)
            speed  = math.max(speed, 1)
            muzzle = muzzle or 0
            iters  = iters  or 5
            local dir = (targetPos - camPos).Unit
            local t   = (targetPos - camPos).Magnitude / speed
            local aimPos
            for _ = 1, iters do
                local origin = camPos + dir * muzzle
                local D = targetPos + targetVel * t - origin + Vector3.new(0, 0.5 * gravity * t * t, 0)
                t   = D.Magnitude / speed
                dir = D.Unit
                aimPos = camPos + dir * math.max(t * speed, 10)
            end
            return dir, t, aimPos
        end

        local function alive(plr)
            local c = plr.Character
            if not c then return false end
            local h = c:FindFirstChildOfClass("Humanoid")
            return h and h.Health > 0
        end

        local function visible(char, targetPos, camPos)
            if not Config.WallCheck then return true end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = { LP.Character }
            params.IgnoreWater = true
            local hit = WS:Raycast(camPos, targetPos - camPos, params)
            return not hit or hit.Instance:IsDescendantOf(char)
        end

        local function resolvePart(char)
            local want = Config.TargetPart
            if type(want) == "string" then
                if want == "Closest" or want == "Random" then return nil end
                local p = char:FindFirstChild(want)
                if p and p:IsA("BasePart") then return p end
            end
            for _, name in ipairs(Config.FallbackOrder) do
                local p = char:FindFirstChild(name)
                if p and p:IsA("BasePart") then return p end
            end
            return nil
        end

        local function allAimParts(char)
            local out = {}
            for _, name in ipairs(Config.FallbackOrder) do
                local p = char:FindFirstChild(name)
                if p and p:IsA("BasePart") then table.insert(out, p) end
            end
            if #out == 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then table.insert(out, hrp) end
            end
            return out
        end

        local function findBest(bowMode)
            local camPos = Cam.CFrame.Position
            local center = Cam.ViewportSize / 2
            local fov     = bowMode and Config.BowFOV       or Config.FOV
            local maxDist = bowMode and Config.BowMaxDistance or Config.MaxDistance
            local speed   = bowMode and getBowSpeed()      or nil
            local best, bestScore = nil, math.huge

            for _, plr in ipairs(P:GetPlayers()) do
                if plr ~= LP and alive(plr) and not (Config.TeamCheck and plr.Team == LP.Team) then
                    local char = plr.Character
                    local hrp  = char:FindFirstChild("HumanoidRootPart")
                    local candidates = {}
                    if Config.TargetPart == "Closest" or Config.TargetPart == "Random" then
                        candidates = allAimParts(char)
                    else
                        local p = resolvePart(char)
                        if p then candidates = { p } end
                    end
                    for _, part in ipairs(candidates) do
                        local dist = (part.Position - camPos).Magnitude
                        if dist <= maxDist then
                            local vel = (hrp and hrp.AssemblyLinearVelocity) or part.AssemblyLinearVelocity
                            if vel.Magnitude > Config.MaxVel then vel = Vector3.zero end
                            local sp, on = Cam:WorldToViewportPoint(part.Position)
                            if on and sp.Z > 0 then
                                local delta = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                                if delta <= fov and visible(char, part.Position, camPos) then
                                    local aimDir, aimPos, flyT
                                    if bowMode then
                                        aimDir, flyT, aimPos = solveBallistic(camPos, part.Position, vel, speed, Config.BowGravity, Config.BowMuzzle, Config.BowSolveIters)
                                    else
                                        local lead = Config.Prediction + Config.PingComp
                                        aimPos = part.Position + vel * lead
                                        aimDir = (aimPos - camPos).Unit
                                    end
                                    local score = delta + dist * 0.02
                                    if Config.TargetPart == "Random" then
                                        score = score * (0.85 + math.random() * 0.3)
                                    end
                                    if score < bestScore then
                                        bestScore = score
                                        best = {
                                            char = char, part = part, pos = part.Position,
                                            vel = vel, dist = dist, aimDir = aimDir, aimPos = aimPos,
                                            flyT = flyT, isBow = bowMode, speed = speed,
                                        }
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return best
        end

        track(UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Config.ToggleKey then
                Config.Enabled = not Config.Enabled
            elseif input.KeyCode == Config.HoldKey then
                State.Locked = true
            elseif input.KeyCode == Config.CycleModeKey then
                local idx = 1
                for i, m in ipairs(MODES) do
                    if m == Config.TargetPart then idx = i break end
                end
                Config.TargetPart = MODES[(idx % #MODES) + 1]
            end
        end))

        track(UIS.InputEnded:Connect(function(input)
            if input.KeyCode == Config.HoldKey then
                State.Locked = false
            end
        end))

        RS:BindToRenderStep("ARC3USX_Aimbot", Enum.RenderPriority.Camera.Value + 10, function(dt)
            Cam = WS.CurrentCamera
            if not Cam then return end
            local bowMode = isBowActive()
            State.Bow = bowMode

            local active
            if bowMode and Config.BowAutoLock then
                active = Config.Enabled
            else
                active = Config.Enabled and State.Locked
            end

            local center = Cam.ViewportSize / 2
            local fov    = bowMode and Config.BowFOV or Config.FOV

            vFOV.Position = center
            vFOV.Radius   = fov
            vFOV.Visible  = Config.ShowFOV and Config.Enabled

            if Config.ShowInfo and Config.Enabled then
                local label = bowMode and ("bow (" .. Config.BowChargeMode .. "  spd=" .. math.floor(getBowSpeed()) .. ")") or "gun"
                vInfo.Text = ("%s | %s%s"):format(label, Config.TargetPart, active and "  [LOCKED]" or "  [hold Q]")
                vInfo.Position = center + Vector2.new(0, fov + 14)
                vInfo.Visible = true
            else
                vInfo.Visible = false
            end

            if not active then
                vTarget.Visible = false
                State.Target = nil
                return
            end

            local t = findBest(bowMode)
            State.Target = t
            if not t then
                vTarget.Visible = false
                return
            end

            local cur = Cam.CFrame
            local lookAt = t.isBow and (cur.Position + t.aimDir) or t.aimPos
            local desired = CFrame.lookAt(cur.Position, lookAt)
            local smooth = t.isBow and Config.BowSmoothness or Config.Smoothness
            local alpha = smooth <= 0 and 1 or (1 - math.exp(-dt / math.max(smooth, 0.0001)))
            Cam.CFrame = cur:Lerp(desired, alpha)

            local sp = Cam:WorldToViewportPoint(t.isBow and t.aimPos or t.pos)
            if sp.Z > 0 then
                vTarget.Position = Vector2.new(sp.X, sp.Y)
                vTarget.Visible = Config.ShowTarget
            else
                vTarget.Visible = false
            end
        end)

        local function cleanup()
            pcall(function() RS:UnbindFromRenderStep("ARC3USX_Aimbot") end)
            for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
            connections = {}
            pcall(function() vFOV:Remove() end)
            pcall(function() vTarget:Remove() end)
            pcall(function() vInfo:Remove() end)
        end

        return { Config = Config, State = State, Cleanup = cleanup, MODES = MODES }
    end

    local ok, result = pcall(createAimbot)
    if ok and result then
        Aimbot = result
    else
        warn("[ARC3USX] Aimbot init failed: " .. tostring(result))
        Aimbot = { Config = {}, State = {}, Cleanup = function() end, MODES = {} }
    end
end

-- ═══════════════════════════════════════════════════════════════
--  MAIN RENDER LOOP
-- ═══════════════════════════════════════════════════════════════
local lastPlayerTick = 0
local lastOtherTick = 0

connect(RunService.RenderStepped, function(dt)
    if unloaded then return end
    Camera = Workspace.CurrentCamera
    if not Camera then return end
    local camPos = Camera.CFrame.Position
    local currentTick = tick()

    -- Players
    local playerHz = getFlag("player_esp_hz", 60)
    if currentTick - lastPlayerTick >= (1 / playerHz) then
        lastPlayerTick = currentTick
        if getFlag("plr_master", true) and getFlag("plr_enabled", false) then
            for _, plr in ipairs(Players:GetPlayers()) do
                local char = plr.Character
                if plr ~= LocalPlayer and char and char.Parent and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    if not plrStore[char] then plrStore[char] = buildEsp() end
                    local esp = plrStore[char]
                    local root = char.HumanoidRootPart
                    local distStuds = (root.Position - camPos).Magnitude
                    if distStuds <= (getFlag("plr_max_dist", 500) * METER_TO_STUD) then
                        local cf, size = char:GetBoundingBox()
                        local topX, topY, topOn = getScreenPos(cf.Position + Vector3.new(0, size.Y * 0.5, 0))
                        local botX, botY, botOn = getScreenPos(cf.Position - Vector3.new(0, size.Y * 0.5, 0))
                        if topOn and botOn then
                            local h = math.max(botY - topY, 1); local w = math.max(h * 0.55, 1)
                            local bLeft, bRight = topX - w * 0.5, topX + w * 0.5

                            if getFlag("plr_chams", true) then
                                local vis = isVisible(char, root)
                                if esp.lastVisible ~= vis then
                                    ensureHighlight(esp, char, vis and Colors.plr_chams_vis or Colors.plr_chams_occ)
                                    esp.lastVisible = vis
                                elseif esp.highlight and not esp.highlight.Enabled then esp.highlight.Enabled = true end
                            elseif esp.highlight and esp.highlight.Enabled then esp.highlight.Enabled = false end

                            if getFlag("plr_box", true) then drawBox(esp, bLeft, topY, bRight, botY, getFlag("plr_style", "Corners"), Colors.plr_box)
                            else for _, c in ipairs(esp.corners) do c.Visible = false end; esp.box.Visible = false end

                            esp.name.Visible = getFlag("plr_name", true)
                            if esp.name.Visible then esp.name.Text = plr.Name; esp.name.TextColor3 = Colors.plr_name; esp.name.Position = UDim2.fromOffset(math.floor(topX), math.floor(topY - 16)) end

                            local meters = math.floor(distStuds * STUD_TO_METER)
                            if esp.lastDist ~= meters then esp.lastDist = meters; esp.distance.Text = tostring(meters) .. "m" end
                            esp.distance.Visible = getFlag("plr_dist", true)
                            if esp.distance.Visible then esp.distance.TextColor3 = Colors.plr_dist; esp.distance.Position = UDim2.fromOffset(math.floor(topX), math.floor(botY + 16)) end

                            esp.weapon.Visible = getFlag("plr_weapon", true)
                            if esp.weapon.Visible then local tool = char:FindFirstChildWhichIsA("Tool"); esp.weapon.Text = tool and tool.Name or "Unarmed"; esp.weapon.TextColor3 = Colors.plr_wep; esp.weapon.Position = UDim2.fromOffset(math.floor(topX), math.floor(botY + 32)) end

                            if getFlag("plr_health", true) then
                                local hpPerc = math.clamp(char.Humanoid.Health / char.Humanoid.MaxHealth, 0, 1)
                                esp.healthBg.Visible = true; esp.healthBg.Position = UDim2.fromOffset(math.floor(bLeft - 6), math.floor(topY)); esp.healthBg.Size = UDim2.fromOffset(4, math.floor(h))
                                esp.healthFill.Visible = true; esp.healthFill.BackgroundColor3 = Colors.plr_hp_low:Lerp(Colors.plr_hp_high, hpPerc); esp.healthFill.Position = UDim2.fromOffset(math.floor(bLeft - 5), math.floor(topY + (h * (1 - hpPerc)))); esp.healthFill.Size = UDim2.fromOffset(2, math.floor(h * hpPerc))
                            else esp.healthBg.Visible = false; esp.healthFill.Visible = false end

                            if getFlag("plr_skel", true) then
                                local activeBones = char:FindFirstChild("UpperTorso") and bonesR15 or bonesR6
                                for i, bone in ipairs(activeBones) do
                                    local p1, p2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                                    local line = esp.skeleton[i]
                                    if p1 and p2 then
                                        local x1, y1, on1 = getScreenPos(p1.Position); local x2, y2, on2 = getScreenPos(p2.Position)
                                        if on1 and on2 then drawLine(line, x1, y1, x2, y2, Colors.plr_skel) else line.Visible = false end
                                    else line.Visible = false end
                                end
                                for i = #activeBones + 1, #esp.skeleton do esp.skeleton[i].Visible = false end
                            else for _, l in ipairs(esp.skeleton) do l.Visible = false end end
                        else hideEsp(esp) end
                    else hideEsp(esp) end
                end
            end
            for char, esp in pairs(plrStore) do if not char.Parent then destroyEsp(esp); plrStore[char] = nil end end
        else for _, e in pairs(plrStore) do hideEsp(e) end end
    end

    if currentTick - lastOtherTick >= (1 / 60) then
        lastOtherTick = currentTick

        -- NPCs
        if getFlag("npc_master", true) and getFlag("npc_enabled", false) then
            local npcFolder = Workspace:FindFirstChild("Npcs")
            if npcFolder then
                for _, model in ipairs(npcFolder:GetChildren()) do
                    if model:IsA("Model") and not Players:GetPlayerFromCharacter(model) then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if not npcStore[model] then npcStore[model] = buildEsp() end
                            local esp = npcStore[model]; local root = getRoot(model)
                            local distStuds = root and (root.Position - camPos).Magnitude or math.huge
                            if root and distStuds <= (getFlag("npc_max_dist", 500) * METER_TO_STUD) then
                                local cf, size = model:GetBoundingBox()
                                local topX, topY, topOn = getScreenPos(cf.Position + Vector3.new(0, size.Y * 0.5, 0))
                                local botX, botY, botOn = getScreenPos(cf.Position - Vector3.new(0, size.Y * 0.5, 0))
                                if topOn and botOn then
                                    local h = math.max(botY - topY, 1); local w = math.max(h * 0.55, 1)
                                    local bLeft, bRight = topX - w * 0.5, topX + w * 0.5

                                    if getFlag("npc_chams", true) then
                                        local vis = isVisible(model, root)
                                        if esp.lastVisible ~= vis then
                                            ensureHighlight(esp, model, vis and Colors.npc_chams_vis or Colors.npc_chams_occ); esp.lastVisible = vis
                                        elseif esp.highlight and not esp.highlight.Enabled then esp.highlight.Enabled = true end
                                    elseif esp.highlight and esp.highlight.Enabled then esp.highlight.Enabled = false end

                                    if getFlag("npc_box", true) then drawBox(esp, bLeft, topY, bRight, botY, getFlag("npc_style", "Corners"), Colors.npc_box)
                                    else for _, c in ipairs(esp.corners) do c.Visible = false end; esp.box.Visible = false end

                                    esp.name.Visible = getFlag("npc_name", true)
                                    if esp.name.Visible then esp.name.Text = model.Name; esp.name.TextColor3 = Colors.npc_name; esp.name.Position = UDim2.fromOffset(math.floor(topX), math.floor(topY - 16)) end

                                    local meters = math.floor(distStuds * STUD_TO_METER)
                                    if esp.lastDist ~= meters then esp.lastDist = meters; esp.distance.Text = tostring(meters) .. "m" end
                                    esp.distance.Visible = getFlag("npc_dist", true)
                                    if esp.distance.Visible then esp.distance.TextColor3 = Colors.npc_dist; esp.distance.Position = UDim2.fromOffset(math.floor(topX), math.floor(botY + 16)) end

                                    esp.weapon.Visible = getFlag("npc_weapon", true)
                                    if esp.weapon.Visible then local tool = model:FindFirstChildWhichIsA("Tool"); esp.weapon.Text = tool and tool.Name or "Unarmed"; esp.weapon.TextColor3 = Colors.npc_wep; esp.weapon.Position = UDim2.fromOffset(math.floor(topX), math.floor(botY + 32)) end
                                else hideEsp(esp) end
                            else hideEsp(esp) end
                        end
                    end
                end
            end
            for model, esp in pairs(npcStore) do if not model.Parent then destroyEsp(esp); npcStore[model] = nil end end
        else for _, e in pairs(npcStore) do hideEsp(e) end end

        -- Ores (icon viewports)
        if getFlag("ore_master", true) and getFlag("ore_enabled", false) then
            local maxDistStuds = getFlag("ore_max_dist", 300) * METER_TO_STUD
            for desc in pairs(trackedOres) do
                if desc.Parent then
                    if not getFlag("ore_" .. desc.Name, true) then
                        hideOreIcon(oreIcons[desc])
                    else
                        local root = getRoot(desc)
                        if root then
                            local distStuds = (root.Position - camPos).Magnitude
                            if distStuds <= maxDistStuds then
                                local px, py, onScreen = getScreenPos(root.Position)
                                if onScreen then
                                    local entry = oreIcons[desc]
                                    if not entry then
                                        entry = createOreIcon(desc)
                                        oreIcons[desc] = entry
                                    end
                                    if entry and entry.view then
                                        local size = math.clamp(3000 / math.max(distStuds, 1), 22, 64)
                                        entry.view.AnchorPoint = Vector2.new(0.5, 0.5)
                                        entry.view.Position = UDim2.fromOffset(math.floor(px), math.floor(py))
                                        entry.view.Size = UDim2.fromOffset(math.floor(size), math.floor(size))
                                        entry.view.Visible = true

                                        if getFlag("ore_dist", true) then
                                            local meters = math.floor(distStuds * STUD_TO_METER)
                                            entry.distLabel.Text = tostring(meters) .. "m"
                                            entry.distLabel.Position = UDim2.fromOffset(math.floor(px), math.floor(py + size * 0.5 + 8))
                                            entry.distLabel.Visible = true
                                        else
                                            entry.distLabel.Visible = false
                                        end
                                    end
                                else
                                    hideOreIcon(oreIcons[desc])
                                end
                            else
                                hideOreIcon(oreIcons[desc])
                            end
                        else
                            hideOreIcon(oreIcons[desc])
                        end
                    end
                end
            end
        else
            for _, e in pairs(oreIcons) do hideOreIcon(e) end
        end

        -- Helis
        if getFlag("heli_master", true) and getFlag("heli_enabled", false) then
            for desc in pairs(trackedHelis) do
                if desc.Parent then
                    local root = getRoot(desc)
                    if root then
                        local distStuds = (root.Position - camPos).Magnitude
                        if distStuds <= (getFlag("heli_max_dist", 2000) * METER_TO_STUD) then
                            local cf, size = desc:GetBoundingBox()
                            local topX, topY, topOn = getScreenPos(cf.Position + Vector3.new(0, size.Y * 0.5, 0))
                            local botX, botY, botOn = getScreenPos(cf.Position - Vector3.new(0, size.Y * 0.5, 0))
                            if topOn and botOn then
                                if not heliStore[desc] then heliStore[desc] = buildEsp() end
                                local esp = heliStore[desc]
                                local h = math.max(botY - topY, 1); local w = math.max(h * 0.8, 1)
                                local bLeft, bRight = topX - w * 0.5, topX + w * 0.5

                                if getFlag("heli_chams", true) then ensureHighlight(esp, desc, Color3.fromRGB(255, 170, 0))
                                elseif esp.highlight and esp.highlight.Enabled then esp.highlight.Enabled = false end

                                drawBox(esp, bLeft, topY, bRight, botY, getFlag("heli_style", "Full"), Color3.fromRGB(255, 170, 0))

                                esp.distance.Visible = getFlag("heli_dist", true)
                                if esp.distance.Visible then
                                    local meters = math.floor(distStuds * STUD_TO_METER)
                                    if esp.lastDist ~= meters then esp.lastDist = meters; esp.distance.Text = tostring(meters) .. "m" end
                                    esp.distance.TextColor3 = Color3.new(1,1,1); esp.distance.Position = UDim2.fromOffset(math.floor(topX), math.floor(botY + 16))
                                end
                            elseif heliStore[desc] then hideEsp(heliStore[desc]) end
                        elseif heliStore[desc] then hideEsp(heliStore[desc]) end
                    elseif heliStore[desc] then hideEsp(heliStore[desc]) end
                end
            end
        else for _, e in pairs(heliStore) do hideEsp(e) end end
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  UI BUILDING
-- ═══════════════════════════════════════════════════════════════
local Window = Library:CreateWindow({ Name = "ARC3USX.EXE", Size = Vector2.new(800, 620), Intro = false, Theme = "Purple" })
local Visuals = Window:AddTab("ESP / World")
local CombatTab = Window:AddTab("Combat")
local MiscTab = Window:AddTab("Misc")

-- PLAYER ESP
local PlayerGroup = Visuals:AddGroup("Player ESP", "Left")
PlayerGroup:AddToggle({ Name = "Master Enable (Players)", Flag = "plr_master", Default = true })
PlayerGroup:AddToggle({ Name = "Player ESP Toggle", Flag = "plr_enabled", Default = false })
PlayerGroup:AddSlider({ Name = "Update Rate (Hz)", Flag = "player_esp_hz", Min = 30, Max = 240, Default = 60, Suffix = " Hz" })
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
--  COMBAT TAB
-- ═══════════════════════════════════════════════════════════════
local AimbotGroup = CombatTab:AddGroup("Aimbot", "Left")
AimbotGroup:AddToggle({
    Name = "Master Enable", Default = false,
    Callback = function(state) Aimbot.Config.Enabled = state end
})
AimbotGroup:AddToggle({
    Name = "Team Check", Default = true,
    Callback = function(state) Aimbot.Config.TeamCheck = state end
})
AimbotGroup:AddToggle({
    Name = "Wall Check", Default = true,
    Callback = function(state) Aimbot.Config.WallCheck = state end
})
AimbotGroup:AddDropdown({
    Name = "Target Part", Options = {"Head","HumanoidRootPart","Closest","Random"}, Default = "Head",
    Callback = function(v) Aimbot.Config.TargetPart = v end
})
AimbotGroup:AddSlider({
    Name = "FOV", Min = 10, Max = 360, Default = 180, Suffix = "°",
    Callback = function(v) Aimbot.Config.FOV = v end
})
AimbotGroup:AddSlider({
    Name = "Max Distance", Min = 50, Max = 2000, Default = 600, Suffix = " studs",
    Callback = function(v) Aimbot.Config.MaxDistance = v end
})
AimbotGroup:AddSlider({
    Name = "Prediction", Min = 0, Max = 0.5, Default = 0.12,
    Callback = function(v) Aimbot.Config.Prediction = v end
})
AimbotGroup:AddSlider({
    Name = "Smoothness", Min = 0, Max = 1, Default = 0.10,
    Callback = function(v) Aimbot.Config.Smoothness = v end
})

local AimbotVisualGroup = CombatTab:AddGroup("Aimbot Visuals", "Right")
AimbotVisualGroup:AddToggle({ Name = "Show FOV Circle", Default = true, Callback = function(v) Aimbot.Config.ShowFOV = v end })
AimbotVisualGroup:AddToggle({ Name = "Show Target", Default = true, Callback = function(v) Aimbot.Config.ShowTarget = v end })
AimbotVisualGroup:AddToggle({ Name = "Show Info", Default = true, Callback = function(v) Aimbot.Config.ShowInfo = v end })

local BowGroup = CombatTab:AddGroup("Bow Assist", "Left")
BowGroup:AddToggle({ Name = "Bow Auto Lock", Default = true, Callback = function(v) Aimbot.Config.BowAutoLock = v end })
BowGroup:AddToggle({
    Name = "Full Charge (Crossbow)", Default = false,
    Callback = function(v) Aimbot.Config.BowChargeMode = v and "full" or "auto" end
})
BowGroup:AddSlider({ Name = "Bow FOV", Min = 10, Max = 360, Default = 180, Callback = function(v) Aimbot.Config.BowFOV = v end })
BowGroup:AddSlider({ Name = "Bow Max Distance", Min = 50, Max = 1000, Default = 300, Callback = function(v) Aimbot.Config.BowMaxDistance = v end })
BowGroup:AddSlider({ Name = "Bow Smoothness", Min = 0, Max = 0.5, Default = 0.05, Callback = function(v) Aimbot.Config.BowSmoothness = v end })
BowGroup:AddSlider({ Name = "Draw Time", Min = 0.1, Max = 2, Default = 0.8, Callback = function(v) Aimbot.Config.BowDrawTime = v end })
BowGroup:AddSlider({ Name = "Speed Base", Min = 20, Max = 200, Default = 95, Callback = function(v) Aimbot.Config.BowSpeedBase = v end })
BowGroup:AddSlider({ Name = "Speed Charge", Min = 0, Max = 200, Default = 125, Callback = function(v) Aimbot.Config.BowSpeedCharge = v end })
BowGroup:AddSlider({ Name = "Gravity", Min = 0, Max = 200, Default = 50, Callback = function(v) Aimbot.Config.BowGravity = v end })

local AimbotKeys = CombatTab:AddGroup("Aimbot Keys", "Right")
AimbotKeys:AddLabel("Toggle: Z  |  Hold: Q  |  Cycle Mode: X")
AimbotKeys:AddButton({
    Name = "Cycle Target Part",
    Callback = function()
        local modes = Aimbot.MODES or {"Head","HumanoidRootPart","Closest","Random"}
        local idx = 1
        for i, m in ipairs(modes) do
            if m == Aimbot.Config.TargetPart then idx = i break end
        end
        Aimbot.Config.TargetPart = modes[(idx % #modes) + 1]
        Library:Notify("Target: " .. tostring(Aimbot.Config.TargetPart), 3)
    end
})

-- ═══════════════════════════════════════════════════════════════
--  MISC TAB
-- ═══════════════════════════════════════════════════════════════
local function attachStaffToUI()
    StaffDetector:SetNotifier(function(text, color, duration) pcall(function() Library:Notify(text, duration or 5) end) end)
    local DetectGroup = MiscTab:AddGroup("Staff Detection", "Left")
    local ResultLabel = DetectGroup:AddLabel("Not scanned yet.")
    local function renderResults()
        local list = StaffDetector:Scan()
        if #list == 0 then ResultLabel:SetText("No staff online."); return end
        local lines = {}
        for i, entry in ipairs(list) do lines[i] = string.format("%d. %s — %s (rank %d)", i, entry.player.Name, entry.label, entry.rank) end
        ResultLabel:SetText(table.concat(lines, "\n"))
    end
    StaffDetector.RefreshUI = renderResults
    DetectGroup:AddToggle({
        Name = "Enable Staff Monitor", Flag = "staff_monitor", Default = false,
        Callback = function(state) if state then StaffDetector:StartMonitor(); renderResults() else StaffDetector:StopMonitor() end end
    })
    DetectGroup:AddButton({
        Name = "Scan Now",
        Callback = function() renderResults(); Library:Notify("Scanned — " .. #StaffDetector:Scan() .. " staff online.", 3) end
    })
    local EspGroup = MiscTab:AddGroup("Staff ESP", "Right")
    EspGroup:AddToggle({
        Name = "Highlight Staff", Flag = "staff_esp", Default = false,
        Callback = function(state) StaffDetector.EspEnabled = state; StaffDetector:UpdateESP(state) end
    })
    EspGroup:AddButton({ Name = "Refresh Highlights", Callback = function() if StaffDetector.EspEnabled then StaffDetector:UpdateESP(true) end end })
    EspGroup:AddButton({ Name = "Clear Highlights", Callback = function() StaffDetector:ClearESP() end })
end
attachStaffToUI()

local WeakspotGroup = MiscTab:AddGroup("Mining (Silent Insta-Hit)", "Right")
WeakspotGroup:AddToggle({ Name = "Enable Insta-Hit Weakspot", Flag = "weakspot_enabled", Default = false })
WeakspotGroup:AddLabel("Silently snaps the camera at the nearest weakspot for one tick, activates the tool, then restores the camera. No visible lock. Radius: 50 studs.")

local MiscGroup = MiscTab:AddGroup("System", "Left")
MiscGroup:AddButton({
    Name = "Unload Script & Clear Memory",
    Callback = function()
        unloaded = true
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        table.clear(connections)
        pcall(function() RunService:UnbindFromRenderStep("ARC3USX_InstaHit") end)
        pcall(function() Aimbot.Cleanup() end)
        StaffDetector:StopMonitor()
        for _, e in pairs(plrStore) do destroyEsp(e) end; table.clear(plrStore)
        for _, e in pairs(npcStore) do destroyEsp(e) end; table.clear(npcStore)
        for _, e in pairs(heliStore) do destroyEsp(e) end; table.clear(heliStore)
        for _, e in pairs(oreIcons) do destroyOreIcon(e) end; table.clear(oreIcons)
        table.clear(cachedNodes); table.clear(trackedOres); table.clear(trackedHelis)
        if espGui then espGui:Destroy() end
        pcall(function() Library:Unload() end)
    end
})

Window:AddSettingsTab()
