-- ARC3USX.EXE: combat, weakspot and staff controls with the ESP loaded separately.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local environment = type(getgenv) == "function" and getgenv() or _G
local ESP_URL = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/da1d5ede-arceus-x/scripts/esp.lua"
local UI_URL = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/da1d5ede-arceus-x/scripts/ui_bootstrap.lua"

local function report(message)
    warn("[ARC3USX] " .. tostring(message))
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "ARC3USX", Text = tostring(message), Duration = 6 })
    end)
end
if type(environment.ARC3USX_MAIN_UNLOAD) == "function" then pcall(environment.ARC3USX_MAIN_UNLOAD) end
local cancelled, startupLibrary = false, nil
local function cancelStartup()
    cancelled = true
    if startupLibrary then pcall(function() startupLibrary:Unload() end) end
    if environment.ARC3USX_MAIN_UNLOAD == cancelStartup then environment.ARC3USX_MAIN_UNLOAD = nil end
end
environment.ARC3USX_MAIN_UNLOAD = cancelStartup
local ok, ui, failure = pcall(function()
    local bootstrap = assert(loadstring(game:HttpGet(UI_URL)))()
    return bootstrap({
        Name = "ARC3USX.EXE",
        OnLibrary = function(library) startupLibrary = library; library.OnUnload = cancelStartup end,
        IsCancelled = function() return cancelled end,
    })
end)
if not ok or not ui then
    cancelStartup()
    if not cancelled or failure ~= "cancelled" then report("Could not load UI: " .. tostring(failure or ui)) end
    return
end
local Library, Window, Mix = ui.Library, ui.Window, ui.Mix
local Visuals = Window:AddTab("ESP / World")
local Combat = Window:AddTab("Combat")
local Misc = Window:AddTab("Misc")
local unloaded = false
local connections = {}
local function connect(signal, fn)
    local connection = signal:Connect(fn)
    table.insert(connections, connection)
    return connection
end

local espUnload
local loaded, result = pcall(function()
    local source = game:HttpGet(ESP_URL)
    if cancelled then return nil end
    return assert(loadstring(source))({ Library = Library, Window = Window, Visuals = Visuals, Misc = Misc })
end)
if cancelled then
    if type(result) == "function" then pcall(result) end
    return
end
if loaded and type(result) == "function" then
    espUnload = result
else
    report("ESP failed to load: " .. tostring(result))
end

local GunMods = {
    Enabled = false, InstantEquip = false, EquipTime = 0.001, InstantAds = false, AdsTime = 0.001,
    NoSpread = false, Rate = 0.05, ForceAuto = true, Spread = 0, AdsSpread = 0, MoveSpread = 0,
    NoRecoil = false, VisualBloom = 0, RecoilClimb = 0, ShakeMax = 0,
    NoSway = false, Sway = 0, SwayMax = 0, BobWalk = 0, BobIdle = 0, Lean = 0,
    KickPitch = 0, KickBack = 0,
}
local BowMods = { Enabled = false, InstantDraw = false, InstantReload = false, NoCooldown = false, NoRecoil = false, NoDrop = false }
local Universal = { InfiniteAmmo = false, NoAirBlock = false }
local TIMING_KEYS = { "EQUIP_TIME", "HOLSTER_TIME", "AdsTime", "AdsOutTime", "adsTime" }
local activeGunStates, activeBowStates, activeCrossbows, activeAmmoStates = {}, {}, {}, {}
local bowSpecTable, originalBowSpec, wrappedBowSpec
local u16Table, originalBlocked, wrappedBlocked
local newClosure = type(newcclosure) == "function" and newcclosure or function(f) return f end

-- Keep snapshots of settings changed by the scanner so turning them off can restore them.
local NIL = {}
local changes = {}
local function patch(tag, tbl, key, value)
    local tags = changes[tag]
    if not tags then tags = {}; changes[tag] = tags end
    local fields = tags[tbl]
    if not fields then fields = {}; tags[tbl] = fields end
    if fields[key] == nil then
        local old = rawget(tbl, key)
        fields[key] = old == nil and NIL or old
    end
    if type(setreadonly) == "function" then pcall(setreadonly, tbl, false) end
    rawset(tbl, key, value)
