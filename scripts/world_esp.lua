-- ARC3USX chams ESP: players, NPCs and resource nodes with chams, R15/R6 skeletons
-- and corner or full boxes. Features only — this file builds no UI.
--
--   local WorldESP = assert(loadstring(game:HttpGet(URL)))()
--   local esp = WorldESP.new({ enabled = true })
--   esp:Set("boxMode", "full")
--   esp:SetNpcWhitelist("Guard, Soldier")
--   esp:Unload()
--
-- Fixes over the pasted version: Drawing objects are released with :Remove() (they
-- have no Destroy), the camera is re-read every frame, chams appear/disappear live
-- instead of only when the first target was created, R6 rigs get a skeleton too,
-- depth is guarded against divide-by-zero, and unload really disconnects everything.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local environment = type(getgenv) == "function" and getgenv() or _G

local function report(message)
    warn("[ARC3USX Chams] " .. tostring(message))
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Chams ESP", Text = tostring(message), Duration = 5 })
    end)
end

local R15_PAIRS = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "LowerTorso", "LeftUpperLeg" },
    { "LeftUpperLeg", "LeftLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" },
    { "RightUpperLeg", "RightLowerLeg" },
    { "RightLowerLeg", "RightFoot" },
    { "UpperTorso", "LeftUpperArm" },
    { "LeftUpperArm", "LeftLowerArm" },
    { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" },
    { "RightUpperArm", "RightLowerArm" },
    { "RightLowerArm", "RightHand" },
}

local R6_PAIRS = {
    { "Head", "Torso" },
    { "Torso", "Left Arm" },
    { "Torso", "Right Arm" },
    { "Torso", "Left Leg" },
    { "Torso", "Right Leg" },
}

local BONE_PAIRS = {}
for _, pair in ipairs(R15_PAIRS) do table.insert(BONE_PAIRS, pair) end
for _, pair in ipairs(R6_PAIRS) do table.insert(BONE_PAIRS, pair) end

local BOX_LINES = 8
local CHARACTER_HEIGHT = 2000
local MAX_BOX_HEIGHT = 800
local VISIBILITY_INTERVAL = 0.15

local DEFAULTS = {
    enabled = false,

    -- categories
    players = true,
    npcs = true,
    nodes = true,

    -- elements
    chams = true,
    chamsVisibleCheck = true,  -- chams show a different colour when the target is occluded
    chamsFillTransparency = 0.6,
    chamsOutlineTransparency = 0,
    skeleton = true,
    healthBar = true,
    name = true,
    distance = true,
    weapon = true,

    -- box
    boxMode = "corners",       -- "corners" | "full"
    boxVisibleCheck = true,    -- green when visible, occluded colour when not
    cornerFraction = 0.25,
    boxThickness = 1,
    skelThickness = 1,
    textSize = 14,

    -- filters / misc
    maxDistance = 0,           -- studs, 0 = off
    updateRate = 0,            -- Hz, 0 = every frame
    studsPerMeter = 3.571,

    -- colours
    playerBoxColor = Color3.fromRGB(80, 220, 120),
    playerBoxOccludedColor = Color3.fromRGB(235, 70, 70),
    playerSkelColor = Color3.fromRGB(120, 200, 255),
    playerNameColor = Color3.fromRGB(255, 255, 255),
    playerChamColor = Color3.fromRGB(120, 200, 255),
    playerChamOccludedColor = Color3.fromRGB(60, 90, 160),

    npcBoxColor = Color3.fromRGB(80, 220, 120),
    npcBoxOccludedColor = Color3.fromRGB(235, 70, 70),
    npcSkelColor = Color3.fromRGB(255, 80, 80),
    npcNameColor = Color3.fromRGB(255, 220, 220),
    npcChamColor = Color3.fromRGB(255, 80, 80),
    npcChamOccludedColor = Color3.fromRGB(150, 45, 45),

    -- nodes are dot + name + distance only
    nodeDotColor = Color3.fromRGB(80, 220, 140),
    nodeNameColor = Color3.fromRGB(180, 255, 200),
    nodeDotSize = 5,

    -- lists (comma separated names)
    npcWhitelist = "Guard, Scavenger, Soldier",
    nodeWhitelist = "MetalNode, StoneNode, SulfurNode, Tree",
}

local RANGES = {
    cornerFraction = { 0.05, 1 },
    boxThickness = { 1, 4 },
    skelThickness = { 1, 4 },
    textSize = { 8, 24 },
    nodeDotSize = { 1, 16 },
    chamsFillTransparency = { 0, 1 },
    chamsOutlineTransparency = { 0, 1 },
    maxDistance = { 0, 2000 },
    updateRate = { 0, 60 },
    studsPerMeter = { 0.5, 20 },
}

local CHOICES = { boxMode = { "corners", "full" } }

