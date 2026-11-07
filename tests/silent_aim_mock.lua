-- Silent aim mock tests: features (scripts/silent_aim.lua) and UI (scripts/silent_aim_ui.lua).
-- Run from the repository root with Lua 5.3 or a compatible interpreter:
--     lua tests/silent_aim_mock.lua
-- The mocks exercise the splitting, targeting rules, camera sandwich, cleanup and the
-- Octohook control wiring. Roblox/executor behaviour still needs an in-game test.

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
-- signals, tasks
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
function task.wait(seconds) return coroutine.yield(seconds or 0) end
function task.delay(_, fn, ...) return task.spawn(fn, ...) end
function task.defer(fn, ...) return task.spawn(fn, ...) end

------------------------------------------------------------------------
-- datatypes
------------------------------------------------------------------------

local function color(r, g, b) return { R = r, G = g, B = b } end
Color3 = { new = color, fromRGB = function(r, g, b) return color(r / 255, g / 255, b / 255) end, fromHSV = function() return color(1, 1, 1) end }

local v3meta = {}
v3meta.__add = function(a, b) return setmetatable({ X = a.X + b.X, Y = a.Y + b.Y, Z = a.Z + b.Z }, v3meta) end
v3meta.__sub = function(a, b) return setmetatable({ X = a.X - b.X, Y = a.Y - b.Y, Z = a.Z - b.Z }, v3meta) end
v3meta.__mul = function(a, b)
    if type(b) == "number" then return setmetatable({ X = a.X * b, Y = a.Y * b, Z = a.Z * b }, v3meta) end
    return setmetatable({ X = a.X * b.X, Y = a.Y * b.Y, Z = a.Z * b.Z }, v3meta)
end
v3meta.__div = function(a, b)
    if type(b) == "number" then return setmetatable({ X = a.X / b, Y = a.Y / b, Z = a.Z / b }, v3meta) end
    return setmetatable({ X = a.X / b.X, Y = a.Y / b.Y, Z = a.Z / b.Z }, v3meta)
end
v3meta.__index = function(a, key)
    if key == "Magnitude" then return math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z) end
    if key == "Unit" then
        local magnitude = math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z)
        if magnitude == 0 then return setmetatable({ X = 0, Y = 0, Z = 0 }, v3meta) end
        return setmetatable({ X = a.X / magnitude, Y = a.Y / magnitude, Z = a.Z / magnitude }, v3meta)
    end
end
Vector3 = { new = function(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, v3meta) end }
Vector2 = { new = function(x, y) return { X = x or 0, Y = y or 0 } end }
local function udim2(xs, xo, ys, yo)
    xs, xo, ys, yo = xs or 0, xo or 0, ys or 0, yo or 0
    return { X = { Scale = xs, Offset = xo }, Y = { Scale = ys, Offset = yo } }
end
UDim2 = { new = udim2, fromOffset = function(x, y) return udim2(0, x, 0, y) end, fromScale = function(x, y) return udim2(x, 0, y, 0) end }
UDim = { new = function(...) return { ... } end }

CFrame = {
    new = function(position) return { Position = position } end,
    lookAt = function(origin, target)
        return { Position = origin, LookAt = target, IsLookAt = true }
    end,
}

Enum = {
    RenderPriority = { Camera = { Value = 200 } },
    RaycastFilterType = { Exclude = "Exclude" },
    UserInputType = { MouseButton1 = "MouseButton1", MouseButton2 = "MouseButton2" },
    KeyCode = setmetatable({}, { __index = function(t, key) local v = { Name = key }; rawset(t, key, v); return v end }),
}
RaycastParams = { new = function() return {} end }

Drawing = {
    new = function(class)
        local drawing = { ClassName = class, Visible = false, removed = false }
        function drawing:Remove() self.removed = true; self.Visible = false end
        table.insert(Drawing.created, drawing)
        return drawing
    end,
    created = {},
}

typeof = function(value)
    if type(value) == "table" and value.R and value.G and value.B then return "Color3" end
    return type(value)
end