end
local function restore(tag)
    local tables = changes[tag]
    if not tables then return end
    for tbl, fields in pairs(tables) do
        pcall(function()
            if type(setreadonly) == "function" then pcall(setreadonly, tbl, false) end
            for key, value in pairs(fields) do
                if value == NIL then rawset(tbl, key, nil) else rawset(tbl, key, value) end
            end
        end)
    end
    changes[tag] = nil
end
local function restoreInactive()
    if not GunMods.Enabled or not GunMods.InstantEquip then restore("equip") end
    if not GunMods.Enabled or not GunMods.InstantAds then restore("ads") end
    if not GunMods.Enabled or not GunMods.NoSpread then restore("spread") end
    if not GunMods.Enabled or not GunMods.NoRecoil then restore("gunRecoil") end
    if not GunMods.Enabled or not GunMods.NoSway then restore("sway") end
    if not BowMods.Enabled or not BowMods.NoCooldown then restore("bowCooldown") end
    if not BowMods.Enabled or not BowMods.NoRecoil then restore("bowRecoil") end
end
local function scanTable(tbl, guns, bows, crossbows, ammo)
    if GunMods.Enabled and (GunMods.InstantEquip or GunMods.InstantAds) then
        for _, key in ipairs(TIMING_KEYS) do
            if rawget(tbl, key) ~= nil then
                local ads = key == "AdsTime" or key == "AdsOutTime" or key == "adsTime"
                if ads and GunMods.InstantAds then patch("ads", tbl, key, GunMods.AdsTime)
                elseif not ads and GunMods.InstantEquip then patch("equip", tbl, key, GunMods.EquipTime) end
            end
        end
    end
    if GunMods.Enabled and GunMods.NoSpread and rawget(tbl, "rate") ~= nil and rawget(tbl, "auto") ~= nil then
        patch("spread", tbl, "rate", GunMods.Rate); patch("spread", tbl, "auto", GunMods.ForceAuto)
        if rawget(tbl, "spread") ~= nil then patch("spread", tbl, "spread", GunMods.Spread) end
        if rawget(tbl, "adsSpread") ~= nil then patch("spread", tbl, "adsSpread", GunMods.AdsSpread) end
        if rawget(tbl, "moveSpread") ~= nil then patch("spread", tbl, "moveSpread", GunMods.MoveSpread) end
    end
    if GunMods.Enabled and GunMods.NoRecoil and rawget(tbl, "VisualBloom") ~= nil then
        for key, value in pairs({ VisualBloom = GunMods.VisualBloom, MOVE_SPREAD = 0, AirSpread = 0, RecoilClimb = GunMods.RecoilClimb, ShakeMax = GunMods.ShakeMax, AdsMoveMult = 1, AimRun = 1 }) do
            patch("gunRecoil", tbl, key, value)
        end
    end
    if GunMods.Enabled and GunMods.NoSway and rawget(tbl, "SWAY_MAX") ~= nil then
        for key, value in pairs({ KICK_PITCH = GunMods.KickPitch, KICK_BACK = GunMods.KickBack, SWAY = GunMods.Sway, SWAY_MAX = GunMods.SwayMax, BOB_WALK = GunMods.BobWalk, BOB_IDLE = GunMods.BobIdle, LEAN = GunMods.Lean }) do
            patch("sway", tbl, key, value)
        end
    end
    if GunMods.Enabled and rawget(tbl, "SpreadPx") ~= nil and rawget(tbl, "equipAt") ~= nil then table.insert(guns, tbl) end
    if BowMods.Enabled and type(rawget(tbl, "DRAW_TIME")) == "number" and type(rawget(tbl, "SHOT_GAP")) == "number" and type(rawget(tbl, "MIN_DRAW")) == "number" and type(rawget(tbl, "SPEED_BASE")) == "number" and type(rawget(tbl, "SPEED_CHARGE")) == "number" and BowMods.NoCooldown then
        patch("bowCooldown", tbl, "SHOT_GAP", 0); patch("bowCooldown", tbl, "REDRAW_GAP", 0); patch("bowCooldown", tbl, "MIN_DRAW", 0)
    end
    if BowMods.Enabled and type(rawget(tbl, "drawStart")) == "number" and type(rawget(tbl, "lastShot")) == "number" and type(rawget(tbl, "drawing")) == "boolean" and type(rawget(tbl, "shotId")) == "number" and type(rawget(tbl, "pendingSpent")) == "number" then table.insert(bows, tbl) end
    if BowMods.Enabled and type(rawget(tbl, "reloadLen")) == "function" and type(rawget(tbl, "xbow")) == "function" and type(rawget(tbl, "drawTime")) == "function" and type(rawget(tbl, "loaded")) == "boolean" and type(rawget(tbl, "startReload")) == "function" then table.insert(crossbows, tbl) end
    if BowMods.Enabled and BowMods.NoRecoil and type(rawget(tbl, "TREMBLE_MAX")) == "number" and type(rawget(tbl, "TREMBLE_AFTER")) == "number" and type(rawget(tbl, "SWAY")) == "number" and type(rawget(tbl, "SWAY_MAX")) == "number" and type(rawget(tbl, "BOB_WALK")) == "number" and type(rawget(tbl, "BOB_IDLE")) == "number" then
        for key, value in pairs({ TREMBLE_MAX = 0, TREMBLE_AFTER = 9999, SWAY = 0, SWAY_MAX = 0, BOB_WALK = 0, BOB_IDLE = 0 }) do patch("bowRecoil", tbl, key, value) end
    end
    if Universal.InfiniteAmmo and type(rawget(tbl, "counts")) == "table" and type(rawget(tbl, "pendingSpent")) == "number" and type(rawget(tbl, "lastSpentAt")) == "number" then table.insert(ammo, tbl) end