local COLOR_KEYS = {
    playerBoxColor = true, playerBoxOccludedColor = true,
    playerSkelColor = true, playerNameColor = true,
    playerChamColor = true, playerChamOccludedColor = true,
    npcBoxColor = true, npcBoxOccludedColor = true,
    npcSkelColor = true, npcNameColor = true,
    npcChamColor = true, npcChamOccludedColor = true,
    nodeDotColor = true, nodeNameColor = true,
}

local WorldESP = {}
WorldESP.SkeletonPairs = BONE_PAIRS
WorldESP.BoxMode = CHOICES.boxMode
WorldESP.R15Pairs = R15_PAIRS
WorldESP.R6Pairs = R6_PAIRS

local function copyDefaults()
    local copy = {}
    for key, value in pairs(DEFAULTS) do copy[key] = value end
    return copy
end
WorldESP.Defaults = copyDefaults()

local function isColor(value)
    if type(value) == "table" or type(value) == "userdata" then
        return value.R ~= nil and value.G ~= nil and value.B ~= nil
    end
    return false
end

local function listHas(list, value)
    for _, item in ipairs(list) do
        if item == value then return true end
    end
    return false
end

local function parseList(value)
    local set = {}
    if type(value) == "table" then
        for key, item in pairs(value) do
            if type(key) == "number" then
                if item ~= nil then set[tostring(item)] = true end
            elseif item then
                set[tostring(key)] = true
            end
        end
    elseif value ~= nil then
        for item in string.gmatch(tostring(value), "[^,;%s]+") do set[item] = true end
    end
    return set
end

local function positionOf(instance)
    if not instance then return nil end
    if instance.Position then return instance.Position end
    if type(instance.IsA) == "function" and instance:IsA("Model") then
        local part = instance.PrimaryPart
        if not part then
            local ok, found = pcall(function() return instance:FindFirstChildWhichIsA("BasePart") end)
            part = ok and found or nil
        end
        if not part then
            local ok, children = pcall(function() return instance:GetChildren() end)
            if ok and children then
                for _, child in ipairs(children) do
                    if child.Position then part = child break end
                end
            end
        end
        return part and part.Position or nil
    end
    return nil
end

local Object = {}
Object.__index = Object

function WorldESP.new(config)
    config = type(config) == "table" and config or {}

    local self = setmetatable({}, Object)
    self.Options = copyDefaults()
    for key, value in pairs(config) do
        if DEFAULTS[key] ~= nil then self.Options[key] = value end
    end

    self.Running = false
    self.Supported = true
    self._listeners = {}
    self._connections = {}
    self._records = {}
    self._characterConnections = {}
    self._accumulator = 0
    self._destroyed = false
    self._drawing = Drawing or environment.Drawing
    self._npcNames = parseList(self.Options.npcWhitelist)
    self._nodeNames = parseList(self.Options.nodeWhitelist)

    if self.Options.enabled then self:Start() end
    return self
end

------------------------------------------------------------------------
-- options
------------------------------------------------------------------------

function Object:Get(key)
    return self.Options[key]
end

function Object:GetAll()
    local copy = {}
    for key, value in pairs(self.Options) do copy[key] = value end
    return copy
end

function Object:OnChanged(callback)
    if type(callback) ~= "function" then return function() end end
    local entry = { callback = callback, connected = true }
    table.insert(self._listeners, entry)
    return function()
        entry.connected = false
        for index, item in ipairs(self._listeners) do
            if item == entry then table.remove(self._listeners, index) break end
        end
    end
end

function Object:_changed(key, value)
    for _, entry in ipairs(self._listeners) do
        if entry.connected then pcall(entry.callback, key, value, self) end
    end
end

function Object:Set(key, value)
    local default = DEFAULTS[key]
    if default == nil then return false, "unknown option: " .. tostring(key) end

    if type(default) == "boolean" then
        value = value and true or false
    elseif type(default) == "number" then
        value = tonumber(value)
        if value == nil then return false, tostring(key) .. " must be a number" end
        local range = RANGES[key]
        if range then value = math.clamp(value, range[1], range[2]) end
    elseif COLOR_KEYS[key] then
        if not isColor(value) then return false, tostring(key) .. " must be a Color3" end
    elseif type(default) == "string" then
        value = tostring(value)
        local choices = CHOICES[key]
        if choices and not listHas(choices, value) then
            return false, tostring(key) .. " must be one of " .. table.concat(choices, ", ")
        end
    end

    if self.Options[key] == value then return true end
    self.Options[key] = value

    if key == "npcWhitelist" then
        self._npcNames = parseList(value)
        self:Rescan()
    elseif key == "nodeWhitelist" then
        self._nodeNames = parseList(value)
        self:Rescan()
    elseif key == "enabled" then
        if value then self:Start() else self:Stop() end
    elseif key == "chams" then
        self:_syncAllChams()
    elseif key == "chamsVisibleCheck" or key == "chamsFillTransparency" or key == "chamsOutlineTransparency"
        or key == "boxVisibleCheck" then
        self:_applyColorsAll()
    elseif key == "boxMode" or key == "cornerFraction" then
        -- geometry is rebuilt from the options every frame, nothing to cache here
        self:_applyColorsAll()
    elseif key == "boxThickness" or key == "skelThickness" or key == "textSize" then
        self:_applyThickness()
    elseif key == "players" or key == "npcs" or key == "nodes" then
        self:Rescan()
    elseif COLOR_KEYS[key] then
        self:_applyColorsAll()
    end

    self:_changed(key, value)
    return true
