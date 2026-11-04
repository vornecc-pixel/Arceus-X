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

-- ═══════════════════════════════════════════════════════════════
-- AUTO WEAKSPOT
-- Fust marks a resource node's live weakspot with a "WeakSpot" Vector3
-- attribute (nodes are tagged "FustNode" / carry a NodeType attribute).
-- Melee tools report hits through the "Swing" remote as { target, pos }.
-- We redirect that pos to the node's current WeakSpot so every swing lands
-- on the weakspot the instant it appears, and auto-swing a held mining tool.
-- ═══════════════════════════════════════════════════════════════
local okCS, CollectionService = pcall(function() return game:GetService("CollectionService") end)
if not okCS then CollectionService = nil end
local nodeNames = { Tree = true, MetalNode = true, SulfurNode = true, StoneNode = true, Cactus = true, Meteor = true }
local cachedNodes = {}
local SWING_RANGE = 16          -- studs; roughly the game's melee reach
local SWING_INTERVAL = 0.3
local AIM_SPEED = 0.5
local AIM_TOLERANCE = 0.95
local MINING_KEYWORDS = { "pickaxe", "hatchet", "jackhammer", "chainsaw", "rock", "axe", "pick" }

local function isVector3(v)
    if typeof and typeof(v) == "Vector3" then return true end
    return type(v) == "table" and type(v.X) == "number" and type(v.Y) == "number" and type(v.Z) == "number"
end
local function isNode(object)
    if not (object:IsA("Model") or object:IsA("BasePart")) then return false end
    if nodeNames[object.Name] then return true end
    if object:GetAttribute("NodeType") ~= nil then return true end
    if CollectionService and CollectionService:HasTag(object, "FustNode") then return true end
    return false
end
local function weakspotOf(node)
    local v = node:GetAttribute("WeakSpot")
    if isVector3(v) then return v end
    return nil
end
local function nodeAlive(node)
    return node:IsDescendantOf(workspace) and node:GetAttribute("Depleted") ~= true
end
local function registerNode(object)
    if isNode(object) then cachedNodes[object] = true end
end
local function unregisterNode(object)
    cachedNodes[object] = nil
end
connect(workspace.DescendantAdded, registerNode)
connect(workspace.DescendantRemoving, unregisterNode)
if CollectionService and CollectionService.GetInstanceAddedSignal then
    connect(CollectionService:GetInstanceAddedSignal("FustNode"), registerNode)
end
task.spawn(function()
    for i, object in ipairs(workspace:GetDescendants()) do
        if unloaded then return end
        registerNode(object)
        if i % 300 == 0 then task.wait() end
    end
end)

local function isMiningTool(tool)
    if not tool then return false end
    local name = tool.Name:lower()
    for _, keyword in ipairs(MINING_KEYWORDS) do
        if name:find(keyword, 1, true) then return true end
    end
    return false
end
local function nodeFromPart(part)
    local cur = part
    while cur and cur ~= workspace do
        if isNode(cur) then return cur end
        cur = cur.Parent
    end
    return nil
end
local function nodeHitPart(node)
    if node:IsA("BasePart") then return node end
    return node:FindFirstChild("Rock") or node:FindFirstChild("Trunk") or node.PrimaryPart or node:FindFirstChildWhichIsA("BasePart")
end
-- Nearest node that currently has a live weakspot (used to redirect swings).
local function nearestWeakspotNode(rootPos)
    local best, bestSpot, bestD = nil, nil, SWING_RANGE
    for node in pairs(cachedNodes) do
        if nodeAlive(node) then
            local spot = weakspotOf(node)
            if spot then
                local d = (spot - rootPos).Magnitude
                if d < bestD then best, bestSpot, bestD = node, spot, d end
            end
        end
    end
    return best, bestSpot
end
-- Nearest node to auto-swing at; aims at its weakspot if present, else its
-- center (the first hits are what make the weakspot appear).
local function findWeakspotTarget(rootPos)
    local best, bestAim, bestSpot, bestD = nil, nil, nil, SWING_RANGE
    for node in pairs(cachedNodes) do
        if nodeAlive(node) then
            local spot = weakspotOf(node)
            local aim = spot
            if not aim then
                local ok, pivot = pcall(function() return node:GetPivot().Position end)
                if ok then aim = pivot end
            end
            if aim then
                local d = (aim - rootPos).Magnitude
                if d < bestD then best, bestAim, bestSpot, bestD = node, aim, spot, d end
            end
        end
    end
    return best, bestAim, bestSpot
end

-- Swing-remote redirect: rewrite the reported hit position to the live weakspot.
local function rewriteSwing(self, ...)
    if not self or self.Name ~= "Swing" then return nil end
    local character = LocalPlayer.Character
    local tool = character and character:FindFirstChildOfClass("Tool")
    if not isMiningTool(tool) then return nil end
    local args = { ... }
    local payload = type(args[1]) == "table" and args[1] or nil
    if not payload then return nil end
    local node = payload.target and nodeFromPart(payload.target) or nil
    local spot = node and nodeAlive(node) and weakspotOf(node) or nil
    if not spot then
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then node, spot = nearestWeakspotNode(root.Position) end
    end
    if not (node and spot) then return nil end
    payload.pos = spot
    payload.target = payload.target or nodeHitPart(node)
    return payload
end
local oldNamecall, weakspotWrapped
local weakspotHookInstalled, weakspotHookVia = false, nil
local function weakspotNamecall(self, ...)
    if unloaded or not Library.Flags.weakspot_enabled then return oldNamecall(self, ...) end
    local rawMethod = getnamecallmethod and getnamecallmethod() or ""
    if rawMethod:lower() ~= "fireserver" then return oldNamecall(self, ...) end
    local ok, payload = pcall(rewriteSwing, self, ...)
    if ok and payload then
        if setnamecallmethod and rawMethod ~= "" then pcall(setnamecallmethod, rawMethod) end
        return oldNamecall(self, payload)
    end
    return oldNamecall(self, ...)