end
local function installBowSpec(objects)
    if bowSpecTable then return end
    for _, value in pairs(objects) do
        if type(value) == "table" and type(rawget(value, "BowSpec")) == "function" and type(rawget(value, "Get")) == "function" and type(rawget(value, "BOW_DRAW")) == "table" then
            if type(setreadonly) == "function" then pcall(setreadonly, value, false) end
            local old = rawget(value, "BowSpec")
            local wrapper = function(def)
                local spec = old(def)
                if not unloaded and BowMods.Enabled and BowMods.NoDrop and type(spec) == "table" then
                    rawset(spec, "gravity", 0); rawset(spec, "speedBase", 600); rawset(spec, "speedCharge", 600)
                end
                return spec
            end
            rawset(value, "BowSpec", wrapper)
            bowSpecTable, originalBowSpec, wrappedBowSpec = value, old, wrapper
            return
        end
    end
end
local function installAirBlock(objects)
    if u16Table or not debug or type(debug.getinfo) ~= "function" or type(debug.getupvalue) ~= "function" then return end
    for _, fn in pairs(objects) do
        if type(fn) == "function" then
            local success, info = pcall(debug.getinfo, fn)
            if success and type(info) == "table" and type(info.nups) == "number" then
                for i = 1, info.nups do
                    local okUp, name, value = pcall(debug.getupvalue, fn, i)
                    if okUp and name == "u16" and type(value) == "table" and rawget(value, "blocked") == fn then
                        if type(setreadonly) == "function" then pcall(setreadonly, value, false) end
                        local wrapper = newClosure(function(now) if not unloaded and Universal.NoAirBlock then return false end return fn(now) end)
                        rawset(value, "blocked", wrapper)
                        u16Table, originalBlocked, wrappedBlocked = value, fn, wrapper
                        return
                    end
                end
            end
        end
    end
end

task.spawn(function()
    local warned = false
    while not unloaded do
        restoreInactive()
        local need = GunMods.Enabled or BowMods.Enabled or Universal.InfiniteAmmo or Universal.NoAirBlock
        if need and type(getgc) == "function" then
            local success, objects = pcall(getgc, true)
            if success and type(objects) == "table" then
                local guns, bows, crossbows, ammo = {}, {}, {}, {}
                local count = 0
                for _, tbl in pairs(objects) do
                    if unloaded then return end
                    if type(tbl) == "table" then
                        count = count + 1
                        pcall(scanTable, tbl, guns, bows, crossbows, ammo)
                        if count % 1000 == 0 then task.wait() end
                    end
                end
                if BowMods.Enabled and BowMods.NoDrop then pcall(installBowSpec, objects) end
                if Universal.NoAirBlock then pcall(installAirBlock, objects) end
                if not unloaded then activeGunStates, activeBowStates, activeCrossbows, activeAmmoStates = guns, bows, crossbows, ammo end
            elseif not warned then warned = true; report("getgc scan failed: " .. tostring(objects)) end
        elseif need and not warned then
            warned = true
            report("Combat mods require executor getgc support.")
        end
        task.wait(1)
    end
end)

