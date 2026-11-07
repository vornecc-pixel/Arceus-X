-- ARC3USX gun mods: no recoil, no crosshair bloom and payload spread zeroing.
-- Features only — this file builds no UI.
--
--   local GunMods = assert(loadstring(game:HttpGet(URL)))()
--   local mods = GunMods.new({ enabled = true })
--   mods:Set("noBloom", false)
--   print(mods:GetStatus().hookInstalled)
--   mods:Unload()
--
-- No recoil keeps the real mouse aim and cancels the camera kick the game adds:
-- FustGuns multiplies camera.CFrame by CFrame.Angles(...) at Camera + 1, so this
-- binds at Camera + 500, notices that the pitch/yaw no longer match the last mouse
-- driven aim and restores it. Aim is only accepted (and the base updated) while the
-- mouse actually moved, otherwise every camera change looks like recoil.
--
-- The spread hook is the only part that needs executor functions
-- (getrawmetatable / setreadonly / getnamecallmethod). It installs ONE wrapper on the
-- RemoteEvent namecall metatable, keys the work by method name, zeroes spread-ish
-- number fields in the payload in place, and always forwards the original call. The
-- pasted version wrapped the shared metatable once per remote, which chained wrappers
-- and could never be undone.

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local environment = type(getgenv) == "function" and getgenv() or _G

local function report(message)
    warn("[ARC3USX Mods] " .. tostring(message))
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "Mods", Text = tostring(message), Duration = 5 })
    end)
end

local SPREAD_FIELDS = {
    "spread", "Spread", "spreadMult", "spreadMul", "SpreadMult", "spreadMultiplier",
    "bloom", "Bloom", "bloomAmount", "bloomMult",
}

local DEFAULTS = {
    enabled = false,

    -- recoil
    noRecoil = true,
    recoilGrace = 0.025,      -- seconds; mouse moved this recently -> accept the camera
    recoilPitchEps = 0.0008,  -- radians
    recoilYawEps = 0.0008,    -- radians

    -- visuals
    noBloom = true,
    bloomRate = 0.1,          -- seconds between tick sweeps
    bloomPrefix = "Tick",     -- FustGather crosshair tick frames start with this

    -- payload
    zeroSpread = false,
    verbose = false,
}

local RANGES = {
    recoilGrace = { 0, 0.5 },
    recoilPitchEps = { 0, 0.05 },
    recoilYawEps = { 0, 0.05 },
    bloomRate = { 0.05, 1 },
}

local cameraPriority = 200
if Enum.RenderPriority and Enum.RenderPriority.Camera and type(Enum.RenderPriority.Camera.Value) == "number" then
    cameraPriority = Enum.RenderPriority.Camera.Value
end
local RECOIL_PRIORITY = cameraPriority + 500

local GunMods = {}
GunMods.SpreadFields = SPREAD_FIELDS

local function copyDefaults()
    local copy = {}
    for key, value in pairs(DEFAULTS) do copy[key] = value end
    return copy
end
GunMods.Defaults = copyDefaults()

local function wrapAngle(angle)
    if angle > math.pi then return angle - 2 * math.pi end
    if angle < -math.pi then return angle + 2 * math.pi end
    return angle
end
GunMods.WrapAngle = wrapAngle

-- Zero every spread/bloom number field on a payload table, in place.
local function zeroFields(value, depth, seen)
    if type(value) ~= "table" then return false end
    seen = seen or {}
    if seen[value] then return false end
    seen[value] = true

    local changed = false
    for _, field in ipairs(SPREAD_FIELDS) do
        local current = rawget(value, field)
        if type(current) == "number" and current ~= 0 then
            rawset(value, field, 0)
            changed = true
        end
    end

    if depth < 2 then
        for _, nested in pairs(value) do
            if type(nested) == "table" then
                if zeroFields(nested, depth + 1, seen) then changed = true end
            end
        end
    end

    return changed
end

function GunMods.ZeroSpreadFields(value)
    return zeroFields(value, 0, nil)
end

local Object = {}
Object.__index = Object

function GunMods.new(config)
    config = type(config) == "table" and config or {}

    local self = setmetatable({}, Object)
    self.Options = copyDefaults()
    for key, value in pairs(config) do
        if DEFAULTS[key] ~= nil then self.Options[key] = value end
    end

    self.Running = false
    self.RecoilActive = false
    self.HookInstalled = false
    self.HookError = nil
    self.RecoilUndo = 0
    self.BloomHidden = 0

    self._listeners = {}
    self._connections = {}
    self._hidden = {}
    self._targets = {}
    self._remoteFolder = nil
    self._hook = nil
    self._bloomToken = 0
    self._lastMouseAt = 0
    self._basePitch = nil
    self._baseYaw = nil
    self._destroyed = false

    local tag = tostring(math.random(100000, 999999))
    self._bindName = "ARC3USX_NoRecoil_" .. tag

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
    elseif type(default) == "string" then
        value = tostring(value)
    end

    if self.Options[key] == value then return true end
    self.Options[key] = value

    if key == "enabled" then
        if value then self:Start() else self:Stop() end
    elseif key == "noRecoil" then
        self.RecoilActive = self.Running and value
        if not value then self:_resetBase() end
    elseif key == "noBloom" then
        self:_syncBloom()
    elseif key == "zeroSpread" then
        if self.Running and value then
            self:_installHook()
        elseif not value then
            self:_removeHook()
        end
    elseif key == "bloomRate" or key == "bloomPrefix" then
        self:_syncBloom()
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
-- no recoil
------------------------------------------------------------------------

