-- ARC3USX.EXE: combat, weakspot and staff controls with the ESP loaded separately.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local environment = type(getgenv) == "function" and getgenv() or _G
local ROOT = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/d7cd4b6e-arceus-x/"
local ESP_URL = ROOT .. "scripts/esp.lua"
local UI_URL = ROOT .. "scripts/ui_bootstrap.lua"
local SILENT_AIM_URL = ROOT .. "scripts/silent_aim.lua"
local WORLD_ESP_URL = ROOT .. "scripts/world_esp.lua"
local GUN_MODS_URL = ROOT .. "scripts/gun_mods.lua"

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
local Chams = Window:AddTab("Chams ESP")
local ModsTab = Window:AddTab("Mods")
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

-- Silent aim features (scripts/silent_aim.lua) hold no UI: the controls are added to
-- the Combat tab below. The standalone Octohook menu is scripts/silent_aim_ui.lua and
-- is not loaded here, so both share the same feature module.
local silentAim
local silentAimLoaded, silentAimModule = pcall(function()
    local source = game:HttpGet(SILENT_AIM_URL)
    if cancelled then return nil end
    return assert(loadstring(source))()
end)
if cancelled then
    return
end
if silentAimLoaded and type(silentAimModule) == "table" and type(silentAimModule.new) == "function" then
    local created, instance = pcall(silentAimModule.new, { enabled = false })
    if created and instance then
        silentAim = instance
        environment.ARC3USX_MAIN_SILENT_AIM = silentAim
    else
        report("Silent aim failed to start: " .. tostring(instance))
    end
else
    report("Silent aim module unavailable: " .. tostring(silentAimModule))
end

-- Chams ESP features (scripts/world_esp.lua) also hold no UI: the controls live in the
-- "Chams ESP" tab below, while scripts/world_esp_ui.lua is the standalone Octohook menu.
local worldEsp
local worldEspLoaded, worldEspModule = pcall(function()
    local source = game:HttpGet(WORLD_ESP_URL)
    if cancelled then return nil end
    return assert(loadstring(source))()
end)
if cancelled then
    return
end
if worldEspLoaded and type(worldEspModule) == "table" and type(worldEspModule.new) == "function" then
    local created, instance = pcall(worldEspModule.new, { enabled = false })
    if created and instance then
        worldEsp = instance
        environment.ARC3USX_MAIN_WORLD_ESP = worldEsp
    else
        report("Chams ESP failed to start: " .. tostring(instance))
    end
else
    report("Chams ESP module unavailable: " .. tostring(worldEspModule))
end

-- Gun mods features (scripts/gun_mods.lua) also hold no UI: the controls live in the
-- "Mods" tab below, while scripts/gun_mods_ui.lua is the standalone Octohook menu.
local gunMods
local gunModsLoaded, gunModsModule = pcall(function()
    local source = game:HttpGet(GUN_MODS_URL)
    if cancelled then return nil end
    return assert(loadstring(source))()
end)
if cancelled then
    return
end
if gunModsLoaded and type(gunModsModule) == "table" and type(gunModsModule.new) == "function" then
    local created, instance = pcall(gunModsModule.new, { enabled = false })
    if created and instance then
        gunMods = instance
        environment.ARC3USX_MAIN_GUN_MODS = gunMods
    else
        report("Gun mods failed to start: " .. tostring(instance))
    end
else
    report("Gun mods module unavailable: " .. tostring(gunModsModule))
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

-- ═══════════════════════════════════════════════════════════════
-- AUTO WEAKSPOT (real aim + swing)
-- ═══════════════════════════════════════════════════════════════
local nodeNames = { Tree = true, MetalNode = true, SulfurNode = true, StoneNode = true, Cactus = true, Meteor = true }
local cachedNodes = {}
local weakspotMarkers = {}
local WEAKSPOT_NAMES = {
    "Weakspot", "WeakSpot", "WeakPoint", "Weakpoint",
    "CriticalSpot", "CriticalPart", "Critical", "CritSpot",
    "Hitpoint", "HitPoint", "HitSpot",
    "Mark", "MarkSpot",
    "Bonus", "BonusSpot",
}
local SWING_RANGE = 25
local SWING_INTERVAL = 0.3
local AIM_SPEED = 0.4
local AIM_TOLERANCE = 0.97
local MINING_KEYWORDS = { "pickaxe", "hatchet", "jackhammer", "chainsaw" }

