-- Run with a Lua 5.3 interpreter or fengari: lua tests/esp_mock.lua
-- Lightweight mocks check lifecycle logic; Roblox/executor behavior still needs in-game testing.
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
local v3 = {}
local v3meta = {
    __sub = function(a, b) return v3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end,
    __index = function(a, k) if k == "Magnitude" then return math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z) end end,
}
function v3.new(x, y, z) return setmetatable({ X = x, Y = y, Z = z }, v3meta) end
Vector3 = v3
Vector2 = { new = function(x, y) return { X = x, Y = y } end }
local function color(r, g, b)
    return { R = r, G = g, B = b, Lerp = function(self, other, t) return color(self.R * (1-t) + other.R*t, self.G*(1-t)+other.G*t, self.B*(1-t)+other.B*t) end }
end
Color3 = { new = color, fromRGB = function(r, g, b) return color(r/255, g/255, b/255) end }
Enum = { KeyCode = { RightShift = 1 }, RaycastFilterType = { Exclude = 1 }, HighlightDepthMode = { AlwaysOnTop = 1 } }
RaycastParams = { new = function() return {} end }
math.clamp = function(n, lo, hi) return math.max(lo, math.min(hi, n)) end
warn = function(message) io.stderr:write(message .. "\n") end
local nodes = {}
local function node(class, name, parent)
    local n = { ClassName = class, Name = name, Parent = parent, children = {}, Destroyed = false }
    if parent then table.insert(parent.children, n) end
    table.insert(nodes, n)
    function n:IsA(typeName) return self.ClassName == typeName end
    function n:IsDescendantOf(ancestor)
        local p = self.Parent
        while p do if p == ancestor then return true end; p = p.Parent end
        return false
    end
    function n:FindFirstChild(name)
        for _, child in ipairs(self.children) do if child.Parent == self and child.Name == name then return child end end
    end
    function n:FindFirstChildOfClass(className)
        for _, child in ipairs(self.children) do if child.Parent == self and child.ClassName == className then return child end end
    end
    function n:FindFirstChildWhichIsA(className, recursive)
        for _, child in ipairs(self.children) do
            if child.Parent == self then
                if child:IsA(className) then return child end
                if recursive then local result = child:FindFirstChildWhichIsA(className, true); if result then return result end end
            end
        end
    end
    function n:Destroy() self.Destroyed = true; self.Parent = nil end
    function n:GetAttribute(key) return self.attributes and self.attributes[key] end
    function n:GetBoundingBox()
        return { Position = v3.new(0, 0, 10), PointToWorldSpace = function(_, point) return v3.new(point.X, point.Y, point.Z + 10) end }, v3.new(4, 6, 2)
    end
    return n
end
local world = node("Workspace", "Workspace")
workspace = world
world.DescendantAdded, world.DescendantRemoving = signal(), signal()
world.CurrentCamera = { CFrame = { Position = v3.new(0, 0, 0) }, ViewportSize = { X = 800, Y = 600 } }
function world.CurrentCamera:WorldToViewportPoint(p) return { X = 400 + p.X * 10, Y = 300 - p.Y * 10, Z = p.Z } end
function world:Raycast() return nil end
function world:GetDescendants()
    local result = {}
    for _, n in ipairs(nodes) do if n:IsDescendantOf(self) then table.insert(result, n) end end
    return result
end
local gui = node("CoreGui", "CoreGui")
Instance = { new = function(class) return node(class, class) end }
local drawings = {}
Drawing = { new = function(class)
    local d = { class = class, Visible = false, removed = false }
    function d:Remove() self.removed = true; self.Visible = false end
    table.insert(drawings, d)
    return d
end }
local players = { PlayerAdded = signal(), PlayerRemoving = signal(), list = {} }
function players:GetPlayers() return self.list end
function players:GetPlayerFromCharacter(character) for _, p in ipairs(self.list) do if p.Character == character then return p end end end
local function player(name)
    local p = node("Player", name)
    p.CharacterAdded, p.CharacterRemoving = signal(), signal()
    table.insert(players.list, p)
    return p
end
players.LocalPlayer = player("Local")
local run = { RenderStepped = signal() }
local rep = node("ReplicatedStorage", "ReplicatedStorage")
function rep:WaitForChild() return nil end
local services = { Players = players, RunService = run, CoreGui = gui, ReplicatedStorage = rep, StarterGui = { SetCore = function() end } }
game = { GetService = function(_, name) return services[name] end, HttpGet = function() return "library" end }
local env = {}
getgenv = function() return env end
task = { spawn = function(fn) fn() end, wait = function() end }
local library = { Flags = {}, unloaded = false }
local group = {}
function group:AddToggle(o) library.Flags[o.Flag] = o.Default or false end
function group:AddSlider(o) library.Flags[o.Flag] = o.Default end
function group:AddDropdown(o) library.Flags[o.Flag] = o.Default end
function group:AddLabel() return { SetText = function(self, text) self.text = text end } end
function group:AddButton(o)
    if o.Name == "Unload Script & Clear ESP" or o.Name == "Unload Script & Clear Memory" then library.unloadButton = o.Callback end