function Object:_camera()
    local camera = workspace.CurrentCamera
    if not camera or not camera.Parent or not camera.CFrame then return nil end
    return camera
end

function Object:_resetBase()
    local camera = self:_camera()
    if not camera then
        self._basePitch, self._baseYaw = nil, nil
        return
    end
    local look = camera.CFrame.LookVector
    if not look then return end
    self._basePitch = math.asin(math.clamp(look.Y, -1, 1))
    self._baseYaw = math.atan2(-look.X, -look.Z)
end

function Object:_onMouseMoved(input)
    if not input then return end
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseMovement or inputType == Enum.UserInputType.Touch then
        self._lastMouseAt = os.clock()
    end
end

function Object:_recoilStep()
    if not self.Running or not self.Options.enabled or not self.Options.noRecoil then return end

    local camera = self:_camera()
    if not camera then return end

    local look = camera.CFrame.LookVector
    if not look then return end

    local pitch = math.asin(math.clamp(look.Y, -1, 1))
    local yaw = math.atan2(-look.X, -look.Z)

    if (os.clock() - self._lastMouseAt) < self.Options.recoilGrace then
        self._basePitch, self._baseYaw = pitch, yaw
        return
    end

    if self._basePitch == nil or self._baseYaw == nil then
        self._basePitch, self._baseYaw = pitch, yaw
        return
    end

    local deltaPitch = pitch - self._basePitch
    local deltaYaw = wrapAngle(yaw - self._baseYaw)
    if math.abs(deltaPitch) <= self.Options.recoilPitchEps
        and math.abs(deltaYaw) <= self.Options.recoilYawEps then
        return
    end

    local position = camera.CFrame.Position
    local ok = pcall(function()
        camera.CFrame = CFrame.new(position) * CFrame.Angles(self._basePitch, self._baseYaw, 0)
    end)
    if ok then
        self.RecoilUndo = self.RecoilUndo + 1
        if self.Options.verbose then
            print(string.format("[ARC3USX Mods] recoil cancelled pitch %.5f yaw %.5f", deltaPitch, deltaYaw))
        end
    end
end

------------------------------------------------------------------------
-- no bloom
------------------------------------------------------------------------

function Object:_playerGui()
    local player = Players.LocalPlayer
    if not player then return nil end
    local ok, gui = pcall(function() return player:FindFirstChild("PlayerGui") end)
    return ok and gui or nil
end

