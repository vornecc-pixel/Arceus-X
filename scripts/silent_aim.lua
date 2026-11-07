-- ARC3USX silent aim: features only. This file never builds a UI.
-- Run it with an injected UI (scripts/silent_aim_ui.lua, scripts/main.lua) or drive it directly:
--
--   local SilentAim = assert(loadstring(game:HttpGet(URL)))()
--   local aim = SilentAim.new()
--   aim:Set("enabled", true)
--   aim:Set("fov", 300)
--   aim:Unload()
--
-- The camera sandwich is unchanged from the original: at Camera + 2 the camera is
-- aimed at the target for the duration of the frame, at Camera + 4 the real camera
-- is put back, so the player never sees the snap and no game tool is hooked.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local environment = type(getgenv) == "function" and getgenv() or _G

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "ARC3USX Silent Aim", Text = tostring(message), Duration = 5 })
    end)
end

local GUN_SPEEDS = {
    assault_rifle = 1173, semi_auto_rifle = 1110, bolt_action_rifle = 1200,
    hunting_rifle = 1100, tactical_smg = 825, custom_smg = 824, hunt_smg = 825,
    m249 = 1097, pump_shotgun = 525, double_barrel = 525, pipe_shotgun = 525,
    pistol = 828, service_pistol = 828, revolver = 885,
    musket = 1100, flintlock = 700, rocket_launcher = 250,
    drum_gun = 800,
}
local GUN_DEFAULT_SPEED = 1000

local DEFAULTS = {
    -- master switch
    enabled = false,
    activation = "Always",        -- "Always" | "Hold" (right mouse) | "Toggle" (keybind)

    -- targeting
    hitChance = 100,              -- 0..100, rolled once per acquired target
    fov = 220,                    -- pixels from the crosshair, 0 = ignore the circle
    distance = 0,                 -- studs, 0 = no limit
    bone = "Head",                -- "Head" | "HumanoidRootPart" | "Random"
    randomPartLifetime = 1.5,     -- seconds a randomly chosen hit part is kept
    prediction = true,
    wallCheck = false,
    teamCheck = true,
    targetNpcs = false,
    shotOnly = true,              -- only snap while (or just after) firing

    -- gun handling
    gunSpeed = 0,                 -- 0 = look the equipped gun up in GUN_SPEEDS
    cooldown = 0,                 -- seconds between snaps per gun, 0 = every frame

    -- FOV circle
    showFov = true,
    fovFilled = false,
    fovColor = Color3.fromRGB(255, 80, 80),
    fovThickness = 1,
    fovTransparency = 50,         -- 0 = solid, 100 = invisible

    -- snapline from the FOV centre to the target that will be hit
    showSnapline = true,
    snaplineColor = Color3.fromRGB(255, 255, 255),
    snaplineThickness = 1,
    snaplineTransparency = 0,     -- 0 = solid, 100 = invisible

    -- misc
    verbose = false,
}

local RANGES = {
    hitChance = { 0, 100 },
    fov = { 0, 800 },
    distance = { 0, 1000 },
    gunSpeed = { 0, 6000 },
    cooldown = { 0, 1 },
    fovThickness = { 1, 5 },
    fovTransparency = { 0, 100 },
    randomPartLifetime = { 0.1, 5 },
    snaplineThickness = { 1, 5 },
    snaplineTransparency = { 0, 100 },
}

local CHOICES = {
    activation = { "Always", "Hold", "Toggle" },
    bone = { "Head", "HumanoidRootPart", "Random" },
}

local cameraPriority = 200
if Enum.RenderPriority and Enum.RenderPriority.Camera
    and type(Enum.RenderPriority.Camera.Value) == "number" then
    cameraPriority = Enum.RenderPriority.Camera.Value
end
local SNAP_PRIORITY = cameraPriority + 2
local RESTORE_PRIORITY = cameraPriority + 4
local FIRE_MEMORY = 0.2
local TARGET_LOCK = 0.25
local MAX_TRACKED_SPEED = 100
local VELOCITY_CACHE_LIFETIME = 3

