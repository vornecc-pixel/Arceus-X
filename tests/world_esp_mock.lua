-- Chams ESP mock tests: features (scripts/world_esp.lua) and UI (scripts/world_esp_ui.lua).
-- Run from the repository root with Lua 5.3 or a compatible interpreter:
--     lua tests/world_esp_mock.lua
-- The mocks cover tracking, drawing, chams, filters, cleanup and the Octohook wiring.
-- They do not replace an in-game test.

local clock = 0
os.clock = function() return clock end
math.clamp = math.clamp or function(n, low, high) return math.max(low, math.min(high, n)) end
warn = function(message) io.stderr:write(tostring(message) .. "\n") end

local failures = {}
local function check(condition, message)
    if not condition then
        table.insert(failures, message)
        io.stderr:write("FAIL: " .. message .. "\n")
    end
end

------------------------------------------------------------------------
-- signals and tasks
------------------------------------------------------------------------

local function signal()
    local s = { listeners = {} }
    function s:Connect(fn)
        local c = { connected = true }
        function c:Disconnect() self.connected = false end
        table.insert(self.listeners, { fn = fn, connection = c })
        return c
    end
    function s:Fire(...)
        for _, item in ipairs(self.listeners) do
            if item.connection.connected then item.fn(...) end
        end
    end
    return s
end

task = {}
function task.spawn(fn, ...)
    local co = coroutine.create(fn)
    local ok, err = coroutine.resume(co, ...)
    if not ok then error(err, 0) end
    return co
end
local function yieldable()
    local ok, result = pcall(coroutine.isyieldable)
    return ok and result
end
function task.wait(seconds)
    if yieldable() then return coroutine.yield(seconds or 0) end
    return seconds or 0
end
function task.delay(_, fn, ...) return task.spawn(fn, ...) end

------------------------------------------------------------------------
-- datatypes
------------------------------------------------------------------------

local function color(r, g, b) return { R = r, G = g, B = b } end
Color3 = { new = color, fromRGB = function(r, g, b) return color(r / 255, g / 255, b / 255) end }

