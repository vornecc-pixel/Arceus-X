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

local function createBox(z, stroked, name)
    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.BorderColor3 = Color3.new(1,1,1)
    frame.BorderSizePixel = stroked and 0 or 1
    frame.Visible = false
    frame.ZIndex = z or 1
    if name then frame.Name = name end
    if stroked then
        local stroke = Instance.new("UIStroke")
        stroke.Name = "ARC3USX_BoxStroke"
        stroke.Thickness = 1
        stroke.Color = Color3.new(1,1,1)
        stroke.Transparency = 0
        stroke.Parent = frame
    end
    frame.Parent = espGui
    return frame
end

local function drawLine(line, fromX, fromY, toX, toY, color, thickness)
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
    line.Size = UDim2.fromOffset(math.floor(length), math.max(1, math.floor(thickness or 1)))
    line.Rotation = angle
    line.BackgroundColor3 = color
    if not line.Visible then line.Visible = true end
end

local function buildEsp()
    local esp = {
        box = createBox(1, true, "ARC3USX_Box"), outline = createBox(0, true, "ARC3USX_Outline"),
        name = createText(3), distance = createText(3), weapon = createText(3),
        healthBg = createBox(1), healthFill = createBox(1), highlight = nil,
        corners = {}, outlineCorners = {}, skeleton = {},
        lastHp = -1, lastDist = -1, lastVisible = nil
    }
    esp.healthBg.BackgroundTransparency = 0; esp.healthBg.BorderSizePixel = 0; esp.healthBg.BackgroundColor3 = Color3.new(0,0,0)
    esp.healthFill.BackgroundTransparency = 0; esp.healthFill.BorderSizePixel = 0
    for i = 1, 8 do esp.corners[i] = createLine(2); esp.outlineCorners[i] = createLine(1) end
    for i = 1, 15 do esp.skeleton[i] = createLine(2) end
    return esp
end

local function destroyEsp(esp)
    if not esp then return end
    esp.box:Destroy(); esp.outline:Destroy(); esp.name:Destroy(); esp.distance:Destroy(); esp.weapon:Destroy()
    esp.healthBg:Destroy(); esp.healthFill:Destroy()
    if esp.highlight then esp.highlight:Destroy() end
    for _, c in ipairs(esp.corners) do c:Destroy() end
    for _, c in ipairs(esp.outlineCorners) do c:Destroy() end
    for _, l in ipairs(esp.skeleton) do l:Destroy() end
end

local function hideEsp(esp)
    if not esp then return end
    esp.box.Visible = false; esp.outline.Visible = false; esp.name.Visible = false; esp.distance.Visible = false
    esp.weapon.Visible = false; esp.healthBg.Visible = false; esp.healthFill.Visible = false
    if esp.highlight then esp.highlight.Enabled = false end
    for _, c in ipairs(esp.corners) do c.Visible = false end
    for _, c in ipairs(esp.outlineCorners) do c.Visible = false end
    for _, l in ipairs(esp.skeleton) do l.Visible = false end
end

