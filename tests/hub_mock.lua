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
    if key == "Lerp" then
        return function(self, other, t)
            return V3.new(self.X + (other.X - self.X) * t, self.Y + (other.Y - self.Y) * t, self.Z + (other.Z - self.Z) * t)
        end
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
    if key == "PointToObjectSpace" then
        return function(a, point) return point - a.Position end
    end
end
function cfmt.__mul(a, b)
    if b.__cf then
        return CFrame.new(V3.new(a.Position.X + b.Position.X, a.Position.Y + b.Position.Y, a.Position.Z + b.Position.Z))
    end
    return V3.new(a.Position.X + b.X, a.Position.Y + b.Y, a.Position.Z + b.Z)
end
CFrame = {
    new = function(pos)
        return setmetatable({ Position = pos or V3.zero, LookVector = V3.new(0, 0, -1), __cf = true }, cfmt)
    end,
    lookAt = function(pos, target)
        return setmetatable({ Position = pos, LookVector = (target - pos).Unit, __cf = true }, cfmt)
    end,
}

typeof = function(value)
    if type(value) == "table" then return value.__typeof or "table" end
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
local function node(class, name, parent)
    -- Roblox lets `model.Humanoid` resolve to a child; mirror that here.
    local n = setmetatable({
        ClassName = class, Name = name or class, Parent = parent, children = {},
        attributes = {}, Destroyed = false, Visible = false, __typeof = "Instance",
    }, {
        __index = function(self, key)
            return self:FindFirstChild(key)
        end,
        __newindex = function(self, key, value)
            if key == "Parent" then
                local previous = rawget(self, "Parent")
                if previous and previous.children then
                    for i, child in ipairs(previous.children) do
                        if child == self then table.remove(previous.children, i) break end
                    end
                end
                rawset(self, "Parent", value)
                if value and value.children then table.insert(value.children, self) end
            else
                rawset(self, key, value)
            end
        end,
    })
    if parent then table.insert(parent.children, n) end
    table.insert(nodes, n)
    if class == "BasePart" then
        n.Position = V3.new(0, 0, 0)
        n.CFrame = CFrame.new(n.Position)
        n.Size = V3.new(1, 1, 1)
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
        return CFrame.new(V3.new(0, 0, 10)), V3.new(4, 6, 2)
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

local coreGui = node("CoreGui", "CoreGui")
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
local services = {
    Players = players, RunService = run, CoreGui = coreGui,
    ReplicatedStorage = rep, UserInputService = uis, Workspace = workspace,
    StarterGui = { SetCore = function() end },
}
game = { GetService = function(_, name) return services[name] end, HttpGet = function(_, url) return url end }