local function updateCombat()
    if unloaded then return end
    if GunMods.Enabled then
        for _, state in ipairs(activeGunStates) do pcall(function()
            if GunMods.InstantEquip and state.equipAt and state.equipAt ~= -math.huge then state.equipAt = -math.huge end
            if GunMods.NoSpread then state.SpreadPx = 0 end
            if GunMods.NoRecoil then
                state.kick = 0; state.kickV = 0; state.kickPitch = 0; state.kickRoll = 0; state.recoil = 0; state.recoilYaw = 0
                state.RecoilPend = 0; state.RecoilYawPend = 0; state.shakeUntil = 0; state.shakeStrength = 0
            end
        end) end
    end
    if BowMods.Enabled then
        for _, state in ipairs(activeBowStates) do pcall(function()
            if BowMods.InstantDraw then state.drawStart = os.clock() - 10 end
            if BowMods.NoCooldown then state.lastShot = -math.huge end
            if BowMods.NoRecoil then state.shakeUntil = 0; state.shakeStrength = 0 end
        end) end
        if BowMods.InstantReload then for _, cb in ipairs(activeCrossbows) do pcall(function() cb.loaded = true; cb.reloadAt = nil end) end end
    end
    if Universal.InfiniteAmmo then
        for _, state in ipairs(activeAmmoStates) do pcall(function()
            state.pendingSpent = 0
            local counts = state.counts
            if type(counts) == "table" then
                for key in pairs(counts) do counts[key] = 9999 end
                if type(state.bowDef) == "table" and type(state.bowDef.ammo) == "string" then counts[state.bowDef.ammo] = 9999 end
            end
        end) end
    end
end
connect(RunService.Heartbeat, updateCombat)

local nodeNames = { Tree = true, MetalNode = true, SulfurNode = true, StoneNode = true, Cactus = true, Meteor = true }
local cachedNodes = {}
local weakspotPart
local function isNode(object) return nodeNames[object.Name] and (object:IsA("Model") or object:IsA("BasePart")) end
connect(workspace.DescendantAdded, function(object) if isNode(object) then cachedNodes[object] = true end end)
connect(workspace.DescendantRemoving, function(object) cachedNodes[object] = nil end)
task.spawn(function()
    for i, object in ipairs(workspace:GetDescendants()) do
        if unloaded then return end
        if isNode(object) and object:IsDescendantOf(workspace) then cachedNodes[object] = true end
        if i % 300 == 0 then task.wait() end
    end
end)
local weakspotElapsed = 0
connect(RunService.Heartbeat, function(dt)
    if unloaded then return end
    weakspotElapsed = weakspotElapsed + dt
    if weakspotElapsed < 0.2 then return end
    weakspotElapsed = 0
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local tool = character and character:FindFirstChildOfClass("Tool")
    local flags = Library.Flags
    local name = tool and tool.Name:lower() or ""
    local valid = root and tool and (name:find("pickaxe") or name:find("hatchet") or name:find("rock") or name:find("jackhammer") or name:find("chainsaw"))
    if not flags.weakspot_enabled or not valid then
        if weakspotPart then weakspotPart:Destroy(); weakspotPart = nil end
        return
    end
    local best, bestDistance = nil, (tonumber(flags.weakspot_max_dist) or 30) / 0.28
    for object in pairs(cachedNodes) do
        if object:IsDescendantOf(workspace) then
            local position = object:GetPivot().Position
            local distance = (position - root.Position).Magnitude
            if distance < bestDistance then best, bestDistance = position, distance end
        end
    end
    if best and workspace.CurrentCamera then
        if not weakspotPart then
            weakspotPart = Instance.new("Part")
            weakspotPart.Name = "FustWeakSpot"; weakspotPart.Size = Vector3.new(1, 1, 1)
            weakspotPart.Transparency = 1; weakspotPart.CanCollide = false; weakspotPart.Anchored = true
        end
        weakspotPart.Parent = workspace.CurrentCamera
        weakspotPart.CFrame = CFrame.new(best)
    elseif weakspotPart then weakspotPart:Destroy(); weakspotPart = nil end
end)

local function toggle(group, name, flag, state, field, default)
    group:AddToggle({ Name = name, Flag = flag, Default = default or false, Callback = function(on) state[field] = on end })