end
local function installWeakspotHook()
    if weakspotHookInstalled then return true end
    local newc = type(newcclosure) == "function" and newcclosure or function(f) return f end
    weakspotWrapped = newc(weakspotNamecall)
    if type(hookmetamethod) == "function" then
        local ok, old = pcall(hookmetamethod, game, "__namecall", weakspotWrapped)
        if ok and type(old) == "function" then
            oldNamecall, weakspotHookInstalled, weakspotHookVia = old, true, "hookmetamethod"
            return true
        end
    end
    if type(getrawmetatable) == "function" and type(setreadonly) == "function" then
        local ok, old = pcall(function()
            local mt = getrawmetatable(game)
            local prev = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = weakspotWrapped
            setreadonly(mt, true)
            return prev
        end)
        if ok and type(old) == "function" then
            oldNamecall, weakspotHookInstalled, weakspotHookVia = old, true, "rawmetatable"
            return true
        end
    end
    return false
end
local function uninstallWeakspotHook()
    if not weakspotHookInstalled then return end
    -- Only restore the raw metatable if our wrapper is still on top; a
    -- hookmetamethod hook is left in place but becomes inert via `unloaded`.
    pcall(function()
        if weakspotHookVia == "rawmetatable" and type(getrawmetatable) == "function" and type(setreadonly) == "function" then
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            if mt.__namecall == weakspotWrapped then mt.__namecall = oldNamecall end
            setreadonly(mt, true)
        end
    end)
    weakspotHookInstalled = false
end

-- Small green marker shown only while a weakspot is actually present.
local weakspotMarker
local function setWeakspotMarker(pos)
    local cam = workspace.CurrentCamera
    if not pos or not cam then
        if weakspotMarker then weakspotMarker:Destroy(); weakspotMarker = nil end
        return
    end
    if not weakspotMarker then
        weakspotMarker = Instance.new("Part")
        weakspotMarker.Name = "ARC3USX_Weakspot"
        weakspotMarker.Size = Vector3.new(0.6, 0.6, 0.6)
        weakspotMarker.Transparency = 0.3
        weakspotMarker.Color = Color3.fromRGB(80, 255, 140)
        weakspotMarker.Material = Enum.Material.Neon
        weakspotMarker.CanCollide = false
        weakspotMarker.CanQuery = false
        weakspotMarker.CanTouch = false
        weakspotMarker.Anchored = true
    end
    weakspotMarker.Parent = cam
    weakspotMarker.CFrame = CFrame.new(pos)
end

local weakspotElapsed, lastSwing = 0, 0
connect(RunService.Heartbeat, function(dt)
    if unloaded then return end
    weakspotElapsed = weakspotElapsed + dt
    if weakspotElapsed < 0.05 then return end
    weakspotElapsed = 0

    if not Library.Flags.weakspot_enabled then setWeakspotMarker(nil); return end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local tool = character and character:FindFirstChildOfClass("Tool")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not (root and tool and humanoid and humanoid.Health > 0 and isMiningTool(tool))
        or LocalPlayer:GetAttribute("Dead") == true then
        setWeakspotMarker(nil); return
    end

    local node, aim, spot = findWeakspotTarget(root.Position)
    if not node then setWeakspotMarker(nil); return end
    setWeakspotMarker(spot)

    local cam = workspace.CurrentCamera
    if not cam then return end
    local camPos = cam.CFrame.Position
    local offset = aim - camPos
    if offset.Magnitude < 0.1 then return end
    local desired = offset.Unit
    local newLook = cam.CFrame.LookVector:Lerp(desired, AIM_SPEED).Unit
    cam.CFrame = CFrame.lookAt(camPos, camPos + newLook)

    local now = os.clock()
    if now - lastSwing < SWING_INTERVAL then return end
    if cam.CFrame.LookVector:Dot(desired) < AIM_TOLERANCE then return end
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
local WG = Misc:AddGroup("Auto Weakspot", "Left")
WG:AddToggle({ Name = "Enable Auto Weakspot", Flag = "weakspot_enabled", Default = false, Callback = function(on)
    if on and not installWeakspotHook() then
        report("Auto Weakspot: no remote-hook API on this executor; using camera aim only.")
    end
end })
WG:AddLabel("Auto-swings a held mining tool and lands every hit on the node's weakspot the moment it appears.")
if Mix then pcall(function() Mix.AddTab(Library, Window) end) end
pcall(function() Window:AddSettingsTab() end)
local System = Misc:AddGroup("System", "Right")
local function unload()
    if unloaded then return end
    unloaded = true
    for _, connection in ipairs(connections) do connection:Disconnect() end
    if espUnload then pcall(espUnload) end
    uninstallWeakspotHook()
    setWeakspotMarker(nil)
    for tag in pairs(changes) do restore(tag) end
    pcall(function() if bowSpecTable and rawget(bowSpecTable, "BowSpec") == wrappedBowSpec then rawset(bowSpecTable, "BowSpec", originalBowSpec) end end)
    pcall(function() if u16Table and rawget(u16Table, "blocked") == wrappedBlocked then rawset(u16Table, "blocked", originalBlocked) end end)
    if environment.ARC3USX_MAIN_UNLOAD == unload then environment.ARC3USX_MAIN_UNLOAD = nil end
    pcall(function() Library:Unload() end)
end
environment.ARC3USX_MAIN_UNLOAD = unload
Library.OnUnload = unload
System:AddButton({ Name = "Unload Script & Clear Memory", Callback = unload })