local SilentAim = {}
SilentAim.GunSpeeds = GUN_SPEEDS
SilentAim.ActivationModes = CHOICES.activation
SilentAim.Bones = CHOICES.bone

local function copyDefaults()
    local options = {}
    for key, value in pairs(DEFAULTS) do options[key] = value end
    return options
end
SilentAim.Defaults = copyDefaults()

local function listHas(list, value)
    for _, item in ipairs(list) do
        if item == value then return true end
    end
    return false
end
SilentAim.ListHas = listHas

local function isColor(value)
    if type(value) == "table" or type(value) == "userdata" then
        return value.R ~= nil and value.G ~= nil and value.B ~= nil
    end
    return false
end

local function zero()
    return Vector3.new(0, 0, 0)
end

local Instance = {}
Instance.__index = Instance

function SilentAim.new(config)
    config = type(config) == "table" and config or {}

    local self = setmetatable({}, Instance)

    self.Options = copyDefaults()
    for key, value in pairs(config) do
        if DEFAULTS[key] ~= nil then self.Options[key] = value end
    end

    self.Running = false
    self.Toggled = true             -- used by the "Toggle" activation mode
    self._listeners = {}
    self._connections = {}
    self._velocity = {}
    self._randomParts = {}
    self._last = {}
    self._snapped = false
    self._realCFrame = nil
    self._lock = nil
    self._target = nil
    self._circle = nil
    self._snapline = nil
    self._loop = nil
    self._firing = false
    self._holdingRMB = false
    self._lastFire = -math.huge
    self._gunCooldownAt = {}
    self._destroyed = false

    local tag = tostring(math.random(1000000, 9999999))
    self._snapName = "ARC3USX_SA_SNAP_" .. tag
    self._restoreName = "ARC3USX_SA_RESTORE_" .. tag

    if self.Options.enabled then self:Start() end

    self._rayParams = RaycastParams.new()
    if self._rayParams then
        pcall(function()
            self._rayParams.FilterType = Enum.RaycastFilterType.Exclude
            self._rayParams.IgnoreWater = true
        end)
    end

    return self
end

------------------------------------------------------------------------
-- options
------------------------------------------------------------------------

function Instance:Get(key)
    return self.Options[key]
end

function Instance:GetAll()
    local copy = {}
    for key, value in pairs(self.Options) do copy[key] = value end
    return copy
end

function Instance:Is(key)
    return self.Options[key] == true
end

function Instance:OnChanged(callback)
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

function Instance:_changed(key, value)
    for _, entry in ipairs(self._listeners) do
        if entry.connected then pcall(entry.callback, key, value, self) end
    end
    if key == "showFov" or key == "fov" or key == "fovFilled" or key == "fovColor"
        or key == "fovThickness" or key == "fovTransparency" then
        self:_refreshCircle()
    end
    if key == "snaplineColor" or key == "snaplineThickness" or key == "snaplineTransparency" then
        self:_refreshSnapline()
    end
end

function Instance:Set(key, value)
    local default = DEFAULTS[key]
    if default == nil then return false, "unknown option: " .. tostring(key) end

    if type(default) == "boolean" then
        value = value and true or false
    elseif type(default) == "number" then
        value = tonumber(value)
        if value == nil then return false, tostring(key) .. " must be a number" end
        local range = RANGES[key]
        if range then value = math.clamp(value, range[1], range[2]) end
    elseif key == "fovColor" or key == "snaplineColor" then
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

    if key == "enabled" or key == "activation" then self:_syncRunning() end
    self:_changed(key, value)
    return true
end

function Instance:SetMany(values)
    if type(values) ~= "table" then return end
    for key, value in pairs(values) do self:Set(key, value) end
end

function Instance:Reset()
    local wasRunning = self.Running
    if wasRunning then self:Stop() end
    self.Options = copyDefaults()
    self:_changed("reset", nil)
    if wasRunning then self:Start() end
end

function Instance:ToggleActive()
    self.Toggled = not self.Toggled
    self:_changed("toggled", self.Toggled)
    return self.Toggled
end