local function drawBox(esp, bLeft, bTop, bRight, bBot, style, color, options)
    options = options or {}
    local thickness = math.max(1, math.floor(options.thickness or 1))
    local outlineColor = options.outlineColor or Color3.new(0, 0, 0)
    local showOutline = options.outline ~= false
    local filled = options.filled == true
    local fillTransparency = options.fillTransparency or 0.7
    local strokeOf = function(frame) return frame:FindFirstChildOfClass("UIStroke") end
    local w, h = bRight - bLeft, bBot - bTop
    local x, y = math.floor(bLeft), math.floor(bTop)
    local sx, sy = math.max(1, math.floor(w)), math.max(1, math.floor(h))

    if style == "Full" then
        for _, c in ipairs(esp.corners) do c.Visible = false end
        for _, c in ipairs(esp.outlineCorners) do c.Visible = false end
        esp.box.Visible = true
        esp.box.BackgroundTransparency = filled and (1 - fillTransparency) or 1
        if filled then esp.box.BackgroundColor3 = color end
        esp.box.Position = UDim2.fromOffset(x, y)
        esp.box.Size = UDim2.fromOffset(sx, sy)
        local stroke = strokeOf(esp.box)
        if stroke then
            stroke.Thickness, stroke.Color, stroke.Transparency = thickness, color, options.transparency or 0
        else
            esp.box.BorderColor3, esp.box.BorderSizePixel = color, thickness
        end
        esp.outline.Visible = showOutline
        if showOutline then
            esp.outline.BackgroundTransparency = 1
            esp.outline.Position = UDim2.fromOffset(x - thickness, y - thickness)
            esp.outline.Size = UDim2.fromOffset(sx + thickness * 2, sy + thickness * 2)
            local outlineStroke = strokeOf(esp.outline)
            if outlineStroke then
                outlineStroke.Thickness, outlineStroke.Color, outlineStroke.Transparency = thickness + 2, outlineColor, 0
            else
                esp.outline.BorderColor3, esp.outline.BorderSizePixel = outlineColor, thickness + 2
            end
        end
    else
        esp.box.Visible = false; esp.outline.Visible = false
        local cl = math.max(w * 0.22, h * 0.14)
        local segments = {
            {bLeft, bTop, bLeft + cl, bTop}, {bLeft, bTop, bLeft, bTop + cl},
            {bRight, bTop, bRight - cl, bTop}, {bRight, bTop, bRight, bTop + cl},
            {bLeft, bBot, bLeft + cl, bBot}, {bLeft, bBot, bLeft, bBot - cl},
            {bRight, bBot, bRight - cl, bBot}, {bRight, bBot, bRight, bBot - cl}
        }
        for i, c in ipairs(segments) do
            if showOutline then
                drawLine(esp.outlineCorners[i], c[1], c[2], c[3], c[4], outlineColor, thickness + 2)
            elseif esp.outlineCorners[i].Visible then
                esp.outlineCorners[i].Visible = false
            end
            drawLine(esp.corners[i], c[1], c[2], c[3], c[4], color, thickness)
        end
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
--  ESP CORE UTILITIES (ported from the adapter-based ESP framework)
--  3D box projection, dynamic label layout, throttled error isolation.
-- ═══════════════════════════════════════════════════════════════
local CORNERS = {
    { -1, -1, -1 }, { 1, -1, -1 }, { -1, 1, -1 }, { 1, 1, -1 },
    { -1, -1, 1 }, { 1, -1, 1 }, { -1, 1, 1 }, { 1, 1, 1 },
}
local EDGES = {
    { 1, 2 }, { 1, 3 }, { 2, 4 }, { 3, 4 }, { 5, 6 }, { 5, 7 },
    { 6, 8 }, { 7, 8 }, { 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 },
}
local NEAR_PLANE = 0.05

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

-- Options may be static values or functions of the render context.
local function readValue(value, context, fallback)
    if type(value) == "function" then return value(context) end
    if value ~= nil then return value end
    return fallback
end

local function geometryOf(item)
    if typeof(item) == "Instance" then
        if item:IsA("BasePart") then return { cframe = item.CFrame, size = item.Size } end
        return nil
    end
    if type(item) == "table" and item.cframe and item.size then return item end
    return nil
end

local function cornersOf(geometry)
    local result = {}
    for index, signs in ipairs(CORNERS) do
        result[index] = geometry.cframe * Vector3.new(
            geometry.size.X * signs[1] / 2,
            geometry.size.Y * signs[2] / 2,
            geometry.size.Z * signs[3] / 2
        )
    end
    return result
end

-- Combines several parts/geometries into one oriented bounding box.
local function boundsOfParts(parts, reference)
    reference = reference or CFrame.new()
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    for _, item in ipairs(parts) do
        local geometry = geometryOf(item)
        if geometry then
            for _, corner in ipairs(cornersOf(geometry)) do
                local point = reference:PointToObjectSpace(corner)
                minX, minY, minZ = math.min(minX, point.X), math.min(minY, point.Y), math.min(minZ, point.Z)
                maxX, maxY, maxZ = math.max(maxX, point.X), math.max(maxY, point.Y), math.max(maxZ, point.Z)
            end
        end
    end
    if minX == math.huge then return nil end
    local center = Vector3.new((minX + maxX) / 2, (minY + maxY) / 2, (minZ + maxZ) / 2)
    return { cframe = reference * CFrame.new(center), size = Vector3.new(maxX - minX, maxY - minY, maxZ - minZ) }