------------------------------------------------------------------------
-- instances
------------------------------------------------------------------------

Instance = {
    new = function(class)
        local object = { ClassName = class, Name = class, children = {}, attributes = {} }
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

local function part(name, position, parent)
    local p = Instance.new("Part")
    p.Name, p.Position, p.Parent = name, position, parent
    table.insert(parent.children, p)
    return p
end

local function character(name, position)
    local model = Instance.new("Model")
    model.Name = name
    local head = part("Head", position, model)
    local root = part("HumanoidRootPart", position, model)
    local humanoid = Instance.new("Humanoid")
    humanoid.Health, humanoid.MaxHealth, humanoid.Parent = 100, 100, model
    table.insert(model.children, humanoid)
    return model, head, root, humanoid
end

------------------------------------------------------------------------
-- services
------------------------------------------------------------------------

local renderSteps, renderOrder = {}, 0
local renderStepped = signal()

local RunService = {
    RenderStepped = renderStepped,
    Heartbeat = signal(),
    BindToRenderStep = function(_, name, priority, fn)
        renderOrder = renderOrder + 1
        renderSteps[name] = { priority = priority, order = renderOrder, fn = fn }
    end,
    UnbindFromRenderStep = function(_, name) renderSteps[name] = nil end,
}

local lastSnap, lastFrame = nil, nil
local function runRenderSteps()
    local list = {}
    for _, step in pairs(renderSteps) do table.insert(list, step) end
    table.sort(list, function(a, b)
        if a.priority == b.priority then return a.order < b.order end
        return a.priority < b.priority
    end)
    lastSnap = nil
    for _, step in ipairs(list) do
        step.fn(1 / 60)
        if camera.CFrame and camera.CFrame.IsLookAt then lastSnap = camera.CFrame end
    end
    lastFrame = camera.CFrame
end
local function snapped() return lastSnap ~= nil end
local function restored() return lastFrame ~= nil and lastFrame.IsLookAt ~= true end

local inputBegan, inputEnded = signal(), signal()
local UserInputService = {
    InputBegan = inputBegan,
    InputEnded = inputEnded,
    GetMouseLocation = function() return Vector2.new(400, 300) end,
}

local function fire(inputType, pressed)
    local input = { UserInputType = inputType }
    if pressed then inputBegan:Fire(input, false) else inputEnded:Fire(input) end
end

local localPlayer = Instance.new("Player")
localPlayer.Name = "Local"
localPlayers = { localPlayer }

local Players = {
    LocalPlayer = localPlayer,
    PlayerAdded = signal(),
    PlayerRemoving = signal(),
    GetPlayers = function() return localPlayers end,
    GetPlayerFromCharacter = function(_, model)
        for _, player in ipairs(localPlayers) do
            if player.Character == model then return player end
        end
    end,
}

local world = Instance.new("Workspace")
world.Name = "Workspace"
workspace = world
camera = { CFrame = { Position = Vector3.new(0, 0, 0) }, ViewportSize = Vector2.new(800, 600) }
camera.WorldToViewportPoint = function(_, position)
    -- straight-on projection: 10 px per stud, crosshair at (400, 300)
    return { X = 400 + position.X * 10, Y = 300 - position.Y * 10, Z = position.Z }, position.Z > 0
end
world.CurrentCamera = camera
world.Raycast = function() return nil end
world.children = {}

local services = {
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    StarterGui = { SetCore = function() end },
}
game = { GetService = function(_, name) return assert(services[name], name) end, HttpGet = function() return "" end }

local environment = {}
getgenv = function() return environment end

------------------------------------------------------------------------
-- features
------------------------------------------------------------------------

local SilentAim = assert(loadfile("scripts/silent_aim.lua"))()

check(type(SilentAim.new) == "function", "features expose new()")
check(#SilentAim.ActivationModes == 3 and #SilentAim.Bones == 2, "features expose their option lists")

local aim = SilentAim.new()
check(aim.Options.fov == 220 and aim.Options.hitChance == 100 and aim.Options.bone == "Head", "defaults load")
check(aim:Set("fov", 9999) and aim:Get("fov") == 800, "numeric options clamp")
check(aim:Set("fov", -10) and aim:Get("fov") == 0, "numeric options clamp at the low end")
check(not aim:Set("activation", "nope"), "dropdown options reject unknown values")
check(not aim:Set("missing", true), "unknown options are rejected")
check(not aim:Set("fovColor", "red"), "colour validation rejects strings")

local changes = 0
local disconnect = aim:OnChanged(function(key) if key == "fov" then changes = changes + 1 end end)
aim:Set("fov", 100)
check(changes == 1, "change listeners fire")
disconnect()
aim:Set("fov", 120)
check(changes == 1, "change listeners disconnect")

aim:Set("fov", 220)
aim:Set("fovColor", Color3.fromRGB(255, 0, 0))
check(aim:Get("fovColor").R == 1, "colour options store Color3")

-- target setup: one enemy in front of the camera
local enemy = Instance.new("Player")
enemy.Name = "Enemy"
enemy.UserId = 99
local enemyModel, enemyHead, enemyRoot, enemyHumanoid = character("EnemyCharacter", Vector3.new(0, 0, 50))
enemy.Character = enemyModel
table.insert(localPlayers, enemy)

check(not aim.Running, "features do not run until enabled")
aim:Set("enabled", true)
check(aim.Running, "enabling starts the render steps")
check(type(renderSteps) == "table" and next(renderSteps) ~= nil, "render steps are bound")

local realCFrame = camera.CFrame
aim:Set("shotOnly", false)
runRenderSteps()
check(snapped(), "snap aims the camera at the target")
check(aim:GetTarget() ~= nil, "target is exposed for status labels")
runRenderSteps()
check(restored(), "camera is restored on the next frame")

-- shot gating
aim:Set("shotOnly", true)
runRenderSteps()
check(not snapped(), "shot-only mode waits for a shot")
fire(Enum.UserInputType.MouseButton1, true)
runRenderSteps()
check(snapped(), "shot-only mode snaps while firing")
fire(Enum.UserInputType.MouseButton1, false)
clock = clock + 0.05
runRenderSteps()
check(snapped(), "shot-only mode remembers a recent shot")
clock = clock + 0.5
runRenderSteps()
check(not snapped(), "shot memory expires")

-- hit chance
aim:Set("shotOnly", false)
aim:Set("hitChance", 0)
runRenderSteps()
check(not snapped(), "0% hit chance never snaps")
aim:Set("hitChance", 100)
clock = clock + 1
runRenderSteps()
check(snapped(), "100% hit chance always snaps")

-- fov and distance limits
enemyHead.Position = Vector3.new(30, 0, 50)
enemyRoot.Position = Vector3.new(30, 0, 50)
aim:Set("fov", 10)
clock = clock + 1
runRenderSteps()
check(not snapped(), "targets outside the FOV are ignored")
aim:Set("fov", 400)
enemyRoot.Position = Vector3.new(0, 0, 900)
enemyHead.Position = Vector3.new(0, 0, 900)
aim:Set("distance", 100)
clock = clock + 1
runRenderSteps()
check(not snapped(), "distance limit is respected")
aim:Set("distance", 0)
enemyRoot.Position = Vector3.new(0, 0, 50)
enemyHead.Position = Vector3.new(0, 0, 50)
clock = clock + 1
runRenderSteps()
check(snapped(), "distance limit 0 means unlimited")

-- wall check
aim:Set("wallCheck", true)
world.Raycast = function() return { Instance = Instance.new("Part") } end
clock = clock + 1
runRenderSteps()
check(not snapped(), "wall check blocks occluded targets")
world.Raycast = function() return nil end
clock = clock + 1
runRenderSteps()
check(snapped(), "wall check passes clear targets")

-- team check
aim:Set("teamCheck", true)
localPlayer.attributes.FustMates = "99"
clock = clock + 1
runRenderSteps()
check(not snapped(), "teammates are skipped")
localPlayer.attributes.FustMates = ""
localPlayer.Team = "blue"
enemy.Team = "blue"
clock = clock + 1
runRenderSteps()
check(not snapped(), "same Team is skipped")
localPlayer.Team = nil
enemy.Team = nil
clock = clock + 1
runRenderSteps()
check(snapped(), "enemies with no team are targeted")

-- bone selection
aim:Set("bone", "HumanoidRootPart")
clock = clock + 1
runRenderSteps()
check(snapped() and lastSnap.LookAt.Z > 0, "root bone is used when selected")
aim:Set("bone", "Head")

-- prediction: move the target and compare the aim point
aim:Set("prediction", false)
clock = clock + 2
runRenderSteps()
local staticTarget = lastSnap and lastSnap.LookAt
aim:Set("prediction", true)
enemyRoot.Position = Vector3.new(6, 0, 50)
enemyHead.Position = Vector3.new(6, 0, 50)
clock = clock + 0.1
runRenderSteps()
enemyRoot.Position = Vector3.new(12, 0, 50)
enemyHead.Position = Vector3.new(12, 0, 50)
clock = clock + 0.1
runRenderSteps()
check(lastSnap and lastSnap.LookAt.X > 12, "prediction leads a moving target")
check(staticTarget.X == 0, "static target was aimed at directly")

-- cooldown
aim:Set("prediction", false)
aim:Set("gunSpeed", 0)
aim:Set("cooldown", 0.5)
clock = clock + 1
runRenderSteps()
check(snapped(), "first snap passes the cooldown")
runRenderSteps()
check(not snapped(), "cooldown blocks the next frame")
aim:Set("cooldown", 0)
clock = clock + 1
runRenderSteps()
check(snapped(), "cooldown 0 snaps every frame")

-- hold / toggle activation
aim:Set("activation", "Hold")
runRenderSteps()
check(not snapped(), "hold mode waits for the right mouse button")
fire(Enum.UserInputType.MouseButton2, true)
clock = clock + 1
runRenderSteps()
check(snapped(), "hold mode snaps while held")
fire(Enum.UserInputType.MouseButton2, false)
clock = clock + 1
runRenderSteps()
check(not snapped(), "hold mode releases")
aim:Set("activation", "Toggle")
aim:SetActive(false)
clock = clock + 1
runRenderSteps()
check(not snapped(), "toggle mode waits for the toggle key")
check(aim:ToggleActive() == true, "toggle flips the toggle state")
clock = clock + 1
runRenderSteps()
check(snapped(), "toggle mode snaps when toggled on")
aim:Set("activation", "Always")

-- NPC targeting
local npcs = Instance.new("Folder")
npcs.Name = "Npcs"
npcs.Parent = world
table.insert(world.children, npcs)
local npcModel, npcHead, npcRoot = character("Guard", Vector3.new(0, 0, 40))
npcModel.Parent = npcs
table.insert(npcs.children, npcModel)
enemy.Character = nil
clock = clock + 1
runRenderSteps()
check(not snapped(), "NPCs are ignored by default")
aim:Set("targetNpcs", true)
clock = clock + 1
runRenderSteps()
check(snapped(), "NPCs are targeted when enabled")
local player = Players:GetPlayerFromCharacter(npcModel)
check(player == nil, "NPC is not a player")
aim:Set("targetNpcs", false)
enemy.Character = enemyModel

-- FOV circle
aim:Set("fov", 220)
aim:Set("showFov", true)
clock = clock + 1
runRenderSteps()
check(#Drawing.created > 0, "FOV circle is created for Drawing")
local circle = aim:GetFOVCircle()
check(circle and circle.Visible == true and circle.Radius == 220, "FOV circle follows the radius")
aim:Set("fovColor", Color3.fromRGB(0, 255, 0))
aim:Set("fovFilled", true)
aim:Set("fovTransparency", 0)
runRenderSteps()
check(circle.Color.G == 1 and circle.Filled == true and circle.Transparency == 0, "FOV circle follows colour, fill and transparency")
aim:Set("showFov", false)
runRenderSteps()
check(circle.Visible == false, "FOV circle hides")

-- stop / restart
aim:Set("enabled", false)
check(not aim.Running, "disabling stops the render steps")
check(next(renderSteps) == nil, "render steps are unbound")
check(circle.removed == true, "FOV circle is removed on stop")
aim:Start()
check(aim.Running and next(renderSteps) ~= nil, "start can be called manually")
aim:Stop()
check(not aim.Running, "stop is idempotent")

-- singleton re-execute helper
local first = SilentAim.newSingleton({ enabled = true })
check(first.Running, "singleton instance starts")
local second = SilentAim.newSingleton({})
check(not first.Running and not first.Running and SilentAim.GetInstance() == second, "a new singleton unloads the previous one")
SilentAim.DestroyInstance()
check(SilentAim.GetInstance() == nil, "singleton destroy clears the global")

aim:Set("enabled", true)
aim:Unload()
check(not aim.Running and aim:GetFOVCircle() == nil, "unload stops everything")
aim:Unload()
check(true, "unload is idempotent")

-- unknown camera / no Drawing must not error
Drawing = nil
local quiet = SilentAim.new({ enabled = true, showFov = true })
quiet:Set("enabled", true)
runRenderSteps()
check(quiet.Running, "features start without a Drawing API")
quiet:Set("showFov", true)
check(quiet:GetFOVCircle() == nil, "no circle without a Drawing API")
quiet:Unload()

------------------------------------------------------------------------
-- UI: fake Octohook library so the wiring can be checked without Roblox
------------------------------------------------------------------------

local controls = {}
local function record(kind, config)
    local element = {
        Kind = kind,
        Name = config.Name or kind,
        Enabled = config.Default == true,
        Config = config,
    }
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
        config.Name = self.Name
        local picker = record("Color", config)
        picker.Parent = self
        return picker
    end
    table.insert(controls, element)
    return element
end

local octo = { unloaded = false, notifications = 0, configs = 0 }

local sectionMeta
sectionMeta = {
    Toggle = function(self, config) return record("Toggle", config) end,
    Slider = function(self, config) return record("Slider", config) end,
    Dropdown = function(self, config) return record("Dropdown", config) end,
    Textbox = function(self, config) return record("Textbox", config) end,
    Button = function(self, config) return record("Button", config) end,
    Label = function(self, config)
        local label = record("Label", config)
        function label:Set(text) self.Text = text end
        return label
    end,
    Keybind = function(self, config) return record("Keybind", config) end,
    Colorpicker = function(self, config)
        config = config or {}
        return record("Color", config)
    end,
}
local function newSection(name)
    local object = { Name = name, Items = { Elements = {} } }
    return setmetatable(object, { __index = sectionMeta })
end

function octo:Window(config)
    local holder = { Name = config.Name }
    function holder:Panel(panelConfig)
        local panel = { Name = panelConfig.Name, Size = panelConfig.Size, Position = panelConfig.Position, Tabs = {} }
        function panel:Tab(tabConfig)
            local tab = { Name = tabConfig.Name, Columns = {} }
            function tab:Column()
                local column = { Sections = {} }
                function column:Section(sectionConfig)
                    local section = newSection(sectionConfig.Name)
                    table.insert(column.Sections, section)
                    return section
                end
                table.insert(tab.Columns, column)
                return column
            end
            table.insert(panel.Tabs, tab)
            return tab
        end
        return panel
    end
    function holder.ChangeMenuTitle() end
    return holder
end
function octo:Notification() octo.notifications = octo.notifications + 1 end
function octo:Configs() octo.configs = octo.configs + 1 end
function octo:Unload() octo.unloaded = true end

local handle = assert(loadfile("scripts/silent_aim_ui.lua"))({ Library = octo, SilentAim = SilentAim })
check(type(handle) == "table" and type(handle.Destroy) == "function", "UI returns a handle with Destroy")
check(environment.ARC3USX_SILENT_AIM_UI == handle, "UI registers its handle for re-execute cleanup")
check(#controls > 10, "UI created its controls")

local function control(kind, name)
    for _, element in ipairs(controls) do
        if element.Kind == kind and element.Name == name then return element end
    end
end

check(control("Toggle", "Enabled") ~= nil, "master toggle exists")
check(control("Keybind", "Toggle Key") ~= nil, "master keybind exists")
check(control("Dropdown", "Activation") ~= nil, "activation dropdown exists")
check(control("Slider", "FOV Radius") ~= nil, "FOV slider exists")
check(control("Color", "Visualize FOV") ~= nil, "FOV colour picker exists")
check(control("Label", "Idle") ~= nil, "status label exists")

local uiAim = handle.Aim
uiAim:Set("enabled", false)

control("Toggle", "Enabled"):Fire(true)
check(uiAim:Get("enabled") == true, "master toggle drives the feature")
control("Toggle", "Enabled"):Fire(false)
check(uiAim:Get("enabled") == false, "master toggle turns the feature off")

control("Slider", "FOV Radius"):Fire(300)
check(uiAim:Get("fov") == 300, "FOV slider drives the feature")
control("Slider", "Hit Chance"):Fire(250)
check(uiAim:Get("hitChance") == 100, "hit chance is clamped by the feature")

control("Dropdown", "Activation"):Fire("Hold (RMB)")
check(uiAim:Get("activation") == "Hold", "activation labels map to feature values")
control("Dropdown", "Activation"):Fire("Toggle (Key)")
check(uiAim:Get("activation") == "Toggle", "toggle activation maps too")
control("Dropdown", "Target Bone"):Fire("HumanoidRootPart")
check(uiAim:Get("bone") == "HumanoidRootPart", "bone dropdown drives the feature")

control("Color", "Visualize FOV"):Fire(Color3.fromRGB(0, 0, 255))
check(uiAim:Get("fovColor").B == 1, "colour picker drives the feature")

control("Slider", "Snap Cooldown"):Fire(0.25)
check(uiAim:Get("cooldown") == 0.25, "cooldown slider accepts decimals")

-- keybind: mode Toggle flips the master toggle (and the feature) through its callback
local keybind = control("Keybind", "Toggle Key")
check(keybind.Config.Callback ~= nil, "keybind has a callback")
keybind.Config.Callback(true)
check(control("Toggle", "Enabled").Enabled == true and uiAim:Get("enabled") == true, "keybind mirrors into the toggle and the feature")
keybind.Config.Callback(false)
check(uiAim:Get("enabled") == false, "keybind can switch the feature off")

-- unload button
local unloadButton = control("Button", "Unload Silent Aim")
check(unloadButton ~= nil, "settings tab has an unload button")
uiAim:Set("enabled", true)
unloadButton:Fire()
check(not uiAim.Running, "unload button stops the features")
check(octo.unloaded == false, "an injected library is left alone; its owner unloads it")
check(environment.ARC3USX_SILENT_AIM_UI == nil, "destroy clears the handle")

-- re-executing destroys the previous menu and its features
local secondHandle = assert(loadfile("scripts/silent_aim_ui.lua"))({ Library = octo, SilentAim = SilentAim })
local previousHandle = secondHandle
previousHandle.Aim:Set("enabled", true)
local thirdHandle = assert(loadfile("scripts/silent_aim_ui.lua"))({ Library = octo, SilentAim = SilentAim })
check(previousHandle.Aim.Running == false, "re-executing the UI unloads the previous features")
check(environment.ARC3USX_SILENT_AIM_UI == thirdHandle, "re-executing replaces the handle")
thirdHandle.Destroy()
check(octo.unloaded == false and environment.ARC3USX_SILENT_AIM_UI == nil, "destroy cleans the handle but leaves the owned library")

if #failures > 0 then
    io.stderr:write("Silent aim mock failures:\n")
    for _, message in ipairs(failures) do io.stderr:write("  - " .. message .. "\n") end
    error(#failures .. " silent aim mock assertion(s) failed", 0)
end

print("Silent aim feature, UI split and Octohook wiring mock tests passed")