local function isNode(object)
    return nodeNames[object.Name] and (object:IsA("Model") or object:IsA("BasePart"))
end
local function registerNode(object)
    if isNode(object) then cachedNodes[object] = true end
end
local function unregisterNode(object)
    cachedNodes[object] = nil
    local marker = weakspotMarkers[object]
    if marker then pcall(function() marker:Destroy() end); weakspotMarkers[object] = nil end
end
connect(workspace.DescendantAdded, registerNode)
connect(workspace.DescendantRemoving, unregisterNode)
task.spawn(function()
    for i, object in ipairs(workspace:GetDescendants()) do
        if unloaded then return end
        registerNode(object)
        if i % 300 == 0 then task.wait() end
    end
end)

local function findWeakspot(model)
    for _, name in ipairs(WEAKSPOT_NAMES) do
        local child = model:FindFirstChild(name, true)
        if child and child:IsA("BasePart") then return child.Position end
    end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("BasePart") then
            local lower = desc.Name:lower()
            if lower:find("weak") or lower:find("crit") or lower:find("hitpoint") or lower:find("markspot") or lower:find("bonus") then
                return desc.Position
            end
        end
    end
    for _, name in ipairs({ "Weakspot", "CriticalSpot", "Hitpoint", "Mark", "WeakPoint" }) do
        local att = model:FindFirstChild(name, true)
        if att and att:IsA("Attachment") then return att.WorldPosition end
    end
    return nil
end
local function findNearestNode(rootPos)
    local best, bestPos, bestDist = nil, nil, math.huge
    for node in pairs(cachedNodes) do
        if node:IsDescendantOf(workspace) then
            local ok, pos = pcall(function() return node:GetPivot().Position end)
            if ok and pos then
                local d = (pos - rootPos).Magnitude
                if d < bestDist then best, bestPos, bestDist = node, pos, d end
            end
        end
    end
    return best, bestPos, bestDist
end
local function isMiningTool(tool)
    if not tool then return false end
    local name = tool.Name:lower()
    for _, keyword in ipairs(MINING_KEYWORDS) do
        if name:find(keyword, 1, true) then return true end
    end
    return false
end
local function cleanupMarkers(keepNode)
    for node, marker in pairs(weakspotMarkers) do
        if node ~= keepNode then pcall(function() marker:Destroy() end); weakspotMarkers[node] = nil end
    end
end
local function updateMarker(node, pos)
    local marker = weakspotMarkers[node]
    if not marker then
        marker = Instance.new("Part")
        marker.Name = "ARC3USX_Weakspot"
        marker.Size = Vector3.new(1, 1, 1)
        marker.Transparency = 0.4
        marker.Color = Color3.fromRGB(255, 80, 80)
        marker.Material = Enum.Material.Neon
        marker.CanCollide = false
        marker.CanQuery = false
        marker.CanTouch = false
        marker.Anchored = true
        marker.Parent = workspace.CurrentCamera
        weakspotMarkers[node] = marker
    end
    marker.CFrame = CFrame.new(pos)
end