local v3meta = {}
local function v3(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, v3meta) end
v3meta.__add = function(a, b) return v3(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
v3meta.__sub = function(a, b) return v3(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
v3meta.__index = function(a, key)
    if key == "Magnitude" then return math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z) end
end
Vector3 = { new = function(x, y, z) return v3(x, y, z) end }
Vector2 = { new = function(x, y) return { X = x or 0, Y = y or 0 } end }

local function udim2(xs, xo, ys, yo)
    xs, xo, ys, yo = xs or 0, xo or 0, ys or 0, yo or 0
    return { X = { Scale = xs, Offset = xo }, Y = { Scale = ys, Offset = yo } }
end
UDim2 = { new = udim2, fromOffset = function(x, y) return udim2(0, x, 0, y) end }
UDim = { new = function(...) return { ... } end }
RaycastParams = { new = function() return {} end }

Enum = {
    HighlightDepthMode = { AlwaysOnTop = "AlwaysOnTop" },
    RaycastFilterType = { Exclude = "Exclude" },
    KeyCode = setmetatable({}, { __index = function(t, key) local v = { Name = key }; rawset(t, key, v); return v end }),
    RenderPriority = { Camera = { Value = 200 } },
    UserInputType = { MouseButton1 = "MouseButton1", MouseButton2 = "MouseButton2" },
}

------------------------------------------------------------------------
-- Drawing
------------------------------------------------------------------------

local drawings = {}
Drawing = {
    new = function(class)
        local object = { ClassName = class, Visible = false, removed = false, Thickness = 1 }
        function object:Remove()
            self.removed = true
            self.Visible = false
            self.Parent = nil
        end
        table.insert(drawings, object)
        return object
    end,
}

local function visibleDrawings(class)
    local list = {}
    for _, object in ipairs(drawings) do
        if object.ClassName == class and object.Visible and not object.removed then table.insert(list, object) end
    end
    return list
end

local function textVisible(text)
    for _, object in ipairs(drawings) do
        if object.ClassName == "Text" and object.Visible and not object.removed and object.Text == text then return true end
    end
    return false
end

------------------------------------------------------------------------
-- instances
------------------------------------------------------------------------

local allInstances = {}
Instance = {
    new = function(class)
        local object = { ClassName = class, Name = class, children = {}, attributes = {}, Parent = nil }
        function object:IsA(name) return self.ClassName == name end
        function object:GetChildren()
            local result = {}
            for _, child in ipairs(self.children) do
                if child.Parent == self then table.insert(result, child) end
            end
            return result
        end
        function object:FindFirstChild(name)
            for _, child in ipairs(self.children) do
                if child.Parent == self and child.Name == name then return child end
            end
        end
        function object:FindFirstChildOfClass(name)
            for _, child in ipairs(self.children) do
                if child.Parent == self and child.ClassName == name then return child end
            end
        end
        function object:FindFirstChildWhichIsA(name)
            for _, child in ipairs(self.children) do
                if child.Parent == self and child:IsA(name) then return child end
            end
        end
        function object:GetDescendants()
            local result = {}
            local function walk(node)
                for _, child in ipairs(node.children) do
                    if child.Parent == node then
                        table.insert(result, child)
                        walk(child)
                    end
                end
            end
            walk(self)
            return result
        end
        function object:GetAttribute(key) return self.attributes[key] end
        function object:SetAttribute(key, value) self.attributes[key] = value end
        function object:Destroy() self.destroyed = true; self.Parent = nil end
        table.insert(allInstances, object)
        return object
    end,
}

local function adopt(parent, child, name)
    child.Parent = parent
    if name then child.Name = name end
    table.insert(parent.children, child)
    return child
end

local function rig(name, position, rigType)
    local model = Instance.new("Model")
    model.Name = name
    local parts = rigType == "R6"
        and { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
        or { "Head", "UpperTorso", "LowerTorso", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
             "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperArm", "LeftLowerArm", "LeftHand",
             "RightUpperArm", "RightLowerArm", "RightHand" }
    for index, partName in ipairs(parts) do
        local part = Instance.new("BasePart")
        part.Name = partName
        part.Position = v3(position.X, position.Y - index, position.Z)
        adopt(model, part)
    end
    local humanoid = Instance.new("Humanoid")
    humanoid.Health, humanoid.MaxHealth = 100, 100
    adopt(model, humanoid, "Humanoid")
    model.PrimaryPart = model.children[1]
    return model, humanoid
end

local function nodePart(name, position)
    local part = Instance.new("BasePart")
    part.Name = name
    part.Position = position
    return part
end

------------------------------------------------------------------------
-- services
------------------------------------------------------------------------

camera = {
    CFrame = { Position = v3(0, 0, 0) },
    ViewportSize = Vector2.new(1280, 720),
}
camera.WorldToViewportPoint = function(_, position)
    return { X = 400 + position.X * 2, Y = 300 - position.Y * 2, Z = position.Z }, true
end

local renderStepped = signal()
local heartbeat = signal()
local RunService = { RenderStepped = renderStepped, Heartbeat = heartbeat }

local world = Instance.new("Workspace")
world.Name = "Workspace"
workspace = world
world.CurrentCamera = camera
world.DescendantAdded = signal()
world.DescendantRemoving = signal()
world.Raycast = function() return nil end

local localPlayer = Instance.new("Player")
localPlayer.Name = "Local"
local playersList = { localPlayer }
local Players = {
    LocalPlayer = localPlayer,
    PlayerAdded = signal(),
    PlayerRemoving = signal(),
    GetPlayers = function() return playersList end,
    GetPlayerFromCharacter = function(_, model)
        for _, player in ipairs(playersList) do
            if player.Character == model then return player end
        end
    end,
}

local coreGui = Instance.new("CoreGui")
local clearCount = 0
cleardrawcache = function() clearCount = clearCount + 1 end

local services = {
    Players = Players,
    RunService = RunService,
    CoreGui = coreGui,
    StarterGui = { SetCore = function() end },
}
game = { GetService = function(_, name) return assert(services[name], name) end, HttpGet = function() return "" end }

local environment = {}
getgenv = function() return environment end

------------------------------------------------------------------------
-- world setup: one enemy player, one whitelisted NPC, one stray NPC, two nodes
------------------------------------------------------------------------

local enemy = Instance.new("Player")
enemy.Name = "Enemy"
local enemyModel = rig("EnemyCharacter", v3(0, 0, 50), "R15")
enemy.Character = enemyModel
adopt(world, enemyModel)
table.insert(playersList, enemy)

local guardModel, guardHumanoid = rig("Guard", v3(10, 0, 40), "R15")
adopt(world, guardModel)

local strayModel = rig("Bystander", v3(-10, 0, 40), "R6")
adopt(world, strayModel)

local metalNode = nodePart("MetalNode", v3(0, 0, 30))
adopt(world, metalNode)
local treeNode = nodePart("Tree", v3(5, 0, 30))
adopt(world, treeNode)
local rock = nodePart("Rock", v3(-5, 0, 30))
adopt(world, rock)

------------------------------------------------------------------------
-- features
------------------------------------------------------------------------

local WorldESP = assert(loadfile("scripts/world_esp.lua"))()

check(type(WorldESP.new) == "function", "features expose new()")
check(#WorldESP.SkeletonPairs == 19, "skeleton covers R15 and R6 bones")

local esp = WorldESP.new()
check(esp.Options.boxMode == "corners" and esp.Options.boxThickness == 1, "defaults load")
check(esp:Set("cornerFraction", 5) and esp:Get("cornerFraction") == 1, "corner fraction clamps to 1")
check(esp:Set("cornerFraction", -3) and esp:Get("cornerFraction") == 0.05, "corner fraction clamps to the floor")
check(esp:Set("textSize", 99) and esp:Get("textSize") == 24, "text size clamps")
check(not esp:Set("boxMode", "triangles"), "box mode rejects unknown values")
check(not esp:Set("playerBoxColor", "blue"), "colours are validated")
check(not esp:Set("nonsense", true), "unknown options are rejected")

check(esp:GetNpcWhitelist().Guard == true and esp:GetNpcWhitelist().Soldier == true, "NPC whitelist is parsed")
check(esp:GetNodeWhitelist().MetalNode == true and esp:GetNodeWhitelist().Tree == true, "node whitelist is parsed")
check(esp:GetNodeWhitelist().Rock == nil, "nodes outside the whitelist are ignored")

check(not esp.Running, "features do not run until enabled")
esp:Set("enabled", true)
check(esp.Running, "enabling starts the loop")

local counts = esp:GetCounts()
check(counts.player == 1, "enemy player is tracked")
check(counts.npc == 1, "whitelisted NPC is tracked, stray model is not")
check(counts.node == 2, "whitelisted nodes are tracked")

local function frame()
    clock = clock + 1 / 60
    renderStepped:Fire(1 / 60)
end
frame()

check(#visibleDrawings("Line") > 0, "boxes are drawn")
check(textVisible("Enemy") and textVisible("Guard"), "names are drawn")
check(textVisible("MetalNode") and textVisible("Tree"), "node names are drawn")
check(not textVisible("Rock"), "whitelisted-out node has no label")

local function texts()
    local list = {}
    for _, object in ipairs(drawings) do
        if object.ClassName == "Text" and object.Visible and not object.removed then table.insert(list, object.Text) end
    end
    return list
end
local distanceShown = false
for _, text in ipairs(texts()) do
    if type(text) == "string" and text:find("m$") then distanceShown = true end
end
check(distanceShown, "distance labels are drawn")
check(textVisible("Unarmed"), "weapon label is drawn")

-- resource nodes: dot + name + distance only
local metalRecord = esp._records[metalNode]
check(metalRecord ~= nil and metalRecord.dot ~= nil, "resource nodes own a dot drawing")
check(metalRecord.dot.Visible == true, "resource node dot is drawn")
check(#metalRecord.box == 0, "resource nodes draw no box")
check(metalRecord.highlight == nil, "resource nodes have no highlight")
check(metalRecord.distance ~= nil and metalRecord.distance.Visible == true
    and type(metalRecord.distance.Text) == "string" and metalRecord.distance.Text:find("m$"),
    "resource node distance is drawn")
check(metalRecord.dot.Size.X == 5 and metalRecord.dot.Size.Y == 5, "node dot uses the default size")
esp:Set("nodeDotSize", 9)
frame()
check(metalRecord.dot.Size.X == 9, "node dot size is live")
esp:Set("nodeDotSize", 5)
frame()
check(#visibleDrawings("Square") >= 2, "health bars are drawn")

-- box geometry: corners vs full
local function boxLengths(model)
    local record = esp._records[model]
    if not record then return nil end
    local horizontal = math.abs(record.box[1].To.X - record.box[1].From.X)
    return horizontal, record.box[1]
end

local cornerLength = boxLengths(enemyModel)
esp:Set("boxMode", "full")
frame()
local fullLength = boxLengths(enemyModel)
frame()
check(cornerLength and cornerLength > 0, "corner boxes draw accent lines")
check(fullLength and cornerLength and fullLength > cornerLength * 2, "full boxes span the whole width")
esp:Set("boxMode", "corners")
frame()

-- chams
local function highlights()
    local list = {}
    for _, object in ipairs(allInstances) do
        if object.ClassName == "Highlight" and object.Parent and object.Enabled ~= false then table.insert(list, object) end
    end
    return list
end

check(#highlights() == 2, "highlights cover players and NPCs only")
esp:Set("chams", false)
check(#highlights() == 0, "turning chams off removes highlights")
esp:Set("chams", true)
frame()
check(#highlights() == 2, "turning chams back on recreates highlights")

-- occluded chams: the colour follows line of sight
local enemyRecord = esp._records[enemyModel]
local enemyHighlight = enemyRecord and enemyRecord.highlight
check(enemyHighlight ~= nil, "player highlight exists")
check(enemyHighlight.FillColor == esp.Options.playerChamColor, "visible chams use the visible colour")
local blocked = true
world.Raycast = function() if blocked then return { Instance = world } end return nil end
for _ = 1, 20 do
    enemyRecord.visibleAt = 0
    frame()
end
check(enemyHighlight.FillColor == esp.Options.playerChamOccludedColor, "occluded chams use the occluded colour")
blocked = false
for _ = 1, 20 do
    enemyRecord.visibleAt = 0
    frame()
end
check(enemyHighlight.FillColor == esp.Options.playerChamColor, "chams return to the visible colour")
esp:Set("chamsVisibleCheck", false)
blocked = true
for _ = 1, 20 do
    enemyRecord.visibleAt = 0
    frame()
end
check(enemyHighlight.FillColor == esp.Options.playerChamColor, "disabling the visible check keeps one colour")
world.Raycast = function() return nil end
esp:Set("chamsVisibleCheck", true)
esp:Set("chamsFillTransparency", 0.3)
frame()
check(enemyHighlight.FillTransparency == 0.3, "cham fill transparency is live")
esp:Set("chamsFillTransparency", 0.6)

-- the box itself turns green / occluded colour with line of sight
local playerBoxColor = esp.Options.playerBoxColor
local playerBoxOccluded = esp.Options.playerBoxOccludedColor
local enemyBox = esp._records[enemyModel].box[1]
check(enemyBox ~= nil, "enemy box exists")
world.Raycast = function() return nil end
enemyRecord.visibleAt = 0
frame()
check(enemyBox.Color == playerBoxColor, "visible boxes use the visible colour")
world.Raycast = function() if blocked then return { Instance = world } end return nil end
blocked = true
enemyRecord.visibleAt = 0
frame()
check(enemyBox.Color == playerBoxOccluded, "occluded boxes use the occluded colour")
blocked = false
enemyRecord.visibleAt = 0
frame()
check(enemyBox.Color == playerBoxColor, "box returns to the visible colour")
esp:Set("boxVisibleCheck", false)
blocked = true
enemyRecord.visibleAt = 0
frame()
check(enemyBox.Color == playerBoxColor, "disabling the box check keeps one colour")
esp:Set("boxVisibleCheck", true)
blocked = false
world.Raycast = function() return nil end
frame()

-- occluded colour is customisable per category
esp:Set("playerChamOccludedColor", Color3.fromRGB(1, 2, 3))
check(esp:Get("playerChamOccludedColor").R == 1 / 255, "occluded colour is stored")
esp:Set("playerChamOccludedColor", Color3.fromRGB(60, 90, 160))

-- element toggles
esp:Set("name", false)
frame()
check(not textVisible("Enemy"), "name toggle hides labels")
esp:Set("name", true)
local function anySkeletonVisible()
    for _, record in pairs(esp._records) do
        for _, line in ipairs(record.skeleton) do
            if line and line.Visible then return true end
        end
    end
    return false
end

local function anyDistanceVisible()
    for _, record in pairs(esp._records) do
        if record.distance and record.distance.Visible then return true end
    end
    return false
end

esp:Set("distance", false)
frame()
check(anyDistanceVisible() == false, "distance toggle hides distance labels")
esp:Set("distance", true)
frame()
check(anyDistanceVisible(), "distance toggle restores distance labels")

esp:Set("skeleton", false)
frame()
check(anySkeletonVisible() == false, "skeleton toggle hides bone lines")
esp:Set("skeleton", true)
frame()
check(anySkeletonVisible(), "skeleton toggle restores bone lines")

-- distance filter
esp:Set("maxDistance", 20)
frame()
check(#visibleDrawings("Line") == 0 or textVisible("Enemy") == false, "distance filter hides far targets")
esp:Set("maxDistance", 0)
frame()
check(textVisible("Enemy"), "distance filter off restores targets")

-- category toggles
esp:Set("players", false)
local countsAfterPlayers = esp:GetCounts()
check(countsAfterPlayers.player == 0 and countsAfterPlayers.npc == 1, "disabling players drops player records")
esp:Set("players", true)
frame()
check(esp:GetCounts().player == 1, "re-enabling players re-tracks them")

esp:Set("nodes", false)
check(esp:GetCounts().node == 0, "disabling nodes drops node records")
esp:Set("nodes", true)
frame()
check(esp:GetCounts().node == 2, "re-enabling nodes re-tracks them")

-- live additions and removals
local sulfur = nodePart("SulfurNode", v3(0, 0, 25))
adopt(world, sulfur)
world.DescendantAdded:Fire(sulfur)
check(esp:GetCounts().node == 3, "new nodes are tracked by the descendant hook")
frame()
check(textVisible("SulfurNode"), "new node is labelled")

sulfur.Parent = nil
world.DescendantRemoving:Fire(sulfur)
check(esp:GetCounts().node == 2, "removed nodes are untracked")

local joinModel = rig("Joiner", v3(0, 0, 60), "R6")
local joiner = Instance.new("Player")
joiner.Name = "Joiner"
joiner.Character = joinModel
adopt(world, joinModel)
Players.PlayerAdded:Fire(joiner)
joiner.CharacterAdded = signal()
table.insert(playersList, joiner)
frame()
check(esp:GetCounts().player == 2, "joining players are tracked")
joiner.CharacterAdded:Fire(joinModel)

-- whitelist edits
esp:SetNpcWhitelist("Guard, Bystander")
frame()
check(esp:GetCounts().npc == 2, "adding a name to the NPC whitelist tracks that model")
esp:SetNpcWhitelist("Guard")
frame()
check(esp:GetCounts().npc == 1, "removing a name untracks it")
check(esp:GetNpcWhitelist().Guard == true and esp:GetNpcWhitelist().Bystander == nil, "whitelist table is updated")

-- R6 skeleton support: the stray model uses R6 bone names
esp:SetNpcWhitelist("Guard, Bystander")
frame()
local r6Lines = 0
for _, record in pairs(esp._records) do
    if record.instance == strayModel then
        for _, line in ipairs(record.skeleton) do
            if line and line.Visible then r6Lines = r6Lines + 1 end
        end
    end
end
check(r6Lines >= 5, "R6 rigs get a skeleton")
esp:SetNpcWhitelist("Guard")
frame()

-- health colour reacts to the humanoid
guardHumanoid.Health = 10
frame()
local healthSquare
for _, object in ipairs(drawings) do
    if object.ClassName == "Square" and object.Visible and not object.removed then healthSquare = object break end
end
check(healthSquare ~= nil, "health bar exists")
local function anyHealthVisible()
    for _, record in pairs(esp._records) do
        if record.healthBar and record.healthBar.Visible then return true end
    end
    return false
end
esp:Set("healthBar", false)
frame()
check(anyHealthVisible() == false, "health bar toggle hides bars")
esp:Set("healthBar", true)
frame()
check(anyHealthVisible(), "health bar toggle restores bars")
guardHumanoid.Health = 100
frame()

-- teardown
esp:Unload()
check(not esp.Running, "unload stops the loop")
check(esp.GetCounts and esp:GetCounts().total == 0, "unload clears every record")
for _, object in ipairs(drawings) do
    if not object.removed then check(false, "every drawing is removed on unload") break end
end
for _, object in ipairs(allInstances) do
    if object.ClassName == "Highlight" and object.Parent then check(false, "every highlight is destroyed on unload") break end
end
check(clearCount >= 1, "cleardrawcache is called on unload")
local before = #drawings
frame()
check(#drawings == before, "the render loop stops after unload")

-- singleton
local first = WorldESP.newSingleton({ enabled = true })
local second = WorldESP.newSingleton({ enabled = true })
check(not first.Running and WorldESP.GetInstance() == second, "a new singleton unloads the previous one")
WorldESP.DestroyInstance()
check(WorldESP.GetInstance() == nil, "singleton destroy clears the global")

-- no Drawing API
Drawing = nil
local quiet = WorldESP.new({ enabled = true })
check(not quiet.Supported, "missing Drawing API is reported instead of crashing")
frame()
quiet:Set("enabled", false)
quiet:Unload()
Drawing = {
    new = function(class)
        local object = { ClassName = class, Visible = false, removed = false, Thickness = 1 }
        function object:Remove() self.removed = true; self.Visible = false end
        table.insert(drawings, object)
        return object
    end,
}

------------------------------------------------------------------------
-- UI: fake Octohook library
------------------------------------------------------------------------

local controls = {}
local function record(kind, config)
    local element = { Kind = kind, Name = config.Name or kind, Enabled = config.Default == true, Config = config }
    function element:Set(value, silent)
        if kind == "Toggle" then self.Enabled = value and true or false end
        self.Value = value
        if not silent and type(self.Config.Callback) == "function" then self.Config.Callback(value) end
    end
    function element:Fire(value) return self:Set(value) end
    function element:Keybind(cfg)
        local keybind = record("Keybind", cfg)
        keybind.Parent = self
        return keybind
    end
    function element:Colorpicker(cfg)
        cfg = cfg or {}
        local picker = record("Color", cfg)
        picker.Parent = self
        return picker
    end
    table.insert(controls, element)
    return element
end

local octo = { unloaded = false, configs = 0 }
local sectionMeta = {
    Toggle = function(_, cfg) return record("Toggle", cfg) end,
    Slider = function(_, cfg) return record("Slider", cfg) end,
    Dropdown = function(_, cfg) return record("Dropdown", cfg) end,
    Textbox = function(_, cfg) return record("Textbox", cfg) end,
    Button = function(_, cfg) return record("Button", cfg) end,
    Label = function(_, cfg)
        local label = record("Label", cfg)
        function label:Set(text) self.Text = text end
        return label
    end,
    Keybind = function(_, cfg) return record("Keybind", cfg) end,
    Colorpicker = function(_, cfg)
        cfg = cfg or {}
        return record("Color", cfg)
    end,
}

function octo:Window(config)
    local holder = { Name = config.Name }
    function holder:Panel()
        local panel = { Tabs = {} }
        function panel:Tab(tabConfig)
            local tab = { Name = tabConfig.Name }
            function tab:Column()
                local column = {}
                function column:Section(sectionConfig)
                    local section = { Name = sectionConfig.Name }
                    return setmetatable(section, { __index = sectionMeta })
                end
                return column
            end
            return tab
        end
        return panel
    end
    function holder.ChangeMenuTitle() end
    return holder
end
function octo:Notification() end
function octo:Configs() octo.configs = octo.configs + 1 end
function octo:Unload() octo.unloaded = true end

local handle = assert(loadfile("scripts/world_esp_ui.lua"))({ Library = octo, WorldESP = WorldESP })
check(type(handle) == "table" and type(handle.Destroy) == "function", "UI returns a handle")
check(environment.ARC3USX_WORLD_ESP_UI == handle, "UI registers its handle")
check(#controls > 25, "UI created its controls")

local function control(kind, name)
    for _, element in ipairs(controls) do
        if element.Kind == kind and element.Name == name then return element end
    end
end

check(control("Toggle", "Enabled") ~= nil, "master toggle exists")
check(control("Keybind", "Toggle Key") ~= nil, "master keybind exists")
check(control("Toggle", "Players") ~= nil and control("Toggle", "Resource Nodes") ~= nil, "category toggles exist")
check(control("Toggle", "Chams (highlight)") ~= nil and control("Toggle", "Skeleton") ~= nil, "element toggles exist")
check(control("Dropdown", "Box Mode") ~= nil, "box mode dropdown exists")
check(control("Slider", "Corner Size") ~= nil, "corner slider exists")
check(control("Textbox", "NPC Names") ~= nil and control("Textbox", "Node Names") ~= nil, "whitelist textboxes exist")
check(control("Color", "Box - Visible") ~= nil and control("Color", "Box - Occluded") ~= nil,
    "box colour pickers exist")
check(control("Toggle", "Box Visible Check") ~= nil, "box visible check toggle exists")
check(control("Toggle", "Occluded Chams (visible check)") ~= nil, "occlusion toggle exists")
check(control("Slider", "Fill Transparency") ~= nil and control("Slider", "Outline Transparency") ~= nil,
    "cham transparency sliders exist")
check(control("Slider", "Node Dot Size") ~= nil, "node dot size slider exists")
check(control("Color", "Chams - Visible") ~= nil and control("Color", "Chams - Occluded") ~= nil,
    "visible and occluded cham colours exist")
check(control("Color", "Dot") ~= nil and control("Color", "Name / Distance") ~= nil,
    "node dot and label colours exist")
check(control("Color", "Chams") == nil and control("Color", "Node Box") == nil,
    "node box and node cham colour pickers are gone")
check(control("Label", "Idle") ~= nil, "status label exists")

local uiEsp = handle.Esp
uiEsp:Set("enabled", false)

control("Toggle", "Enabled"):Fire(true)
check(uiEsp:Get("enabled") == true and uiEsp.Running, "master toggle starts the features")
control("Toggle", "Skeleton"):Fire(false)
check(uiEsp:Get("skeleton") == false, "element toggle drives the feature")
control("Dropdown", "Box Mode"):Fire("Full")
check(uiEsp:Get("boxMode") == "full", "box mode labels map to feature values")
control("Slider", "Corner Size"):Fire(0.5)
check(uiEsp:Get("cornerFraction") == 0.5, "corner slider drives the feature")
control("Textbox", "NPC Names"):Fire("Guard, Raider")
check(uiEsp:Get("npcWhitelist") == "Guard, Raider" and uiEsp:GetNpcWhitelist().Raider == true, "whitelist textbox drives the feature")
control("Color", "Box - Visible"):Fire(Color3.fromRGB(1, 2, 3))
check(uiEsp:Get("playerBoxColor").B == 3 / 255, "box colour picker drives the feature")
control("Color", "Box - Occluded"):Fire(Color3.fromRGB(9, 8, 7))
check(uiEsp:Get("playerBoxOccludedColor").G == 8 / 255, "occluded box colour drives the feature")
control("Color", "Box - Visible"):Fire(Color3.fromRGB(80, 220, 120))
control("Toggle", "Box Visible Check"):Fire(false)
check(uiEsp:Get("boxVisibleCheck") == false, "box visible check toggle drives the feature")
control("Toggle", "Box Visible Check"):Fire(true)
control("Toggle", "Occluded Chams (visible check)"):Fire(false)
check(uiEsp:Get("chamsVisibleCheck") == false, "occlusion toggle drives the feature")
control("Toggle", "Occluded Chams (visible check)"):Fire(true)
control("Color", "Chams - Occluded"):Fire(Color3.fromRGB(9, 8, 7))
check(uiEsp:Get("playerChamOccludedColor").R == 9 / 255, "occluded colour picker drives the feature")
control("Slider", "Fill Transparency"):Fire(0.4)
check(uiEsp:Get("chamsFillTransparency") == 0.4, "cham transparency slider drives the feature")
control("Slider", "Node Dot Size"):Fire(11)
check(uiEsp:Get("nodeDotSize") == 11, "node dot size slider drives the feature")
control("Color", "Dot"):Fire(Color3.fromRGB(4, 5, 6))
check(uiEsp:Get("nodeDotColor").G == 5 / 255, "node dot colour drives the feature")

local keybind = control("Keybind", "Toggle Key")
keybind.Config.Callback(true)
check(control("Toggle", "Enabled").Enabled == true and uiEsp:Get("enabled") == true, "keybind mirrors the master toggle")
keybind.Config.Callback(false)
check(uiEsp:Get("enabled") == false, "keybind can switch the feature off")

local unloadButton = control("Button", "Unload Chams ESP")
check(unloadButton ~= nil, "settings tab has an unload button")
uiEsp:Set("enabled", true)
unloadButton:Fire()
check(not uiEsp.Running, "unload button stops the features")
check(environment.ARC3USX_WORLD_ESP_UI == nil, "destroy clears the handle")
check(octo.unloaded == false, "an injected library is left to its owner")

local secondHandle = assert(loadfile("scripts/world_esp_ui.lua"))({ Library = octo, WorldESP = WorldESP })
secondHandle.Esp:Set("enabled", true)
local thirdHandle = assert(loadfile("scripts/world_esp_ui.lua"))({ Library = octo, WorldESP = WorldESP })
check(secondHandle.Esp.Running == false, "re-executing the UI unloads the previous features")
check(environment.ARC3USX_WORLD_ESP_UI == thirdHandle, "re-executing replaces the handle")
thirdHandle.Destroy()

if #failures > 0 then
    io.stderr:write("Chams ESP mock failures:\n")
    for _, message in ipairs(failures) do io.stderr:write("  - " .. message .. "\n") end
    error(#failures .. " chams ESP mock assertion(s) failed", 0)
end

print("Chams ESP feature, UI split and Octohook wiring mock tests passed")