end
local function slider(group, name, flag, state, field, min, max, default)
    group:AddSlider({ Name = name, Flag = flag, Min = min, Max = max, Default = default, Rounding = 3, Callback = function(value) state[field] = value end })
end
-- Silent aim only handles the known Fust Shoot payload; unknown calls pass through.
-- The dispatcher is reused on reinjection, so we never stack our own hooks.
local Silent = { active = true, remote = nil, items = nil }
local silentStatus
local function silentStatusText(message)
    if not unloaded and silentStatus then silentStatus:SetText("Status: " .. message) end
end
local lastSilentWarning, lastSilentWarningAt = "", -math.huge
local function silentWarn(message)
    local now = os.clock()
    if message ~= lastSilentWarning or now - lastSilentWarningAt >= 1 then
        lastSilentWarning, lastSilentWarningAt = message, now
        warn("[SilentAim] " .. message)
    end
end
local function finite(n)
    return type(n) == "number" and n == n and n ~= math.huge and n ~= -math.huge
end
local function targetPart(character)
    for _, name in ipairs({ "Head", "UpperTorso", "Torso", "HumanoidRootPart" }) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
end
local function closestTarget(camera, flags)
    local center = camera.ViewportSize
    local best, bestDistance = nil, tonumber(flags.silent_fov) or 250
    local rayParams
    if flags.silent_visibility then
        rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = LocalPlayer.Character and { LocalPlayer.Character } or {}
    end
    local function consider(character)
        local hum = character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local part = targetPart(character)
        if not part then return end
        local screen, onScreen = camera:WorldToViewportPoint(part.Position)
        if not onScreen or screen.Z <= 0 then return end
        local dx, dy = screen.X - center.X / 2, screen.Y - center.Y / 2
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance >= bestDistance then return end
        if rayParams then
            local origin = camera.CFrame.Position
            local result = workspace:Raycast(origin, part.Position - origin, rayParams)
            if result and not result.Instance:IsDescendantOf(character) then return end
        end
        bestDistance = distance
        best = { part = part, velocity = part.AssemblyLinearVelocity }
    end
    if flags.silent_players then
        for _, player in ipairs(Players:GetPlayers()) do
            local teammate = player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team
            if player ~= LocalPlayer and (not flags.silent_ignore_team or not teammate) and player.Character then
                consider(player.Character)
            end
        end
    end
    if flags.silent_npcs then
        local npcs = workspace:FindFirstChild("Npcs")
        if npcs then
            for _, character in ipairs(npcs:GetChildren()) do
                if character:IsA("Model") then consider(character) end
            end
        end
    end
    return best
end
local function weaponSpec(data)
    local character = LocalPlayer.Character
    local tool = character and character:FindFirstChildOfClass("Tool")
    local itemId = tool and tool:GetAttribute("ItemId")
    if type(itemId) ~= "string" or type(Silent.items.Get) ~= "function" then return end
    local ok, def = pcall(Silent.items.Get, itemId)
    if not ok or type(def) ~= "table" then return end
    local bow = def.weapon == "bow" or def.kind == "bow"
        or (def.weapon == nil and def.kind == nil and itemId:lower():find("bow") ~= nil)
    local gun = def.weapon == "gun" or def.kind == "gun"
    if not bow and not gun then return end
    if gun then bow = false end
    local base = finite(def.speedBase) and def.speedBase or 95
    local charge = finite(def.speedCharge) and def.speedCharge or 125
    local gravity = finite(def.gravity) and math.abs(def.gravity) or 50
    local chargeFraction = finite(data.charge) and math.clamp(data.charge, 0, 1) or 1
    local speed = base + charge
    if bow then
        local draw = Silent.items.BOW_DRAW
        local success, scale = false, nil
        if type(draw) == "table" and type(draw.scale) == "function" then success, scale = pcall(draw.scale, chargeFraction) end
        if success and finite(scale) then speed = speed * math.clamp(scale, 0, 1)
        else speed = speed * (math.clamp(chargeFraction, 0.15, 1) * 125 + 95) / 220 end
    end
    if finite(data.gravity) then gravity = math.abs(data.gravity)
    elseif typeof(data.gravity) == "Vector3" and finite(data.gravity.Y) then gravity = math.abs(data.gravity.Y) end
    if finite(data.speed) then speed = data.speed end
    if not finite(speed) or speed <= 0 or not finite(gravity) then return end
    return { speed = speed, gravity = gravity, bow = bow, name = tostring(def.name or itemId) }