function Instance:SetActive(active)
    self.Toggled = active and true or false
    self:_changed("toggled", self.Toggled)
end

function Instance:IsToggled()
    return self.Toggled
end

------------------------------------------------------------------------
-- weapon helpers
------------------------------------------------------------------------

function Instance:GetEquippedGun()
    local character = LocalPlayer and LocalPlayer.Character
    if not character then return nil end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            local id = child:GetAttribute("ItemId") or child.Name
            if id then return tostring(id) end
        end
    end
    return nil
end

function Instance:GetGunSpeed()
    if self.Options.gunSpeed > 0 then return self.Options.gunSpeed end
    local id = self:GetEquippedGun()
    if not id then return GUN_DEFAULT_SPEED end
    return GUN_SPEEDS[id] or GUN_DEFAULT_SPEED
end

function Instance:_gunCanSnap()
    local cooldown = self.Options.cooldown
    if cooldown <= 0 then return true end
    local id = self:GetEquippedGun() or "default"
    local now = os.clock()
    local nextAt = self._gunCooldownAt[id]
    if nextAt and nextAt > now then return false end
    self._gunCooldownAt[id] = now + cooldown
    return true
end

------------------------------------------------------------------------
-- world helpers
------------------------------------------------------------------------

function Instance:_isTeammate(player)
    if player == LocalPlayer then return true end
    local mates
    if LocalPlayer then
        local ok, value = pcall(function() return LocalPlayer:GetAttribute("FustMates") end)
        if ok then mates = value end
    end
    if type(mates) == "string" and mates ~= "" then
        for id in string.gmatch(mates, "[^,;]+") do
            if tonumber(id) == player.UserId then return true end
        end
    end
    local team = LocalPlayer and LocalPlayer.Team
    if team and player.Team == team then return true end
    return false
end

function Instance:_isNpc(model)
    if model.Name == "Guard" or model.Name == "Soldier" then return true end
    local ok, scavenger = pcall(function() return model:GetAttribute("Scavenger") end)
    return ok and scavenger == true
end

local RANDOM_BONE_NAMES = {
    "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Torso",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftHand", "RightHand", "LeftUpperLeg", "RightUpperLeg",
    "LeftLowerLeg", "RightLowerLeg", "LeftFoot", "RightFoot",
}