local weakspotElapsed = 0
local lastSwing = 0
connect(RunService.Heartbeat, function(dt)
    if unloaded then return end
    weakspotElapsed = weakspotElapsed + dt
    if weakspotElapsed < 0.05 then return end
    weakspotElapsed = 0

    local flags = Library.Flags
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local tool = character and character:FindFirstChildOfClass("Tool")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    local shouldAct = flags.weakspot_enabled
        and root and tool and humanoid and humanoid.Health > 0
        and LocalPlayer:GetAttribute("Dead") ~= true
        and isMiningTool(tool)

    if not shouldAct then cleanupMarkers(nil); return end

    local nearest, nearestPos, nearestDist = findNearestNode(root.Position)
    if not nearest or nearestDist > SWING_RANGE then cleanupMarkers(nil); return end

    local weakspotPos = findWeakspot(nearest) or nearestPos
    cleanupMarkers(nearest)
    updateMarker(nearest, weakspotPos)

    local cam = workspace.CurrentCamera
    if not cam then return end

    local camPos = cam.CFrame.Position
    local desired = (weakspotPos - camPos).Unit
    local current = cam.CFrame.LookVector
    local newLook = current:Lerp(desired, AIM_SPEED).Unit
    cam.CFrame = CFrame.lookAt(camPos, camPos + newLook)

    local now = os.clock()
    if now - lastSwing < SWING_INTERVAL then return end

    local camLook = cam.CFrame.LookVector
    local toTarget = (weakspotPos - camPos).Unit
    if camLook:Dot(toTarget) < AIM_TOLERANCE then return end

    lastSwing = now
    pcall(function() tool:Activate() end)
    if type(mouse1click) == "function" then pcall(mouse1click) end
end)

local function toggle(group, name, flag, state, field, default)
    group:AddToggle({ Name = name, Flag = flag, Default = default or false, Callback = function(on) state[field] = on end })
end
local function slider(group, name, flag, state, field, min, max, default)
    group:AddSlider({ Name = name, Flag = flag, Min = min, Max = max, Default = default, Rounding = 3, Callback = function(value) state[field] = value end })
end
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

-- Silent aim controls: the same feature module that scripts/silent_aim_ui.lua drives.
if silentAim then
    local function saToggle(group, name, flag, key, default)
        group:AddToggle({
            Name = name, Flag = flag, Default = default or false,
            Callback = function(on) silentAim:Set(key, on) end,
        })
    end
    local function saSlider(group, name, flag, key, min, max, default, rounding, suffix)
        group:AddSlider({
            Name = name, Flag = flag, Min = min, Max = max, Default = default,
            Rounding = rounding or 0, Suffix = suffix,
            Callback = function(value) silentAim:Set(key, value) end,
        })
    end
    local ACTIVATION = { ["Always"] = "Always", ["Hold (RMB)"] = "Hold", ["Toggle (Key)"] = "Toggle" }

    local SAG = Combat:AddGroup("Silent Aim", "Left")
    SAG:AddToggle({
        Name = "Enable Silent Aim", Flag = "sa_enabled", Default = false,
        Bind = true, BindDefault = Enum.KeyCode.V,
        Callback = function(on) silentAim:Set("enabled", on) end,
    })
    SAG:AddDropdown({
        Name = "Activation", Flag = "sa_activation",
        Options = { "Always", "Hold (RMB)", "Toggle (Key)" }, Default = "Always",
        Callback = function(option) silentAim:Set("activation", ACTIVATION[option] or option) end,
    })
    saToggle(SAG, "Only While Firing", "sa_shot_only", "shotOnly", true)
    saToggle(SAG, "Prediction", "sa_prediction", "prediction", true)
    SAG:AddDropdown({
        Name = "Target Bone", Flag = "sa_bone",
        Options = { "Head", "HumanoidRootPart", "Random" }, Default = "Head",
        Callback = function(option) silentAim:Set("bone", option) end,
    })
    saSlider(SAG, "Random Re-roll", "sa_random_part", "randomPartLifetime", 0.1, 5, 1.5, 1, "s")
    saSlider(SAG, "Hit Chance", "sa_hit_chance", "hitChance", 0, 100, 100, 0, "%")
    saSlider(SAG, "FOV Radius", "sa_fov", "fov", 0, 800, 220, 0, "px")
    saSlider(SAG, "Distance Limit", "sa_distance", "distance", 0, 1000, 0, 0)

    local SAF = Combat:AddGroup("Silent Aim Filters", "Right")
    saToggle(SAF, "Wall Check", "sa_wall_check", "wallCheck", false)
    saToggle(SAF, "Team Check", "sa_team_check", "teamCheck", true)
    saToggle(SAF, "Target NPCs", "sa_target_npcs", "targetNpcs", false)
    saSlider(SAF, "Bullet Speed Override", "sa_gun_speed", "gunSpeed", 0, 6000, 0, 0)
    saSlider(SAF, "Snap Cooldown", "sa_cooldown", "cooldown", 0, 1, 0, 2, "s")
    saToggle(SAF, "Show FOV Circle", "sa_show_fov", "showFov", true)
    SAF:AddColor({
        Name = "FOV Color", Flag = "sa_fov_color", Default = Color3.fromRGB(255, 80, 80),
        Callback = function(color) silentAim:Set("fovColor", color) end,
    })
    local SAS = Combat:AddGroup("Silent Aim Snapline", "Right")
    saToggle(SAS, "Show Snapline", "sa_snapline", "showSnapline", true)
    SAS:AddColor({
        Name = "Snapline Color", Flag = "sa_snapline_color", Default = Color3.fromRGB(255, 255, 255),
        Callback = function(color) silentAim:Set("snaplineColor", color) end,
    })
    saSlider(SAS, "Snapline Thickness", "sa_snapline_thickness", "snaplineThickness", 1, 5, 1, 0, "px")
    saSlider(SAS, "Snapline Transparency", "sa_snapline_transparency", "snaplineTransparency", 0, 100, 0, 0, "%")
    SAS:AddLabel("Line from the FOV centre to the target that will be hit.")
    SAF:AddLabel("Snaps the camera only for the shot frame; no game tool is hooked.")
