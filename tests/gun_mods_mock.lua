-- Gun mods mock tests: features (scripts/gun_mods.lua) and UI (scripts/gun_mods_ui.lua).
-- Run from the repository root with Lua 5.3 or a compatible interpreter:
--     lua tests/gun_mods_mock.lua
-- Mocks the camera, input, PlayerGui ticks and the executor hook functions. It does not
-- replace an in-game test: the real recoil curve and payloads come from the game.

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
end
Vector3 = { new = function(x, y, z) return v3(x, y, z) end }
Vector2 = { new = function(x, y) return { X = x or 0, Y = y or 0 } end }
UDim2 = {
    fromOffset = function(x, y) return { X = x, Y = y } end,
    new = function(x, xs, y, ys) return { X = x, XS = xs, Y = y, YS = ys } end,
}

local CFrameMeta = {}
CFrame = {}
function CFrame.new(position)
    return setmetatable({ Position = position or v3(0, 0, 0), Pitch = 0, Yaw = 0 }, CFrameMeta)
end
function CFrame.Angles(pitch, yaw)
    return setmetatable({ Position = v3(0, 0, 0), Pitch = pitch or 0, Yaw = yaw or 0 }, CFrameMeta)
end
CFrameMeta.__mul = function(a, b)
    return setmetatable({ Position = a.Position, Pitch = b.Pitch, Yaw = b.Yaw }, CFrameMeta)
end
CFrameMeta.__index = function(self, key)
    if key == "LookVector" then
        local cp, sp = math.cos(self.Pitch or 0), math.sin(self.Pitch or 0)
        local cy, sy = math.cos(self.Yaw or 0), math.sin(self.Yaw or 0)
        return v3(-sy * cp, sp, -cy * cp)
    end
end

Enum = {
    UserInputType = { MouseMovement = "MouseMovement", Touch = "Touch" },
    RenderPriority = { Camera = { Value = 200 } },
    KeyCode = setmetatable({}, { __index = function(t, key) local v = { Name = key }; rawset(t, key, v); return v end }),
}

------------------------------------------------------------------------
-- instances
------------------------------------------------------------------------