function Instance:_randomBone(model, refresh)
    local now = os.clock()
    local cache = self._randomParts[model]
    if not refresh and cache and cache.part and cache.part.Parent == model
        and (now - cache.at) < self.Options.randomPartLifetime then
        return cache.part
    end

    local candidates = {}
    for _, name in ipairs(RANDOM_BONE_NAMES) do
        local ok, part = pcall(function() return model:FindFirstChild(name) end)
        if ok and part then
            local okPart, isPart = pcall(function() return part:IsA("BasePart") end)
            if okPart and isPart and part.Position then table.insert(candidates, part) end
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

    if #candidates == 0 then
        return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    end

    local part = candidates[math.random(1, #candidates)]
    self._randomParts[model] = { part = part, at = now }
    return part
end

function Instance:_bone(model, refresh)
    local name = self.Options.bone
    if name == "Random" then return self:_randomBone(model, refresh) end
    if name == "HumanoidRootPart" then
        return model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
    end
    return model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
end

function Instance:_alive(model)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0
end

function Instance:_visible(origin, targetPosition, targetModel)
    if not self.Options.wallCheck then return true end
    local params = self._rayParams
    if not params or type(workspace.Raycast) ~= "function" then return true end
    local filter = {}
    if LocalPlayer and LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    if targetModel then table.insert(filter, targetModel) end
    local ok, result = pcall(function()
        params.FilterDescendantsInstances = filter
        return workspace:Raycast(origin, targetPosition - origin, params)
    end)
    if not ok then return true end
    return result == nil
end

function Instance:_velocityOf(part)
    local model = part and part.Parent
    if not model then return zero() end
    local root = model:FindFirstChild("HumanoidRootPart")
    if not root or not root.Position then return zero() end
    local now = os.clock()
    local position = root.Position
    local entry = self._velocity[model]
    if not entry then
        self._velocity[model] = { p = position, t = now, v = zero() }
        return zero()
    end
    local delta = now - entry.t
    if delta < 0.016 then return entry.v end
    local velocity = (position - entry.p) / delta
    if velocity.Magnitude > MAX_TRACKED_SPEED then velocity = zero() end
    entry.p, entry.t, entry.v = position, now, velocity
    return velocity
end

function Instance:_pruneVelocity()
    local now = os.clock()
    for model, entry in pairs(self._velocity) do
        if now - entry.t > VELOCITY_CACHE_LIFETIME then self._velocity[model] = nil end
    end
    local limit = math.max(self.Options.randomPartLifetime, 1) * 3
    for model, entry in pairs(self._randomParts) do
        if not entry.part or entry.part.Parent ~= model or (now - entry.at) > limit then
            self._randomParts[model] = nil
        end
    end
end

------------------------------------------------------------------------
-- targeting
------------------------------------------------------------------------

function Instance:_rollHitChance()
    local chance = self.Options.hitChance
    if chance >= 100 then return true end
    if chance <= 0 then return false end
    return math.random(1, 100) <= chance
end

function Instance:_pickTarget(camera, aimPoint, origin)
    local fov = self.Options.fov
    local limit = self.Options.distance
    local best, bestDelta = nil, math.huge

    local function consider(model)
        local bone = self:_bone(model)
        if not bone or not bone.Position then return end
        local position = bone.Position
        if limit > 0 and (position - origin).Magnitude > limit then return end
        local screen, onScreen = camera:WorldToViewportPoint(position)
        if not onScreen then return end
        local dx, dy = screen.X - aimPoint.X, screen.Y - aimPoint.Y
        local delta = dx * dx + dy * dy
        if fov > 0 and delta > fov * fov then return end
        if delta < bestDelta then
            bestDelta = delta
            best = { bone = bone, model = model, position = position, screen = { X = screen.X, Y = screen.Y } }
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local skip = self.Options.teamCheck and self:_isTeammate(player)
            if not skip then
                local model = player.Character
                if model and self:_alive(model) then consider(model) end
            end
        end
    end

    if self.Options.targetNpcs then
        local folder = workspace:FindFirstChild("Npcs")
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                if self:_isNpc(model) and self:_alive(model) then consider(model) end
            end
        end
    end

    return best
end

function Instance:_lockedTarget(camera, aimPoint, origin)
    local lock = self._lock
    local now = os.clock()
    if lock and lock.expiresAt > now and lock.bone and lock.bone.Parent then
        local position = lock.bone.Position
        if position then
            local limit = self.Options.distance
            local screen, onScreen = camera:WorldToViewportPoint(position)
            local fov = self.Options.fov
            local dx, dy = screen.X - aimPoint.X, screen.Y - aimPoint.Y
            local inside = onScreen and (fov <= 0 or (dx * dx + dy * dy) <= fov * fov)
                and (limit <= 0 or (position - origin).Magnitude <= limit)
            if inside and self:_alive(lock.model) then
                return {
                    bone = lock.bone, model = lock.model, position = position, hit = lock.hit,
                    screen = onScreen and screen and { X = screen.X, Y = screen.Y } or nil,
                }
            end
        end
    end
    self._lock = nil
    return nil
end

------------------------------------------------------------------------
-- FOV circle
------------------------------------------------------------------------

function Instance:_refreshCircle()
    if self._destroyed then return end
    local options = self.Options
    local visible = options.showFov and self.Running and not self._destroyed

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
    local aim = self:GetAimPoint()
    pcall(function()
        circle.Radius = options.fov
        circle.Thickness = options.fovThickness
        circle.Filled = options.fovFilled
        circle.Color = options.fovColor
        circle.Transparency = math.clamp(options.fovTransparency / 100, 0, 1)
        if aim then circle.Position = aim end
        circle.Visible = options.fov > 0
    end)
end

function Instance:GetAimPoint()
    if type(self._aimPointProvider) == "function" then
        local ok, point = pcall(self._aimPointProvider)
        if ok and point then return point end
    end
    local ok, point = pcall(function() return UserInputService:GetMouseLocation() end)
    if ok then return point end
    return Vector2.new(0, 0)
end

function Instance:SetAimPointProvider(provider)
    self._aimPointProvider = type(provider) == "function" and provider or nil
end

function Instance:GetFOVCircle()
    return self._circle
end

function Instance:_refreshSnapline()
    if self._destroyed then return end
    local options = self.Options
    local target = self._target
    local visible = options.showSnapline == true and self.Running and not self._destroyed
        and target ~= nil and target.screen ~= nil

    if not visible then
        if self._snapline then pcall(function() self._snapline.Visible = false end) end
        return
    end

    if not self._snapline then
        local drawing = Drawing or environment.Drawing
        if not drawing or type(drawing.new) ~= "function" then return end
        local ok, line = pcall(drawing.new, "Line")
        if not ok or not line then return end
        self._snapline = line
    end

    local aim = self:GetAimPoint()
    if not aim then return end

    local line = self._snapline
    pcall(function()
        line.From = Vector2.new(aim.X, aim.Y)
        line.To = Vector2.new(target.screen.X, target.screen.Y)
        line.Color = options.snaplineColor
        line.Thickness = options.snaplineThickness
        line.Transparency = math.clamp(options.snaplineTransparency / 100, 0, 1)
        line.Visible = true
    end)
end

function Instance:GetSnapline()
    return self._snapline
end

------------------------------------------------------------------------
-- render steps
------------------------------------------------------------------------

function Instance:WantsSnap()
    if not self.Options.enabled then return false end
    local mode = self.Options.activation
    if mode == "Hold" and not self._holdingRMB then return false end
    if mode == "Toggle" and not self.Toggled then return false end
    if self.Options.shotOnly then
        if self._firing then return true end
        return (os.clock() - self._lastFire) < FIRE_MEMORY
    end
    return true
end

function Instance:_snap()
    self._snapped = false
    self._realCFrame = nil

    if not self:WantsSnap() or not self:_gunCanSnap() then
        self._target = nil
        return
    end

    local camera = workspace.CurrentCamera
    if not camera then return end

    local origin = camera.CFrame.Position
    local aimPoint = self:GetAimPoint()

    local best = self:_lockedTarget(camera, aimPoint, origin)
    if not best then
        best = self:_pickTarget(camera, aimPoint, origin)
        if best then
            if self.Options.bone == "Random" then
                local part = self:_bone(best.model, true)
                if part and part.Position then
                    best.bone, best.position = part, part.Position
                    local okScreen, screen, onScreen = pcall(function()
                        return camera:WorldToViewportPoint(part.Position)
                    end)
                    if okScreen and onScreen and screen then
                        best.screen = { X = screen.X, Y = screen.Y }
                    end
                end
            end
            best.hit = self:_rollHitChance()
            self._lock = {
                bone = best.bone,
                model = best.model,
                hit = best.hit,
                expiresAt = os.clock() + TARGET_LOCK,
            }
        end
    end

    if not best or not best.hit then
        self._target = nil
        return
    end

    self._target = best

    if not self:_visible(origin, best.position, best.model) then return end

    local targetPosition = best.position
    if self.Options.prediction then
        local speed = self:GetGunSpeed()
        if speed > 0 then
            local travel = (targetPosition - origin).Magnitude / speed
            local velocity = self:_velocityOf(best.bone)
            if velocity.Magnitude > 0.5 then
                targetPosition = targetPosition + velocity * travel
            end
        end
    end

    if (targetPosition - origin).Magnitude < 0.05 then return end

    local realCFrame = camera.CFrame
    local ok = pcall(function()
        camera.CFrame = CFrame.lookAt(origin, targetPosition)
    end)
    if ok then
        self._realCFrame = realCFrame
        self._snapped = true
    end
end

function Instance:_restore()
    if self._snapped and self._realCFrame then
        local camera = workspace.CurrentCamera
        if camera then pcall(function() camera.CFrame = self._realCFrame end) end
    end
    self._snapped, self._realCFrame = false, nil
    self:_refreshCircle()
    self:_refreshSnapline()
end

------------------------------------------------------------------------
-- lifecycle
------------------------------------------------------------------------

function Instance:Start()
    if self._destroyed or self.Running then return end
    self.Running = true

    if type(RunService.BindToRenderStep) == "function" then
        RunService:BindToRenderStep(self._snapName, SNAP_PRIORITY, function() self:_snap() end)
        RunService:BindToRenderStep(self._restoreName, RESTORE_PRIORITY, function() self:_restore() end)
        self._bound = true
    elseif RunService.RenderStepped then
        table.insert(self._connections, RunService.RenderStepped:Connect(function()
            self:_snap()
            self:_restore()
        end))
    end

    local function bind(signal, handler)
        if signal then table.insert(self._connections, signal:Connect(handler)) end
    end

    bind(UserInputService.InputBegan, function(input, processed)
        if processed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self._firing = true
            self._lastFire = os.clock()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            self._holdingRMB = true
        end
    end)

    bind(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self._firing = false
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            self._holdingRMB = false
        end
    end)

    self._loop = task.spawn(function()
        while self.Running and not self._destroyed do
            task.wait(5)
            self:_pruneVelocity()
        end
    end)

    self:_refreshCircle()
end

function Instance:Stop()
    if not self.Running then return end
    self.Running = false

    if self._bound and type(RunService.UnbindFromRenderStep) == "function" then
        pcall(function() RunService:UnbindFromRenderStep(self._snapName) end)
        pcall(function() RunService:UnbindFromRenderStep(self._restoreName) end)
    end
    self._bound = false

    for _, connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    self._connections = {}

    self:_restore()
    self._velocity = {}
    self._lock = nil
    self._target = nil
    self._firing, self._holdingRMB = false, false

    if self._circle then
        pcall(function()
            self._circle.Visible = false
            self._circle:Remove()
        end)
        self._circle = nil
    end

    if self._snapline then
        pcall(function()
            self._snapline.Visible = false
            self._snapline:Remove()
        end)
        self._snapline = nil
    end

    self._randomParts = {}
end

function Instance:_syncRunning()
    local shouldRun = self.Options.enabled
    if shouldRun and not self.Running then
        self:Start()
    elseif not shouldRun and self.Running then
        self:Stop()
    end
end

function Instance:IsRunning()
    return self.Running
end

function Instance:GetTarget()
    return self._target
end

function Instance:GetStatus()
    local target = self._target
    local name = ""
    if target and target.model then
        local ok, player = pcall(function() return Players:GetPlayerFromCharacter(target.model) end)
        name = (ok and player and player.Name) or target.model.Name
    end
    return {
        enabled = self.Options.enabled,
        running = self.Running,
        armed = self:WantsSnap(),
        toggled = self.Toggled,
        activation = self.Options.activation,
        target = name,
        gun = self:GetEquippedGun(),
        gunSpeed = self:GetGunSpeed(),
    }
end

function Instance:Unload()
    if self._destroyed then return end
    self:Stop()
    self._destroyed = true
    self._listeners = {}
    self._velocity = {}
    self._randomParts = {}
    self._target = nil
    self._lock = nil
    self._gunCooldownAt = {}
    self._loop = nil
end

------------------------------------------------------------------------
-- singleton helpers so a re-executed script can clean up after itself
------------------------------------------------------------------------

function SilentAim.GetInstance()
    return environment.ARC3USX_SILENT_AIM
end

function SilentAim.DestroyInstance()
    local instance = environment.ARC3USX_SILENT_AIM
    if instance then pcall(function() instance:Unload() end) end
    environment.ARC3USX_SILENT_AIM = nil
end

function SilentAim.newSingleton(config)
    SilentAim.DestroyInstance()
    local instance = SilentAim.new(config)
    environment.ARC3USX_SILENT_AIM = instance
    return instance
end

SilentAim.Notify = notify
SilentAim.Instance = Instance

return SilentAim