local clock = 0
tick = function() clock = clock + 1 / 60; return clock end
os.clock = function() return clock end
local warnings = {}
warn = function(message) warnings[#warnings + 1] = tostring(message) end
local clicks = 0
mouse1click = function() clicks = clicks + 1 end
task = {
    spawn = function(fn, ...) pcall(fn, ...) end,
    wait = function() error("__mock_yield__") end,
    delay = function() end,
    defer = function(fn, ...) pcall(fn, ...) end,
}

-- ─── Mock UI library ────────────────────────────────────────────
local library = {
    Flags = {}, Notifications = {}, controls = {}, buttons = {}, labels = {},
    groups = {}, tabs = {}, previews = {}, settingsTab = false, unloaded = false,
}
function library:Notify(text) self.Notifications[#self.Notifications + 1] = text end
function library:Unload() self.unloaded = true end
local function addControl(group, o)
    group.controls[#group.controls + 1] = o
    local key = o.Flag or o.Name
    library.controls[key] = o
    if o.Flag then library.Flags[o.Flag] = o.Default end
    return o
end
local function newGroup(name, side)
    local g = { name = name, side = side, controls = {} }
    function g:AddToggle(o) return addControl(self, o) end
    function g:AddSlider(o) return addControl(self, o) end
    function g:AddDropdown(o) return addControl(self, o) end
    function g:AddButton(o) library.buttons[o.Name] = o.Callback; return addControl(self, o) end
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
    function t:AddGroup(groupName, side) return newGroup(groupName, side) end
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
local function labelNode(text)
    return findNode(function(n)
        return n.ClassName == "TextLabel" and n.Visible and not n.Destroyed and n.Text == text
    end)
end
local function visibleBox()
    return findNode(function(n) return n.Name == "ARC3USX_Box" and n.Visible and not n.Destroyed end)
end
local function visibleOutline()
    return findNode(function(n) return n.Name == "ARC3USX_Outline" and n.Visible and not n.Destroyed end)
end
local function healthBackgrounds()
    local out = {}
    for _, n in ipairs(nodes) do
        if n.ClassName == "Frame" and n.Visible and not n.Destroyed and n.BackgroundTransparency == 0
            and n.BackgroundColor3 and n.BackgroundColor3.R == 0
            and n.BackgroundColor3.G == 0 and n.BackgroundColor3.B == 0 then
            out[#out + 1] = n
        end
    end
    return out
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
    root.CFrame = CFrame.new(root.Position)
    head.CFrame = CFrame.new(head.Position)
    torso.CFrame = CFrame.new(torso.Position)
    upper.CFrame = CFrame.new(upper.Position)
    return m, hum, root
end

-- ─── Load the hub ───────────────────────────────────────────────
assert(load(hubSource, "scripts/main.lua"))()

-- No legacy feature code or controls may survive the swap.
for _, removed in ipairs({ "GunMods", "BowMods", "getgc", "gunmods_enabled", "bowmods_enabled",
    "universal_ammo", "ESP_URL", "ui_bootstrap", "ARC3USX_NH", "weakspotMarkers" }) do
    check(not hubSource:find(removed, 1, true), "legacy feature still present: " .. removed)
end
for _, flag in ipairs({ "gunmods_enabled", "bowmods_enabled", "universal_ammo", "universal_noair" }) do
    check(library.Flags[flag] == nil, "legacy flag still registered: " .. flag)
end

check(library.windowOpts.Intro == false and library.windowOpts.Theme == "Purple", "hub window options")
check(library.windowOpts.Size.X == 800 and library.windowOpts.Size.Y == 620, "hub window size")
check(#library.tabs == 3 and library.settingsTab, "three tabs plus settings")
check(library.tabs[1].name == "ESP / World" and library.tabs[2].name == "Combat" and library.tabs[3].name == "Misc", "tab names")
local expectedGroups = {
    "Player ESP", "NPC ESP", "Ore ESP (Icons)", "Heli ESP", "ESP Preview",
    "Aimbot", "Aimbot Visuals", "Bow Assist", "Aimbot Keys",
    "Staff Detection", "Staff ESP", "Mining (Silent Insta-Hit)", "System", "ESP Engine",
}
for _, name in ipairs(expectedGroups) do
    local found = false
    for _, g in ipairs(library.groups) do if g.name == name then found = true end end
    check(found, "missing group: " .. name)
end
for _, flag in ipairs({ "plr_master", "plr_enabled", "plr_chams", "plr_skel", "player_esp_hz",
    "npc_enabled", "ore_enabled", "ore_MetalNode", "heli_enabled", "weakspot_enabled",
    "staff_monitor", "staff_esp", "world_esp_hz", "esp_text_size", "esp_label_gap",
    "esp_fill_transparency", "esp_distance_style", "esp_parts_bounds", "plr_box_fill", "plr_box_thickness",
    "plr_box_outline", "plr_visible_only", "plr_hp_side", "npc_box_fill", "npc_box_thickness",
    "npc_box_outline", "npc_visible_only", "npc_health", "npc_hp_side",
    "heli_box_fill", "heli_box_thickness", "heli_box_outline" }) do
    check(library.Flags[flag] ~= nil, "missing flag: " .. flag)
end
check(#library.previews == 1 and library.previews[1].Elements.Box == "plr_box", "ESP preview wired to hub flags")
check(type(renderSteps.ARC3USX_InstaHit) == "function", "insta-hit render step bound")
check(type(renderSteps.ARC3USX_Aimbot) == "function", "aimbot render step bound")
check(#drawings == 3, "aimbot drawing objects created")
local espGui = findNode(function(n) return n.Name == "ARC3USX_ESP_UI" end)
check(espGui and espGui.Parent == coreGui, "ESP ScreenGui parented to CoreGui")

-- Color callbacks are wired without errors.
library.controls.plr_box.ColorCallback(1, newColor(0.5, 0.5, 0.5))
library.controls.plr_box.ColorCallback(2, newColor(0.1, 0.1, 0.1))
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

-- ─── Ported ESP features ────────────────────────────────────────
-- 3D corner projection: 4x6x2 box at z=10 projects to 40x60 at (380,270).
library.Flags.plr_style = "Full"
step()
local box = visibleBox()
check(box, "3D-projected box frame is drawn")
check(box.Position.X.Offset == 380 and box.Position.Y.Offset == 270, "3D box position from projected corners")
check(box.Size.X.Offset == 40 and box.Size.Y.Offset == 60, "3D box size from projected corners")
local stroke = box:FindFirstChildOfClass("UIStroke")
check(stroke and stroke.Thickness == 1, "box uses a UIStroke for thickness")

-- Multi-part bounds mode (state.parts / boundsOfParts from the framework).
library.Flags.esp_parts_bounds = true
step()
local partsBox = visibleBox()
check(partsBox and partsBox.Position.X.Offset == 395 and partsBox.Position.Y.Offset == 275
    and partsBox.Size.X.Offset == 10 and partsBox.Size.Y.Offset == 30,
    "parts bounds derive a box from the rig's physical parts")
library.Flags.esp_parts_bounds = false
step()
check(visibleBox().Size.X.Offset == 40, "bounding-box mode restored")

-- Dynamic label stacking (above/below) with configurable gap.
check(labelNode("Target").Position.Y.Offset == 255, "name reserves space above the box")
check(labelNode("2m").Position.Y.Offset == 332, "distance reserves space below the box")
check(labelNode("Unarmed").Position.Y.Offset == 347, "weapon stacks under distance")
library.Flags.plr_dist = false
step()
check(labelNode("Unarmed").Position.Y.Offset == 332, "hidden label releases its slot")
library.Flags.plr_dist = true
library.Flags.esp_label_gap = 6
step()
check(labelNode("Unarmed").Position.Y.Offset == 351, "label gap is configurable")
library.Flags.esp_label_gap = 2
step()

-- Box fill, thickness and outline color.
library.Flags.plr_style = "Full"
library.Flags.plr_box_fill = true
library.Flags.plr_box_thickness = 3
step()
box = visibleBox()
check(box and box.BackgroundTransparency ~= 1, "filled box tints its background")
check(box:FindFirstChildOfClass("UIStroke").Thickness == 3, "box thickness is configurable")
local outline = visibleOutline()
check(outline, "box outline is drawn behind the box")
check(outline:FindFirstChildOfClass("UIStroke").Thickness == 5, "outline is thicker than the box")
library.Flags.plr_box_outline = false
step()
check(not visibleOutline(), "box outline can be disabled")
library.Flags.plr_style = "Corners"
library.Flags.plr_box_fill = false
library.Flags.plr_box_thickness = 1
library.Flags.plr_box_outline = true
step()

-- Health bar side.
library.Flags.plr_hp_side = "Right"
step()
check(healthBackgrounds()[1].Position.X.Offset == 423, "health bar moves to the right side")
library.Flags.plr_hp_side = "Left"
step()
check(healthBackgrounds()[1].Position.X.Offset == 374, "health bar returns to the left side")

-- Visible-only filter.
workspace.obstruction = { Instance = node("BasePart", "Wall", workspace) }
library.Flags.plr_visible_only = true
step()
check(not labelVisible("Target"), "visible-only filter hides occluded targets")
workspace.obstruction = nil
library.Flags.plr_visible_only = false
step()

-- Distance styles.
library.Flags.esp_distance_style = "Brackets"
step()
check(labelVisible("[2]") and not labelVisible("2m"), "bracketed distance style")
library.Flags.esp_distance_style = "Studs"
step()
check(labelVisible("10s"), "studs distance style")
library.Flags.esp_distance_style = "Metres"
step()

-- Per-target error isolation: one bad model must not kill the frame.
local broken = newPlayer("Broken")
broken.Team = "red"
local brokenChar = character("BrokenChar", workspace)
broken.Character = brokenChar
function brokenChar:GetBoundingBox() error("bad bounds") end
step()
check(labelVisible("Target"), "a failing target does not break other ESP")
check(not labelVisible("Broken"), "failing target is hidden")
local sawWarning = false
for _, message in ipairs(warnings) do
    if message:find("player failed for Broken", 1, true) then sawWarning = true end
end
check(sawWarning, "failures are reported through the throttled error handler")
for i, plr in ipairs(players.list) do
    if plr == broken then table.remove(players.list, i) break end
end
brokenChar.Parent = nil

-- ─── NPC ESP ────────────────────────────────────────────────────
local npcFolder = node("Folder", "Npcs", workspace)
local guard = character("Guard", npcFolder)
library.Flags.npc_enabled = true
step()
check(labelVisible("Guard"), "NPC name label drawn")
local healthBefore = #healthBackgrounds()
check(healthBefore >= 2, "NPC health bar drawn alongside player health bars")
library.Flags.npc_health = false
step()
check(#healthBackgrounds() == healthBefore - 1, "NPC health bar can be disabled")
library.Flags.npc_health = true
library.Flags.npc_enabled = false
step()
library.Flags.world_esp_hz = 5
library.Flags.npc_enabled = true
step()
check(not labelVisible("Guard"), "world update rate throttles NPC resolution")
for _ = 1, 8 do step() end
check(labelVisible("Guard"), "NPC resolves once its interval elapses")
library.Flags.world_esp_hz = 60
library.Flags.npc_enabled = false
step()

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
check(clicks == 1, "insta-hit also fires a synthetic click")
check(camera.CFrame == savedCFrame, "insta-hit restores the camera without a visible lock")
library.Flags.weakspot_enabled = false

-- ─── Combat aim assist ──────────────────────────────────────────
library.controls["Master Enable"].Callback(true)
uis.InputBegan:Fire({ KeyCode = Enum.KeyCode.Q }, false)
renderSteps.ARC3USX_Aimbot(1 / 60)
check(drawings[1].Visible and drawings[3].Visible, "FOV circle and info text shown when enabled")
check(drawings[3].Text:find("gun", 1, true), "gun mode info text")
check(drawings[2].Visible, "target marker shown for a valid enemy")
players.LocalPlayer:SetAttribute("FustAimBow", true)
renderSteps.ARC3USX_Aimbot(1 / 60)
check(drawings[3].Text:find("bow", 1, true), "bow mode info text with ballistic speed")
players.LocalPlayer:SetAttribute("FustAimBow", nil)
uis.InputEnded:Fire({ KeyCode = Enum.KeyCode.Q })
library.buttons["Cycle Target Part"]()
check(library.Notifications[#library.Notifications]:find("Target:", 1, true), "cycle target part notifies")

-- ─── Unload ─────────────────────────────────────────────────────
library.buttons["Unload Script & Clear Memory"]()
check(library.unloaded, "unload closes the UI library")
check(espGui.Destroyed, "unload destroys the ESP ScreenGui")
check(renderSteps.ARC3USX_InstaHit == nil and renderSteps.ARC3USX_Aimbot == nil, "render steps unbound")
check(run.RenderStepped:ActiveCount() == 0, "render connections disconnected")
for _, d in ipairs(drawings) do check(d.removed, "aimbot drawing removed on unload") end
step()
check(not labelVisible("Target"), "no ESP updates after unload")
check(staffHighlight.Destroyed, "staff highlights cleaned on unload")

print("Hub mock tests passed")