end

function Object:SetMany(values)
    if type(values) ~= "table" then return end
    for key, value in pairs(values) do self:Set(key, value) end
end

function Object:Reset()
    local wasRunning = self.Running
    if wasRunning then self:Stop() end
    self.Options = copyDefaults()
    self._npcNames = parseList(self.Options.npcWhitelist)
    self._nodeNames = parseList(self.Options.nodeWhitelist)
    self:_changed("reset", nil)
    if wasRunning then self:Start() end
end

function Object:SetNpcWhitelist(value)
    return self:Set("npcWhitelist", type(value) == "table" and table.concat(value, ", ") or tostring(value))
end

function Object:SetNodeWhitelist(value)
    return self:Set("nodeWhitelist", type(value) == "table" and table.concat(value, ", ") or tostring(value))
end

function Object:GetNpcWhitelist()
    return self._npcNames
end

function Object:GetNodeWhitelist()
    return self._nodeNames
end

------------------------------------------------------------------------
-- drawing helpers
------------------------------------------------------------------------

function Object:_newDrawing(class)
    if not self._drawing or type(self._drawing.new) ~= "function" then return nil end
    local ok, object = pcall(self._drawing.new, class)
    if not ok or not object then return nil end
    pcall(function() object.Visible = false end)
    return object
end

function Object:_drop(object)
    if not object then return end
    pcall(function()
        object.Visible = false
        object:Remove()
    end)
end

------------------------------------------------------------------------
-- styles
------------------------------------------------------------------------

local function colorsFor(self, kind)
    local o = self.Options
    if kind == "player" then
        return o.playerSkelColor, o.playerNameColor
    elseif kind == "npc" then
        return o.npcSkelColor, o.npcNameColor
    end
    return o.nodeDotColor, o.nodeNameColor
end

function Object:_chamColor(kind, visible)
    local o = self.Options
    local base, occluded
    if kind == "player" then
        base, occluded = o.playerChamColor, o.playerChamOccludedColor
    elseif kind == "npc" then
        base, occluded = o.npcChamColor, o.npcChamOccludedColor
    else
        return o.nodeDotColor
    end
    if o.chamsVisibleCheck and not visible then return occluded or base end
    return base
end

function Object:_boxColor(record)
    local o = self.Options
    local base, occluded
    if record.kind == "player" then
        base, occluded = o.playerBoxColor, o.playerBoxOccludedColor
    elseif record.kind == "npc" then
        base, occluded = o.npcBoxColor, o.npcBoxOccludedColor
    else
        return o.nodeDotColor
    end
    if o.boxVisibleCheck and record.visibleNow == false then return occluded or base end
    return base
end

function Object:_applyChamsColor(record)
    if not record.highlight or record.kind == "node" then return end
    local color = self:_chamColor(record.kind, record.visibleNow ~= false)
    local fill = self.Options.chamsFillTransparency
    local outline = self.Options.chamsOutlineTransparency
    pcall(function()
        record.highlight.FillColor = color
        record.highlight.OutlineColor = color
        record.highlight.FillTransparency = fill
        record.highlight.OutlineTransparency = outline
    end)
end

function Object:_applyColors(record)
    local skeletonColor, nameColor = colorsFor(self, record.kind)
    local boxColor = self:_boxColor(record)
    for _, line in ipairs(record.box) do
        if line then pcall(function() line.Color = boxColor end) end
    end
    for _, line in ipairs(record.skeleton) do
        if line then pcall(function() line.Color = skeletonColor end) end
    end
    if record.dot then pcall(function() record.dot.Color = self.Options.nodeDotColor end) end
    if record.name then pcall(function() record.name.Color = nameColor end) end
    if record.distance and record.kind == "node" then
        pcall(function() record.distance.Color = nameColor end)
    end
    self:_applyChamsColor(record)
end

function Object:_applyColorsAll()
    for _, record in pairs(self._records) do self:_applyColors(record) end
end