end
local function inBallisticRange(origin, target, spec)
    if spec.gravity <= 0 then return true end
    local delta = target - origin
    local horiz2 = delta.X * delta.X + delta.Z * delta.Z
    local v2, g = spec.speed * spec.speed, spec.gravity
    return v2 * v2 - g * (g * horiz2 + 2 * delta.Y * v2) >= 0
end
-- Find the earliest positive intercept. Upward compensation opposes downward gravity.
local function intercept(origin, position, velocity, speed, gravity)
    local delta = position - origin
    local maxTime = math.min(15, math.max(0.25, delta.Magnitude / speed * 3, gravity > 0 and 2.1 * speed / gravity or 0))
    local function offset(t)
        return delta + velocity * t + Vector3.new(0, 0.5 * gravity * t * t, 0)
    end
    local function residual(t)
        local v = offset(t)
        return v.X * v.X + v.Y * v.Y + v.Z * v.Z - speed * speed * t * t
    end
    local low, high = 0, nil
    for i = 1, 240 do
        local t = maxTime * i / 240
        if residual(t) <= 0 then high = t; break end
        low = t
    end
    if not high then return nil end
    for _ = 1, 28 do
        local mid = (low + high) / 2
        if residual(mid) <= 0 then high = mid else low = mid end
    end
    local result = offset(high)
    if result.Magnitude <= 1e-4 then return nil end
    return result.Unit
end
local function rewriteShot(remote, data)
    local flags = Library.Flags
    if unloaded or not Silent.active or not flags.silent_enabled or remote ~= Silent.remote or type(data) ~= "table" or data.draw then return end
    local origin = data.origin or data.position or data.pos
    local directionKey = data.dir and "dir" or (data.direction and "direction") or (data.lookVector and "lookVector")
    if typeof(origin) ~= "Vector3" or not directionKey or typeof(data[directionKey]) ~= "Vector3" then return end
    local camera = workspace.CurrentCamera
    if not camera then return end
    local spec = weaponSpec(data)
    if not spec then return end
    local target = closestTarget(camera, flags)
    if not target then return end
    local targetPosition = target.part.Position
    local inRange = inBallisticRange(origin, targetPosition, spec)
    if flags.silent_range and not inRange then
        silentWarn("Out of range: " .. spec.name .. "; shot left unchanged")
        return
    end
    if spec.bow and inRange and spec.gravity > 0 then
        local levelRange = spec.speed * spec.speed / spec.gravity
        if (targetPosition - origin).Magnitude > levelRange * 0.95 then
            silentWarn("Bow near its approximate level-ground maximum range: " .. spec.name)
        end
    end
    local aim
    if flags.silent_prediction then
        local velocity = typeof(target.velocity) == "Vector3" and target.velocity or Vector3.new(0, 0, 0)
        aim = intercept(origin, targetPosition, velocity, spec.speed, spec.gravity)
        if not aim then
            silentWarn("No reliable intercept for " .. spec.name .. "; shot left unchanged")
            return
        end
    else
        local delta = targetPosition - origin
        if delta.Magnitude > 1e-4 then aim = delta.Unit end
    end
    if not aim then return end
    local copy
    if type(table.clone) == "function" then copy = table.clone(data)
    else
        copy = {}
        for key, value in pairs(data) do copy[key] = value end
    end
    copy[directionKey] = aim
    return copy
end
local function installSilentHook()
    local dispatcher = environment.ARC3USX_SILENT_AIM_HOOK
    if type(dispatcher) == "table" and dispatcher.version == 1 and dispatcher.installed then
        dispatcher.handler, dispatcher.remote = rewriteShot, Silent.remote
        return true
    end
    if type(hookmetamethod) ~= "function" or type(getnamecallmethod) ~= "function" or type(checkcaller) ~= "function" then
        return false, "Executor lacks namecall hook support"
    end
    dispatcher = { version = 1, handler = rewriteShot, remote = Silent.remote }
    local old
    local wrapper = function(remote, ...)
        local method = getnamecallmethod()
        if dispatcher.handler and remote == dispatcher.remote and (method == "FireServer" or method == "fireServer") and not checkcaller() then
            local args = table.pack(...)
            local ok, replacement = pcall(dispatcher.handler, remote, args[1])
            if ok and replacement then args[1] = replacement
            elseif not ok then silentWarn("Shot handler error: " .. tostring(replacement)) end
            return old(remote, table.unpack(args, 1, args.n))
        end
        return old(remote, ...)
    end
    local ok, result = pcall(function()
        return hookmetamethod(game, "__namecall", newClosure(wrapper))
    end)
    if not ok or type(result) ~= "function" then return false, "Could not install namecall hook: " .. tostring(result) end
    old = result
    dispatcher.installed = true
    environment.ARC3USX_SILENT_AIM_HOOK = dispatcher
    return true
