--[[
    ARC3USX bow silent aim — features only. No window, no buttons, no library.

    Separate from scripts/silent_aim.lua: that one is the gun silent aim (camera
    sandwich). This one is the bow/projectile variant and works on the payload the
    game sends to ReplicatedStorage.Fust.Remotes.Shoot instead of the camera:

      * rewrites dir/origin so the arrow flies at the picked target part
      * optional wallbang origin, charge override, rapid fire, shot-id dedupe
      * patches the bow tables found with getgc (instant draw, no crossbow reload,
        no client fire rate, no airborne block) and reverts them on stop
      * infinite arrows through InventorySync, optional fake hit injection

    Drive it directly:
        local Bow = assert(loadstring(game:HttpGet(ROOT .. "scripts/bow_silent_aim.lua")))()
        local aim = Bow.newSingleton({ enabled = true, fov = 300 })
        aim:Set("targetPart", "Random")
        aim:ManualShoot()
        aim:Unload()

    Everything that needs executor functions is capability-checked: without them the
    feature stays off and GetStatus().hookError says why.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local environment = type(getgenv) == "function" and getgenv() or _G
local LocalPlayer = Players.LocalPlayer

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Bow Silent Aim", Text = tostring(message), Duration = 5 })
    end)
end

local DEFAULTS = {
    enabled = false,

    -- targeting
    fov = 250,                    -- pixels from the screen centre, 0 = ignore the FOV
    distance = 0,                 -- studs, 0 = no limit
    targetPart = "Head",          -- "Head" | "Torso" | "HumanoidRootPart" | "Random"
    randomPartLifetime = 1.5,     -- seconds a random part stays picked
    wallCheck = false,            -- require line of sight
    teamCheck = true,
    targetNpcs = false,

    -- payload
    aimPayload = true,            -- rewrite dir/origin on Shoot:FireServer
    overrideCharge = true,
    chargeOverride = 1,           -- 0..1
    wallbang = false,             -- send origin at the target instead of the camera
    rapidFire = 1,                -- shots per click, 1..5
    dedupeProbe = false,          -- reuse the same shotId every shot
    modeProbe = false,            -- force Fust.Mode to "World" before firing

    -- bow internals (found with getgc, patched while running)
    instaCharge = true,           -- drawTime -> 0.01 while drawing
    noClientRate = true,          -- clear lastShot / fireQueuedAt so clicks chain
    noReloadCrossbow = true,      -- crossbow always loaded
    airborneBypass = false,       -- shoot while airborne
    infiniteArrows = false,
    ammoAmount = 9999,

    -- fake hit injection (only works if the game trusts client hit reg)
    fakeHits = false,
    fakeDamage = 9999,
    fakeRegion = "head",          -- "head" | "torso" | "limb"
    fakeKill = true,

    -- FOV circle
    showFov = false,
    fovFilled = false,
    fovColor = Color3.fromRGB(255, 170, 0),
    fovThickness = 1,
    fovTransparency = 50,

    -- misc
    verbose = false,
}

local RANGES = {
    fov = { 0, 800 },
    distance = { 0, 1000 },
    randomPartLifetime = { 0.1, 5 },
    chargeOverride = { 0, 1 },
    rapidFire = { 1, 5 },
    ammoAmount = { 1, 99999 },
    fakeDamage = { 1, 100000 },
    fovThickness = { 1, 5 },
    fovTransparency = { 0, 100 },
}

local CHOICES = {
    targetPart = { "Head", "Torso", "HumanoidRootPart", "Random" },
    fakeRegion = { "head", "torso", "limb" },
}

local COLOR_KEYS = { fovColor = true }

local BowSilentAim = {
    TargetParts = CHOICES.targetPart,
    FakeRegions = CHOICES.fakeRegion,
}

local function copyDefaults()
    local copy = {}
    for key, value in pairs(DEFAULTS) do copy[key] = value end
    return copy
end
BowSilentAim.Defaults = copyDefaults()

local function listHas(list, value)
    for _, item in ipairs(list) do
        if item == value then return true end
    end
    return false
end

local function isColor(value)
    if type(value) == "table" or type(value) == "userdata" then
        return value.R ~= nil and value.G ~= nil and value.B ~= nil
    end
    return false
end

------------------------------------------------------------------------
-- table heuristics (same shapes the pasted script scans for)
------------------------------------------------------------------------

local function isBowState(t)
    return type(t) == "table"
        and rawget(t, "drawStart") ~= nil
        and rawget(t, "drawing") ~= nil
        and rawget(t, "humanoid") ~= nil
        and rawget(t, "bowDef") ~= nil
        and rawget(t, "counts") ~= nil
        and rawget(t, "pendingSpent") ~= nil
        and rawget(t, "lastShot") ~= nil
        and rawget(t, "shotId") ~= nil
        and rawget(t, "aimMouse") ~= nil
end

local function isDrawController(t)
    return type(t) == "table"
        and type(rawget(t, "drawTime")) == "function"
        and type(rawget(t, "stepXbow")) == "function"
        and type(rawget(t, "spec")) == "function"
        and type(rawget(t, "progress")) == "function"
        and type(rawget(t, "xbow")) == "function"
        and type(rawget(t, "fireXbow")) == "function"
        and rawget(t, "loaded") ~= nil
end

local function isGunControl(t)
    return type(t) == "table"
        and type(rawget(t, "blocked")) == "function"
        and type(rawget(t, "gc")) ~= nil
        and rawget(t, "hintAt") ~= nil
end

------------------------------------------------------------------------
-- instance
------------------------------------------------------------------------

local Object = {}
Object.__index = Object

function BowSilentAim.new(config)
    config = type(config) == "table" and config or {}

    local self = setmetatable({}, Object)
    self.Options = copyDefaults()
    for key, value in pairs(config) do
        if DEFAULTS[key] ~= nil then self.Options[key] = value end
    end

    self.Running = false
    self.HookInstalled = false
    self.HookError = nil
    self.Shots = 0
    self.TableError = nil
    self.Tables = { u14 = nil, u17 = nil, u16 = nil }

    self._listeners = {}
    self._connections = {}
    self._patches = {}
    self._randomParts = {}
    self._lastShotId = 0
    self._lastTarget = nil
    self._circle = nil
    self._hook = nil
    self._remoteCache = {}
    self._remoteRetryAt = 0
    self._destroyed = false

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

    if key == "enabled" then
        if value then self:Start() else self:Stop() end
    elseif self.Running then
        if key == "instaCharge" or key == "noClientRate" or key == "noReloadCrossbow"
            or key == "airborneBypass" then
            self:_revertPatches()
            self:_applyPatches()
        elseif key == "infiniteArrows" then
            if value then
                self:_connectInventory()
            else
                self:_disconnectInventory()
            end
        elseif key == "showFov" or key == "fov" or key == "fovFilled" or key == "fovColor"
            or key == "fovThickness" or key == "fovTransparency" then
            self:_refreshCircle()
        end
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
    self:_changed("reset", nil)
    if wasRunning then self:Start() end
end

------------------------------------------------------------------------
-- remotes
------------------------------------------------------------------------

function Object:_remotes()
    local now = os.clock()
    if self._remoteCache.shoot and self._remoteCache.shoot.Parent then return self._remoteCache end
    if now < self._remoteRetryAt then return self._remoteCache end
    self._remoteRetryAt = now + 1

    local cache = { shoot = nil, arrowHit = nil, combatFX = nil, inventory = nil }
    local ok, fust = pcall(function() return ReplicatedStorage:FindFirstChild("Fust") end)
    if ok and fust then
        local remotes = fust:FindFirstChild("Remotes")
        if remotes then
            cache.shoot = remotes:FindFirstChild("Shoot")
            cache.arrowHit = remotes:FindFirstChild("ArrowHit")
            cache.combatFX = remotes:FindFirstChild("CombatFX")
            cache.inventory = remotes:FindFirstChild("InventorySync")
        end
        cache.mode = fust:FindFirstChild("Mode")
    end
    self._remoteCache = cache
    return cache
end

function Object:_shootRemote()
    return self:_remotes().shoot
end

------------------------------------------------------------------------
-- game tables (getgc scan) and patches
------------------------------------------------------------------------

function Object:ScanTables()
    local getGc = getgc
    if type(getGc) ~= "function" then
        self.TableError = "getgc is unavailable"
        return false
    end

    local ok, objects = pcall(getGc, true)
    if not ok or type(objects) ~= "table" then
        self.TableError = "getgc failed: " .. tostring(objects)
        return false
    end

    for _, object in pairs(objects) do
        if not self.Tables.u14 and isBowState(object) then self.Tables.u14 = object end
        if not self.Tables.u17 and isDrawController(object) then self.Tables.u17 = object end
        if not self.Tables.u16 and isGunControl(object) then self.Tables.u16 = object end
        if self.Tables.u14 and self.Tables.u17 and self.Tables.u16 then break end
    end

    if not (self.Tables.u14 and self.Tables.u17) then
        self.TableError = "bow tables not found yet"
        return false
    end

    self.TableError = nil
    return true
end

function Object:_patch(name, target, key, value)
    if self._patches[name] or type(target) ~= "table" then return false end
    local original = target[key]
    local ok = pcall(function() target[key] = value end)
    if not ok then return false end
    self._patches[name] = { target = target, key = key, original = original }
    return true
end

function Object:_applyPatches()
    local o = self.Options
    local u14, u17, u16 = self.Tables.u14, self.Tables.u17, self.Tables.u16

    if o.instaCharge and u17 then
        local original = u17.drawTime
        if type(original) == "function" then
            self:_patch("drawTime", u17, "drawTime", function(...)
                if u14 and u14.drawing then return 0.01 end
                return original(...)
            end)
        end
    end

    if o.noReloadCrossbow and u17 then
        if type(u17.xbow) == "function" then
            self:_patch("xbow", u17, "xbow", function() return true end)
        end
        self:_patch("loaded", u17, "loaded", true)
    end

    if o.airborneBypass and u16 then
        if type(u16.blocked) == "function" then
            self:_patch("blocked", u16, "blocked", function() return false end)
        end
        if type(u16.gc) == "table" and type(u16.gc.Airborne) == "function" then
            self:_patch("gcAirborne", u16.gc, "Airborne", function() return false end)
        end
    end

    if o.infiniteArrows then self:_connectInventory() end
end

function Object:_revertPatches()
    for name, entry in pairs(self._patches) do
        pcall(function() entry.target[entry.key] = entry.original end)
        self._patches[name] = nil
    end
end

function Object:_connectInventory()
    if self._inventoryConnection then return true end
    local inventory = self:_remotes().inventory
    if not inventory then return false end
    local signal = inventory.OnClientEvent
    if type(signal) ~= "table" and type(signal) ~= "userdata" then return false end

    local ok, connection = pcall(function()
        return inventory.OnClientEvent:Connect(function(payload)
            self:_onInventory(payload)
        end)
    end)
    if not ok or not connection then return false end
    self._inventoryConnection = connection
    return true
end

function Object:_disconnectInventory()
    if self._inventoryConnection then
        pcall(function() self._inventoryConnection:Disconnect() end)
        self._inventoryConnection = nil
    end
end

function Object:_onInventory(payload)
    if not self.Options.infiniteArrows then return end
    local u14 = self.Tables.u14
    if not u14 or type(payload) ~= "table" or type(payload.slots) ~= "table" then return end
    if type(u14.counts) ~= "table" then return end

    local amount = self.Options.ammoAmount
    for _, slot in ipairs(payload.slots) do
        if type(slot) == "table" and type(slot.id) == "string" then
            pcall(function() u14.counts[slot.id] = amount end)
        end
    end
    pcall(function() u14.pendingSpent = 0 end)
end

------------------------------------------------------------------------
-- targeting
------------------------------------------------------------------------

local RANDOM_PART_NAMES = {
    "Head", "UpperTorso", "LowerTorso", "Torso", "HumanoidRootPart",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
    "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot",
}

local TORSO_NAMES = { "UpperTorso", "Torso", "LowerTorso" }

local function firstPart(model, names)
    for _, name in ipairs(names) do
        local ok, part = pcall(function() return model:FindFirstChild(name) end)
        if ok and part and part.Position then return part end
    end
end

function Object:_randomPart(model, refresh)
    local now = os.clock()
    local cache = self._randomParts[model]
    if not refresh and cache and cache.part and cache.part.Parent == model
        and (now - cache.at) < self.Options.randomPartLifetime then
        return cache.part
    end

    local candidates = {}
    for _, name in ipairs(RANDOM_PART_NAMES) do
        local ok, part = pcall(function() return model:FindFirstChild(name) end)
        if ok and part and part.Position then
            local okPart, isPart = pcall(function() return part:IsA("BasePart") end)
            if okPart and isPart then table.insert(candidates, part) end
        end
    end
    if #candidates == 0 then
        local okChildren, children = pcall(function() return model:GetChildren() end)
        if okChildren and children then
            for _, child in ipairs(children) do
                local okPart, isPart = pcall(function() return child:IsA("BasePart") end)
                if okPart and isPart and child.Position then table.insert(candidates, child) end
            end
        end
    end

    local part
    if #candidates > 0 then part = candidates[math.random(1, #candidates)] end
    part = part or firstPart(model, { "Head", "HumanoidRootPart" })
    if part then self._randomParts[model] = { part = part, at = now } end
    return part
end

function Object:_partFor(model, refresh)
    local mode = self.Options.targetPart
    if mode == "Random" then return self:_randomPart(model, refresh) end
    if mode == "Torso" then
        return firstPart(model, TORSO_NAMES) or firstPart(model, { "HumanoidRootPart" })
    end
    if mode == "HumanoidRootPart" then
        return firstPart(model, { "HumanoidRootPart" }) or firstPart(model, { "Head" })
    end
    return firstPart(model, { "Head" }) or firstPart(model, { "HumanoidRootPart" })
end

function Object:_alive(model)
    local ok, humanoid = pcall(function() return model:FindFirstChildOfClass("Humanoid") end)
    return ok and humanoid ~= nil and humanoid.Health > 0
end

function Object:_isTeammate(player)
    if not self.Options.teamCheck then return false end
    local own = LocalPlayer and LocalPlayer.Team
    if own and player.Team == own then return true end
    if LocalPlayer and player:GetAttribute("FustMates") == LocalPlayer.UserId then return true end
    return false
end

function Object:_isNpc(model)
    local name = model.Name
    if name == "Guard" or name == "Soldier" or name == "Scavenger" then return true end
    local ok, scavenger = pcall(function() return model:GetAttribute("Scavenger") end)
    return ok and scavenger == true
end

function Object:_visible(origin, position, model)
    if not self.Options.wallCheck then return true end
    if type(workspace.Raycast) ~= "function" then return true end

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
    if not self._rayParams then return true end

    local hit
    local ok = pcall(function()
        local filter = { model }
        if LocalPlayer and LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
        self._rayParams.FilterDescendantsInstances = filter
        hit = workspace:Raycast(origin, position - origin, self._rayParams)
    end)
    if not ok then return true end
    return hit == nil
end

function Object:_aimPoint()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize
    if viewport then return Vector2.new(viewport.X / 2, viewport.Y / 2) end
    return Vector2.new(0, 0)
end

function Object:GetTarget(refresh)
    local camera = workspace.CurrentCamera
    if not camera then return nil end

    local origin = camera.CFrame.Position
    local aim = self:_aimPoint()
    local fov = self.Options.fov
    local limit = self.Options.distance
    local best, bestDelta = nil, math.huge

    local function consider(model, player)
        if not self:_alive(model) then return end
        local part = self:_partFor(model, refresh)
        if not part or not part.Position then return end
        local position = part.Position
        if limit > 0 and (position - origin).Magnitude > limit then return end
        local ok, screen, onScreen = pcall(function()
            return camera:WorldToViewportPoint(position)
        end)
        if not ok or not onScreen or not screen then return end
        local dx, dy = screen.X - aim.X, screen.Y - aim.Y
        local delta = dx * dx + dy * dy
        if fov > 0 and delta > fov * fov then return end
        if delta < bestDelta and self:_visible(origin, position, model) then
            bestDelta = delta
            best = {
                model = model, player = player, part = part, position = position,
                screen = { X = screen.X, Y = screen.Y },
            }
        end
    end

    local okPlayers, players = pcall(function() return Players:GetPlayers() end)
    if okPlayers and players then
        for _, player in ipairs(players) do
            if player ~= LocalPlayer and player.Character and not self:_isTeammate(player) then
                consider(player.Character, player)
            end
        end
    end

    if self.Options.targetNpcs then
        local ok, folder = pcall(function() return workspace:FindFirstChild("Npcs") end)
        if ok and folder then
            for _, model in ipairs(folder:GetChildren()) do
                if self:_isNpc(model) then consider(model) end
            end
        end
    end

    self._lastTarget = best
    return best
end

function Object:GetLastTarget()
    return self._lastTarget
end

------------------------------------------------------------------------
-- payload rewriting
------------------------------------------------------------------------

function Object:_prepareShot()
    local o = self.Options
    local u14, u17 = self.Tables.u14, self.Tables.u17

    if u14 then
        if o.instaCharge then
            pcall(function()
                u14.pendingSpent = 0
                u14.lastSpentAt = -math.huge
            end)
        end
        if o.noClientRate then
            pcall(function()
                u14.lastShot = -math.huge
                u14.fireQueuedAt = nil
            end)
        end
    end

    if u17 and o.noReloadCrossbow then
        pcall(function()
            u17.loaded = true
            u17.reloadAt = nil
        end)
    end
end

function Object:NextShotId()
    if self.Options.dedupeProbe then
        self._lastShotId = self._lastShotId == 0 and 1 or self._lastShotId
    else
        self._lastShotId = self._lastShotId + 1
    end
    return self._lastShotId
end

function Object:_modeProbe()
    if not self.Options.modeProbe then return end
    local mode = self:_remotes().mode
    if mode and type(mode.IsA) == "function" and mode:IsA("StringValue") then
        pcall(function() mode.Value = "World" end)
    end
end

function Object:_aimPayload(payload, target)
    local camera = workspace.CurrentCamera
    if not camera or not target then return payload end
    local origin = payload.origin or camera.CFrame.Position
    local direction = target.position - origin
    if direction.Magnitude <= 0.001 then return payload end

    payload.dir = direction.Unit
    if self.Options.wallbang then
        payload.origin = target.position - direction.Unit * 0.5
    end
    return payload
end

function Object:RewritePayload(payload)
    if type(payload) ~= "table" then return payload end

    if payload.draw == true then
        if self.Tables.u14 and self.Options.noClientRate then
            pcall(function() self.Tables.u14.lastShot = -math.huge end)
        end
        return payload
    end

    self:_prepareShot()
    if self.Options.overrideCharge then payload.charge = self.Options.chargeOverride end

    if self.Options.aimPayload then
        local target = self:GetTarget(true)
        if target then self:_aimPayload(payload, target) end
    elseif self.Options.wallbang then
        local target = self:GetTarget(true)
        if target then self:_aimPayload(payload, target) end
    end

    if payload.shotId == nil or self.Options.dedupeProbe then
        payload.shotId = self:NextShotId()
    end
    return payload
end

------------------------------------------------------------------------
-- firing
------------------------------------------------------------------------

function Object:_fireDirect(payload)
    local shoot = self:_shootRemote()
    if not shoot then return false, "Shoot remote not found" end
    local ok
    if self._hook then
        ok = pcall(self._hook.original, shoot, payload)
    else
        ok = pcall(function() shoot:FireServer(payload) end)
    end
    if ok then self.Shots = self.Shots + 1 end
    return ok
end

function Object:_sendFakeHit(target)
    if not target then return end
    local remotes = self:_remotes()
    if remotes.arrowHit then
        pcall(function()
            remotes.arrowHit:FireServer({
                id = 0,
                pos = target.position,
                stuck = false,
                broke = false,
                hitPlayer = target.player and target.player.UserId or nil,
                kind = "arrow",
            })
        end)
    end
    if remotes.combatFX then
        pcall(function()
            remotes.combatFX:FireServer({
                kind = "hit",
                damage = self.Options.fakeDamage,
                region = self.Options.fakeRegion,
                kill = self.Options.fakeKill,
            })
        end)
    end
end

function Object:ManualShoot()
    if self._destroyed then return false, "unloaded" end
    local camera = workspace.CurrentCamera
    if not camera then return false, "no camera" end
    if not self:_shootRemote() then return false, "Shoot remote not found" end

    self:_modeProbe()

    local target = self:GetTarget(true)
    local payload = {
        origin = camera.CFrame.Position,
        dir = camera.CFrame.LookVector,
        charge = self.Options.chargeOverride,
        shotId = self:NextShotId(),
    }
    if self.Options.aimPayload and target then self:_aimPayload(payload, target) end
    if not self.Options.overrideCharge then payload.charge = nil end

    self:_prepareShot()
    local ok, err = self:_fireDirect(payload)
    if not ok then
        if self.Options.verbose then notify("manual shot failed: " .. tostring(err)) end
        return false, err
    end

    local extra = self.Options.rapidFire - 1
    for index = 1, extra do
        local copy = {}
        for key, value in pairs(payload) do copy[key] = value end
        copy.shotId = payload.shotId + index
        task.spawn(function() self:_fireDirect(copy) end)
    end

    if self.Options.fakeHits and target then self:_sendFakeHit(target) end
    return true, payload
end

------------------------------------------------------------------------
-- namecall hook on Shoot
------------------------------------------------------------------------

function Object:_installHook()
    if self._hook then return true end

    local getRawMetatable = getrawmetatable
    local setReadOnly = setreadonly
    local getNamecall = getnamecallmethod
    if type(getRawMetatable) ~= "function" or type(setReadOnly) ~= "function"
        or type(getNamecall) ~= "function" then
        self.HookInstalled = false
        self.HookError = "executor hook functions unavailable"
        return false
    end

    local shoot = self:_shootRemote()
    if not shoot then
        self.HookInstalled = false
        self.HookError = "Shoot remote not found"
        return false
    end

    local okMeta, metatable = pcall(getRawMetatable, shoot)
    if not okMeta or type(metatable) ~= "table" or type(metatable.__namecall) ~= "function" then
        self.HookInstalled = false
        self.HookError = "namecall metatable unavailable"
        return false
    end

    local original = metatable.__namecall
    local hookSelf = self

    local wrapper = function(instance, ...)
        if instance ~= shoot or getNamecall() ~= "FireServer" then
            return original(instance, ...)
        end
        local payload = select(1, ...)
        if type(payload) ~= "table" then return original(instance, ...) end

        local ok, rewritten = pcall(hookSelf.RewritePayload, hookSelf, payload)
        if ok and type(rewritten) == "table" then payload = rewritten end

        if hookSelf.Options.rapidFire > 1 then
            for index = 2, hookSelf.Options.rapidFire do
                local copy = {}
                for key, value in pairs(payload) do copy[key] = value end
                copy.shotId = (payload.shotId or hookSelf._lastShotId) + index
                task.spawn(function() hookSelf:_fireDirect(copy) end)
            end
        end

        hookSelf.Shots = hookSelf.Shots + 1
        return original(instance, payload, select(2, ...))
    end

    local newClosure = type(newcclosure) == "function" and newcclosure or function(fn) return fn end
    local wrapped = newClosure(wrapper)

    pcall(setReadOnly, metatable, false)
    local installed, err = pcall(function() metatable.__namecall = wrapped end)
    pcall(setReadOnly, metatable, true)

    if not installed then
        self.HookInstalled = false
        self.HookError = tostring(err)
        return false
    end

    self._hook = { metatable = metatable, original = original, wrapper = wrapped }
    self.HookInstalled = true
    self.HookError = nil
    return true
end

function Object:_removeHook()
    local hook = self._hook
    if not hook then
        self.HookInstalled = false
        return
    end
    self._hook = nil
    self.HookInstalled = false

    local setReadOnly = setreadonly
    if type(setReadOnly) == "function" then pcall(setReadOnly, hook.metatable, false) end
    pcall(function()
        if rawget(hook.metatable, "__namecall") == hook.wrapper then
            hook.metatable.__namecall = hook.original
        end
    end)
    if type(setReadOnly) == "function" then pcall(setReadOnly, hook.metatable, true) end
end

------------------------------------------------------------------------
-- FOV circle
------------------------------------------------------------------------

function Object:_refreshCircle()
    if self._destroyed then return end
    local options = self.Options
    local visible = options.showFov and self.Running and options.fov > 0

    if not visible then
        if self._circle then pcall(function() self._circle.Visible = false end) end
        return
    end

    if not self._circle then
        local drawing = Drawing or environment.Drawing
        if not drawing or type(drawing.new) ~= "function" then return end
        local ok, circle = pcall(drawing.new, "Circle")
        if not ok or not circle then return end
        self._circle = circle
    end

    local circle = self._circle
    local aim = self:_aimPoint()
    pcall(function()
        circle.Position = Vector2.new(aim.X, aim.Y)
        circle.Radius = options.fov
        circle.Thickness = options.fovThickness
        circle.Filled = options.fovFilled
        circle.Color = options.fovColor
        circle.Transparency = math.clamp(options.fovTransparency / 100, 0, 1)
        circle.Visible = true
    end)
end

function Object:GetFOVCircle()
    return self._circle
end

------------------------------------------------------------------------
-- lifecycle
------------------------------------------------------------------------

function Object:_startRetry()
    self._retryToken = (self._retryToken or 0) + 1
    local token = self._retryToken
    if self.Tables.u14 and self.Tables.u17 and self.HookInstalled then return end

    task.spawn(function()
        while self.Running and not self._destroyed and self._retryToken == token do
            if self.Tables.u14 and self.Tables.u17 and self.HookInstalled then break end
            task.wait(1)
            if not self.Running or self._destroyed or self._retryToken ~= token then break end
            if not (self.Tables.u14 and self.Tables.u17) then self:ScanTables() end
            self:_applyPatches()
            if not self.HookInstalled then self:_installHook() end
        end
    end)
end

function Object:Start()
    if self._destroyed or self.Running then return end
    self.Running = true

    self.Tables = { u14 = nil, u17 = nil, u16 = nil }
    self:ScanTables()
    self:_applyPatches()
    self:_installHook()
    self:_refreshCircle()
    self:_startRetry()
end

function Object:Stop()
    if not self.Running then return end
    self.Running = false
    self._retryToken = (self._retryToken or 0) + 1

    self:_removeHook()
    self:_revertPatches()
    self:_disconnectInventory()
    self._randomParts = {}
    self._lastTarget = nil

    if self._circle then
        pcall(function()
            self._circle.Visible = false
            self._circle:Remove()
        end)
        self._circle = nil
    end
end

function Object:IsRunning()
    return self.Running
end

function Object:GetStatus()
    local target = self._lastTarget
    local name = ""
    if target and target.model then
        local ok, player = pcall(function() return Players:GetPlayerFromCharacter(target.model) end)
        name = (ok and player and player.Name) or target.model.Name
    end

    return {
        enabled = self.Options.enabled,
        running = self.Running,
        hookInstalled = self.HookInstalled,
        hookError = self.HookError,
        tableError = self.TableError,
        rows = self.Tables.u14 ~= nil,
        draw = self.Tables.u17 ~= nil,
        gun = self.Tables.u16 ~= nil,
        shots = self.Shots,
        target = name,
        arrows = self._inventoryConnection ~= nil,
    }
end

function Object:Unload()
    if self._destroyed then return end
    self:Stop()
    self._destroyed = true
    self._listeners = {}
    self._randomParts = {}
    self._remoteCache = {}
end

------------------------------------------------------------------------
-- singleton helpers
------------------------------------------------------------------------

function BowSilentAim.GetInstance()
    return environment.ARC3USX_BOW_SILENT_AIM
end

function BowSilentAim.DestroyInstance()
    local instance = environment.ARC3USX_BOW_SILENT_AIM
    if instance then pcall(function() instance:Unload() end) end
    environment.ARC3USX_BOW_SILENT_AIM = nil
end

function BowSilentAim.newSingleton(config)
    BowSilentAim.DestroyInstance()
    local instance = BowSilentAim.new(config)
    environment.ARC3USX_BOW_SILENT_AIM = instance
    return instance
end

BowSilentAim.Notify = notify
BowSilentAim.Instance = Object
BowSilentAim.TableShapes = {
    bowState = isBowState,
    drawController = isDrawController,
    gunControl = isGunControl,
}

return BowSilentAim