function Object:_applyThickness()
    for _, record in pairs(self._records) do
        for _, line in ipairs(record.box) do
            if line then pcall(function() line.Thickness = self.Options.boxThickness end) end
        end
        for _, line in ipairs(record.skeleton) do
            if line then pcall(function() line.Thickness = self.Options.skelThickness end) end
        end
        if record.dot then
            local size = self.Options.nodeDotSize
            pcall(function() record.dot.Size = Vector2.new(size, size) end)
        end
        if record.name then
            local size = record.kind == "node" and math.max(8, self.Options.textSize - 2) or self.Options.textSize
            pcall(function() record.name.Size = size end)
        end
        if record.distance then pcall(function() record.distance.Size = math.max(8, self.Options.textSize - 2) end) end
        if record.weapon then pcall(function() record.weapon.Size = math.max(8, self.Options.textSize - 2) end) end
    end
end

------------------------------------------------------------------------
-- chams
------------------------------------------------------------------------

function Object:_syncChams(record)
    local options = self.Options
    -- Resource nodes are dot + name + distance only: no boxes, no highlight.
    local wanted = record.kind ~= "node" and options.enabled and options.chams and self:IsKindEnabled(record.kind)

    if not wanted then
        if record.highlight then
            pcall(function()
                record.highlight.Enabled = false
                record.highlight:Destroy()
            end)
            record.highlight = nil
        end
        return
    end

    if record.highlight then
        pcall(function() record.highlight.Enabled = true end)
        self:_applyChamsColor(record)
        return
    end

    local ok, highlight = pcall(function() return Instance.new("Highlight") end)
    if not ok or not highlight then return end

    pcall(function()
        highlight.Name = "ARC3USX_Chams"
        highlight.FillTransparency = self.Options.chamsFillTransparency
        highlight.OutlineTransparency = self.Options.chamsOutlineTransparency
        if Enum.HighlightDepthMode and Enum.HighlightDepthMode.AlwaysOnTop then
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
        highlight.Adornee = record.instance
        local parented = pcall(function() highlight.Parent = CoreGui end)
        if not parented or not highlight.Parent then
            pcall(function() highlight.Parent = record.instance end)
        end
    end)
    record.highlight = highlight
    self:_applyChamsColor(record)
end

function Object:_syncAllChams()
    for _, record in pairs(self._records) do self:_syncChams(record) end
end

------------------------------------------------------------------------
-- tracking
------------------------------------------------------------------------

function Object:IsKindEnabled(kind)
    if not self.Options.enabled then return false end
    if kind == "player" then return self.Options.players == true end
    if kind == "npc" then return self.Options.npcs == true end
    if kind == "node" then return self.Options.nodes == true end
    return false
end

function Object:_isNpcModel(model)
    if not model then return false end
    local ok, isModel = pcall(function() return model:IsA("Model") end)
    if not ok or not isModel then return false end
    if not self._npcNames[model.Name] then
        local okAttribute, hasAttribute = pcall(function() return model:GetAttribute("Scavenger") == true end)
        if not okAttribute or not hasAttribute then return false end
    end
    local okPlayer, player = pcall(function() return Players:GetPlayerFromCharacter(model) end)
    if okPlayer and player then return false end
    local ok, humanoid = pcall(function() return model:FindFirstChildOfClass("Humanoid") end)
    return ok and humanoid ~= nil
end

function Object:_createRecord(instance, kind)
    local record = { kind = kind, instance = instance, box = {}, skeleton = {}, lastWeapon = nil }

    if kind == "node" then
        -- Resource nodes are a dot plus name and distance; no box, no highlight.
        record.dot = self:_newDrawing("Square")
        if record.dot then pcall(function() record.dot.Filled = true end) end

        record.name = self:_newDrawing("Text")
        if record.name then
            pcall(function()
                record.name.Size = math.max(8, self.Options.textSize - 2)
                record.name.Center = true
                record.name.Outline = true
            end)
        end

        record.distance = self:_newDrawing("Text")
        if record.distance then
            pcall(function()
                record.distance.Size = math.max(8, self.Options.textSize - 2)
                record.distance.Center = true
                record.distance.Outline = true
            end)
        end
    else
        for index = 1, BOX_LINES do
            record.box[index] = self:_newDrawing("Line")
            if record.box[index] then
                pcall(function() record.box[index].Thickness = self.Options.boxThickness end)
            end
        end

        for index = 1, #BONE_PAIRS do
            record.skeleton[index] = self:_newDrawing("Line")
            if record.skeleton[index] then
                pcall(function() record.skeleton[index].Thickness = self.Options.skelThickness end)
            end
        end

        record.healthBar = self:_newDrawing("Square")
        if record.healthBar then pcall(function() record.healthBar.Filled = true end) end

        record.name = self:_newDrawing("Text")
        if record.name then
            pcall(function()
                record.name.Size = self.Options.textSize
                record.name.Center = true
                record.name.Outline = true
            end)
        end

        record.distance = self:_newDrawing("Text")
        if record.distance then
            pcall(function()
                record.distance.Size = math.max(8, self.Options.textSize - 2)
                record.distance.Center = true
                record.distance.Outline = true
                record.distance.Color = Color3.fromRGB(200, 200, 200)
            end)
        end

        record.weapon = self:_newDrawing("Text")
        if record.weapon then
            pcall(function()
                record.weapon.Size = math.max(8, self.Options.textSize - 2)
                record.weapon.Center = true
                record.weapon.Outline = true
                record.weapon.Color = Color3.fromRGB(255, 220, 80)
            end)
        end
    end

    self:_applyColors(record)
    self:_syncChams(record)

    return record