end

-- Chams ESP controls: the same feature module that scripts/world_esp_ui.lua drives.
if worldEsp then
    local function weToggle(group, name, flag, key, default)
        group:AddToggle({
            Name = name, Flag = flag, Default = default or false,
            Callback = function(on) worldEsp:Set(key, on) end,
        })
    end
    local function weSlider(group, name, flag, key, min, max, default, rounding, suffix)
        group:AddSlider({
            Name = name, Flag = flag, Min = min, Max = max, Default = default,
            Rounding = rounding or 0, Suffix = suffix,
            Callback = function(value) worldEsp:Set(key, value) end,
        })
    end
    local BOX_MODES = { ["Corners"] = "corners", ["Full"] = "full" }

    local WEG = Chams:AddGroup("Chams ESP", "Left")
    WEG:AddToggle({
        Name = "Enable Chams ESP", Flag = "we_enabled", Default = false,
        Bind = true, BindDefault = Enum.KeyCode.B,
        Callback = function(on) worldEsp:Set("enabled", on) end,
    })
    weToggle(WEG, "Players", "we_players", "players", true)
    weToggle(WEG, "NPCs", "we_npcs", "npcs", true)
    weToggle(WEG, "Resource Nodes", "we_nodes", "nodes", true)
    weToggle(WEG, "Box Visible Check", "we_box_visible", "boxVisibleCheck", true)
    weToggle(WEG, "Chams (highlight)", "we_chams", "chams", true)
    weToggle(WEG, "Occluded Chams (visible check)", "we_chams_visible", "chamsVisibleCheck", true)
    weSlider(WEG, "Cham Fill Transparency", "we_chams_fill", "chamsFillTransparency", 0, 1, 0.6, 2, "")
    weSlider(WEG, "Cham Outline Transparency", "we_chams_outline", "chamsOutlineTransparency", 0, 1, 0, 2, "")
    weToggle(WEG, "Skeleton", "we_skeleton", "skeleton", true)
    weToggle(WEG, "Health Bar", "we_health", "healthBar", true)
    weToggle(WEG, "Name", "we_name", "name", true)
    weToggle(WEG, "Distance", "we_distance", "distance", true)
    weToggle(WEG, "Weapon", "we_weapon", "weapon", true)

    local WEB = Chams:AddGroup("Chams Box", "Right")
    WEB:AddDropdown({
        Name = "Box Mode", Flag = "we_box_mode", Options = { "Corners", "Full" }, Default = "Corners",
        Callback = function(option) worldEsp:Set("boxMode", BOX_MODES[option] or option) end,
    })
    weSlider(WEB, "Corner Size", "we_corner", "cornerFraction", 0.05, 1, 0.25, 2, "x")
    weSlider(WEB, "Box Thickness", "we_box_thickness", "boxThickness", 1, 4, 1, 0, "px")
    weSlider(WEB, "Skeleton Thickness", "we_skel_thickness", "skelThickness", 1, 4, 1, 0, "px")
    weSlider(WEB, "Text Size", "we_text_size", "textSize", 8, 24, 14, 0, "px")
    weSlider(WEB, "Node Dot Size", "we_node_dot_size", "nodeDotSize", 1, 16, 5, 0, "px")

    local WEF = Chams:AddGroup("Chams Filters", "Right")
    weSlider(WEF, "Max Distance", "we_max_distance", "maxDistance", 0, 2000, 0, 0, " (0 = off)")
    weSlider(WEF, "Update Rate", "we_rate", "updateRate", 0, 60, 0, 0, " Hz")
    WEF:AddTextbox({
        Name = "NPC Names", Flag = "we_npc_names", Default = worldEsp:Get("npcWhitelist"),
        Placeholder = "Guard, Soldier",
        Callback = function(text) worldEsp:Set("npcWhitelist", text) end,
    })
    WEF:AddTextbox({
        Name = "Node Names", Flag = "we_node_names", Default = worldEsp:Get("nodeWhitelist"),
        Placeholder = "MetalNode, Tree",
        Callback = function(text) worldEsp:Set("nodeWhitelist", text) end,
    })

    local WEC = Chams:AddGroup("Chams Colors", "Left")
    local COLOR_ROWS = {
        { "Player Box (visible)", "we_player_box", "playerBoxColor" },
        { "Player Box (occluded)", "we_player_box_occ", "playerBoxOccludedColor" },
        { "Player Chams (visible)", "we_player_cham", "playerChamColor" },
        { "Player Chams (occluded)", "we_player_cham_occ", "playerChamOccludedColor" },
        { "Player Name", "we_player_name", "playerNameColor" },
        { "NPC Box (visible)", "we_npc_box", "npcBoxColor" },
        { "NPC Box (occluded)", "we_npc_box_occ", "npcBoxOccludedColor" },
        { "NPC Chams (visible)", "we_npc_cham", "npcChamColor" },
        { "NPC Chams (occluded)", "we_npc_cham_occ", "npcChamOccludedColor" },
        { "NPC Name", "we_npc_name", "npcNameColor" },
        { "Node Dot", "we_node_dot", "nodeDotColor" },
        { "Node Name / Distance", "we_node_name", "nodeNameColor" },
    }
    for _, row in ipairs(COLOR_ROWS) do
        local key = row[3]
        WEC:AddColor({
            Name = row[1], Flag = row[2], Default = worldEsp:Get(key),
            Callback = function(color) worldEsp:Set(key, color) end,
        })
    end
    WEC:AddLabel("Colors update live. Nodes are a dot, name and distance only.")
