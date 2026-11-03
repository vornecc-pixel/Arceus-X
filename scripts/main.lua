-- ARC3USX.EXE: combat, weakspot and staff controls with the ESP loaded separately.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local environment = type(getgenv) == "function" and getgenv() or _G
local ESP_URL = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/arena/da1d5ede-arceus-x/scripts/esp.lua"
local LIBRARY_URL = "https://raw.githubusercontent.com/vornecc-pixel/Arceus-X/refs/heads/main/ARC3USX.lua"

local function report(message)
    warn("[ARC3USX] " .. tostring(message))
    pcall(function()
        StarterGui:SetCore("SendNotification", { Title = "ARC3USX", Text = tostring(message), Duration = 6 })
    end)
end
if type(environment.ARC3USX_MAIN_UNLOAD) == "function" then pcall(environment.ARC3USX_MAIN_UNLOAD) end
local ok, Library = pcall(function() return assert(loadstring(game:HttpGet(LIBRARY_URL)))() end)
if not ok or type(Library) ~= "table" then report("Could not load UI library: " .. tostring(Library)); return end

local Window = Library:CreateWindow({ Name = "ARC3USX.EXE", Size = Vector2.new(750, 600), Intro = false, Theme = "Purple", MenuKey = Enum.KeyCode.RightShift })
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
    return assert(loadstring(source))({ Library = Library, Window = Window, Visuals = Visuals, Misc = Misc })
end)
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
pcall(function() Window:AddSettingsTab() end)
local System = Misc:AddGroup("System", "Right")
local function unload()
    if unloaded then return end
    unloaded = true
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
System:AddButton({ Name = "Unload Script & Clear Memory", Callback = unload })