Instance = {
    new = function(class)
        local object = { ClassName = class, Name = class, children = {}, Visible = true }
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
        function object:IsDescendantOf(ancestor)
            local parent = self.Parent
            while parent do
                if parent == ancestor then return true end
                parent = parent.Parent
            end
            return false
        end
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

------------------------------------------------------------------------
-- services
------------------------------------------------------------------------

workspace = Instance.new("Workspace")

camera = CFrame.new(v3(0, 10, 0))
camera.Parent = workspace
camera.ViewportSize = Vector2.new(1280, 720)
workspace.CurrentCamera = camera

local renderSteps = {}
RunService = {
    RenderStepped = signal(),
    Heartbeat = signal(),
    BindToRenderStep = function(_, name, priority, fn) renderSteps[name] = { priority = priority, fn = fn } end,
    UnbindFromRenderStep = function(_, name) renderSteps[name] = nil end,
}

local function countRenderSteps()
    local count = 0
    for _ in pairs(renderSteps) do count = count + 1 end
    return count
end

local function runRenderSteps()
    local list = {}
    for _, step in pairs(renderSteps) do table.insert(list, step) end
    table.sort(list, function(a, b) return a.priority < b.priority end)
    for _, step in ipairs(list) do step.fn(1 / 60) end
end

local inputChanged = signal()
UserInputService = { InputChanged = inputChanged }

local function moveMouse()
    clock = clock + 0.005
    inputChanged:Fire({ UserInputType = Enum.UserInputType.MouseMovement })
end

local localPlayer = Instance.new("Player")
localPlayer.Name = "Local"
local playerGui = adopt(localPlayer, Instance.new("PlayerGui"), "PlayerGui")
local gather = adopt(playerGui, Instance.new("ScreenGui"), "FustGather")
local tickOne = adopt(gather, Instance.new("Frame"), "Tick1")
local tickTwo = adopt(gather, Instance.new("Frame"), "TickShadow")
local alwaysHidden = adopt(gather, Instance.new("Frame"), "TickHidden")
alwaysHidden.Visible = false
local crosshair = adopt(gather, Instance.new("Frame"), "Crosshair")

Players = { LocalPlayer = localPlayer }

ReplicatedStorage = Instance.new("ReplicatedStorage")
local fustFolder = adopt(ReplicatedStorage, Instance.new("Folder"), "Fust")
local remote = adopt(fustFolder, Instance.new("RemoteEvent"), "Shoot")

StarterGui = { SetCore = function() end }

------------------------------------------------------------------------
-- executor hook functions
------------------------------------------------------------------------

local remoteCalls = 0
local remoteMetatable = {}
remoteMetatable.__namecall = function(self, ...)
    remoteCalls = remoteCalls + 1
    return "forwarded", ...
end
setmetatable(remote, remoteMetatable)

local currentMethod = nil

getrawmetatable = function(object) return getmetatable(object) end
setreadonly = function(_, state) return true end
getnamecallmethod = function() return currentMethod end
newcclosure = function(fn) return fn end

local services = {
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    ReplicatedStorage = ReplicatedStorage,
    Workspace = workspace,
    StarterGui = StarterGui,
}
game = {
    GetService = function(_, name) return assert(services[name], name) end,
    HttpGet = function() return "" end,
}

local environment = {}
getgenv = function() return environment end

local function setCameraAngles(pitch, yaw)
    camera.CFrame = setmetatable({ Position = v3(0, 10, 0), Pitch = pitch, Yaw = yaw }, CFrameMeta)
end

------------------------------------------------------------------------
-- features
------------------------------------------------------------------------

local GunMods = assert(loadfile("scripts/gun_mods.lua"))()

check(type(GunMods.new) == "function", "features expose new()")
check(#GunMods.SpreadFields >= 5, "spread field list is exported")
check(GunMods.ZeroSpreadFields({ spread = 3 }) == true, "spread zeroing works on a bare table")
check(GunMods.ZeroSpreadFields({ spread = "3" }) == false, "non numeric spread values are left alone")
check(GunMods.WrapAngle(3 * math.pi) > -math.pi, "angles wrap")

local mods = GunMods.new()
check(mods.Options.recoilGrace == 0.025 and mods.Options.noRecoil == true, "defaults load")
check(mods:Set("recoilGrace", 5) and mods:Get("recoilGrace") == 0.5, "grace clamps")
check(mods:Set("recoilPitchEps", -1) and mods:Get("recoilPitchEps") == 0, "tolerance clamps")
check(not mods:Set("nonsense", true), "unknown options are rejected")
check(not mods:Set("recoilGrace", "soon"), "non numeric values are rejected")

local changes = 0
local disconnect = mods:OnChanged(function(key) if key == "noRecoil" then changes = changes + 1 end end)
mods:Set("noRecoil", false)
check(changes == 1, "change listeners fire")
disconnect()
mods:Set("noRecoil", true)
check(changes == 1, "change listeners disconnect")

check(not mods.Running and countRenderSteps() == 0, "features do not run until enabled")
setCameraAngles(0, 0)
mods:Set("enabled", true)
check(mods.Running, "enabling starts the loop")
check(countRenderSteps() == 1, "exactly one render step is bound")

local boundPriority
for _, step in pairs(renderSteps) do boundPriority = step.priority end
check(boundPriority ~= nil and boundPriority > 200, "recoil step binds after the camera")

-- recoil cancellation
setCameraAngles(0.05, 0.01)
runRenderSteps()
check(math.abs(camera.CFrame.Pitch) < 1e-6 and math.abs(camera.CFrame.Yaw) < 1e-6,
    "recoil is cancelled back to the base aim")
check(mods.RecoilUndo >= 1, "cancellations are counted")

-- mouse movement is accepted as real aim
moveMouse()
setCameraAngles(0.3, 0.2)
runRenderSteps()
check(math.abs(camera.CFrame.Pitch - 0.3) < 1e-6, "mouse driven aim is kept")

clock = clock + 1
setCameraAngles(0.5, 0.2)
runRenderSteps()
check(math.abs(camera.CFrame.Pitch - 0.3) < 1e-6, "recoil after the grace window is cancelled")

-- tolerances
mods:Set("recoilPitchEps", 0.05)
setCameraAngles(0.31, 0.2)
runRenderSteps()
check(math.abs(camera.CFrame.Pitch - 0.31) < 1e-6, "small deviations inside the tolerance are left alone")
setCameraAngles(0.4, 0.2)
runRenderSteps()
check(math.abs(camera.CFrame.Pitch - 0.3) < 1e-6, "larger deviations are cancelled")
mods:Set("recoilPitchEps", 0.0008)

-- toggle off
mods:Set("noRecoil", false)
setCameraAngles(0.9, 0.2)
runRenderSteps()
check(math.abs(camera.CFrame.Pitch - 0.9) < 1e-6, "no recoil toggle leaves the camera alone")
mods:Set("noRecoil", true)
mods:Set("recoilPitchEps", 0.0008)

-- bloom
check(mods.BloomHidden == 3, "bloom hides every Tick frame")
check(tickOne.Visible == false and tickTwo.Visible == false, "tick frames are hidden")
check(crosshair.Visible == true, "other frames are left alone")
mods:Set("noBloom", false)
check(tickOne.Visible == true and mods.BloomHidden == 0, "turning bloom off restores the ticks")
check(alwaysHidden.Visible == false, "originally hidden ticks stay hidden")
mods:Set("noBloom", true)
check(tickOne.Visible == false, "turning bloom back on hides them again")

-- spread hook
check(mods.HookInstalled == false, "hook starts off")
mods:Set("zeroSpread", true)
check(mods.HookInstalled == true, "hook installs when enabled")
local wrapped = remoteMetatable.__namecall
check(type(wrapped) == "function", "metatable has a wrapper")

currentMethod = "FireServer"
local payload = { spread = 5, bloom = 3, nested = { SpreadMult = 2 } }
local forwarded = wrapped(remote, payload)
check(payload.spread == 0 and payload.bloom == 0, "spread fields are zeroed")
check(payload.nested.SpreadMult == 0, "nested payload fields are zeroed")
check(remoteCalls == 1 and forwarded == "forwarded", "the original namecall is still forwarded")

currentMethod = "FindFirstChild"
local untouched = { spread = 4 }
wrapped(remote, untouched)
check(untouched.spread == 4, "other namecalls are untouched")

mods:Set("zeroSpread", false)
check(mods.HookInstalled == false, "turning the hook off uninstalls it")
check(remoteMetatable.__namecall ~= wrapped, "the original namecall is restored")

-- hook unavailable
getrawmetatable, setreadonly, getnamecallmethod = nil, nil, nil
mods:Set("zeroSpread", true)
check(mods.HookInstalled == false and type(mods.HookError) == "string",
    "missing executor functions are reported")
mods:Set("zeroSpread", false)
getrawmetatable = function(object) return getmetatable(object) end
setreadonly = function(_, state) return true end
getnamecallmethod = function() return currentMethod end

-- unload
mods:Set("noBloom", true)
mods:Unload()
check(not mods.Running, "unload stops the loop")
check(countRenderSteps() == 0, "render steps are unbound")
check(tickOne.Visible == true and tickTwo.Visible == true, "unload restores the crosshair ticks")
check(alwaysHidden.Visible == false, "unload keeps originally hidden ticks hidden")
check(mods.HookInstalled == false, "unload leaves no hook")

-- singleton
local first = GunMods.newSingleton({ enabled = true })
local second = GunMods.newSingleton({ enabled = true })
check(not first.Running and GunMods.GetInstance() == second, "a new singleton unloads the previous one")
check(countRenderSteps() == 1, "the singleton keeps a single render step")
GunMods.DestroyInstance()
check(GunMods.GetInstance() == nil and countRenderSteps() == 0, "singleton destroy clears the global")

-- camera swap is picked up
workspace.CurrentCamera = nil
local quiet = GunMods.new({ enabled = true })
runRenderSteps()
check(quiet.Running, "a missing camera does not error")
workspace.CurrentCamera = camera
setCameraAngles(0.9, 0.2)
runRenderSteps()
setCameraAngles(0.2, 0.2)
runRenderSteps()
check(math.abs(camera.CFrame.Pitch - 0.9) < 1e-6, "the camera is re-acquired after it comes back")
quiet:Unload()

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

local handle = assert(loadfile("scripts/gun_mods_ui.lua"))({ Library = octo, GunMods = GunMods })
check(type(handle) == "table" and type(handle.Destroy) == "function", "UI returns a handle")
check(environment.ARC3USX_GUN_MODS_UI == handle, "UI registers its handle")
check(handle.Tabs.Mods ~= nil and handle.Tabs.Mods.Name == "Mods", "the Mods tab exists")
check(handle.Tabs.Settings ~= nil, "the settings tab exists")
check(octo.configs == 1, "the config panel is offered")

local function control(kind, name)
    for _, element in ipairs(controls) do
        if element.Kind == kind and element.Name == name then return element end
    end
end

local function titledToggle(title)
    for _, element in ipairs(controls) do
        if element.Kind == "Toggle" and type(element.Config.Tooltip) == "table"
            and element.Config.Tooltip.Title == title then
            return element
        end
    end
end

local masterToggle = titledToggle("Gun Mods")
check(masterToggle ~= nil and masterToggle.Config.Bind == nil, "master toggle exists")
check(control("Keybind", "Toggle Key") ~= nil, "master keybind exists")
check(titledToggle("No Recoil") ~= nil, "recoil toggle exists")
check(control("Slider", "Mouse Grace") ~= nil and control("Slider", "Pitch Tolerance") ~= nil
    and control("Slider", "Yaw Tolerance") ~= nil, "recoil sliders exist")
check(control("Toggle", "No Bloom") ~= nil and control("Slider", "Sweep Rate") ~= nil, "bloom controls exist")
check(control("Toggle", "Zero Spread Fields") ~= nil, "spread hook toggle exists")
check(control("Label", "Recoil: -") ~= nil and control("Label", "Bloom: -") ~= nil
    and control("Label", "Hook: -") ~= nil, "status labels exist")

local uiMods = handle.Mods
check(uiMods:Get("enabled") == false and not uiMods.Running, "the UI starts disabled")

masterToggle:Fire(true)
check(uiMods:Get("enabled") == true and uiMods.Running, "master toggle starts the features")
masterToggle:Fire(false)
check(uiMods:Get("enabled") == false and not uiMods.Running, "master toggle stops the features")

titledToggle("No Recoil"):Fire(false)
check(uiMods:Get("noRecoil") == false, "recoil toggle drives the feature")
titledToggle("No Recoil"):Fire(true)
control("Slider", "Mouse Grace"):Fire(0.1)
check(uiMods:Get("recoilGrace") == 0.1, "grace slider drives the feature")
control("Slider", "Pitch Tolerance"):Fire(0.01)
check(uiMods:Get("recoilPitchEps") == 0.01, "pitch slider drives the feature")
control("Slider", "Sweep Rate"):Fire(0.25)
check(uiMods:Get("bloomRate") == 0.25, "bloom rate slider drives the feature")
control("Toggle", "No Bloom"):Fire(false)
check(uiMods:Get("noBloom") == false, "bloom toggle drives the feature")
control("Toggle", "No Bloom"):Fire(true)

local keybind = control("Keybind", "Toggle Key")
keybind.Config.Callback(true)
check(masterToggle.Enabled == true and uiMods:Get("enabled") == true, "keybind mirrors the master toggle")
keybind.Config.Callback(false)
check(uiMods:Get("enabled") == false, "keybind can switch the feature off")

local unloadButton = control("Button", "Unload Mods")
check(unloadButton ~= nil, "settings tab has an unload button")
uiMods:Set("enabled", true)
unloadButton:Fire()
check(not uiMods.Running, "unload button stops the features")
check(environment.ARC3USX_GUN_MODS_UI == nil, "destroy clears the handle")
check(octo.unloaded == false, "an injected library is left to its owner")

local secondHandle = assert(loadfile("scripts/gun_mods_ui.lua"))({ Library = octo, GunMods = GunMods })
secondHandle.Mods:Set("enabled", true)
local thirdHandle = assert(loadfile("scripts/gun_mods_ui.lua"))({ Library = octo, GunMods = GunMods })
check(secondHandle.Mods.Running == false, "re-executing the UI unloads the previous features")
check(environment.ARC3USX_GUN_MODS_UI == thirdHandle, "re-executing replaces the handle")
thirdHandle.Destroy()

if #failures > 0 then
    io.stderr:write("Gun mods mock failures:\n")
    for _, message in ipairs(failures) do io.stderr:write("  - " .. message .. "\n") end
    error(#failures .. " gun mods mock assertion(s) failed", 0)
end

print("Gun mods feature, UI split and Octohook wiring mock tests passed")