end

-- Gun mods controls: the same feature module that scripts/gun_mods_ui.lua drives.
if gunMods then
    local function gmToggle(group, name, flag, key, default, tooltip)
        group:AddToggle({
            Name = name, Flag = flag, Default = default or false,
            Callback = function(on) gunMods:Set(key, on) end,
        })
    end
    local function gmSlider(group, name, flag, key, min, max, default, rounding, suffix)
        group:AddSlider({
            Name = name, Flag = flag, Min = min, Max = max, Default = default,
            Rounding = rounding or 0, Suffix = suffix,
            Callback = function(value) gunMods:Set(key, value) end,
        })
    end

    local GMG = ModsTab:AddGroup("Gun Mods", "Left")
    GMG:AddToggle({
        Name = "Enable Gun Mods", Flag = "gm_enabled", Default = false,
        Bind = true, BindDefault = Enum.KeyCode.N,
        Callback = function(on) gunMods:Set("enabled", on) end,
    })
    gmToggle(GMG, "No Recoil", "gm_no_recoil", "noRecoil", true)
    gmSlider(GMG, "Mouse Grace", "gm_recoil_grace", "recoilGrace", 0, 0.5, 0.025, 3, "s")
    gmSlider(GMG, "Pitch Tolerance", "gm_recoil_pitch", "recoilPitchEps", 0, 0.05, 0.0008, 4, "rad")
    gmSlider(GMG, "Yaw Tolerance", "gm_recoil_yaw", "recoilYawEps", 0, 0.05, 0.0008, 4, "rad")
    GMG:AddLabel("Cancels the camera kick added after your real aim input.")

    local GMB = ModsTab:AddGroup("Crosshair", "Right")
    gmToggle(GMB, "No Bloom", "gm_no_bloom", "noBloom", true)
    gmSlider(GMB, "Sweep Rate", "gm_bloom_rate", "bloomRate", 0.05, 1, 0.1, 2, "s")
    GMB:AddLabel("Hides the FustGather spread ticks; server spread is unchanged.")

    local GMS = ModsTab:AddGroup("Spread Payload", "Right")
    gmToggle(GMS, "Zero Spread Fields", "gm_zero_spread", "zeroSpread", false)
    GMS:AddLabel("Needs executor hook functions; zeroes spread/bloom numbers in Fust remotes.")