end

function Object:_destroyRecord(record)
    for _, line in ipairs(record.box) do self:_drop(line) end
    self:_drop(record.dot)
    for _, line in ipairs(record.skeleton) do self:_drop(line) end
    self:_drop(record.healthBar)
    self:_drop(record.name)
    self:_drop(record.distance)
    self:_drop(record.weapon)
    if record.highlight then
        pcall(function()
            record.highlight.Enabled = false
            record.highlight:Destroy()
        end)
        record.highlight = nil
    end
end

function Object:_track(instance, kind)
    if not instance or self._records[instance] then return end
    if not self:IsKindEnabled(kind) then return end
    if not self.Supported then return end
    local record = self:_createRecord(instance, kind)
    self._records[instance] = record
end

function Object:_untrack(instance)
    local record = self._records[instance]
    if not record then return end
    self:_destroyRecord(record)
    self._records[instance] = nil
end

function Object:_untrackKind(kind)
    local doomed = {}
    for instance, record in pairs(self._records) do
        if record.kind == kind then table.insert(doomed, instance) end
    end
    for _, instance in ipairs(doomed) do self:_untrack(instance) end
end

------------------------------------------------------------------------
-- reset of the tracked set
------------------------------------------------------------------------

function Object:Rescan()
    if not self.Running then return end

    if not self.Options.players then self:_untrackKind("player") end
    if not self.Options.npcs then self:_untrackKind("npc") end
    if not self.Options.nodes then self:_untrackKind("node") end

    -- drop records whose whitelist entry disappeared
    local dropped = {}
    for instance, record in pairs(self._records) do
        local keep = true
        if record.kind == "npc" then
            keep = self:_isNpcModel(instance)
        elseif record.kind == "node" then
            keep = self._nodeNames[instance.Name] ~= nil
        elseif record.kind == "player" then
            local okPlayer, player = pcall(function() return Players:GetPlayerFromCharacter(instance) end)
            keep = okPlayer and player ~= nil
        end
        if not keep then table.insert(dropped, instance) end
    end
    for _, instance in ipairs(dropped) do self:_untrack(instance) end

    if self.Options.players then
        local ok, players = pcall(function() return Players:GetPlayers() end)
        if ok and players then
            for _, player in ipairs(players) do
                if player ~= LocalPlayer and player.Character then
                    self:_track(player.Character, "player")
                end
            end
        end
    end

    if self.Options.npcs or self.Options.nodes then
        local ok, descendants = pcall(function() return workspace:GetDescendants() end)
        if ok and descendants then
            for _, instance in ipairs(descendants) do
                if self.Options.npcs and instance:IsA("Humanoid") then
                    if self:_isNpcModel(instance.Parent) then self:_track(instance.Parent, "npc") end
                elseif self.Options.nodes and self._nodeNames[instance.Name] then
                    self:_track(instance, "node")
                end
            end
        end
    end
end

------------------------------------------------------------------------
-- drawing
------------------------------------------------------------------------

function Object:_setVisible(record, visible)
    if record.dot then pcall(function() record.dot.Visible = visible end) end
    for _, line in ipairs(record.box) do
        if line then pcall(function() line.Visible = visible end) end
    end
    for _, line in ipairs(record.skeleton) do
        if line then pcall(function() line.Visible = visible and self.Options.skeleton == true end) end
    end
    if record.healthBar then
        pcall(function() record.healthBar.Visible = visible and self.Options.healthBar == true end)
    end
    if record.name then pcall(function() record.name.Visible = visible and self.Options.name == true end) end
    if record.distance then
        pcall(function() record.distance.Visible = visible and self.Options.distance == true end)
    end
    if record.weapon then pcall(function() record.weapon.Visible = visible and self.Options.weapon == true end) end
end

