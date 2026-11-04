-- Mocked test for scripts/main.lua (the optimized hub).
-- Run from the repository root with Lua 5.3:  lua tests/hub_mock.lua
-- A fengari runner can inject the script through the global HUB_SOURCE instead
-- of reading the file:  HUB_SOURCE = "...", then dofile("tests/hub_mock.lua").
-- These are lifecycle checks, not a substitute for testing inside Roblox.

local function check(condition, message)
    if not condition then error(message, 2) end
end

-- ─── Lua 5.3 stand-ins for Luau-only helpers ─────────────────────
math.clamp = math.clamp or function(n, lo, hi) return math.max(lo, math.min(hi, n)) end
math.atan2 = math.atan2 or function(y, x) return math.atan(y, x) end
table.find = table.find or function(t, value)
    for i, item in ipairs(t) do if item == value then return i end end
    return nil
end
table.clear = table.clear or function(t)
    for key in pairs(t) do t[key] = nil end
end

-- ─── Math types ─────────────────────────────────────────────────
local V3 = {}
local v3mt = {}
function v3mt.__add(a, b) return V3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
function v3mt.__sub(a, b) return V3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
function v3mt.__mul(a, b)
    if type(b) == "number" then return V3.new(a.X * b, a.Y * b, a.Z * b) end
    return V3.new(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
function v3mt.__index(a, key)
    if key == "Magnitude" then return math.sqrt(a.X * a.X + a.Y * a.Y + a.Z * a.Z) end
    if key == "Unit" then
        local m = a.Magnitude
        if m == 0 then return V3.new(0, 0, 0) end
        return V3.new(a.X / m, a.Y / m, a.Z / m)
    end
end
function V3.new(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, v3mt) end
V3.zero = V3.new(0, 0, 0)
Vector3 = V3

local V2 = {}
local v2mt = {}
function v2mt.__add(a, b) return V2.new(a.X + b.X, a.Y + b.Y) end
function v2mt.__sub(a, b) return V2.new(a.X - b.X, a.Y - b.Y) end
function v2mt.__div(a, b) return V2.new(a.X / b, a.Y / b) end
function v2mt.__index(a, key)
    if key == "Magnitude" then return math.sqrt(a.X * a.X + a.Y * a.Y) end
end
function V2.new(x, y) return setmetatable({ X = x or 0, Y = y or 0 }, v2mt) end
Vector2 = V2

UDim2 = { fromOffset = function(x, y) return { X = { Offset = x }, Y = { Offset = y } } end }

local function newColor(r, g, b)
    local c = { R = r, G = g, B = b, __typeof = "Color3" }
    function c:Lerp(other, t)
        return newColor(self.R + (other.R - self.R) * t, self.G + (other.G - self.G) * t, self.B + (other.B - self.B) * t)
    end
    return c
end
Color3 = {
    new = newColor,
    fromRGB = function(r, g, b) return newColor(r / 255, g / 255, b / 255) end,
}

local cfmt = {}
function cfmt.__index(self, key)
    if key == "Lerp" then
        return function(a, b, alpha)
            return CFrame.lookAt(a.Position, a.Position + b.LookVector * alpha + a.LookVector * (1 - alpha))
        end
    end
end
local lookAtCalls = {}
CFrame = {
    lookAt = function(pos, target)
        lookAtCalls[#lookAtCalls + 1] = { pos = pos, target = target }
        return setmetatable({ Position = pos, LookVector = (target - pos).Unit }, cfmt)
    end,
}

typeof = function(value)
    if type(value) == "table" then return value.__typeof or "Instance" end
    return type(value)
end

-- ─── Enums, signals, instances ──────────────────────────────────
local function enumSet()
    return setmetatable({}, { __index = function(t, key)
        local v = { Name = key, Value = 0 }; rawset(t, key, v); return v
    end })
end
Enum = setmetatable({}, { __index = function(t, key)
    local e = enumSet(); rawset(t, key, e); return e
end })

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
    function s:ActiveCount()
        local n = 0
        for _, item in ipairs(self.listeners) do if item.connection.connected then n = n + 1 end end
        return n
    end
    return s
end

local nodes = {}
-- Roblox throws when an unknown member is assigned to an Instance. Mirror that
-- here: caching helpers must keep their scratch state off the Instance.
local validProps = {
    Parent=true, Name=true, ClassName=true, Visible=true, Position=true, Size=true,
    Rotation=true, BackgroundColor3=true, BackgroundTransparency=true,
    BorderColor3=true, BorderSizePixel=true, Text=true, TextColor3=true,
    TextSize=true, Font=true, TextStrokeColor3=true, TextStrokeTransparency=true,
    AnchorPoint=true, ZIndex=true, ResetOnSpawn=true, IgnoreGuiInset=true,
    DisplayOrder=true, ZIndexBehavior=true, Adornee=true, FillColor=true,
    FillTransparency=true, OutlineColor=true, OutlineTransparency=true,
    DepthMode=true, Enabled=true, CurrentCamera=true, Ambient=true,
    LightColor=true, LightDirection=true, FieldOfView=true, CFrame=true,
    ViewportSize=true, AssemblyLinearVelocity=true, PrimaryPart=true,
    Health=true, MaxHealth=true, Team=true, Character=true, UserId=true,
    Destroyed=true, children=true, attributes=true, activations=true,
    obstruction=true, DescendantAdded=true, DescendantRemoving=true,
    connected=true,
    -- world visuals
    Brightness=true, OutdoorAmbient=true, GlobalShadows=true, ClockTime=true,
    WorldPosition=true, AbsolutePosition=true, AbsoluteSize=true, PlayerGui=true,
}
local function node(class, name, parent)
    -- Roblox lets `model.Humanoid` resolve to a child; mirror that here.
    local n = setmetatable({
        ClassName = class, Name = name or class, Parent = parent, children = {},
        attributes = {}, Destroyed = false, Visible = false,
    }, {
        __index = function(self, key)
            return self:FindFirstChild(key)
        end,
        __newindex = function(self, key, value)
            if type(value) ~= "function" and not validProps[key] then
                error(string.format("%s is not a valid member of %s", tostring(key), tostring(class)), 2)
            end
            rawset(self, key, value)
        end,
    })
    if parent then table.insert(parent.children, n) end
    table.insert(nodes, n)
    if class == "BasePart" then
        n.Position = V3.new(0, 0, 0)
        n.AssemblyLinearVelocity = V3.zero
    end
    function n:IsA(typeName)
        return self.ClassName == typeName or (typeName == "BasePart" and self.ClassName == "Part")
    end
    function n:IsDescendantOf(ancestor)
        local p = self.Parent
        while p do if p == ancestor then return true end; p = p.Parent end
        return false
    end
    function n:GetChildren()
        local out = {}
        for _, child in ipairs(self.children) do if child.Parent == self then out[#out + 1] = child end end
        return out
    end
    function n:GetDescendants()
        local out = {}
        for _, child in ipairs(self:GetChildren()) do
            out[#out + 1] = child
            for _, d in ipairs(child:GetDescendants()) do out[#out + 1] = d end
        end
        return out
    end
    function n:FindFirstChild(childName, recursive)
        for _, child in ipairs(self:GetChildren()) do
            if child.Name == childName then return child end
            if recursive then
                local found = child:FindFirstChild(childName, true)
                if found then return found end
            end
        end
        return nil
    end
    function n:FindFirstChildOfClass(className) return self:FindFirstChildWhichIsA(className, false) end
    function n:FindFirstChildWhichIsA(className, recursive)
        for _, child in ipairs(self:GetChildren()) do
            if child:IsA(className) then return child end
            if recursive then
                local found = child:FindFirstChildWhichIsA(className, true)
                if found then return found end
            end
        end
        return nil
    end
    function n:GetAttribute(key) return self.attributes[key] end
    function n:SetAttribute(key, value) self.attributes[key] = value end
    function n:GetBoundingBox()
        return { Position = V3.new(0, 0, 10) }, V3.new(4, 6, 2)
    end
    function n:GetPivot() return { Position = (self.PrimaryPart and self.PrimaryPart.Position) or V3.zero } end
    function n:Clone() return node(self.ClassName, self.Name .. "Clone") end
    function n:Destroy() self.Destroyed = true; self.Parent = nil end
    function n:WaitForChild(childName) return self:FindFirstChild(childName) end
    function n:Activate() self.activations = (self.activations or 0) + 1 end
    return n
end
Instance = { new = function(class) return node(class, class) end }
RaycastParams = { new = function() return {} end }

local drawings = {}
Drawing = { new = function(class)
    local d = { class = class, Visible = false, removed = false }
    function d:Remove() self.removed = true; self.Visible = false end
    drawings[#drawings + 1] = d
    return d
end }

-- ─── Services ───────────────────────────────────────────────────
local workspace = node("Workspace", "Workspace")
workspace.DescendantAdded, workspace.DescendantRemoving = signal(), signal()
function workspace:Raycast() return self.obstruction end
local camera = node("Camera", "Camera", workspace)
camera.CFrame = CFrame.lookAt(V3.new(0, 0, 0), V3.new(0, 0, -10))
camera.ViewportSize = V2.new(800, 600)
function camera:ViewportPointToRay(x, y)
    return { Origin = V3.new(0, 0, 0), Direction = V3.new((x - 400) / 800, (300 - y) / 600, -1) }
end
function camera:WorldToViewportPoint(p)
    return { X = 400 + p.X * 10, Y = 300 - p.Y * 10, Z = p.Z }, true
end
workspace.CurrentCamera = camera

local players = { PlayerAdded = signal(), PlayerRemoving = signal(), list = {} }
function players:GetPlayers() return self.list end
function players:GetPlayerFromCharacter(character)
    for _, p in ipairs(self.list) do if p.Character == character then return p end end
    return nil
end
local function newPlayer(name)
    local p = node("Player", name)
    table.insert(players.list, p)
    return p
end
players.LocalPlayer = newPlayer("Local")
players.LocalPlayer.Team = "blue"
local playerGui = node("PlayerGui", "PlayerGui", players.LocalPlayer)

local coreGui = node("CoreGui", "CoreGui")
local lighting = node("Lighting", "Lighting")
lighting.Brightness = 1
lighting.Ambient = newColor(0.2, 0.2, 0.2)
lighting.OutdoorAmbient = newColor(0.3, 0.3, 0.3)
lighting.GlobalShadows = true
lighting.ClockTime = 14
local rep = node("ReplicatedStorage", "ReplicatedStorage")
local fust = node("Folder", "Fust", rep)
local iconsScript = node("ModuleScript", "ItemIcons", fust)
local staffState = node("ModuleScript", "StaffState", fust)
local adminPerms = node("ModuleScript", "AdminPerms", fust)
local iconModel = node("Model", "OreIconModel")
local modules = {}
modules[iconsScript] = {
    FOV = 30,
    Get = function(item)
        if item == "metal_ore" then
            return { model = iconModel, camCF = CFrame.lookAt(V3.new(0, 0, 0), V3.new(0, 0, -1)) }
        end
        return nil
    end,
    Abbr = function(item) return string.upper(string.sub(item, 1, 3)) end,
    Color = function() return newColor(1, 1, 1) end,
}
modules[staffState] = {
    get = function(plr, key) return plr:GetAttribute(key) end,
    changed = function() return signal() end,
}
modules[adminPerms] = {
    Label = { mod = "Moderator", admin = "Admin" },
    Rank = function(role) return role == "admin" and 4 or 2 end,
}
require = function(mod) return modules[mod] end

local renderSteps = {}
local run = { RenderStepped = signal() }
function run:BindToRenderStep(name, _, fn) renderSteps[name] = fn end
function run:UnbindFromRenderStep(name) renderSteps[name] = nil end
local uis = { InputBegan = signal(), InputEnded = signal() }
local mouseLocation = V2.new(400, 300)
function uis:GetMouseLocation() return mouseLocation end
local services = {
    Players = players, RunService = run, CoreGui = coreGui,
    ReplicatedStorage = rep, UserInputService = uis, Workspace = workspace,
    Lighting = lighting,
    StarterGui = { SetCore = function() end },
}
local requestedLibraryUrl = nil
game = { GetService = function(_, name) return services[name] end,
    HttpGet = function(_, url) requestedLibraryUrl = url; return url end }

local clock = 0
tick = function() clock = clock + 1 / 60; return clock end
os.clock = function() return clock end
warn = function(message) print("[warn] " .. tostring(message)) end
local clicks = 0
mouse1click = function() clicks = clicks + 1 end
local mouseMoves = {}
mousemoverel = function(x, y) mouseMoves[#mouseMoves + 1] = { x, y } end
task = {
    spawn = function(fn, ...) pcall(fn, ...) end,
    wait = function() error("__mock_yield__") end,
    delay = function() end,
    defer = function(fn, ...) pcall(fn, ...) end,
}

-- ─── Mock UI library ────────────────────────────────────────────
local library = {
    Flags = {}, Options = {}, Notifications = {}, controls = {}, buttons = {}, labels = {},
    groups = {}, tabs = {}, previews = {}, settingsTab = false, unloaded = false,
}
function library:Notify(text) self.Notifications[#self.Notifications + 1] = text end
function library:Unload() self.unloaded = true end
local function addControl(group, o)
    group.controls[#group.controls + 1] = o
    local key = o.Flag or o.Name
    library.controls[key] = o
    if o.Flag then library.Flags[o.Flag] = o.Default end
    local obj = { Type = o.Type or "Control", Key = o.Default }
    function obj:Set(v)
        library.Flags[key] = v
        if o.Callback then o.Callback(v) end
    end
    library.Options[key] = obj
    return o
end
local function newGroup(name, side, tab)
    local g = { name = name, side = side, tab = tab, controls = {} }
    function g:AddToggle(o) return addControl(self, o) end
    function g:AddSlider(o) return addControl(self, o) end
    function g:AddDropdown(o) return addControl(self, o) end
    function g:AddButton(o) library.buttons[o.Name] = o.Callback; return addControl(self, o) end
    function g:AddKeybind(o)
        local c = addControl(self, o)
        if o.Flag then library.Flags[o.Flag] = o.Default and o.Default.Name or "" end
        return c
    end
    function g:AddLabel(text)
        local label = { text = text }
        function label:SetText(t) self.text = t end
        library.labels[#library.labels + 1] = label
        return label
    end
    function g:AddESPPreview(o) library.previews[#library.previews + 1] = o; return {} end
    library.groups[#library.groups + 1] = g
    return g
end
local function newTab(name)
    local t = { name = name }
    function t:AddGroup(groupName, side) return newGroup(groupName, side, name) end
    library.tabs[#library.tabs + 1] = t
    return t
end
local window = {}
function window:AddTab(name) return newTab(name) end
function window:AddSettingsTab() library.settingsTab = true end
function library:CreateWindow(opts) self.windowOpts = opts; return window end
loadstring = function(source)
    check(type(source) == "string" and source:find("ARC3USX.lua", 1, true), "hub requests the UI library")
    return function() return library end
end

-- ─── Helpers ────────────────────────────────────────────────────
local hubSource = HUB_SOURCE
if not hubSource then
    local f = assert(io.open("scripts/main.lua", "r"))
    hubSource = f:read("*a")
    f:close()
end
local libSource = LIB_SOURCE
if not libSource then
    local f = assert(io.open("ARC3USX.lua", "r"))
    libSource = f:read("*a")
    f:close()
end
local function labelVisible(text)
    for _, n in ipairs(nodes) do
        if n.ClassName == "TextLabel" and n.Visible and not n.Destroyed and n.Text == text then return true end
    end
    return false
end
local function findNode(predicate)
    for _, n in ipairs(nodes) do if predicate(n) then return n end end
    return nil
end
local function step()
    clock = clock + 1 / 60
    run.RenderStepped:Fire(1 / 60)
end
local function character(name, parent)
    local m = node("Model", name, parent)
    local root = node("BasePart", "HumanoidRootPart", m)
    root.Position = V3.new(0, 0, 10)
    m.PrimaryPart = root
    local hum = node("Humanoid", "Humanoid", m)
    hum.Health, hum.MaxHealth = 100, 100
    local head = node("BasePart", "Head", m); head.Position = V3.new(0, 2, 10)
    local torso = node("BasePart", "Torso", m); torso.Position = V3.new(0, 1, 10)
    local upper = node("BasePart", "UpperTorso", m); upper.Position = V3.new(0, 1, 10)
    return m, hum, root
end

-- ─── Load the hub ───────────────────────────────────────────────
assert(load(hubSource, "scripts/main.lua"))()

-- No legacy feature code or controls may survive the swap.
for _, removed in ipairs({ "GunMods", "BowMods", "getgc", "gunmods_enabled", "bowmods_enabled",
    "universal_ammo", "ESP_URL", "ui_bootstrap", "ARC3USX_NH", "weakspotMarkers",
    "FustAimBow", "BowAutoLock", "solveBallistic", "ARC3USX_Aimbot", "Aimbot.Config",
    "Cycle Target Part", "Toggle: Z", "considerTarget", "predictPosition",
    "screenDelta", "getBonePart", "moveMouse", "aimStep" }) do
    check(not hubSource:find(removed, 1, true), "legacy feature still present: " .. removed)
end
for _, flag in ipairs({ "gunmods_enabled", "bowmods_enabled", "universal_ammo", "universal_noair" }) do
    check(library.Flags[flag] == nil, "legacy flag still registered: " .. flag)
end
-- Roblox rejects arbitrary fields on Instances; scratch state must live in the
-- weak-keyed side table, never on a Frame/TextLabel (this broke every ESP except chams).
for _, bad in ipairs({ ".lastX", ".lastY", ".lastW", ".lastH", ".lastLen", ".lastAngle" }) do
    check(not hubSource:find(bad, 1, true), "ESP writes an invalid Instance property: " .. bad)
end
check(hubSource:find("okEsp, espErr = pcall", 1, true), "ESP pass is not isolated")
check(hubSource:find("Aimbot step error", 1, true), "aimbot step is not isolated")
check(hubSource:find("MouseButton2", 1, true), "RMB keybind support missing")
check(hubSource:find("Keybind List", 1, true), "keybind list control missing")
check(not hubSource:find("aim_rmb", 1, true), "separate RMB toggle still present")
check(library.Flags.aim_rmb == nil, "no separate RMB flag registered")
-- The loading screen is embedded in the library the hub actually downloads.
check(requestedLibraryUrl and requestedLibraryUrl:find("arena/6af703ac-arceus-x/ARC3USX.lua", 1, true),
    "hub does not load this branch's library")
check(not requestedLibraryUrl:find("refs/heads/main/", 1, true), "hub still loads main's library")
check(hubSource:find("Intro = true", 1, true), "hub does not enable the intro")
check(libSource:find("function Library:_RunIntro", 1, true), "loading screen missing from the library")
check(libSource:find("if opts.Intro ~= false then", 1, true), "library does not start the intro from CreateWindow")
check(libSource:find("ACCESS GRANTED", 1, true), "intro reveal missing from the library")
check(hubSource:find("FustWeakSpotMark", 1, true), "real weakspot mark path missing")
for _, removed in ipairs({ "FustArcticTerrain", "Decoration", "world_grass", "world_leaves",
    "world_fog", "world_brightness", "world_fog_end", "world_leaf_transparency",
    "applyGrass", "applyLeaves", "applyFog", "reapplyTerrain", "restoreWorldVisuals",
    "Report Game Paths", "World Visuals" }) do
    check(not hubSource:find(removed, 1, true), "removed world visual still present: " .. removed)
end

check(library.windowOpts.Intro == true and library.windowOpts.Theme == "Purple", "hub window options / intro enabled")
check(library.windowOpts.Size.X == 800 and library.windowOpts.Size.Y == 620, "hub window size")
check(#library.tabs == 3 and library.settingsTab, "three tabs plus settings")
check(library.tabs[1].name == "ESP / World" and library.tabs[2].name == "Combat" and library.tabs[3].name == "Misc", "tab names")
local expectedGroups = {
    "Player ESP", "NPC ESP", "Ore ESP (Icons)", "Heli ESP", "ESP Preview",
    "Aimbot", "Aimbot Options",
    "Staff Detection", "Staff ESP", "Mining (Silent Insta-Hit)", "System",
}
for _, g in ipairs(library.groups) do
    check(g.name ~= "World Visuals", "World Visuals group still registered")
end
for _, name in ipairs(expectedGroups) do
    local found = false
    for _, g in ipairs(library.groups) do if g.name == name then found = true end end
    check(found, "missing group: " .. name)
end
for _, flag in ipairs({ "plr_master", "plr_enabled", "plr_chams", "plr_skel", "player_esp_hz",
    "npc_enabled", "ore_enabled", "ore_MetalNode", "heli_enabled", "weakspot_enabled",
    "world_fullbright",
    "staff_monitor", "staff_esp", "aim_enabled", "aim_key", "aim_lock_mode", "aim_key_list",
    "weakspot_auto_click", "weakspot_source", "weakspot_radius", "aim_bone",
    "aim_fov", "aim_distance", "aim_smoothing", "aim_bullet_speed", "Aim_FOV_Circle",
    "aim_prediction", "aim_target_npcs", "aim_wall_check", "aim_team_check" }) do
    check(library.Flags[flag] ~= nil, "missing flag: " .. flag)
end
check(#library.previews == 1 and library.previews[1].Elements.Box == "plr_box", "ESP preview wired to hub flags")
local fullbrightGroup = nil
for _, g in ipairs(library.groups) do
    for _, c in ipairs(g.controls) do
        if c.Flag == "world_fullbright" then fullbrightGroup = g end
    end
end
check(fullbrightGroup ~= nil and fullbrightGroup.tab == "Misc" and fullbrightGroup.name == "System",
    "Looped Fullbright is the only visual and lives in Misc / System")
for _, f in ipairs({ "world_grass", "world_leaves", "world_fog", "world_brightness",
    "world_fog_end", "world_leaf_transparency" }) do
    check(library.Flags[f] == nil, "removed world visual flag still registered: " .. f)
end
check(type(renderSteps.ARC3USX_InstaHit) == "function", "insta-hit render step bound")
check(renderSteps.ARC3USX_Aimbot == nil, "old bound aimbot render step removed")
check(#drawings == 1, "a single aimbot FOV circle created")
check(type(library.Options.aim_key.Key) == "table", "aimbot keybind registered with a default key")
check(type(library.Flags.aim_lock) == "table", "aim lock state table registered")
local espGui = findNode(function(n) return n.Name == "ARC3USX_ESP_UI" end)
check(espGui and espGui.Parent == coreGui, "ESP ScreenGui parented to CoreGui")

-- Color callbacks are wired without errors.
library.controls.plr_box.ColorCallback(1, newColor(0.5, 0.5, 0.5))
library.controls.plr_chams.ColorCallback(2, newColor(1, 0, 0))
library.controls.plr_health.ColorCallback(1, newColor(0, 1, 0))

-- ─── Staff detection ────────────────────────────────────────────
local staff = newPlayer("ModeratorGuy")
staff:SetAttribute("AdminRole", "mod")
staff.Character = character("ModChar", workspace)
library.buttons["Scan Now"]()
local staffLabel = nil
for _, label in ipairs(library.labels) do
    if label.text and label.text:find("Moderator", 1, true) then staffLabel = label end
end
check(staffLabel ~= nil, "staff scan lists the moderator with its label")
library.controls.staff_monitor.Callback(true)
check(#library.Notifications > 0 and library.Notifications[1]:find("online", 1, true), "staff monitor notifies")
library.controls.staff_esp.Callback(true)
local staffHighlight = findNode(function(n) return n.Name == "FustStaffDetect_ModeratorGuy" and not n.Destroyed end)
check(staffHighlight and staffHighlight.Adornee == staff.Character, "staff highlight created for staff character")
library.buttons["Clear Highlights"]()
check(staffHighlight.Destroyed, "clear highlights removes them")
library.controls.staff_esp.Callback(false)

-- ─── Player ESP ─────────────────────────────────────────────────
local target = newPlayer("Target")
target.Team = "red"
target.Character = character("TargetChar", workspace)
library.Flags.plr_enabled = true
step()
check(labelVisible("Target"), "player name label drawn")
check(labelVisible("2m"), "player distance label drawn")
check(labelVisible("Unarmed"), "player weapon label drawn")
local playerHighlight = findNode(function(n) return n.Name == "ARC3USX_ESP" and n.Adornee == target.Character end)
check(playerHighlight and playerHighlight.Enabled, "player chams highlight drawn")
library.Flags.plr_enabled = false
step()
check(not labelVisible("Target") and playerHighlight.Enabled == false, "disabling player ESP hides overlays")
library.Flags.plr_enabled = true
library.Flags.plr_style = "Full"
step()
check(labelVisible("Target"), "full box style still draws player ESP")
library.Flags.plr_style = "Corners"

-- ESP must never stay stuck on screen for dead or removed targets.
local targetHum = target.Character:FindFirstChild("Humanoid")
targetHum.Health = 0
step()
check(not labelVisible("Target") and playerHighlight.Enabled == false, "dead player's ESP hidden on the next frame")
targetHum.Health = 100
step()
check(labelVisible("Target"), "ESP returns when the target is alive again")
library.Flags.plr_master = false
step()
check(not labelVisible("Target"), "master switch hides all player overlays")
step()
check(not labelVisible("Target"), "a hidden overlay stays hidden (idempotent hide)")
library.Flags.plr_master = true

-- ─── NPC ESP ────────────────────────────────────────────────────
local npcFolder = node("Folder", "Npcs", workspace)
local guard = character("Guard", npcFolder)
library.Flags.npc_enabled = true
step()
check(labelVisible("Guard"), "NPC name label drawn")
library.Flags.npc_enabled = false

-- ─── Ore ESP (3D icon + labeled fallback) ───────────────────────
local ore = node("BasePart", "MetalNode", workspace)
ore.Position = V3.new(0, 0, 10)
workspace.DescendantAdded:Fire(ore)
local stone = node("BasePart", "StoneNode", workspace)
stone.Position = V3.new(2, 0, 10)
workspace.DescendantAdded:Fire(stone)
library.Flags.ore_enabled = true
step()
local viewport = findNode(function(n) return n.Name == "ARC3USX_OreIcon" and n.Visible and not n.Destroyed end)
check(viewport and viewport.CurrentCamera, "ItemIcons model shown in a ViewportFrame")
check(labelVisible("STO"), "unknown item falls back to an abbreviation")
library.Flags.ore_MetalNode = false
step()
check(viewport.Visible == false, "per-ore toggle hides its icon")
library.Flags.ore_MetalNode = true
library.Flags.ore_dist = false
step()
check(viewport.Visible, "per-ore toggle restores its icon")
library.Flags.ore_enabled = false
step()
check(viewport.Visible == false and not labelVisible("STO"), "disabling ore ESP hides icons")
workspace.DescendantRemoving:Fire(ore); ore.Parent = nil
workspace.DescendantRemoving:Fire(stone); stone.Parent = nil

-- ─── Heli ESP ───────────────────────────────────────────────────
local heli = character("PatrolHeli", workspace)
workspace.DescendantAdded:Fire(heli)
library.Flags.heli_enabled = true
step()
check(labelVisible("2m"), "heli distance label drawn")
library.Flags.heli_enabled = false
workspace.DescendantRemoving:Fire(heli); heli.Parent = nil

-- ─── Silent insta-hit weakspot ──────────────────────────────────
local localChar = character("LocalChar", workspace)
players.LocalPlayer.Character = localChar
local tool = node("Tool", "Stone Pickaxe", localChar)
local tree = node("Model", "Tree", workspace)
local weakspot = node("BasePart", "Weakspot", tree)
weakspot.Position = V3.new(0, 0, 5)
tree.PrimaryPart = weakspot
workspace.DescendantAdded:Fire(tree)
local savedCFrame = camera.CFrame
library.Flags.weakspot_enabled = true
clock = clock + 1
renderSteps.ARC3USX_InstaHit(1 / 60)
check((tool.activations or 0) == 1, "insta-hit activates the mining tool")
check(clicks == 0, "no synthetic auto click by default")
check(camera.CFrame == savedCFrame, "insta-hit restores the camera without a visible lock")
-- Opting in past the 0.12s cooldown is the only way to get a synthetic click.
library.Flags.weakspot_auto_click = true
for _ = 1, 10 do step() end
renderSteps.ARC3USX_InstaHit(1 / 60)
check(clicks == 1, "auto click only when explicitly enabled")
library.Flags.weakspot_auto_click = false
library.Flags.weakspot_enabled = false

-- ─── FustWeakSpotMark: the real LocalPlayer.PlayerGui path ────────
local markAnchor = node("BasePart", "MarkAnchor", workspace)
markAnchor.Position = V3.new(3, 4, 5)
local weakMark = node("BillboardGui", "FustWeakSpotMark", playerGui)
weakMark.Visible = true
weakMark.Adornee = markAnchor

local function hitOnce()
    clock = clock + 1
    lookAtCalls = {}
    local before = tool.activations or 0
    renderSteps.ARC3USX_InstaHit(1 / 60)
    return (tool.activations or 0) - before, lookAtCalls[#lookAtCalls]
end

library.Flags.weakspot_enabled = true
local delta, aim = hitOnce()
check(delta == 1, "insta-hit activates from the real FustWeakSpotMark")
check(aim ~= nil and aim.target == markAnchor.Position, "aim comes from the mark Adornee, not the node")
check(camera.CFrame == savedCFrame, "mark aim restores the camera")

-- "Node Parts" must ignore the marker and use the node's weakspot part.
library.controls.weakspot_source.Callback("Node Parts")
delta, aim = hitOnce()
check(aim ~= nil and aim.target == weakspot.Position, "Node Parts source uses the node weakspot")

-- "Mark Only" must refuse to fire when the marker is hidden.
library.controls.weakspot_source.Callback("Mark Only")
weakMark.Visible = false
delta = hitOnce()
check(delta == 0, "hidden FustWeakSpotMark blocks Mark Only hits")
weakMark.Visible = true

-- Screen-space marker: AbsolutePosition -> camera direction.
weakMark.Adornee = nil
weakMark.AbsolutePosition = V2.new(100, 100)
weakMark.AbsoluteSize = V2.new(20, 20)
delta, aim = hitOnce()
check(delta == 1, "screen-space FustWeakSpotMark still fires")
check(aim ~= nil and aim.target.Z ~= 0, "screen mark aims along a camera ray")
library.controls.weakspot_source.Callback("Auto")
library.controls.weakspot_radius.Callback(75)
library.Flags.weakspot_auto_click = false
library.Flags.weakspot_enabled = false

-- ─── Aimbot (mouse-relative lock) ───────────────────────────────
library.controls.aim_enabled.Callback(true)
library.Flags.Aim_FOV_Circle = true
step()
check(drawings[1].Visible and drawings[1].Radius == 220, "FOV circle shown with configured radius")
check(#mouseMoves > 0 and mouseMoves[#mouseMoves][2] == -10, "aimbot nudges the mouse toward the head target")
library.controls.aim_bone.Callback("Hrp")
step()
check(mouseMoves[#mouseMoves][2] == 0, "Hrp bone aims at the root instead of the head")
library.controls.aim_bone.Callback("Head")

-- Isolate one target so bullet-travel prediction is measurable.
staff.Character:FindFirstChild("Humanoid").Health = 0
local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
targetRoot.AssemblyLinearVelocity = V3.new(90, 0, 0)
step()
check(mouseMoves[#mouseMoves][1] == 5, "prediction leads the target using bullet travel time")
library.controls.aim_prediction.Callback(false)
step()
check(mouseMoves[#mouseMoves][1] == 0, "prediction can be disabled")
library.controls.aim_prediction.Callback(true)
targetRoot.AssemblyLinearVelocity = V3.zero
staff.Character:FindFirstChild("Humanoid").Health = 100

-- FOV and distance limits.
library.controls.aim_fov.Callback(5)
local movesBefore = #mouseMoves
step()
check(#mouseMoves == movesBefore, "targets outside the FOV are ignored")
library.controls.aim_fov.Callback(220)
library.controls.aim_distance.Callback(1)
step()
check(#mouseMoves == movesBefore, "targets beyond max distance are ignored")
library.controls.aim_distance.Callback(0)

-- Team check via the FustMates attribute.
library.controls.aim_team_check.Callback(true)
players.LocalPlayer:SetAttribute("FustMates", " " .. tostring(target.UserId) .. ", 999 ")
step()
check(#mouseMoves == movesBefore, "team check skips listed teammates")
library.controls.aim_team_check.Callback(false)
players.LocalPlayer:SetAttribute("FustMates", nil)

-- Smoothing divides the mouse delta.
library.controls.aim_smoothing.Callback(4)
step()
check(mouseMoves[#mouseMoves][2] == -5, "smoothing divides the mouse delta")
library.controls.aim_smoothing.Callback(2)

-- Wall check rejects blocked targets.
library.controls.aim_wall_check.Callback(true)
workspace.obstruction = { Instance = node("Part", "Wall", workspace) }
movesBefore = #mouseMoves
step()
check(#mouseMoves == movesBefore, "wall check rejects blocked targets")
workspace.obstruction = nil
library.controls.aim_wall_check.Callback(false)
step()

-- NPC targets are opt-in.
library.controls.aim_target_npcs.Callback(false)
target.Character:FindFirstChild("Humanoid").Health = 0
staff.Character:FindFirstChild("Humanoid").Health = 0
movesBefore = #mouseMoves
step()
check(#mouseMoves == movesBefore, "NPCs are ignored when targetNpcs is off")
library.controls.aim_target_npcs.Callback(true)
step()
check(#mouseMoves > movesBefore, "NPC targets can be included")
library.controls.aim_target_npcs.Callback(false)
target.Character:FindFirstChild("Humanoid").Health = 100
staff.Character:FindFirstChild("Humanoid").Health = 100

-- Hold mode gates on the keybind; Always mode uses the keybind as a toggle.
library.controls.aim_lock_mode.Callback("Hold")
movesBefore = #mouseMoves
step()
check(#mouseMoves == movesBefore, "hold mode does not aim without the key")
uis.InputBegan:Fire({ KeyCode = Enum.KeyCode.Q }, false)
step()
check(#mouseMoves > movesBefore, "hold mode aims while the key is held")
uis.InputEnded:Fire({ KeyCode = Enum.KeyCode.Q })
library.controls.aim_lock_mode.Callback("Toggle")
library.controls.aim_enabled.Callback(true)
uis.InputBegan:Fire({ KeyCode = Enum.KeyCode.Q }, false)
check(library.Flags.aim_enabled == false, "keybind toggles the aimbot in toggle mode")
library.controls.aim_enabled.Callback(true)
library.Flags.Aim_FOV_Circle = false
step()
check(not drawings[1].Visible, "FOV circle hidden when its toggle is off")

-- RMB is a normal option in the Keybind List, not a separate toggle.
library.controls.aim_key_list.Callback("RMB (Right Mouse)")
library.Options.aim_enabled:Set(true)
check(library.Flags.aim_enabled == true, "aimbot starts enabled before the RMB test")
uis.InputBegan:Fire({ UserInputType = Enum.UserInputType.MouseButton2 }, false)
check(library.Flags.aim_enabled == false, "RMB from the keybind list toggles the aimbot off")
uis.InputBegan:Fire({ UserInputType = Enum.UserInputType.MouseButton2 }, false)
check(library.Flags.aim_enabled == true, "RMB from the keybind list toggles it back on")

-- Hold mode must work even with Aimbot Enabled OFF (the reported bug).
library.controls.aim_lock_mode.Callback("Hold")
library.Options.aim_enabled:Set(false)
movesBefore = #mouseMoves
step()
check(#mouseMoves == movesBefore, "hold mode does not aim without the key")
uis.InputBegan:Fire({ UserInputType = Enum.UserInputType.MouseButton2 }, false)
step()
check(#mouseMoves > movesBefore, "hold mode aims while held even with Aimbot Enabled off")
movesBefore = #mouseMoves
uis.InputEnded:Fire({ UserInputType = Enum.UserInputType.MouseButton2 })
step()
check(#mouseMoves == movesBefore, "hold mode stops aiming on release")
library.controls.aim_lock_mode.Callback("Toggle")

-- Switching the list back to a keyboard key removes RMB as the aim key.
library.controls.aim_key_list.Callback("Q")
library.Options.aim_enabled:Set(true)
uis.InputBegan:Fire({ UserInputType = Enum.UserInputType.MouseButton2 }, false)
check(library.Flags.aim_enabled == true, "RMB no longer acts as the key after rebinding to Q")
uis.InputBegan:Fire({ KeyCode = Enum.KeyCode.Q }, false)
check(library.Flags.aim_enabled == false, "Q is the active keybind again")
library.Options.aim_enabled:Set(false)

-- ─── Looped Fullbright (Misc / System) ───────────────────────────
library.controls.world_fullbright.Callback(true)
check(lighting.Brightness == 2 and lighting.GlobalShadows == false and lighting.ClockTime == 12,
    "fullbright applies immediately with its built-in brightness")
-- The loop must re-apply each frame if the game resets Lighting.
lighting.Brightness = 1
lighting.GlobalShadows = true
step()
check(lighting.Brightness == 2 and lighting.GlobalShadows == false, "looped fullbright re-applies every frame")
library.controls.world_fullbright.Callback(false)
check(lighting.Brightness == 1 and lighting.GlobalShadows == true and lighting.ClockTime == 14,
    "disabling fullbright restores lighting")

-- ─── ESP ScreenGui rebuild + cleanup ─────────────────────────────
espGui.Parent = nil
step()
local rebuiltGui = findNode(function(n) return n.Name == "ARC3USX_ESP_UI" and n.Parent == coreGui end)
check(rebuiltGui and rebuiltGui ~= espGui, "ESP ScreenGui rebuilt if removed externally")
local targetLabel = findNode(function(n) return n.ClassName == "TextLabel" and n.Text == "Target" end)
target.Character.Parent = nil
step()
check(targetLabel.Destroyed, "overlays destroyed when their character leaves")

-- ─── Unload ──────────────────────────────────────────────────────
-- Leave fullbright enabled so unload has to restore lighting.
library.controls.world_fullbright.Callback(true)
library.buttons["Unload Script & Clear Memory"]()
check(library.unloaded, "unload closes the UI library")
check(lighting.Brightness == 1 and lighting.GlobalShadows == true and lighting.ClockTime == 14,
    "unload restores lighting")
check(findNode(function(n) return n.Name == "ARC3USX_ESP_UI" and n.Parent == coreGui end) == nil,
    "unload destroys the ESP ScreenGui")
check(renderSteps.ARC3USX_InstaHit == nil and renderSteps.ARC3USX_Aimbot == nil, "render steps unbound")
check(run.RenderStepped:ActiveCount() == 0, "render connections disconnected")
for _, d in ipairs(drawings) do check(d.removed, "aimbot drawing removed on unload") end
check(not drawings[1].Visible, "FOV circle hidden on unload")
movesBefore = #mouseMoves
step()
check(#mouseMoves == movesBefore, "no aimbot movement after unload")
check(not labelVisible("Target"), "no ESP updates after unload")
check(staffHighlight.Destroyed, "staff highlights cleaned on unload")

print("Hub mock tests passed")