end
local WG = Misc:AddGroup("Auto Weakspot", "Left")
WG:AddToggle({ Name = "Enable Auto Weakspot", Flag = "weakspot_enabled", Default = false })
WG:AddLabel("Aims and auto-swings at the nearest node weakspot.")
if Mix then pcall(function() Mix.AddTab(Library, Window) end) end
pcall(function() Window:AddSettingsTab() end)
local System = Misc:AddGroup("System", "Right")
local function unload()
    if unloaded then return end
    unloaded = true
    for _, connection in ipairs(connections) do connection:Disconnect() end
    if espUnload then pcall(espUnload) end
    if silentAim then pcall(function() silentAim:Unload() end) end
    if environment.ARC3USX_MAIN_SILENT_AIM == silentAim then environment.ARC3USX_MAIN_SILENT_AIM = nil end
    if worldEsp then pcall(function() worldEsp:Unload() end) end
    if environment.ARC3USX_MAIN_WORLD_ESP == worldEsp then environment.ARC3USX_MAIN_WORLD_ESP = nil end
    if gunMods then pcall(function() gunMods:Unload() end) end
    if environment.ARC3USX_MAIN_GUN_MODS == gunMods then environment.ARC3USX_MAIN_GUN_MODS = nil end
    for _, marker in pairs(weakspotMarkers) do pcall(function() marker:Destroy() end) end
    weakspotMarkers = {}
    for tag in pairs(changes) do restore(tag) end
    pcall(function() if bowSpecTable and rawget(bowSpecTable, "BowSpec") == wrappedBowSpec then rawset(bowSpecTable, "BowSpec", originalBowSpec) end end)
    pcall(function() if u16Table and rawget(u16Table, "blocked") == wrappedBlocked then rawset(u16Table, "blocked", originalBlocked) end end)
    if environment.ARC3USX_MAIN_UNLOAD == unload then environment.ARC3USX_MAIN_UNLOAD = nil end
    pcall(function() Library:Unload() end)
end
environment.ARC3USX_MAIN_UNLOAD = unload
Library.OnUnload = unload
System:AddButton({ Name = "Unload Script & Clear Memory", Callback = unload })