function Object:_drawBox(record, x, y, width, height)
    local fraction = self.Options.boxMode == "full" and 1 or self.Options.cornerFraction
    local cornerWidth = width * fraction
    local cornerHeight = height * fraction

    local from = {
        { x, y }, { x + cornerWidth, y },
        { x, y }, { x, y + cornerHeight },
        { x + width - cornerWidth, y }, { x + width, y },
        { x + width, y }, { x + width, y + cornerHeight },
        { x, y + height }, { x + cornerWidth, y + height },
        { x, y + height - cornerHeight }, { x, y + height },
        { x + width - cornerWidth, y + height }, { x + width, y + height },
        { x + width, y + height - cornerHeight }, { x + width, y + height },
    }

    local color = self:_boxColor(record)
    for index = 1, BOX_LINES do
        local line = record.box[index]
        if line then
            local a, b = from[index * 2 - 1], from[index * 2]
            pcall(function()
                line.From = Vector2.new(a[1], a[2])
                line.To = Vector2.new(b[1], b[2])
                line.Color = color
            end)
        end
    end
end

function Object:_drawSkeleton(record, camera)
    local model = record.instance
    for index, pair in ipairs(BONE_PAIRS) do
        local line = record.skeleton[index]
        if line then
            local okA, partA = pcall(function() return model:FindFirstChild(pair[1]) end)
            local okB, partB = pcall(function() return model:FindFirstChild(pair[2]) end)
            partA = okA and partA or nil
            partB = okB and partB or nil

            if partA and partB and partA.Position and partB.Position then
                local ok, screenA, onA, screenB, onB = pcall(function()
                    local a, visibleA = camera:WorldToViewportPoint(partA.Position)
                    local b, visibleB = camera:WorldToViewportPoint(partB.Position)
                    return a, visibleA, b, visibleB
                end)
                if ok and onA and onB then
                    pcall(function()
                        line.From = Vector2.new(screenA.X, screenA.Y)
                        line.To = Vector2.new(screenB.X, screenB.Y)
                    end)
                    pcall(function() line.Visible = true end)
                else
                    pcall(function() line.Visible = false end)
                end
            else
                pcall(function() line.Visible = false end)
            end
        end
    end
end

function Object:_equippedWeapon(model)
    local ok, tool = pcall(function() return model:FindFirstChildOfClass("Tool") end)
    if ok and tool then
        local id = nil
        pcall(function() id = tool:GetAttribute("ItemId") end)
        return tostring(id or tool.Name)
    end

    for _, attribute in ipairs({ "EquippedWeapon", "Weapon", "CurrentGun", "EquippedItemId", "WeaponName" }) do
        local value
        pcall(function() value = model:GetAttribute(attribute) end)
        if value ~= nil and value ~= "" then return tostring(value) end
    end

    local okChildren, children = pcall(function() return model:GetChildren() end)
    if okChildren and children then
        for _, child in ipairs(children) do
            local isPart = false
            pcall(function() isPart = child:IsA("BasePart") end)
            if isPart then
                local name = child.Name
                if string.find(name, "Gun") or string.find(name, "Rifle") or string.find(name, "Pistol")
                    or string.find(name, "SMG") or string.find(name, "Shotgun") or string.find(name, "Sniper")
                    or string.find(name, "Melee") or string.find(name, "Knife") then
                    return name
                end
            end
        end
    end

    return "Unarmed"
end

function Object:_recordVisible(record, camera)
    local now = os.clock()
    if record.visibleAt and now < record.visibleAt then return record.visibleNow ~= false end
    record.visibleAt = now + VISIBILITY_INTERVAL

    local model = record.instance
    local target
    pcall(function()
        target = model:FindFirstChild("Head")
            or model:FindFirstChild("HumanoidRootPart")
            or model.PrimaryPart
    end)

    local origin = camera and camera.CFrame and camera.CFrame.Position
    if not (target and target.Position and origin) then
        record.visibleNow = true
        return true
    end

    if not self._rayParams and type(RaycastParams) == "table" and type(RaycastParams.new) == "function" then
        local ok, params = pcall(RaycastParams.new)
        if ok and params then
            pcall(function()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.IgnoreWater = true
            end)
            self._rayParams = params
        end
    end

    if not self._rayParams or type(workspace.Raycast) ~= "function" then
        record.visibleNow = true
        return true
    end

    local visible
    local ok = pcall(function()
        local filter = { model }
        if LocalPlayer and LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
        self._rayParams.FilterDescendantsInstances = filter
        visible = workspace:Raycast(origin, target.Position - origin, self._rayParams) == nil
    end)
    record.visibleNow = (ok and visible) ~= false
    return record.visibleNow
end