end

-- Gathers physical parts so a box can be derived from the rig itself.
local function collectParts(model, limit)
    if model:IsA("BasePart") then return { model } end
    local parts = {}
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("BasePart") then
            parts[#parts + 1] = child
            if limit and #parts >= limit then break end
        end
    end
    if #parts == 0 and model.PrimaryPart then parts[1] = model.PrimaryPart end
    return parts
end

-- Projects eight corners (plus near-plane clipped edges) into a screen rect.
-- Unlike a top/bottom estimate this handles rotation and partly off-screen models.
local function projectBounds(camera, geometries, nearPlane)
    nearPlane = nearPlane or NEAR_PLANE
    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
    local function include(point)
        if finite(point.X) and finite(point.Y) then
            minX, minY = math.min(minX, point.X), math.min(minY, point.Y)
            maxX, maxY = math.max(maxX, point.X), math.max(maxY, point.Y)
        end
    end
    for _, item in ipairs(geometries) do
        local geometry = geometryOf(item)
        if geometry then
            local world, projected = cornersOf(geometry), {}
            for index, corner in ipairs(world) do
                local point = camera:WorldToViewportPoint(corner)
                projected[index] = point
                if point.Z >= nearPlane then include(point) end
            end
            for _, edge in ipairs(EDGES) do
                local first, second = projected[edge[1]], projected[edge[2]]
                if (first.Z >= nearPlane) ~= (second.Z >= nearPlane) then
                    local alpha = (nearPlane - first.Z) / (second.Z - first.Z)
                    include(camera:WorldToViewportPoint(world[edge[1]]:Lerp(world[edge[2]], alpha)))
                end
            end
        end
    end
    local viewport = camera.ViewportSize
    if minX == math.huge or maxX <= minX or maxY <= minY
        or maxX < 0 or maxY < 0 or minX > viewport.X or minY > viewport.Y then
        return nil
    end
    return { position = Vector2.new(minX, minY), size = Vector2.new(maxX - minX, maxY - minY) }
end

-- Stacks enabled labels above/below the box with no gaps when one is hidden.
local function newLabelLayout(rect)
    local layout = { above = 2, below = 2 }
    return function(side, height, gap)
        local offset = layout[side]
        layout[side] = offset + height + (gap or 2)
        local centerX = rect.position.X + rect.size.X * 0.5
        if side == "above" then
            return Vector2.new(centerX, rect.position.Y - offset - height)
        end
        return Vector2.new(centerX, rect.position.Y + rect.size.Y + offset)
    end
end

-- One broken target must not kill the whole render frame.
local errorCache = {}
local function guarded(tag, target, fn, onError)
    local ok, problem = pcall(fn)
    if ok then return true end
    local name = typeof(target) == "Instance" and target.Name or tostring(target)
    local key = tag .. ":" .. name
    local now = os.clock()
    if not errorCache[key] or now - errorCache[key] >= 1 then
        errorCache[key] = now
        warn(string.format("[ARC3USX ESP] %s failed for %s: %s", tag, name, tostring(problem)))
    end
    if onError then pcall(onError) end
    return false
end

local function formatDistance(studs, style)
    local meters = math.floor(studs * STUD_TO_METER)
    if style == "Brackets" then return string.format("[%d]", meters) end
    if style == "Studs" then return tostring(math.floor(studs)) .. "s" end
    return tostring(meters) .. "m"
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
    plr_box_outline = Color3.new(0,0,0),
    npc_box = Color3.new(1,1,1), npc_name = Color3.new(1,1,1), npc_dist = Color3.new(1,1,1), npc_wep = Color3.fromRGB(255, 180, 60),
    npc_chams_vis = Color3.fromRGB(60, 255, 120), npc_chams_occ = Color3.fromRGB(255, 50, 80),
    npc_hp_high = Color3.fromRGB(0, 255, 0), npc_hp_low = Color3.fromRGB(255, 0, 0),
    npc_box_outline = Color3.new(0,0,0),
    heli_box_outline = Color3.new(0,0,0),
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

-- Either the model's bounding box or a box computed from its parts.
local function boxGeometries(model)
    if getFlag("esp_parts_bounds", false) then
        local parts = collectParts(model, 24)
        local bounds = boundsOfParts(parts)
        return bounds and { bounds } or parts
    end
    local cf, size = model:GetBoundingBox()
    return {{ cframe = cf, size = size }}
end

local function boxOptions(prefix, outlineColor)
    return {
        thickness = getFlag(prefix .. "_box_thickness", 1),
        filled = getFlag(prefix .. "_box_fill", false),
        fillTransparency = getFlag("esp_fill_transparency", 0.7),
        outline = getFlag(prefix .. "_box_outline", true),
        outlineColor = outlineColor,
    }
end

local function setLabel(label, text, visible, color, size, gap, reserve, side, context)
    label.Visible = visible
    if not visible then return end
    label.TextSize = size
    label.TextColor3 = readValue(color, context, color)
    label.Text = tostring(text)
    local pos = reserve(side, size, gap)
    label.Position = UDim2.fromOffset(math.floor(pos.X), math.floor(pos.Y))
end

local function setHealthBar(esp, bLeft, bTop, bRight, h, health, maxHealth, side, low, high, context)
    if not finite(health) or not finite(maxHealth) or maxHealth <= 0 then
        esp.healthBg.Visible = false; esp.healthFill.Visible = false
        return
    end
    local ratio = math.clamp(health / maxHealth, 0, 1)
    local barX = side == "Right" and (bRight + 3) or (bLeft - 6)
    esp.healthBg.Visible = true
    esp.healthBg.Position = UDim2.fromOffset(math.floor(barX), math.floor(bTop))
    esp.healthBg.Size = UDim2.fromOffset(4, math.floor(h))
    esp.healthFill.Visible = true
    esp.healthFill.BackgroundColor3 = low:Lerp(high, ratio)
    esp.healthFill.Position = UDim2.fromOffset(math.floor(barX + 1), math.floor(bTop + (h * (1 - ratio))))
    esp.healthFill.Size = UDim2.fromOffset(2, math.floor(h * ratio))
end

local function hideBox(esp)
    esp.box.Visible = false; esp.outline.Visible = false
    for _, c in ipairs(esp.corners) do c.Visible = false end
    for _, c in ipairs(esp.outlineCorners) do c.Visible = false end
end

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
    local textSize = getFlag("esp_text_size", 13)
    local labelGap = getFlag("esp_label_gap", 2)
    local distanceStyle = getFlag("esp_distance_style", "Metres")

    -- Players have their own throttled resolve interval.
    local playerHz = getFlag("player_esp_hz", 60)
    if currentTick - lastPlayerTick >= (1 / playerHz) then
        lastPlayerTick = currentTick
        if getFlag("plr_master", true) and getFlag("plr_enabled", false) then
            for _, plr in ipairs(Players:GetPlayers()) do
                local char = plr.Character
                if plr ~= LocalPlayer and char and char.Parent and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                    if not plrStore[char] then plrStore[char] = buildEsp() end
                    local esp = plrStore[char]
                    guarded("player", plr, function()
                        local root = char.HumanoidRootPart
                        local distStuds = (root.Position - camPos).Magnitude
                        local vis = isVisible(char, root)
                        if getFlag("plr_visible_only", false) and not vis then hideEsp(esp); return end
                        if distStuds > (getFlag("plr_max_dist", 500) * METER_TO_STUD) then hideEsp(esp); return end
                        local rect = projectBounds(Camera, boxGeometries(char), NEAR_PLANE)
                        if not rect then hideEsp(esp); return end
                        local bLeft, bTop = rect.position.X, rect.position.Y
                        local bRight, bBot = bLeft + rect.size.X, bTop + rect.size.Y
                        local h = math.max(bBot - bTop, 1)
                        local reserve = newLabelLayout(rect)
                        local context = { distance = math.floor(distStuds * STUD_TO_METER),
                            state = { health = char.Humanoid.Health, maxHealth = char.Humanoid.MaxHealth }, visible = vis }

                        if getFlag("plr_chams", true) then
                            if esp.lastVisible ~= vis then
                                ensureHighlight(esp, char, vis and Colors.plr_chams_vis or Colors.plr_chams_occ)
                                esp.lastVisible = vis
                            elseif esp.highlight and not esp.highlight.Enabled then esp.highlight.Enabled = true end
                        elseif esp.highlight and esp.highlight.Enabled then esp.highlight.Enabled = false end

                        if getFlag("plr_box", true) then
                            drawBox(esp, bLeft, bTop, bRight, bBot, getFlag("plr_style", "Corners"),
                                readValue(Colors.plr_box, context, Colors.plr_box),
                                boxOptions("plr", readValue(Colors.plr_box_outline, context, Colors.plr_box_outline)))
                        else hideBox(esp) end

                        setLabel(esp.name, plr.Name, getFlag("plr_name", true), Colors.plr_name, textSize, labelGap, reserve, "above", context)
                        setLabel(esp.distance, formatDistance(distStuds, distanceStyle), getFlag("plr_dist", true), Colors.plr_dist, textSize, labelGap, reserve, "below", context)
                        local tool = char:FindFirstChildWhichIsA("Tool")
                        setLabel(esp.weapon, tool and tool.Name or "Unarmed", getFlag("plr_weapon", true), Colors.plr_wep, textSize, labelGap, reserve, "below", context)

                        if getFlag("plr_health", true) then
                            setHealthBar(esp, bLeft, bTop, bRight, h, char.Humanoid.Health, char.Humanoid.MaxHealth,
                                getFlag("plr_hp_side", "Left"), Colors.plr_hp_low, Colors.plr_hp_high, context)
                        else esp.healthBg.Visible = false; esp.healthFill.Visible = false end

                        if getFlag("plr_skel", true) then
                            local activeBones = char:FindFirstChild("UpperTorso") and bonesR15 or bonesR6
                            for i, bone in ipairs(activeBones) do
                                local p1, p2 = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
                                local line = esp.skeleton[i]
                                if p1 and p2 then
                                    local x1, y1, on1 = getScreenPos(p1.Position); local x2, y2, on2 = getScreenPos(p2.Position)
                                    if on1 and on2 then drawLine(line, x1, y1, x2, y2, readValue(Colors.plr_skel, context, Colors.plr_skel)) else line.Visible = false end
                                else line.Visible = false end
                            end
                            for i = #activeBones + 1, #esp.skeleton do esp.skeleton[i].Visible = false end
                        else for _, l in ipairs(esp.skeleton) do l.Visible = false end end
                    end, function() hideEsp(esp) end)
                end
            end
            for char, esp in pairs(plrStore) do if not char.Parent then destroyEsp(esp); plrStore[char] = nil end end
        else for _, e in pairs(plrStore) do hideEsp(e) end end
    end

    -- NPC / ore / heli share a separate throttled resolve interval.
    local worldHz = getFlag("world_esp_hz", 60)
    if currentTick - lastOtherTick >= (1 / worldHz) then
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
                            local esp = npcStore[model]
                            guarded("npc", model, function()
                                local root = getRoot(model)
                                local distStuds = root and (root.Position - camPos).Magnitude or math.huge
                                local vis = isVisible(model, root)
                                if getFlag("npc_visible_only", false) and not vis then hideEsp(esp); return end
                                if not root or distStuds > (getFlag("npc_max_dist", 500) * METER_TO_STUD) then hideEsp(esp); return end
                                local rect = projectBounds(Camera, boxGeometries(model), NEAR_PLANE)
                                if not rect then hideEsp(esp); return end
                                local bLeft, bTop = rect.position.X, rect.position.Y
                                local bRight, bBot = bLeft + rect.size.X, bTop + rect.size.Y
                                local h = math.max(bBot - bTop, 1)
                                local reserve = newLabelLayout(rect)
                                local context = { distance = math.floor(distStuds * STUD_TO_METER),
                                    state = { health = hum.Health, maxHealth = hum.MaxHealth }, visible = vis }

                                if getFlag("npc_chams", true) then
                                    if esp.lastVisible ~= vis then
                                        ensureHighlight(esp, model, vis and Colors.npc_chams_vis or Colors.npc_chams_occ); esp.lastVisible = vis
                                    elseif esp.highlight and not esp.highlight.Enabled then esp.highlight.Enabled = true end
                                elseif esp.highlight and esp.highlight.Enabled then esp.highlight.Enabled = false end

                                if getFlag("npc_box", true) then
                                    drawBox(esp, bLeft, bTop, bRight, bBot, getFlag("npc_style", "Corners"),
                                        readValue(Colors.npc_box, context, Colors.npc_box),
                                        boxOptions("npc", readValue(Colors.npc_box_outline, context, Colors.npc_box_outline)))
                                else hideBox(esp) end

                                setLabel(esp.name, model.Name, getFlag("npc_name", true), Colors.npc_name, textSize, labelGap, reserve, "above", context)
                                setLabel(esp.distance, formatDistance(distStuds, distanceStyle), getFlag("npc_dist", true), Colors.npc_dist, textSize, labelGap, reserve, "below", context)
                                local tool = model:FindFirstChildWhichIsA("Tool")
                                setLabel(esp.weapon, tool and tool.Name or "Unarmed", getFlag("npc_weapon", true), Colors.npc_wep, textSize, labelGap, reserve, "below", context)

                                if getFlag("npc_health", true) then
                                    setHealthBar(esp, bLeft, bTop, bRight, h, hum.Health, hum.MaxHealth,
                                        getFlag("npc_hp_side", "Left"), Colors.npc_hp_low, Colors.npc_hp_high, context)
                                else esp.healthBg.Visible = false; esp.healthFill.Visible = false end
                            end, function() hideEsp(esp) end)
                        end
                    end
                end
            end
            for model, esp in pairs(npcStore) do if not model.Parent then destroyEsp(esp); npcStore[model] = nil end end
        else for _, e in pairs(npcStore) do hideEsp(e) end end

        -- Ores (3D item icons)
        if getFlag("ore_master", true) and getFlag("ore_enabled", false) then
            local maxDistStuds = getFlag("ore_max_dist", 300) * METER_TO_STUD
            for desc in pairs(trackedOres) do
                if desc.Parent then
                    if not getFlag("ore_" .. desc.Name, true) then
                        hideOreIcon(oreIcons[desc])
                    else
                        guarded("ore", desc, function()
                            local root = getRoot(desc)
                            if not root then hideOreIcon(oreIcons[desc]); return end
                            local distStuds = (root.Position - camPos).Magnitude
                            if distStuds > maxDistStuds then hideOreIcon(oreIcons[desc]); return end
                            local px, py, onScreen = getScreenPos(root.Position)
                            if not onScreen then hideOreIcon(oreIcons[desc]); return end
                            local entry = oreIcons[desc]
                            if not entry then entry = createOreIcon(desc); oreIcons[desc] = entry end
                            if entry and entry.view then
                                local size = math.clamp(3000 / math.max(distStuds, 1), 22, 64)
                                entry.view.AnchorPoint = Vector2.new(0.5, 0.5)
                                entry.view.Position = UDim2.fromOffset(math.floor(px), math.floor(py))
                                entry.view.Size = UDim2.fromOffset(math.floor(size), math.floor(size))
                                entry.view.Visible = true
                                if getFlag("ore_dist", true) then
                                    entry.distLabel.TextSize = math.max(8, textSize - 1)
                                    entry.distLabel.Text = formatDistance(distStuds, distanceStyle)
                                    entry.distLabel.Position = UDim2.fromOffset(math.floor(px), math.floor(py + size * 0.5 + 8))
                                    entry.distLabel.Visible = true
                                else entry.distLabel.Visible = false end
                            end
                        end, function() hideOreIcon(oreIcons[desc]) end)
                    end
                end
            end
        else for _, e in pairs(oreIcons) do hideOreIcon(e) end end

        -- Helis
        if getFlag("heli_master", true) and getFlag("heli_enabled", false) then
            for desc in pairs(trackedHelis) do
                if desc.Parent then
                    guarded("heli", desc, function()
                        local root = getRoot(desc)
                        if not root then if heliStore[desc] then hideEsp(heliStore[desc]) end; return end
                        local distStuds = (root.Position - camPos).Magnitude
                        if distStuds > (getFlag("heli_max_dist", 2000) * METER_TO_STUD) then if heliStore[desc] then hideEsp(heliStore[desc]) end; return end
                        local rect = projectBounds(Camera, boxGeometries(desc), NEAR_PLANE)
                        if not rect then if heliStore[desc] then hideEsp(heliStore[desc]) end; return end
                        if not heliStore[desc] then heliStore[desc] = buildEsp() end
                        local esp = heliStore[desc]
                        local bLeft, bTop = rect.position.X, rect.position.Y
                        local bRight, bBot = bLeft + rect.size.X, bTop + rect.size.Y
                        local reserve = newLabelLayout(rect)
                        local context = { distance = math.floor(distStuds * STUD_TO_METER), visible = true }

                        if getFlag("heli_chams", true) then ensureHighlight(esp, desc, Color3.fromRGB(255, 170, 0))
                        elseif esp.highlight and esp.highlight.Enabled then esp.highlight.Enabled = false end

                        drawBox(esp, bLeft, bTop, bRight, bBot, getFlag("heli_style", "Full"),
                            Color3.fromRGB(255, 170, 0), boxOptions("heli", Colors.heli_box_outline))
                        setLabel(esp.distance, formatDistance(distStuds, distanceStyle), getFlag("heli_dist", true),
                            Color3.new(1,1,1), textSize, labelGap, reserve, "below", context)
                    end, function() if heliStore[desc] then hideEsp(heliStore[desc]) end end)
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

-- ESP ENGINE (shared rendering options)
local EngineGroup = Visuals:AddGroup("ESP Engine", "Left")
EngineGroup:AddSlider({ Name = "World Update Rate (Hz)", Flag = "world_esp_hz", Min = 5, Max = 120, Default = 60, Suffix = " Hz" })
EngineGroup:AddSlider({ Name = "Text Size", Flag = "esp_text_size", Min = 8, Max = 24, Default = 13 })
EngineGroup:AddSlider({ Name = "Label Gap", Flag = "esp_label_gap", Min = 0, Max = 12, Default = 2 })
EngineGroup:AddSlider({ Name = "Box Fill Transparency", Flag = "esp_fill_transparency", Min = 0, Max = 1, Default = 0.7, Rounding = 2 })
EngineGroup:AddDropdown({ Name = "Distance Style", Flag = "esp_distance_style", Options = {"Metres", "Brackets", "Studs"}, Default = "Metres" })
EngineGroup:AddToggle({ Name = "Parts Bounds", Flag = "esp_parts_bounds", Default = false })
EngineGroup:AddLabel("Boxes project eight 3D corners with near-plane clipping; labels stack above/below automatically.")

-- PLAYER ESP
local PlayerGroup = Visuals:AddGroup("Player ESP", "Left")
PlayerGroup:AddToggle({ Name = "Master Enable (Players)", Flag = "plr_master", Default = true })
PlayerGroup:AddToggle({ Name = "Player ESP Toggle", Flag = "plr_enabled", Default = false })
PlayerGroup:AddSlider({ Name = "Update Rate (Hz)", Flag = "player_esp_hz", Min = 30, Max = 240, Default = 60, Suffix = " Hz" })
PlayerGroup:AddDropdown({ Name = "Box Style", Flag = "plr_style", Options = {"Corners", "Full"}, Default = "Corners" })
PlayerGroup:AddSlider({ Name = "Max Distance", Flag = "plr_max_dist", Min = 10, Max = 2000, Default = 500, Suffix = "m" })
PlayerGroup:AddToggle({ Name = "Box", Flag = "plr_box", Default = true, Colors = { Color3.new(1,1,1), Color3.new(0,0,0) }, ColorCallback = function(i, c) if i == 1 then Colors.plr_box = c else Colors.plr_box_outline = c end end })
PlayerGroup:AddToggle({ Name = "Filled Box", Flag = "plr_box_fill", Default = false })
PlayerGroup:AddSlider({ Name = "Box Thickness", Flag = "plr_box_thickness", Min = 1, Max = 5, Default = 1 })
PlayerGroup:AddToggle({ Name = "Box Outline", Flag = "plr_box_outline", Default = true })
PlayerGroup:AddToggle({ Name = "Only Visible", Flag = "plr_visible_only", Default = false })
PlayerGroup:AddToggle({ Name = "Name", Flag = "plr_name", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.plr_name = c end })
PlayerGroup:AddToggle({ Name = "Health Bar", Flag = "plr_health", Default = true, Colors = { Color3.fromRGB(0,255,0), Color3.fromRGB(255,0,0) }, ColorCallback = function(i, c) if i==1 then Colors.plr_hp_high = c else Colors.plr_hp_low = c end end })
PlayerGroup:AddDropdown({ Name = "Health Bar Side", Flag = "plr_hp_side", Options = {"Left", "Right"}, Default = "Left" })
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
NPCGroup:AddToggle({ Name = "Box", Flag = "npc_box", Default = true, Colors = { Color3.new(1,1,1), Color3.new(0,0,0) }, ColorCallback = function(i, c) if i == 1 then Colors.npc_box = c else Colors.npc_box_outline = c end end })
NPCGroup:AddToggle({ Name = "Filled Box", Flag = "npc_box_fill", Default = false })
NPCGroup:AddSlider({ Name = "Box Thickness", Flag = "npc_box_thickness", Min = 1, Max = 5, Default = 1 })
NPCGroup:AddToggle({ Name = "Box Outline", Flag = "npc_box_outline", Default = true })
NPCGroup:AddToggle({ Name = "Only Visible", Flag = "npc_visible_only", Default = false })
NPCGroup:AddToggle({ Name = "Name", Flag = "npc_name", Default = true, Colors = { Color3.new(1,1,1) }, ColorCallback = function(i, c) Colors.npc_name = c end })
NPCGroup:AddToggle({ Name = "Health Bar", Flag = "npc_health", Default = true, Colors = { Color3.fromRGB(0,255,0), Color3.fromRGB(255,0,0) }, ColorCallback = function(i, c) if i==1 then Colors.npc_hp_high = c else Colors.npc_hp_low = c end end })
NPCGroup:AddDropdown({ Name = "Health Bar Side", Flag = "npc_hp_side", Options = {"Left", "Right"}, Default = "Left" })
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
HeliGroup:AddToggle({ Name = "Filled Box", Flag = "heli_box_fill", Default = false })
HeliGroup:AddSlider({ Name = "Box Thickness", Flag = "heli_box_thickness", Min = 1, Max = 5, Default = 1 })
HeliGroup:AddToggle({ Name = "Box Outline", Flag = "heli_box_outline", Default = true })

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
    Name = "Prediction", Min = 0, Max = 0.5, Default = 0.12, Rounding = 3,
    Callback = function(v) Aimbot.Config.Prediction = v end
})
AimbotGroup:AddSlider({
    Name = "Smoothness", Min = 0, Max = 1, Default = 0.10, Rounding = 2,
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
BowGroup:AddSlider({ Name = "Bow Smoothness", Min = 0, Max = 0.5, Default = 0.05, Rounding = 3, Callback = function(v) Aimbot.Config.BowSmoothness = v end })
BowGroup:AddSlider({ Name = "Draw Time", Min = 0.1, Max = 2, Default = 0.8, Rounding = 2, Callback = function(v) Aimbot.Config.BowDrawTime = v end })
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
        table.clear(cachedNodes); table.clear(trackedOres); table.clear(trackedHelis); table.clear(errorCache)
        if espGui then espGui:Destroy() end
        pcall(function() Library:Unload() end)
    end
})

Window:AddSettingsTab()