end
local function stopSilent()
    Silent.active = false
    local dispatcher = environment.ARC3USX_SILENT_AIM_HOOK
    if type(dispatcher) == "table" and dispatcher.handler == rewriteShot then dispatcher.handler, dispatcher.remote = nil, nil end
end

local SA = Combat:AddGroup("Silent Aim", "Left")
SA:AddToggle({ Name = "Enable Silent Aim", Flag = "silent_enabled", Default = false, Bind = true, BindDefault = Enum.KeyCode.F })
SA:AddSlider({ Name = "FOV (screen pixels)", Flag = "silent_fov", Min = 10, Max = 1000, Default = 250 })
SA:AddToggle({ Name = "Prediction + drop compensation", Flag = "silent_prediction", Default = true })
SA:AddToggle({ Name = "Visibility check", Flag = "silent_visibility", Default = false })
SA:AddToggle({ Name = "Ignore teammates", Flag = "silent_ignore_team", Default = true })
SA:AddToggle({ Name = "Enforce projectile range", Flag = "silent_range", Default = true })
SA:AddToggle({ Name = "Target players", Flag = "silent_players", Default = true })
SA:AddToggle({ Name = "Target NPCs", Flag = "silent_npcs", Default = true })
silentStatus = SA:AddLabel("Status: off")
task.spawn(function()
    local lastStatus = ""
    while not unloaded do
        local status = "off"
        if Library.Flags.silent_enabled then
            local fust = game:GetService("ReplicatedStorage"):FindFirstChild("Fust")
            local remotes = fust and fust:FindFirstChild("Remotes")
            local remote = remotes and remotes:FindFirstChild("Shoot")
            local itemsModule = fust and fust:FindFirstChild("Items")
            if not remote or not remote:IsA("RemoteEvent") or not itemsModule then
                Silent.remote = nil
                status = "waiting for Fust Shoot / Items"
            else
                if Silent.itemsModule ~= itemsModule then
                    local ok, items = pcall(require, itemsModule)
                    if unloaded then return end
                    if ok and type(items) == "table" and type(items.Get) == "function" then Silent.items, Silent.itemsModule = items, itemsModule
                    else Silent.items, Silent.itemsModule = nil, nil end
                end
                if not Silent.items then Silent.remote = nil; status = "could not load Fust Items"
                else
                    Silent.remote = remote
                    local ok, reason = installSilentHook()
                    status = ok and "ready" or reason
                end
            end
        end
        if status ~= lastStatus then
            silentStatusText(status)
            if status ~= "off" and status ~= "ready" then silentWarn(status) end
            lastStatus = status
        end
        task.wait(1)
    end
end)

