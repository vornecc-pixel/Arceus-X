-- Focused tests for Auto Weakspot: Swing-remote redirect + auto-swing + unload.
-- Run with a Lua 5.3 interpreter or fengari: lua tests/weakspot_mock.lua
-- These mocks verify the redirect logic; live Roblox behavior still needs in-game testing.

local function signal()
    local s = { listeners = {} }
    function s:Connect(fn)
        local c = { connected = true }
        function c:Disconnect() self.connected = false end
        table.insert(self.listeners, { fn = fn, connection = c })
        return c
    end
    function s:Fire(...)
        for _, item in ipairs(self.listeners) do if item.connection.connected then item.fn(...) end end
    end
    return s
end

-- Vector3 with the math the aim loop uses.
local v3 = {}
local v3meta = {}
local function vec(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, v3meta) end
function v3.new(x, y, z) return vec(x, y, z) end
v3.zero = vec(0, 0, 0)
v3meta.__add = function(a, b) return vec(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
v3meta.__sub = function(a, b) return vec(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
v3meta.__index = function(a, k)
    if k == "Magnitude" then return math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z) end
    if k == "Unit" then local m = a.Magnitude; if m == 0 then return vec(0, 0, 0) end; return vec(a.X / m, a.Y / m, a.Z / m) end
    if k == "Lerp" then return function(self, other, t) return vec(self.X + (other.X - self.X) * t, self.Y + (other.Y - self.Y) * t, self.Z + (other.Z - self.Z) * t) end end
    if k == "Dot" then return function(self, other) return self.X * other.X + self.Y * other.Y + self.Z * other.Z end end
end
Vector3 = v3
Vector2 = { new = function(x, y) return { X = x, Y = y } end }
CFrame = {
    new = function(p) return { Position = p, LookVector = vec(0, 0, -1) } end,
    lookAt = function(pos, target) return { Position = pos, LookVector = (target - pos).Unit } end,
}
local function color(r, g, b) return { R = r, G = g, B = b } end
Color3 = { new = color, fromRGB = function(r, g, b) return color(r / 255, g / 255, b / 255) end }
Enum = setmetatable({}, { __index = function(t, k)
    local e = setmetatable({}, { __index = function(_, n) return n end })
    rawset(t, k, e); return e
end })
typeof = function(v)
    if getmetatable(v) == v3meta then return "Vector3" end
    return type(v)
end
math.clamp = function(n, lo, hi) return math.max(lo, math.min(hi, n)) end
warn = function(message) io.stderr:write(tostring(message) .. "\n") end

-- Instance tree.
local nodes = {}
local function node(class, name, parent)
    local n = { ClassName = class, Name = name, Parent = parent, children = {}, attributes = {}, Destroyed = false }
    if parent then table.insert(parent.children, n) end
    table.insert(nodes, n)
    function n:IsA(t) return self.ClassName == t end
    function n:IsDescendantOf(ancestor)
        local p = self.Parent
        while p do if p == ancestor then return true end; p = p.Parent end
        return false
    end
    function n:GetChildren()
        local r = {}
        for _, c in ipairs(self.children) do if c.Parent == self then r[#r + 1] = c end end
        return r
    end
    function n:FindFirstChild(name)
        for _, c in ipairs(self.children) do if c.Parent == self and c.Name == name then return c end end
    end
    function n:FindFirstChildOfClass(class)
        for _, c in ipairs(self.children) do if c.Parent == self and c.ClassName == class then return c end end
    end
    function n:FindFirstChildWhichIsA(class)
        for _, c in ipairs(self.children) do if c.Parent == self and c:IsA(class) then return c end end
    end
    function n:GetAttribute(key) return self.attributes[key] end
    function n:SetAttribute(key, value) self.attributes[key] = value end
    function n:GetPivot() return { Position = self.PivotPosition or vec(0, 0, 0) } end
    function n:Destroy() self.Destroyed = true; self.Parent = nil end
    function n:Activate() self.activations = (self.activations or 0) + 1 end
    return n
end
local world = node("Workspace", "Workspace")
workspace = world
world.DescendantAdded, world.DescendantRemoving = signal(), signal()
world.CurrentCamera = node("Camera", "Camera", world)
world.CurrentCamera.CFrame = { Position = vec(0, 0, 0), LookVector = vec(0, 0, 1) }
function world:GetDescendants()
    local r = {}
    for _, n in ipairs(nodes) do if n:IsDescendantOf(self) then r[#r + 1] = n end end
    return r
end
Instance = { new = function(class) return node(class, class) end }

-- CollectionService with a FustNode tag set.
local tagged = {}
local collection = { tagAdded = signal() }
function collection:HasTag(obj, tag) return tagged[obj] and tagged[obj][tag] or false end
function collection:GetInstanceAddedSignal(_) return self.tagAdded end
function collection:GetInstanceRemovedSignal(_) return signal() end

local players = { LocalPlayer = node("Player", "Local"), PlayerAdded = signal(), PlayerRemoving = signal() }
function players.LocalPlayer:GetAttribute(key) return self.attributes and self.attributes[key] end
players.LocalPlayer.attributes = {}
local run = { Heartbeat = signal(), RenderStepped = signal() }
local services = {
    Players = players, RunService = run, CollectionService = collection,
    StarterGui = { SetCore = function() end },
}
game = { GetService = function(_, name) return services[name] end, HttpGet = function(_, url) return url end }
local env = {}
getgenv = function() return env end
task = { spawn = function() end, wait = function() end }
local mockClock = 1
os.clock = function() return mockClock end

-- Executor hook APIs (primary path: hookmetamethod).
local currentMethod, installedHook, lastRemoteCall = "FireServer", nil, nil
local originalNamecall = function(self, ...) lastRemoteCall = { self = self, args = { ... } } end
hookmetamethod = function(_, _, fn) installedHook = fn; return originalNamecall end
getnamecallmethod = function() return currentMethod end
setnamecallmethod = function(m) currentMethod = m end
checkcaller = function() return false end

-- Lightweight UI library mock.
local library = { Flags = {}, Options = {}, unloaded = false }
local toggleCallbacks = {}
local group = {}
function group:AddToggle(o) library.Flags[o.Flag] = o.Default or false; toggleCallbacks[o.Flag] = o.Callback end
function group:AddSlider(o) library.Flags[o.Flag] = o.Default end
function group:AddDropdown(o) library.Flags[o.Flag] = o.Default end
function group:AddLabel() return { SetText = function() end } end
function group:AddButton(o) if o.Name == "Unload Script & Clear Memory" then library.unloadButton = o.Callback end end
local tab = { AddGroup = function() return group end }
local window = { AddTab = function() return tab end, AddSettingsTab = function() end }
function library:Unload()
    if self.unloading then return end
    self.unloading = true
    local cb = self.OnUnload; self.OnUnload = nil
    if cb then cb() end
    self.unloaded = true; self.unloading = false
end
loadstring = function(source)
    if source:find("ui_bootstrap.lua", 1, true) then
        return function() return function(opts)
            opts.OnLibrary(library)
            return { Library = library, Window = window, Mix = nil }
        end end
    end
    if source:find("scripts/esp.lua", 1, true) then
        return function() return function() end end
    end
    return function() return library end
end

assert(loadfile("scripts/main.lua"))()
assert(type(env.ARC3USX_MAIN_UNLOAD) == "function", "main loaded")
assert(type(installedHook) ~= "function", "hook is not installed until the toggle is enabled")

-- Local character with a mining tool.
local character = node("Model", "LocalCharacter", world)
local root = node("BasePart", "HumanoidRootPart", character)
root.Position = vec(0, 0, 0)
local humanoid = node("Humanoid", "Humanoid", character)
humanoid.Health = 100
local tool = node("Tool", "Stone Pickaxe", character)
players.LocalPlayer.Character = character

-- A resource node with a live weakspot.
local ore = node("Model", "MetalNode", world)
ore.PivotPosition = vec(5, 0, 5)
local rock = node("BasePart", "Rock", ore)
rock.Position = vec(5, 0, 5)
local weakspot = vec(5, 2, 5)
ore:SetAttribute("WeakSpot", weakspot)
world.DescendantAdded:Fire(ore)

local swingRemote = { Name = "Swing" }
local function fireSwing(payload)
    currentMethod = "FireServer"
    lastRemoteCall = nil
    installedHook(swingRemote, payload)
    return lastRemoteCall
end

-- Enable (installs the hook) and redirect a swing to the live weakspot.
library.Flags.weakspot_enabled = true
toggleCallbacks.weakspot_enabled(true)
assert(type(installedHook) == "function", "enabling installs the Swing hook")
local call = fireSwing({ target = rock, pos = vec(0, 0, 0) })
assert(call and call.args[1].pos == weakspot, "swing is redirected to the node's WeakSpot attribute")

-- Disabling the flag makes the installed hook pass through untouched.
library.Flags.weakspot_enabled = false
call = fireSwing({ target = rock, pos = vec(0, 0, 0) })
assert(call and call.args[1].pos.X == 0, "disabled toggle does not redirect")
library.Flags.weakspot_enabled = true
call = fireSwing({ target = rock, pos = vec(0, 0, 0) })
assert(call and call.args[1].pos == weakspot, "swing is redirected to the node's WeakSpot attribute")
assert(call.args[1].target == rock, "existing target is preserved")

-- Weakspot disappears: no redirect (passes through with original pos).
ore:SetAttribute("WeakSpot", nil)
call = fireSwing({ target = rock, pos = vec(1, 1, 1) })
assert(call and call.args[1].pos.X == 1, "no redirect when the weakspot is absent")

-- Weakspot reappears: redirect resumes immediately ("hits when it appears").
ore:SetAttribute("WeakSpot", weakspot)
call = fireSwing({ target = rock, pos = vec(0, 0, 0) })
assert(call and call.args[1].pos == weakspot, "redirect resumes the moment the weakspot reappears")

-- Missing target is filled from the node.
call = fireSwing({ pos = vec(0, 0, 0) })
assert(call and call.args[1].pos == weakspot and call.args[1].target == rock, "missing target is resolved from the node")

-- Non-mining tool: no redirect.
tool.Name = "Rifle"
call = fireSwing({ target = rock, pos = vec(0, 0, 0) })
assert(call and call.args[1].pos.X == 0, "non-mining tool is not redirected")
tool.Name = "Stone Pickaxe"

-- Depleted node is skipped.
ore:SetAttribute("Depleted", true)
call = fireSwing({ target = rock, pos = vec(0, 0, 0) })
assert(call and call.args[1].pos.X == 0, "depleted node is not redirected")
ore:SetAttribute("Depleted", nil)

-- Auto-swing: camera already facing the weakspot, so a heartbeat activates the tool.
world.CurrentCamera.CFrame = { Position = vec(0, 0, 0), LookVector = (weakspot - vec(0, 0, 0)).Unit }
local before = tool.activations or 0
mockClock = mockClock + 1
run.Heartbeat:Fire(0.2)
assert((tool.activations or 0) > before, "auto-swing activates the held mining tool")

-- A green weakspot marker exists while the weakspot is present.
local marker
for _, n in ipairs(nodes) do if n.Name == "ARC3USX_Weakspot" and n.Parent then marker = n end end
assert(marker, "weakspot marker is shown while a weakspot is present")

-- Unload removes the marker and clears the singleton.
library.unloadButton()
assert(env.ARC3USX_MAIN_UNLOAD == nil and library.unloaded, "unload clears the singleton")
assert(marker.Destroyed, "unload destroys the weakspot marker")

print("Auto Weakspot redirect, appearance-gating, auto-swing and unload tests passed")
