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
function world:Raycast() return self.obstruction end
function world:GetDescendants()
    local result = {}
    for _, n in ipairs(nodes) do if n:IsDescendantOf(self) then table.insert(result, n) end end
    return result
end
local gui = node("CoreGui", "CoreGui")
Instance = { new = function(class) return node(class, class) end }
local drawings, failAfter = {}, nil
Drawing = { new = function(class)
    if failAfter then
        failAfter = failAfter - 1
        if failAfter <= 0 then error("simulated drawing failure") end
    end
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
game = { GetService = function(_, name) return services[name] end, HttpGet = function(_, url) return url end }
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
function library:Unload()
    if self.unloading then return end
    self.unloading = true
    local callback = self.OnUnload
    self.OnUnload = nil
    if callback then callback() end
    self.unloaded = true
    self.unloading = false
end
local function mockBootstrap()
    return function(opts)
        opts.OnLibrary(library)
        return { Library = library, Window = window, Mix = { AddTab = function() end } }
    end
end
loadstring = function(source)
    if source:find("ui_bootstrap.lua", 1, true) then return mockBootstrap end
    return function() return library end
end
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
local mockClock = 0
os.clock = function() return mockClock end
local function tick() mockClock=mockClock+1/30;run.RenderStepped:Fire(1/30) end

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
library.Flags.esp_master=false;tick();assert(visible()==0, "global toggle hides overlays")
library.Flags.esp_master=true;tick();assert(visible()>0, "global toggle restores overlays")
target.attributes={AdminRole="mod"};library.Flags.staff_esp=true
for _=1,35 do tick() end
local staffHighlight
for _,o in ipairs(nodes) do if o.Name=="ARC3USX_Staff" and o.Parent then staffHighlight=o end end
assert(staffHighlight and staffHighlight.Enabled, "staff highlight is created")
library.Flags.esp_master=false;tick();assert(not staffHighlight.Enabled, "global toggle also hides staff highlights")
library.Flags.esp_master=true;library.Flags.staff_esp=false
for _=1,35 do tick() end
assert(staffHighlight.Destroyed, "disabled staff highlight is cleaned up")
players.LocalPlayer.Team="blue";target.Team="blue";library.Flags.plr_ignore_team=true;tick()
assert(visible()==0, "team filter hides teammates")
target.Team="red";tick();assert(visible()>0, "team filter leaves enemies visible")
library.Flags.plr_ignore_team=false
local beforeTracer=visible();library.Flags.plr_tracer=true;tick();assert(visible()==beforeTracer+1, "player tracer appears")
library.Flags.plr_tracer=false;tick();assert(visible()==beforeTracer, "player tracer hides")
local oldCamera=world.CurrentCamera
world.obstruction={Instance=node("BasePart","Wall",world)}
world.CurrentCamera={CFrame=oldCamera.CFrame,ViewportSize=oldCamera.ViewportSize,WorldToViewportPoint=oldCamera.WorldToViewportPoint}
library.Flags.plr_visible_only=true;tick();assert(visible()==0, "visible-only filter hides occluded target")
world.obstruction=nil;world.CurrentCamera=oldCamera;tick();assert(visible()>0, "camera replacement refreshes visibility")
library.Flags.plr_visible_only=false
local broken=player("Broken")
players.PlayerAdded:Fire(broken)
broken.Character=character("BrokenCharacter",world)
broken.CharacterAdded:Fire(broken.Character)
local firstDraw=#drawings+1
failAfter=4;tick()
assert(#drawings==firstDraw+2, "failure happens after partially constructing an overlay")
for i=firstDraw,#drawings do assert(drawings[i].removed, "partial drawings are removed on error") end
local afterFailure=#drawings
for _=1,30 do tick() end
assert(#drawings==afterFailure, "failed overlay backs off instead of allocating each frame")
failAfter=nil
for _=1,32 do tick() end
assert(#drawings>afterFailure, "failed overlay retries and recovers")
players.PlayerRemoving:Fire(broken)
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
assert(visible() == 3, "resource marker, name and distance draw")
library.Flags.ore_marker=false;library.Flags.ore_name=false;tick()
assert(visible()==1, "resource name and marker can be disabled independently")
library.Flags.ore_dist=false;tick();assert(visible()==0, "resource distance can be disabled")
library.Flags.ore_marker=true;library.Flags.ore_name=true;library.Flags.ore_dist=true
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
local withHealth=visible();library.Flags.npc_health=false;tick();assert(visible()==withHealth-2, "NPC health bar toggles")
library.Flags.npc_health=true;tick()
local beforeNpcTracer=visible();library.Flags.npc_tracer=true;tick();assert(visible()==beforeNpcTracer+1, "NPC tracer toggles")
library.Flags.npc_tracer=false;tick()
local head=node("BasePart","Head",npc);head.Position=v3.new(0,2,10)
local torso=node("BasePart","Torso",npc);torso.Position=v3.new(0,1,10)
local beforeBones=visible();tick();assert(visible()==beforeBones+1, "NPC skeleton draws for supported rigs")
library.Flags.npc_skel=false;tick();assert(visible()==beforeBones, "NPC skeleton toggles")
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
    if source:find("ui_bootstrap.lua", 1, true) then return mockBootstrap end
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
    if source:find("ui_bootstrap.lua", 1, true) then return mockBootstrap end
    if source:find("scripts/esp.lua", 1, true) then return function() error("test ESP load failure") end end
    return function() return library end
end
assert(loadfile("scripts/main.lua"))()
assert(type(env.ARC3USX_MAIN_UNLOAD) == "function" and env.ARC3USX_ESP_UNLOAD == nil, "main remains usable after ESP load failure")
library.unloadButton()
assert(library.unloaded, "main unload works without ESP")
print("ESP mock lifecycle and main integration tests passed")