function Object:_hideTicks()
    local gui = self:_playerGui()
    if not gui then return 0 end
    local gather = gui:FindFirstChild("FustGather")
    if not gather then return 0 end

    local prefix = self.Options.bloomPrefix
    local count = 0
    local ok, descendants = pcall(function() return gather:GetDescendants() end)
    if not ok or not descendants then return 0 end

    for _, instance in ipairs(descendants) do
        local isFrame = false
        pcall(function() isFrame = instance:IsA("Frame") end)
        if isFrame and type(instance.Name) == "string" and string.sub(instance.Name, 1, #prefix) == prefix then
            if self._hidden[instance] == nil then
                local visible = true
                pcall(function() visible = instance.Visible end)
                self._hidden[instance] = visible
            end
            pcall(function() instance.Visible = false end)
            count = count + 1
        end
    end

    self.BloomHidden = count
    return count
end

function Object:_restoreTicks()
    for instance, visible in pairs(self._hidden) do
        pcall(function() instance.Visible = visible ~= false end)
    end
    self._hidden = {}
    self.BloomHidden = 0
end

function Object:_syncBloom()
    self._bloomToken = self._bloomToken + 1
    local token = self._bloomToken

    if not self.Running or not self.Options.enabled or not self.Options.noBloom then
        self:_restoreTicks()
        return
    end

    task.spawn(function()
        while self.Running and self.Options.enabled and self.Options.noBloom and self._bloomToken == token do
            self:_hideTicks()
            task.wait(self.Options.bloomRate)
        end
    end)
end

------------------------------------------------------------------------
-- spread hook
------------------------------------------------------------------------

function Object:_collectRemotes()
    local folder = ReplicatedStorage:FindFirstChild("Fust")
    self._remoteFolder = folder
    self._targets = {}

    local sample = nil
    if not folder then return nil end

    local ok, descendants = pcall(function() return folder:GetDescendants() end)
    if not ok or not descendants then return nil end

    for _, instance in ipairs(descendants) do
        local isRemote = false
        pcall(function()
            isRemote = instance:IsA("RemoteEvent")
                or (Enum.UnreliableRemoteEvent ~= nil and instance:IsA("UnreliableRemoteEvent"))
        end)
        if isRemote then
            self._targets[instance] = true
            sample = sample or instance
        end
    end

    return sample
end

function Object:_installHook()
    if self._hook then return true end

    local getRawMetatable = getrawmetatable
    local setReadOnly = setreadonly
    local getNamecall = getnamecallmethod
    if type(getRawMetatable) ~= "function" or type(setReadOnly) ~= "function" or type(getNamecall) ~= "function" then
        self.HookInstalled = false
        self.HookError = "executor hook functions unavailable"
        return false, self.HookError
    end

    local sample = self:_collectRemotes()
    if not sample then
        self.HookInstalled = false
        self.HookError = "no Fust remotes found"
        return false, self.HookError
    end

    local okMeta, metatable = pcall(getRawMetatable, sample)
    if not okMeta or type(metatable) ~= "table" or type(metatable.__namecall) ~= "function" then
        self.HookInstalled = false
        self.HookError = "namecall metatable unavailable"
        return false, self.HookError
    end

    local original = metatable.__namecall
    local targets = self._targets
    local folder = self._remoteFolder
    local hookSelf = self

    local wrapper = function(instance, ...)
        -- The varargs are copied out first: '...' is not visible inside the pcall closure.
        local count = select("#", ...)
        local arguments = { ... }
        pcall(function()
            if getNamecall() ~= "FireServer" then return end
            local isTarget = targets[instance] == true
            if not isTarget and folder then
                local okDescendant, descendant = pcall(function() return instance:IsDescendantOf(folder) end)
                isTarget = okDescendant and descendant == true
            end
            if not isTarget then return end

            for index = 1, count do
                local argument = arguments[index]
                local changed = GunMods.ZeroSpreadFields(argument)
                if changed and hookSelf.Options.verbose then
                    print("[ARC3USX Mods] zeroed spread fields on " .. tostring(instance) .. " argument " .. index)
                end
            end
        end)
        return original(instance, ...)
    end

    local newClosure = type(newcclosure) == "function" and newcclosure or function(fn) return fn end
    local wrapped = newClosure(wrapper)

    pcall(setReadOnly, metatable, false)
    local installed, err = pcall(function() metatable.__namecall = wrapped end)
    pcall(setReadOnly, metatable, true)

    if not installed then
        self.HookInstalled = false
        self.HookError = tostring(err)
        return false, self.HookError
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
-- lifecycle
------------------------------------------------------------------------

function Object:Start()
    if self._destroyed or self.Running then return end
    self.Running = true

    if UserInputService.InputChanged then
        table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
            self:_onMouseMoved(input)
        end))
    end

    if type(RunService.BindToRenderStep) == "function" then
        RunService:BindToRenderStep(self._bindName, RECOIL_PRIORITY, function() self:_recoilStep() end)
        self._bound = true
    elseif RunService.RenderStepped then
        table.insert(self._connections, RunService.RenderStepped:Connect(function() self:_recoilStep() end))
    end

    self.RecoilActive = self.Options.noRecoil == true
    self:_resetBase()
    self:_syncBloom()

    if self.Options.zeroSpread then self:_installHook() end
end

function Object:Stop()
    if not self.Running then return end
    self.Running = false

    if self._bound and type(RunService.UnbindFromRenderStep) == "function" then
        pcall(function() RunService:UnbindFromRenderStep(self._bindName) end)
    end
    self._bound = false

    for _, connection in ipairs(self._connections) do
        pcall(function() connection:Disconnect() end)
    end
    self._connections = {}

    self:_removeHook()
    self._bloomToken = self._bloomToken + 1
    self:_restoreTicks()
    self.RecoilActive = false
    self._basePitch, self._baseYaw = nil, nil
end

function Object:IsRunning()
    return self.Running
end

function Object:GetStatus()
    return {
        enabled = self.Options.enabled,
        running = self.Running,
        noRecoil = self.Options.noRecoil == true,
        recoilActive = self.RecoilActive,
        recoilUndos = self.RecoilUndo,
        noBloom = self.Options.noBloom == true,
        bloomHidden = self.BloomHidden,
        zeroSpread = self.Options.zeroSpread == true,
        hookInstalled = self.HookInstalled,
        hookError = self.HookError,
    }
end

function Object:Unload()
    if self._destroyed then return end
    self:Stop()
    self._destroyed = true
    self._listeners = {}
    self._targets = {}
    self._hidden = {}
    self._hook = nil
end

------------------------------------------------------------------------
-- singleton helpers for re-executed scripts
------------------------------------------------------------------------

function GunMods.GetInstance()
    return environment.ARC3USX_GUN_MODS
end

function GunMods.DestroyInstance()
    local instance = environment.ARC3USX_GUN_MODS
    if instance then pcall(function() instance:Unload() end) end
    environment.ARC3USX_GUN_MODS = nil
end

function GunMods.newSingleton(config)
    GunMods.DestroyInstance()
    local instance = GunMods.new(config)
    environment.ARC3USX_GUN_MODS = instance
    return instance
end

GunMods.Object = Object
GunMods.Report = report

return GunMods