function Object:_drawCharacter(record, camera)
    local model = record.instance
    local okHum, humanoid = pcall(function() return model:FindFirstChildOfClass("Humanoid") end)
    local root = model.PrimaryPart
    if not root then pcall(function() root = model:FindFirstChild("HumanoidRootPart") end) end
    if not root then pcall(function() root = model:FindFirstChild("Head") end) end

    if not (okHum and humanoid and humanoid.Health > 0 and root and root.Position and model.Parent) then
        self:_setVisible(record, false)
        return
    end

    local screen, onScreen = camera:WorldToViewportPoint(root.Position)
    if not onScreen or not screen then
        self:_setVisible(record, false)
        return
    end

    local depth = screen.Z or 0
    if depth <= 0.1 then
        self:_setVisible(record, false)
        return
    end

    if self.Options.maxDistance > 0 and depth > self.Options.maxDistance then
        self:_setVisible(record, false)
        return
    end

    local height = math.min(CHARACTER_HEIGHT / depth, MAX_BOX_HEIGHT)
    local width = height * 0.5
    local x = screen.X - width / 2
    local y = screen.Y - height / 2

    if self.Options.boxVisibleCheck or (self.Options.chams and record.highlight) then
        self:_recordVisible(record, camera)
        if self.Options.chams and record.highlight then self:_applyChamsColor(record) end
    end

    self:_setVisible(record, true)
    self:_drawBox(record, x, y, width, height)

    if self.Options.skeleton then self:_drawSkeleton(record, camera) end

    if self.Options.healthBar and record.healthBar then
        local percent = humanoid.Health / math.max(humanoid.MaxHealth, 1)
        pcall(function()
            record.healthBar.Position = Vector2.new(x - 6, y)
            record.healthBar.Size = Vector2.new(3, height)
            record.healthBar.Color = Color3.fromRGB(
                math.floor(255 * (1 - percent)),
                math.floor(255 * percent),
                0
            )
        end)
    end

    if self.Options.name and record.name then
        local label = model.Name
        local okPlayer, player = pcall(function() return Players:GetPlayerFromCharacter(model) end)
        if okPlayer and player then label = player.Name end
        pcall(function()
            record.name.Text = label
            record.name.Position = Vector2.new(screen.X, y - 20)
        end)
    end

    if self.Options.distance and record.distance then
        local meters = depth / math.max(self.Options.studsPerMeter, 0.5)
        pcall(function()
            record.distance.Text = string.format("%.0fm", meters)
            record.distance.Position = Vector2.new(screen.X, y + height + 4)
        end)
    end

    if self.Options.weapon and record.weapon then
        local current = self:_equippedWeapon(model)
        if current ~= record.lastWeapon then
            record.lastWeapon = current
            pcall(function() record.weapon.Text = current end)
        end
        pcall(function() record.weapon.Position = Vector2.new(screen.X, y + height + 20) end)
    end
end

function Object:_drawNode(record, camera)
    local instance = record.instance
    local position = positionOf(instance)
    if not position or not instance.Parent then
        self:_setVisible(record, false)
        return
    end

    local screen, onScreen = camera:WorldToViewportPoint(position)
    if not onScreen or not screen then
        self:_setVisible(record, false)
        return
    end

    local depth = screen.Z or 0
    if depth <= 0.1 then
        self:_setVisible(record, false)
        return
    end

    if self.Options.maxDistance > 0 and depth > self.Options.maxDistance then
        self:_setVisible(record, false)
        return
    end

    local size = self.Options.nodeDotSize
    local half = size / 2

    self:_setVisible(record, true)

    if record.dot then
        pcall(function()
            record.dot.Position = Vector2.new(screen.X - half, screen.Y - half)
            record.dot.Size = Vector2.new(size, size)
            record.dot.Color = self.Options.nodeDotColor
        end)
    end

    if self.Options.name and record.name then
        pcall(function()
            record.name.Text = instance.Name
            record.name.Position = Vector2.new(screen.X, screen.Y - half - 14)
        end)
    end

    if self.Options.distance and record.distance then
        local meters = depth / math.max(self.Options.studsPerMeter, 0.5)
        pcall(function()
            record.distance.Text = string.format("%.0fm", meters)
            record.distance.Position = Vector2.new(screen.X, screen.Y + half + 2)
        end)
    end
end

------------------------------------------------------------------------
-- loop
------------------------------------------------------------------------

function Object:_update()
    if not self.Running or not self.Supported then return end
    local camera = workspace.CurrentCamera
    if not camera then return end

    local stale = nil
    for instance, record in pairs(self._records) do
        if not instance.Parent or not self:IsKindEnabled(record.kind) then
            stale = stale or {}
            table.insert(stale, instance)
        elseif record.kind == "node" then
            self:_drawNode(record, camera)
        else
            self:_drawCharacter(record, camera)
        end
    end

    if stale then
        for _, instance in ipairs(stale) do self:_untrack(instance) end
    end
end

function Object:_onRender(delta)
    local rate = self.Options.updateRate
    if rate and rate > 0 then
        self._accumulator = self._accumulator + (delta or 0)
        if self._accumulator < 1 / rate then return end
        self._accumulator = 0
    end
    self:_update()