end
function group:AddESPPreview() end
local tab = { AddGroup = function() return group end }
local window = { AddTab = function() return tab end, AddSettingsTab = function() end }
function library:CreateWindow() return window end
function library:Unload() self.unloaded = true end
loadstring = function() return function() return library end end
local function character(name, parent)
    local m = node("Model", name, parent)
    local root = node("BasePart", "HumanoidRootPart", m)
    root.Position = v3.new(0, 0, 10)
    m.PrimaryPart = root
    local humanoid = node("Humanoid", "Humanoid", m)
    humanoid.Health, humanoid.MaxHealth = 100, 100
    return m, humanoid
end
local function visible()
    local n = 0
    for _, d in ipairs(drawings) do if d.Visible and not d.removed then n = n + 1 end end
    return n
end
local function tick() run.RenderStepped:Fire(1/30) end

dofile("scripts/esp.lua")
assert(type(env.ARC3USX_ESP_UNLOAD) == "function", "unload registered")
library.Flags.plr_enabled = true
local target = player("Target")
players.PlayerAdded:Fire(target)
local model, humanoid = character("TargetCharacter", world)
target.Character = model
target.CharacterAdded:Fire(model)
tick()
assert(visible() > 0, "new player produces drawings")
humanoid.Health = 0
tick()
assert(visible() == 0, "death hides drawings")
humanoid.Health = 100
tick()
assert(visible() > 0, "revival restores drawings")
library.Flags.plr_enabled = false
tick()
assert(visible() == 0, "disable hides drawings")
library.Flags.plr_enabled = true
tick()
target.CharacterRemoving:Fire(model)
assert(visible() == 0, "character removal destroys drawings")
local replacement = character("TargetCharacter2", world)
target.Character = replacement
target.CharacterAdded:Fire(replacement)
tick()
assert(visible() > 0, "respawn recreates drawings")
players.PlayerRemoving:Fire(target)
assert(visible() == 0, "player removal cleans up")
library.Flags.ore_enabled = true
local ore = node("BasePart", "MetalNode", world)
ore.Position = v3.new(0, 0, 10)
world.DescendantAdded:Fire(ore)
tick()
assert(visible() > 0, "new basepart resource draws")
world.DescendantRemoving:Fire(ore)
ore.Parent = nil
assert(visible() == 0, "resource removal cleans up")
library.Flags.ore_enabled = false
local folder = node("Folder", "Npcs", world)
local npc, npcHumanoid = character("Guard", folder)
world.DescendantAdded:Fire(npc)
library.Flags.npc_enabled = true
tick()
assert(visible() > 0, "NPC under Npcs folder draws")
npcHumanoid.Health = 0
tick()
assert(visible() == 0, "NPC death hides drawings")
npcHumanoid.Health = 100
npc.Parent = world
tick()
assert(visible() == 0, "moving NPC out of its folder hides drawings")
world.DescendantRemoving:Fire(npc)
npc.Parent = nil
library.Flags.npc_enabled = false
local heli = character("PatrolHeli", world)
world.DescendantAdded:Fire(heli)
library.Flags.heli_enabled = true
tick()
assert(visible() > 0, "new helicopter draws")
world.DescendantRemoving:Fire(heli)
heli.Parent = nil
assert(visible() == 0, "helicopter removal cleans up")
library.unloadButton()
assert(env.ARC3USX_ESP_UNLOAD == nil and library.unloaded, "unload clears singleton and UI")
for _, d in ipairs(drawings) do assert(d.removed, "all drawing objects removed") end
library.unloaded = false
local embeddedUnload = assert(loadfile("scripts/esp.lua"))({ Library = library, Window = window, Visuals = tab, Misc = tab })
assert(type(embeddedUnload) == "function", "embedded ESP returns cleanup")
library.Flags.plr_enabled = true
tick()
assert(visible() > 0, "embedded ESP uses shared flags")
embeddedUnload()
assert(visible() == 0 and not library.unloaded, "embedded unload cleans drawings without closing shared UI")

-- Integration smoke test: main loads the separate ESP into the same window.
run.Heartbeat = signal()
task.spawn = function() end -- Background scans are tested separately above.
game.HttpGet = function(_, url) return url end
loadstring = function(source)
    if source:find("scripts/esp.lua", 1, true) then return assert(loadfile("scripts/esp.lua")) end
    return function() return library end
end
assert(loadfile("scripts/main.lua"))()
assert(type(env.ARC3USX_MAIN_UNLOAD) == "function" and type(env.ARC3USX_ESP_UNLOAD) == "function", "main loads ESP")
library.Flags.plr_enabled = true
local newPlayer = player("JoinedAfterMain")
players.PlayerAdded:Fire(newPlayer)
newPlayer.Character = character("NewCharacter", world)
newPlayer.CharacterAdded:Fire(newPlayer.Character)
tick()
assert(visible() > 0, "main and ESP share controls")
library.unloadButton()
assert(library.unloaded and env.ARC3USX_MAIN_UNLOAD == nil and env.ARC3USX_ESP_UNLOAD == nil and visible() == 0, "main unload also unloads ESP")
library.unloaded = false
loadstring = function(source)
    if source:find("scripts/esp.lua", 1, true) then return function() error("test ESP load failure") end end
    return function() return library end
end
assert(loadfile("scripts/main.lua"))()
assert(type(env.ARC3USX_MAIN_UNLOAD) == "function" and env.ARC3USX_ESP_UNLOAD == nil, "main remains usable after ESP load failure")
library.unloadButton()
assert(library.unloaded, "main unload works without ESP")
print("ESP mock lifecycle and main integration tests passed")
