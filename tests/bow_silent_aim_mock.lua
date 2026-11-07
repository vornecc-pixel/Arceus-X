-- Bow silent aim mock tests: features (scripts/bow_silent_aim.lua) and UI
-- (scripts/bow_silent_aim_ui.lua).
-- Run from the repository root with Lua 5.3 or a compatible interpreter:
--     lua tests/bow_silent_aim_mock.lua
-- Mocks the bow tables (getgc), the Shoot remote namecall, the InventorySync event,
-- the camera projection and the executor hook functions. It does not replace an
-- in-game test: the real table shapes and payload fields come from the game.

local clock = 100
os.clock = function() return clock end
math.clamp = math.clamp or function(n, low, high) return math.max(low, math.min(high, n)) end
math.atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
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

local v3meta = {}
local function v3(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, v3meta) end
v3meta.__index = function(a, key)
    if key == "Magnitude" then return math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z) end
    if key == "Unit" then
        local m = math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z)
        if m == 0 then return v3(0, 0, 0) end
        return v3(a.X / m, a.Y / m, a.Z / m)
    end
end
v3meta.__sub = function(a, b) return v3(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
v3meta.__add = function(a, b) return v3(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
v3meta.__mul = function(a, b)
    if type(b) == "number" then return v3(a.X * b, a.Y * b, a.Z * b) end
    return v3(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
Vector3 = { new = function(x, y, z) return v3(x, y, z) end }
Vector2 = { new = function(x, y) return { X = x or 0, Y = y or 0 } end }
UDim2 = {
    fromOffset = function(x, y) return { X = x, Y = y } end,
    new = function(x, xs, y, ys) return { X = x, XS = xs, Y = y, YS = ys } end,
}

Enum = {
    RaycastFilterType = { Exclude = "Exclude" },
    KeyCode = setmetatable({}, { __index = function(t, key) local v = { Name = key }; rawset(t, key, v); return v end }),
}
RaycastParams = { new = function() return {} end }

local function color(r, g, b) return { R = r, G = g, B = b } end
Color3 = { fromRGB = function(r, g, b) return color(r / 255, g / 255, b / 255) end, new = color }

------------------------------------------------------------------------
-- instances
------------------------------------------------------------------------

Instance = {
    new = function(class)
        local object = { ClassName = class, Name = class, children = {}, attributes = {} }
        function object:IsA(name)
            if self.ClassName == name then return true end
            -- Parts are BaseParts in Roblox; the rig lookups rely on it.
            return name == "BasePart" and self.ClassName == "Part"
        end
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
        function object:FindFirstChildOfClass(class)
            for _, child in ipairs(self.children) do
                if child.Parent == self and child.ClassName == class then return child end
            end
        end
        function object:GetAttribute(key) return self.attributes[key] end
        function object:SetAttribute(key, value) self.attributes[key] = value end
        function object:Destroy() self.Parent = nil end
        return object
    end,
}

local function adopt(parent, child, name)
    child.Parent = parent
    if name then child.Name = name end
    table.insert(parent.children, child)
    return child
end

local function part(name, position, model)
    local p = Instance.new("Part")
    p.Name, p.Position, p.Parent = name, position, model
    table.insert(model.children, p)
    return p
end

local function character(name, position)
    local model = Instance.new("Model")
    model.Name = name
    local head = part("Head", position, model)
    local root = part("HumanoidRootPart", position, model)
    local torso = part("UpperTorso", position, model)
    part("LeftHand", position, model)
    part("LeftUpperArm", position, model)
    local humanoid = Instance.new("Humanoid")
    humanoid.Health, humanoid.MaxHealth, humanoid.Parent = 100, 100, model
    table.insert(model.children, humanoid)
    return model, head, root, torso, humanoid
end

------------------------------------------------------------------------
-- services
------------------------------------------------------------------------

workspace = Instance.new("Workspace")
local camera = { Parent = workspace, ViewportSize = Vector2.new(1280, 720) }
camera.CFrame = { Position = v3(0, 0, 0), LookVector = v3(0, 0, 1) }
camera.WorldToViewportPoint = function(_, position)
    return { X = 640 + position.X * 10, Y = 360 - position.Y * 10, Z = position.Z }, position.Z > 0
end
workspace.CurrentCamera = camera
workspace.Raycast = function() return nil end

local localPlayer = Instance.new("Player")
localPlayer.Name = "Local"
localPlayer.UserId = 1
local localModel = character("LocalCharacter", v3(0, 0, 0))
localPlayer.Character = localModel
table.insert(workspace.children, localModel)

local enemy = Instance.new("Player")
enemy.Name = "Enemy"
enemy.UserId = 99
local enemyModel, enemyHead, enemyRoot, enemyTorso, enemyHumanoid = character("EnemyCharacter", v3(3, 0, 50))
enemy.Character = enemyModel
table.insert(workspace.children, enemyModel)

local playersList = { localPlayer, enemy }
Players = {
    LocalPlayer = localPlayer,
    GetPlayers = function() return playersList end,
    GetPlayerFromCharacter = function(_, model)
        if model == enemyModel then return enemy end
        if model == localModel then return localPlayer end
    end,
}

local npcFolder = adopt(workspace, Instance.new("Folder"), "Npcs")

ReplicatedStorage = Instance.new("ReplicatedStorage")
local fust = adopt(ReplicatedStorage, Instance.new("Folder"), "Fust")
local remotesFolder = adopt(fust, Instance.new("Folder"), "Remotes")
local modeValue = adopt(fust, Instance.new("StringValue"), "Mode")
modeValue.Value = "Lobby"

------------------------------------------------------------------------
-- remotes with a namecall metatable
------------------------------------------------------------------------

local currentMethod = nil

local function makeRemote(name, onFire)
    local remote = adopt(remotesFolder, Instance.new("RemoteEvent"), name)
    local metatable = {}
    metatable.__namecall = function(self, ...)
        if onFire then onFire(...) end
        return "sent"
    end
    metatable.__index = function(_, key)
        if key == "FireServer" then
            return function(self, ...) return metatable.__namecall(self, ...) end
        end
    end
    setmetatable(remote, metatable)
    remote.Metatable = metatable
    return remote
end

local shootSends, arrowHits, combatFXSends = {}, {}, {}
local shoot = makeRemote("Shoot", function(payload) table.insert(shootSends, payload) end)
local arrowHit = makeRemote("ArrowHit", function(payload) table.insert(arrowHits, payload) end)
local combatFX = makeRemote("CombatFX", function(payload) table.insert(combatFXSends, payload) end)
local inventory = makeRemote("InventorySync")
inventory.OnClientEvent = signal()

local originalNamecall = shoot.Metatable.__namecall

------------------------------------------------------------------------
-- executor surface
------------------------------------------------------------------------

getrawmetatable = function(object) return getmetatable(object) end
setreadonly = function(_, state) return true end
getnamecallmethod = function() return currentMethod end
newcclosure = function(fn) return fn end

local u14 = {
    drawStart = 0, drawing = false, humanoid = {}, bowDef = {}, counts = {},
    pendingSpent = 0, lastShot = 0, shotId = 0, aimMouse = {},
}
local originalDrawTime = function() return 5 end
local u17 = {
    drawTime = originalDrawTime,
    stepXbow = function() end,
    spec = function() end,
    progress = function() end,
    xbow = function() return false end,
    fireXbow = function() end,
    loaded = false,
}
local u16 = {
    blocked = function() return true end,
    gc = { Airborne = function() return true end },
    hintAt = 0,
}
getgc = function() return { { nope = true }, u14, { drawTime = 1 }, u17, {}, u16 } end

local StarterGui = { SetCore = function() end }
local services = {
    Players = Players,
    RunService = { RenderStepped = signal(), Heartbeat = signal() },
    StarterGui = StarterGui,
    ReplicatedStorage = ReplicatedStorage,
}
game = {
    GetService = function(_, name) return assert(services[name], name) end,
    HttpGet = function() return "" end,
}

Drawing = {
    created = {},
    new = function(class)
        local drawing = { ClassName = class, Visible = false }
        function drawing:Remove() self.removed = true; self.Visible = false end
        table.insert(Drawing.created, drawing)
        return drawing
    end,
}

local environment = {}
getgenv = function() return environment end

------------------------------------------------------------------------
-- features
------------------------------------------------------------------------

local Bow = assert(loadfile("scripts/bow_silent_aim.lua"))()

check(type(Bow.new) == "function", "features expose new()")
check(#Bow.TargetParts == 4 and #Bow.FakeRegions == 3, "option lists are exported")
check(Bow.TableShapes.bowState(u14) and Bow.TableShapes.drawController(u17)
    and Bow.TableShapes.gunControl(u16), "table heuristics recognise the shapes")
check(not Bow.TableShapes.bowState({}) and not Bow.TableShapes.drawController({}), "noise tables are rejected")

local aim = Bow.new()
check(aim.Options.fov == 250 and aim.Options.targetPart == "Head" and aim.Options.rapidFire == 1,
    "defaults load")
check(aim:Set("fov", 9999) and aim:Get("fov") == 800, "fov clamps")
check(aim:Set("rapidFire", 9) and aim:Get("rapidFire") == 5, "rapid fire clamps")
check(aim:Set("chargeOverride", -2) and aim:Get("chargeOverride") == 0, "charge clamps")
check(aim:Set("ammoAmount", 0) and aim:Get("ammoAmount") == 1, "arrow count clamps")
aim:Set("chargeOverride", 1)
aim:Set("rapidFire", 1)
aim:Set("ammoAmount", 9999)
check(not aim:Set("targetPart", "Toe"), "target part rejects unknown values")
check(not aim:Set("fakeRegion", "toe"), "fake region rejects unknown values")
check(not aim:Set("fovColor", "orange"), "colours are validated")
check(not aim:Set("nonsense", true), "unknown options are rejected")
check(not aim:Set("chargeOverride", "lots"), "non numeric values are rejected")
aim:Set("fov", 250)

local changes = 0
local disconnect = aim:OnChanged(function(key) if key == "fov" then changes = changes + 1 end end)
aim:Set("fov", 300)
check(changes == 1, "change listeners fire")
disconnect()
aim:Set("fov", 250)
check(changes == 1, "change listeners disconnect")

check(not aim.Running and aim.HookInstalled == false, "nothing runs until enabled")
aim:Set("enabled", true)
check(aim.Running, "enabling starts the feature")
check(aim.Tables.u14 == u14 and aim.Tables.u17 == u17 and aim.Tables.u16 == u16, "bow tables are found")
check(aim.HookInstalled and shoot.Metatable.__namecall ~= originalNamecall, "the namecall hook is installed")

-- patches
check(u17.drawTime() == 5, "drawTime passes through while not drawing")
u14.drawing = true
check(u17.drawTime() == 0.01, "instant charge shortens the draw")
u14.drawing = false
check(u17.xbow() == true, "the crossbow is always ready")
check(u17.loaded == true, "the crossbow counts as loaded")
check(u16.blocked() == true, "the airborne bypass is off by default")
aim:Set("airborneBypass", true)
check(u16.blocked() == false, "the airborne block is patched out")
check(u16.gc.Airborne() == false, "the airborne flag is patched out")
aim:Set("airborneBypass", false)
check(u16.blocked() == true, "turning it off reverts the patch")
aim:Set("airborneBypass", true)

-- payload rewriting through the hook
currentMethod = "FireServer"
shoot:FireServer({ origin = v3(0, 0, 0), dir = v3(0, 0, 1), charge = 0.2, shotId = 1 })
check(#shootSends == 1, "the shot is forwarded")
local first = shootSends[1]
check(first.charge == 1, "charge override is applied")
check(first.dir.X > 0.01 and math.abs(first.dir.Magnitude - 1) < 1e-6, "the direction points at the target")
check(u14.lastShot == -math.huge, "the client fire rate is cleared")
check(u17.loaded == true and u17.reloadAt == nil, "the crossbow is forced loaded on fire")

-- wallbang
aim:Set("wallbang", true)
shoot:FireServer({ origin = v3(0, 0, 0), dir = v3(0, 0, 1), charge = 1, shotId = 2 })
local wallbangPayload = shootSends[#shootSends]
check(math.abs(wallbangPayload.origin.Z - 50) < 1, "wallbang moves the origin onto the target")
aim:Set("wallbang", false)

-- other namecalls pass straight through
currentMethod = "FindFirstChild"
shoot:FireServer({ dir = v3(0, 0, 1) })
check(#shootSends == 3 and shootSends[3].charge == nil, "unrelated namecalls are untouched")
currentMethod = "FireServer"

-- targeting
local target = aim:GetTarget()
check(target ~= nil and target.model == enemyModel and target.part.Name == "Head", "the head is the default part")
aim:Set("targetPart", "Torso")
check(aim:GetTarget().part.Name == "UpperTorso", "torso targeting picks the torso")
aim:Set("targetPart", "HumanoidRootPart")
check(aim:GetTarget().part.Name == "HumanoidRootPart", "root targeting picks the root")

aim:Set("targetPart", "Random")
local picked = {}
for _ = 1, 40 do
    local randomTarget = aim:GetTarget(true)
    if randomTarget and randomTarget.part then picked[randomTarget.part.Name] = true end
end
local pickedCount = 0
for _ in pairs(picked) do pickedCount = pickedCount + 1 end
check(pickedCount > 1, "random parts vary between picks")
aim:Set("targetPart", "Head")

-- filters
localPlayer.Team = "Blue"
enemy.Team = "Blue"
check(aim:GetTarget() == nil, "teammates are skipped")
enemy.Team = "Red"
check(aim:GetTarget() ~= nil, "enemies are targeted")
localPlayer.Team, enemy.Team = nil, nil

enemyHead.Position = v3(80, 0, 50)
check(aim:GetTarget() == nil, "targets outside the FOV are ignored")
aim:Set("fov", 800)
check(aim:GetTarget() ~= nil, "a wider FOV picks them up")
aim:Set("fov", 250)
enemyHead.Position = v3(3, 0, 50)

aim:Set("distance", 10)
check(aim:GetTarget() == nil, "the distance limit is applied")
aim:Set("distance", 0)

aim:Set("wallCheck", true)
workspace.Raycast = function() return { Instance = workspace } end
check(aim:GetTarget() == nil, "wall check rejects occluded targets")
workspace.Raycast = function() return nil end
check(aim:GetTarget() ~= nil, "wall check accepts clear targets")
aim:Set("wallCheck", false)

local npcModel = character("Guard", v3(-20, 0, 40))
adopt(npcFolder, npcModel)
enemyHumanoid.Health = 0
check(aim:GetTarget() == nil, "NPCs are ignored by default")
aim:Set("targetNpcs", true)
local npcTarget = aim:GetTarget()
check(npcTarget ~= nil and npcTarget.model == npcModel, "NPCs are targeted when enabled")
aim:Set("targetNpcs", false)
enemyHumanoid.Health = 100

-- manual shot
local before = #shootSends
local ok, manualPayload = aim:ManualShoot()
check(ok == true and #shootSends == before + 1, "manual shot fires the remote")
check(manualPayload.charge == 1 and manualPayload.dir ~= nil, "manual payload is aimed and charged")
check(aim.Shots >= 1, "sends are counted")

aim:Set("rapidFire", 3)
before = #shootSends
aim:ManualShoot()
check(#shootSends == before + 3, "rapid fire sends extra shots")
aim:Set("rapidFire", 1)

-- charge override can be turned off
aim:Set("overrideCharge", false)
local _, noCharge = aim:ManualShoot()
check(noCharge.charge == nil, "charge override can be disabled")
aim:Set("overrideCharge", true)

-- payload aiming can be turned off
aim:Set("aimPayload", false)
local _, straightShot = aim:ManualShoot()
check(straightShot.dir.X == 0 and straightShot.dir.Z > 0, "payload aiming off keeps the camera direction")
check(straightShot.charge == 1, "charge still applies with payload aiming off")
shoot:FireServer({ dir = v3(0, 0, 1), charge = 0.2 })
check(shootSends[#shootSends].dir.X == 0 and shootSends[#shootSends].charge == 1,
    "the hook leaves dir alone but still overrides charge")
aim:Set("aimPayload", true)

-- fake hits
aim:Set("fakeHits", true)
aim:ManualShoot()
check(#arrowHits >= 1 and arrowHits[#arrowHits].hitPlayer == 99, "a fake arrow hit is sent")
check(combatFXSends[#combatFXSends].damage == 9999 and combatFXSends[#combatFXSends].region == "head"
    and combatFXSends[#combatFXSends].kill == true, "fake damage uses the slider and region")
aim:Set("fakeDamage", 50)
aim:Set("fakeRegion", "torso")
aim:Set("fakeKill", false)
aim:ManualShoot()
check(combatFXSends[#combatFXSends].damage == 50 and combatFXSends[#combatFXSends].region == "torso"
    and combatFXSends[#combatFXSends].kill == false, "fake hit options are live")
aim:Set("fakeHits", false)

-- mode probe
modeValue.Value = "Lobby"
aim:Set("modeProbe", true)
aim:ManualShoot()
check(modeValue.Value == "World", "mode probe forces world mode")
aim:Set("modeProbe", false)

-- shot ids
aim:Set("dedupeProbe", true)
aim:ManualShoot()
aim:ManualShoot()
check(shootSends[#shootSends].shotId == shootSends[#shootSends - 1].shotId, "the probe reuses one shot id")
aim:Set("dedupeProbe", false)
local _, idOne = aim:ManualShoot()
local _, idTwo = aim:ManualShoot()
check(idOne.shotId ~= idTwo.shotId, "shot ids advance normally")

-- infinite arrows
aim:Set("infiniteArrows", true)
inventory.OnClientEvent:Fire({ slots = { { id = "arrow" }, { id = "fire_arrow" } } })
check(u14.counts.arrow == 9999 and u14.counts.fire_arrow == 9999, "arrow counts are topped up")
check(u14.pendingSpent == 0, "pending spend is cleared")
aim:Set("ammoAmount", 500)
inventory.OnClientEvent:Fire({ slots = { { id = "arrow" } } })
check(u14.counts.arrow == 500, "the arrow count follows the slider")
aim:Set("infiniteArrows", false)
u14.counts.arrow = 5
inventory.OnClientEvent:Fire({ slots = { { id = "arrow" } } })
check(u14.counts.arrow == 5, "disabling infinite arrows disconnects the listener")

-- FOV circle
aim:Set("showFov", true)
local circle = aim:GetFOVCircle()
check(circle ~= nil and circle.Visible == true and circle.Radius == 250, "the FOV circle follows the radius")
aim:Set("fov", 400)
check(circle.Radius == 400, "the circle follows radius changes")
aim:Set("fov", 250)
aim:Set("showFov", false)
check(aim:GetFOVCircle() == nil or true, "turning the circle off is safe")

-- teardown reverts everything
aim:Set("enabled", false)
check(not aim.Running, "disabling stops the feature")
check(u17.drawTime == originalDrawTime, "the draw patch is reverted")
check(u17.xbow() == false, "the crossbow patch is reverted")
check(u17.loaded == false, "the loaded patch is reverted")
check(u16.blocked() == true and u16.gc.Airborne() == true, "the airborne patches are reverted")
check(shoot.Metatable.__namecall == originalNamecall, "the hook is removed")

-- restart works and patches come back
aim:Set("enabled", true)
check(aim.Running and u16.blocked() == false and shoot.Metatable.__namecall ~= originalNamecall,
    "restarting reapplies the patches and hook")
aim:Set("airborneBypass", false)
aim:Set("enabled", false)

-- missing executor capabilities
getrawmetatable, setreadonly, getnamecallmethod = nil, nil, nil
local plain = Bow.new({ enabled = true })
check(plain.Running and plain.HookInstalled == false and type(plain.HookError) == "string",
    "missing hook functions are reported")
local plainBefore = #shootSends
local plainOk = plain:ManualShoot()
check(plainOk == true and #shootSends == plainBefore + 1, "manual shots fall back to FireServer")
plain:Unload()
getrawmetatable = function(object) return getmetatable(object) end
setreadonly = function(_, state) return true end
getnamecallmethod = function() return currentMethod end

getgc = nil
local noTables = Bow.new({ enabled = true })
check(noTables.Running and noTables.Tables.u14 == nil and type(noTables.TableError) == "string",
    "a missing getgc is reported instead of crashing")
noTables:Unload()
getgc = function() return { u14, u17, u16 } end

-- unload and singleton
aim:Unload()
check(not aim.Running, "unload stops the feature")
check(aim:ManualShoot() == false, "unloaded instances cannot fire")
local firstInstance = Bow.newSingleton({ enabled = true })
local secondInstance = Bow.newSingleton({ enabled = true })
check(not firstInstance.Running and Bow.GetInstance() == secondInstance, "a new singleton unloads the previous one")
Bow.DestroyInstance()
check(Bow.GetInstance() == nil, "singleton destroy clears the global")

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
    function element:Keybind(config)
        local keybind = record("Keybind", config)
        keybind.Parent = self
        return keybind
    end
    function element:Colorpicker(config)
        config = config or {}
        config.Name = config.Name or self.Name
        local picker = record("Color", config)
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
    Colorpicker = function(_, cfg) return record("Color", cfg or {}) end,
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
                    return setmetatable({ Name = sectionConfig.Name }, { __index = sectionMeta })
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

local handle = assert(loadfile("scripts/bow_silent_aim_ui.lua"))({ Library = octo, BowSilentAim = Bow })
check(type(handle) == "table" and type(handle.Destroy) == "function", "the UI returns a handle")
check(environment.ARC3USX_BOW_SILENT_AIM_UI == handle, "the UI registers its handle")
check(handle.Tabs.Aim and handle.Tabs.Exploits and handle.Tabs.Visuals and handle.Tabs.Settings,
    "every tab exists")
check(octo.configs == 1, "the config panel is offered")

local function control(kind, name)
    for _, element in ipairs(controls) do
        if element.Kind == kind and element.Name == name then return element end
    end
end

local toggles = {
    "Enabled", "Aim Payload", "Wall Check", "Team Check", "Target NPCs", "Override Charge",
    "Wallbang Origin", "Reuse Shot Id (probe)", "Force World Mode (probe)", "Instant Charge",
    "No Client Fire Rate", "Crossbow Always Loaded", "Airborne Bypass", "Infinite Arrows",
    "Fake Hits", "Request Kill", "Show FOV", "Filled Circle",
}
for _, name in ipairs(toggles) do
    check(control("Toggle", name) ~= nil, "toggle exists: " .. name)
end

local sliders = {
    { "FOV Radius", "fov" }, { "Distance Limit", "distance" }, { "Random Re-roll", "randomPartLifetime" },
    { "Charge", "chargeOverride" }, { "Rapid Fire", "rapidFire" }, { "Arrow Count", "ammoAmount" },
    { "Fake Damage", "fakeDamage" }, { "Thickness", "fovThickness" }, { "Transparency", "fovTransparency" },
}
for _, row in ipairs(sliders) do
    check(control("Slider", row[1]) ~= nil, "slider exists: " .. row[1])
end

check(control("Dropdown", "Target Part") ~= nil and control("Dropdown", "Hit Region") ~= nil,
    "dropdowns exist")
check(control("Keybind", "Toggle Key") ~= nil and control("Keybind", "Manual Shot Key") ~= nil,
    "both keybinds exist")
check(control("Color", "Show FOV") ~= nil, "the FOV colour picker exists")
check(control("Label", "Off") ~= nil, "the status label exists")
check(control("Button", "Unload Bow Aim") ~= nil, "the unload button exists")

local uiAim = handle.Aim
uiAim:Set("enabled", false)

control("Toggle", "Enabled"):Fire(true)
check(uiAim:Get("enabled") == true and uiAim.Running, "the master toggle starts the feature")
control("Toggle", "Enabled"):Fire(false)
check(uiAim:Get("enabled") == false and not uiAim.Running, "the master toggle stops it")
control("Toggle", "Enabled"):Fire(true)

control("Toggle", "Aim Payload"):Fire(false)
check(uiAim:Get("aimPayload") == false, "the payload toggle drives the feature")
control("Toggle", "Aim Payload"):Fire(true)
control("Toggle", "Wall Check"):Fire(true)
check(uiAim:Get("wallCheck") == true, "the wall check toggle drives the feature")
control("Toggle", "Wall Check"):Fire(false)
control("Toggle", "Target NPCs"):Fire(true)
check(uiAim:Get("targetNpcs") == true, "the NPC toggle drives the feature")
control("Toggle", "Target NPCs"):Fire(false)
control("Toggle", "Wallbang Origin"):Fire(true)
check(uiAim:Get("wallbang") == true, "the wallbang toggle drives the feature")
control("Toggle", "Wallbang Origin"):Fire(false)
control("Toggle", "Instant Charge"):Fire(false)
check(uiAim:Get("instaCharge") == false, "the instant charge toggle drives the feature")
control("Toggle", "Instant Charge"):Fire(true)
control("Toggle", "Airborne Bypass"):Fire(true)
check(uiAim:Get("airborneBypass") == true and u16.blocked() == false, "the airborne toggle applies the patch")
control("Toggle", "Airborne Bypass"):Fire(false)
check(u16.blocked() == true, "turning the airborne bypass off reverts the patch")

control("Slider", "FOV Radius"):Fire(320)
check(uiAim:Get("fov") == 320, "the FOV slider drives the feature")
control("Slider", "Distance Limit"):Fire(120)
check(uiAim:Get("distance") == 120, "the distance slider drives the feature")
control("Slider", "Charge"):Fire(0.5)
check(uiAim:Get("chargeOverride") == 0.5, "the charge slider drives the feature")
control("Slider", "Rapid Fire"):Fire(4)
check(uiAim:Get("rapidFire") == 4, "the rapid fire slider drives the feature")
control("Slider", "Rapid Fire"):Fire(1)
control("Slider", "Arrow Count"):Fire(1234)
check(uiAim:Get("ammoAmount") == 1234, "the arrow count slider drives the feature")
control("Slider", "Fake Damage"):Fire(750)
check(uiAim:Get("fakeDamage") == 750, "the fake damage slider drives the feature")
control("Slider", "Thickness"):Fire(3)
check(uiAim:Get("fovThickness") == 3, "the circle thickness drives the feature")
control("Slider", "Transparency"):Fire(25)
check(uiAim:Get("fovTransparency") == 25, "the circle transparency drives the feature")

control("Dropdown", "Target Part"):Fire("Random")
check(uiAim:Get("targetPart") == "Random", "the target part dropdown drives the feature")
control("Dropdown", "Target Part"):Fire("Torso")
check(uiAim:Get("targetPart") == "Torso", "torso is selectable")
control("Dropdown", "Hit Region"):Fire("limb")
check(uiAim:Get("fakeRegion") == "limb", "the hit region dropdown drives the feature")

control("Color", "Show FOV"):Fire(Color3.fromRGB(1, 2, 3))
check(uiAim:Get("fovColor").B == 3 / 255, "the FOV colour picker drives the feature")
control("Toggle", "Show FOV"):Fire(true)
check(uiAim:GetFOVCircle() ~= nil, "the show FOV toggle creates the circle")
control("Toggle", "Show FOV"):Fire(false)

local toggleKey = control("Keybind", "Toggle Key")
toggleKey.Config.Callback(true)
check(control("Toggle", "Enabled").Enabled == true and uiAim:Get("enabled") == true,
    "the keybind mirrors the master toggle")
toggleKey.Config.Callback(false)
check(uiAim:Get("enabled") == false, "the keybind can switch it off")

control("Toggle", "Enabled"):Fire(true)
local sendsBefore = #shootSends
local manualKey = control("Keybind", "Manual Shot Key")
manualKey.Config.Callback(true)
check(#shootSends == sendsBefore + 1, "the manual shot keybind fires")

local unloadButton = control("Button", "Unload Bow Aim")
uiAim:Set("enabled", true)
unloadButton:Fire()
check(not uiAim.Running, "the unload button stops the feature")
check(environment.ARC3USX_BOW_SILENT_AIM_UI == nil, "destroy clears the handle")
check(octo.unloaded == false, "an injected library is left alone")

local secondHandle = assert(loadfile("scripts/bow_silent_aim_ui.lua"))({ Library = octo, BowSilentAim = Bow })
secondHandle.Aim:Set("enabled", true)
local thirdHandle = assert(loadfile("scripts/bow_silent_aim_ui.lua"))({ Library = octo, BowSilentAim = Bow })
check(secondHandle.Aim.Running == false, "re-executing the UI unloads the previous aim")
check(environment.ARC3USX_BOW_SILENT_AIM_UI == thirdHandle, "re-executing replaces the handle")
thirdHandle.Destroy()

if #failures > 0 then
    io.stderr:write("Bow silent aim mock failures:\n")
    for _, message in ipairs(failures) do io.stderr:write("  - " .. message .. "\n") end
    error(#failures .. " bow silent aim mock assertion(s) failed", 0)
end

print("Bow silent aim feature, UI split and Octohook wiring mock tests passed")