end

------------------------------------------------------------------------
-- lifecycle
------------------------------------------------------------------------

function Object:Start()
    if self._destroyed or self.Running then return end

    self._drawing = self._drawing or Drawing or environment.Drawing
    local drawing = self._drawing
    self.Supported = drawing ~= nil and type(drawing.new) == "function"
    if self.Supported then
        for _, class in ipairs({ "Line", "Text", "Square" }) do
            local ok, object = pcall(drawing.new, class)
            if not ok or not object then
                self.Supported = false
                report("Drawing API does not support " .. class .. "; the chams ESP needs Line, Text and Square.")
                break
            end
            pcall(function() object:Remove() end)
        end
    else
        report("Drawing API is unavailable; the chams ESP cannot draw.")
    end

    self.Running = true
    self._accumulator = 0

    local render = RunService.RenderStepped or RunService.Heartbeat
    if render then
        table.insert(self._connections, render:Connect(function(delta) self:_onRender(delta) end))
    end

    if Players.PlayerAdded then
        table.insert(self._connections, Players.PlayerAdded:Connect(function(player)
            if player == LocalPlayer then return end
            local function watch(character)
                task.wait(0.1)
                if self.Running and character and character.Parent then self:_track(character, "player") end
            end
            if player.CharacterAdded then
                local connection = player.CharacterAdded:Connect(watch)
                self._characterConnections[player] = self._characterConnections[player] or {}
                table.insert(self._characterConnections[player], connection)
            end
            if player.Character then watch(player.Character) end
        end))
    end

    if Players.PlayerRemoving then
        table.insert(self._connections, Players.PlayerRemoving:Connect(function(player)
            local tracked = self._characterConnections[player]
            if tracked then
                for _, connection in ipairs(tracked) do pcall(function() connection:Disconnect() end) end
                self._characterConnections[player] = nil
            end
            if player.Character then self:_untrack(player.Character) end
        end))
    end

    if workspace.DescendantAdded then
        table.insert(self._connections, workspace.DescendantAdded:Connect(function(instance)
            if self._nodeNames[instance.Name] then
                self:_track(instance, "node")
                return
            end
            local isHumanoid = false
            pcall(function() isHumanoid = instance:IsA("Humanoid") end)
            if isHumanoid and self:_isNpcModel(instance.Parent) then
                task.wait(0.1)
                if self.Running and instance.Parent then self:_track(instance.Parent, "npc") end
            end
        end))
    end

    if workspace.DescendantRemoving then
        table.insert(self._connections, workspace.DescendantRemoving:Connect(function(instance)
            if self._records[instance] then
                self:_untrack(instance)
                return
            end
            local isHumanoid = false
            pcall(function() isHumanoid = instance:IsA("Humanoid") end)
            if isHumanoid and instance.Parent then self:_untrack(instance.Parent) end
        end))
    end

    self:Rescan()
end

function Object:Stop()
    if not self.Running then return end
    self.Running = false

    for _, connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    self._connections = {}

    for _, connections in pairs(self._characterConnections) do
        for _, connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
    end
    self._characterConnections = {}

    local doomed = {}
    for instance in pairs(self._records) do table.insert(doomed, instance) end
    for _, instance in ipairs(doomed) do self:_untrack(instance) end
    self._records = {}

    if type(cleardrawcache) == "function" then pcall(cleardrawcache) end
end

function Object:IsRunning()
    return self.Running
end

function Object:GetCounts()
    local counts = { player = 0, npc = 0, node = 0, total = 0 }
    for _, record in pairs(self._records) do
        counts[record.kind] = (counts[record.kind] or 0) + 1
        counts.total = counts.total + 1
    end
    return counts
end

function Object:GetStatus()
    local counts = self:GetCounts()
    return {
        enabled = self.Options.enabled,
        running = self.Running,
        supported = self.Supported,
        players = counts.player,
        npcs = counts.npc,
        nodes = counts.node,
        tracked = counts.total,
    }
end

function Object:Unload()
    if self._destroyed then return end
    self:Stop()
    self._destroyed = true
    self._listeners = {}
    self._records = {}
end

------------------------------------------------------------------------
-- singleton helpers for re-executed scripts
------------------------------------------------------------------------

function WorldESP.GetInstance()
    return environment.ARC3USX_WORLD_ESP
end

function WorldESP.DestroyInstance()
    local instance = environment.ARC3USX_WORLD_ESP
    if instance then pcall(function() instance:Unload() end) end
    environment.ARC3USX_WORLD_ESP = nil
end

function WorldESP.newSingleton(config)
    WorldESP.DestroyInstance()
    local instance = WorldESP.new(config)
    environment.ARC3USX_WORLD_ESP = instance
    return instance
end

WorldESP.Object = Object

return WorldESP