local GM = Combat:AddGroup("Gun Master", "Left")
toggle(GM, "Enable Gun Mods", "gunmods_enabled", GunMods, "Enabled")
local TG = Combat:AddGroup("Gun Timing", "Left")
toggle(TG, "Instant Equip", "gunmods_inst_equip", GunMods, "InstantEquip")
slider(TG, "Equip Time", "gunmods_equip_time", GunMods, "EquipTime", 0.001, 1, 0.001)
toggle(TG, "Instant ADS", "gunmods_inst_ads", GunMods, "InstantAds")
slider(TG, "ADS Time", "gunmods_ads_time", GunMods, "AdsTime", 0.001, 1, 0.001)
local FRG = Combat:AddGroup("Fire Rate & Spread", "Left")
toggle(FRG, "No Spread + Custom Rate", "gunmods_nospread", GunMods, "NoSpread")
slider(FRG, "Fire Rate", "gunmods_rate", GunMods, "Rate", 0.01, 1, 0.05)
toggle(FRG, "Force Auto", "gunmods_force_auto", GunMods, "ForceAuto", true)
slider(FRG, "Spread", "gunmods_spread", GunMods, "Spread", 0, 1, 0)
slider(FRG, "ADS Spread", "gunmods_ads_spread", GunMods, "AdsSpread", 0, 1, 0)
slider(FRG, "Move Spread", "gunmods_move_spread", GunMods, "MoveSpread", 0, 1, 0)
local RG = Combat:AddGroup("Recoil & Bloom", "Right")
toggle(RG, "No Recoil", "gunmods_norecoil", GunMods, "NoRecoil")
slider(RG, "Visual Bloom", "gunmods_bloom", GunMods, "VisualBloom", 0, 1, 0)
slider(RG, "Recoil Climb", "gunmods_climb", GunMods, "RecoilClimb", 0, 1, 0)
slider(RG, "Shake Max", "gunmods_shakemax", GunMods, "ShakeMax", 0, 1, 0)
local SG = Combat:AddGroup("Sway", "Right")
toggle(SG, "No Sway", "gunmods_nosway", GunMods, "NoSway")
slider(SG, "Sway", "gunmods_sway", GunMods, "Sway", 0, 1, 0)
slider(SG, "Sway Max", "gunmods_swaymax", GunMods, "SwayMax", 0, 1, 0)
slider(SG, "Bob Walk", "gunmods_bobwalk", GunMods, "BobWalk", 0, 1, 0)
slider(SG, "Bob Idle", "gunmods_bobidle", GunMods, "BobIdle", 0, 1, 0)
slider(SG, "Lean", "gunmods_lean", GunMods, "Lean", 0, 1, 0)
local KG = Combat:AddGroup("Kick", "Right")
slider(KG, "Kick Pitch", "gunmods_kickpitch", GunMods, "KickPitch", 0, 1, 0)
slider(KG, "Kick Back", "gunmods_kickback", GunMods, "KickBack", 0, 1, 0)
local BG = Combat:AddGroup("Bow Mods", "Left")
toggle(BG, "Enable Bow Mods", "bowmods_enabled", BowMods, "Enabled")
toggle(BG, "Instant Draw (max charge)", "bowmods_instdraw", BowMods, "InstantDraw")
toggle(BG, "Instant Reload (crossbow)", "bowmods_instreload", BowMods, "InstantReload")
toggle(BG, "No Shot Cooldown", "bowmods_nocd", BowMods, "NoCooldown")
toggle(BG, "No Recoil / No Tremble", "bowmods_norecoil", BowMods, "NoRecoil")
toggle(BG, "No Drop (every bow)", "bowmods_nodrop", BowMods, "NoDrop")
local UG = Combat:AddGroup("Universal Bypass", "Right")
toggle(UG, "Infinite Ammo (every weapon)", "universal_ammo", Universal, "InfiniteAmmo")
toggle(UG, "No Air Block (fire while jumping)", "universal_noair", Universal, "NoAirBlock")
local WG = Misc:AddGroup("Auto Weakspot", "Left")
WG:AddToggle({ Name = "Enable Auto Weakspot", Flag = "weakspot_enabled", Default = false })
WG:AddSlider({ Name = "Max Distance", Flag = "weakspot_max_dist", Min = 5, Max = 100, Default = 30, Suffix = "m" })
WG:AddLabel("Creates an invisible marker at the nearest node; it does not redirect hits.")
if Mix then pcall(function() Mix.AddTab(Library, Window) end) end
pcall(function() Window:AddSettingsTab() end)
local System = Misc:AddGroup("System", "Right")
local function unload()
    if unloaded then return end
    unloaded = true
    stopSilent()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    if espUnload then pcall(espUnload) end
    if weakspotPart then weakspotPart:Destroy(); weakspotPart = nil end
    for tag in pairs(changes) do restore(tag) end
    pcall(function() if bowSpecTable and rawget(bowSpecTable, "BowSpec") == wrappedBowSpec then rawset(bowSpecTable, "BowSpec", originalBowSpec) end end)
    pcall(function() if u16Table and rawget(u16Table, "blocked") == wrappedBlocked then rawset(u16Table, "blocked", originalBlocked) end end)
    if environment.ARC3USX_MAIN_UNLOAD == unload then environment.ARC3USX_MAIN_UNLOAD = nil end
    pcall(function() Library:Unload() end)
end
environment.ARC3USX_MAIN_UNLOAD = unload
Library.OnUnload = unload
System:AddButton({ Name = "Unload Script & Clear Memory", Callback = unload })
