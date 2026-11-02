-- ═══════════════════════════════════════════════════════════════
-- ESP MODULE — WA Universal Logic converted for Atlanta UI
-- ═══════════════════════════════════════════════════════════════

local esp = { players = {}, connections = {} }

local Workspace    = cloneref(game:GetService("Workspace"))
local RunService   = cloneref(game:GetService("RunService"))
local Players      = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local LocalPlayer  = Players.LocalPlayer

local camera = Workspace.CurrentCamera
local raw_flags
local flags

local Drawings = { ESP = {}, Skeleton = {} }
local Highlights = {}

-- SAFE COLOR PARSER: Prevents crashes if the library hasn't loaded the color yet
local function get_color(key, default)
    local v = raw_flags[key]
    if type(v) == "table" and v.Color then return v.Color end
    if type(v) == "Color3" then return v end
    return default or Color3.fromRGB(255, 255, 255)
end

local function build_flags_proxy()
    flags = setmetatable({}, {
        __index = function(_, key)
            local v = raw_flags[key]
            if v == nil then
                if key == "MaxDistance" then return 1000 end
                if key == "BoxStyle" then return "Corner" end
                if key == "TracerOrigin" then return "Bottom" end
                if key == "BoxThickness" then return 1 end
                if key == "RefreshRate" then return 144 end
                return false
            end
            if typeof(v) == "Color3" then return {Color = v, Alpha = 1} end
            return v
        end
    })
end

local function GetTracerOrigin()
    local origin = flags["TracerOrigin"] or "Bottom"
    if origin == "Bottom" then
        return Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
    elseif origin == "Top" then
        return Vector2.new(camera.ViewportSize.X/2, 0)
    elseif origin == "Mouse" then
        return UserInputService:GetMouseLocation()
    else
        return Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local box = {
        TopLeft = Drawing.new("Line"), TopRight = Drawing.new("Line"),
        BottomLeft = Drawing.new("Line"), BottomRight = Drawing.new("Line"),
        Left = Drawing.new("Line"), Right = Drawing.new("Line"),
        Top = Drawing.new("Line"), Bottom = Drawing.new("Line")
    }
    
    for _, line in pairs(box) do line.Visible = false end
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    
    local healthBar = {
        Outline = Drawing.new("Square"),
        Fill = Drawing.new("Square"),
        Text = Drawing.new("Text")
    }
    for _, obj in pairs(healthBar) do obj.Visible = false end
    healthBar.Text.Center = true
    healthBar.Text.Outline = true
    healthBar.Fill.Filled = true
    
    local info = {
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text")
    }
    for _, text in pairs(info) do
        text.Visible = false
        text.Center = true
        text.Outline = true
    end
    
    local highlight = Instance.new("Highlight")
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    Highlights[player] = highlight
    
    local skeleton = {}
    for i = 1, 15 do
        local line = Drawing.new("Line")
        line.Visible = false
        table.insert(skeleton, line)
    end
    Drawings.Skeleton[player] = skeleton
    
    Drawings.ESP[player] = {
        Box = box,
        Tracer = tracer,
        HealthBar = healthBar,
        Info = info
    }
end

local function RemoveESP(player)
    local esp_data = Drawings.ESP[player]
    if esp_data then
        for _, obj in pairs(esp_data.Box) do obj:Remove() end
        esp_data.Tracer:Remove()
        for _, obj in pairs(esp_data.HealthBar) do obj:Remove() end
        for _, obj in pairs(esp_data.Info) do obj:Remove() end
        Drawings.ESP[player] = nil
    end
    
    local highlight = Highlights[player]
    if highlight then
        highlight:Destroy()
        Highlights[player] = nil
    end
    
    local skeleton = Drawings.Skeleton[player]
    if skeleton then
        for _, line in pairs(skeleton) do line:Remove() end
        Drawings.Skeleton[player] = nil
    end
end

local function UpdateESP(player)
    local esp_data = Drawings.ESP[player]
    if not esp_data then return end
    
    local function hide_all()
        for _, obj in pairs(esp_data.Box) do obj.Visible = false end
        esp_data.Tracer.Visible = false
        for _, obj in pairs(esp_data.HealthBar) do obj.Visible = false end
        for _, obj in pairs(esp_data.Info) do obj.Visible = false end
        local skeleton = Drawings.Skeleton[player]
        if skeleton then for _, line in pairs(skeleton) do line.Visible = false end end
        local hl = Highlights[player]
        if hl then hl.Enabled = false end
    end
    
    if not flags["Enabled"] then return hide_all() end
    
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    if not rootPart or not humanoid or humanoid.Health <= 0 then return hide_all() end
    
    local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
    local distance = (rootPart.Position - camera.CFrame.Position).Magnitude
    
    if not onScreen or distance > (flags["MaxDistance"] or 1000) then return hide_all() end
    if flags["TeamCheck"] and player.Team == LocalPlayer.Team and not flags["ShowTeam"] then return hide_all() end
    
    -- Base color
    local color = Color3.fromRGB(255, 25, 25)
    if player.Team == LocalPlayer.Team then color = Color3.fromRGB(25, 255, 25) end
    
    -- Rainbow mode logic
    if flags["RainbowEnabled"] then
        color = Color3.fromHSV(tick() * 1 % 1, 1, 1)
    else
        if player.Team == LocalPlayer.Team then color = get_color("AllyColor", color) else color = get_color("EnemyColor", color) end
    end
    
    local size = character:GetExtentsSize()
    local cf = rootPart.CFrame
    
    local top, top_onscreen = camera:WorldToViewportPoint((cf * CFrame.new(0, size.Y/2, 0)).Position)
    local bottom, bottom_onscreen = camera:WorldToViewportPoint((cf * CFrame.new(0, -size.Y/2, 0)).Position)
    
    if not top_onscreen or not bottom_onscreen then return hide_all() end
    
    local screenSize = bottom.Y - top.Y
    local boxWidth = screenSize * 0.65
    local boxPosition = Vector2.new(top.X - boxWidth/2, top.Y)
    local boxSize = Vector2.new(boxWidth, screenSize)
    
    for _, obj in pairs(esp_data.Box) do obj.Visible = false end
    
    -- BOXES
    if flags["BoxESP"] then
        local style = flags["BoxStyle"] or "Corner"
        if style == "ThreeD" then
            local front = {
                TL = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2)).Position),
                TR = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2)).Position),
                BL = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2)).Position),
                BR = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2)).Position)
            }
            local back = {
                TL = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2)).Position),
                TR = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)).Position),
                BL = camera:WorldToViewportPoint((cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2)).Position),
                BR = camera:WorldToViewportPoint((cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2)).Position)
            }
            local function toV2(v3) return Vector2.new(v3.X, v3.Y) end
            
            esp_data.Box.TopLeft.From = toV2(front.TL); esp_data.Box.TopLeft.To = toV2(front.TR); esp_data.Box.TopLeft.Visible = true
            esp_data.Box.TopRight.From = toV2(front.TR); esp_data.Box.TopRight.To = toV2(front.BR); esp_data.Box.TopRight.Visible = true
            esp_data.Box.BottomLeft.From = toV2(front.BL); esp_data.Box.BottomLeft.To = toV2(front.BR); esp_data.Box.BottomLeft.Visible = true
            esp_data.Box.BottomRight.From = toV2(front.TL); esp_data.Box.BottomRight.To = toV2(front.BL); esp_data.Box.BottomRight.Visible = true
            
            esp_data.Box.Left.From = toV2(back.TL); esp_data.Box.Left.To = toV2(back.TR); esp_data.Box.Left.Visible = true
            esp_data.Box.Right.From = toV2(back.TR); esp_data.Box.Right.To = toV2(back.BR); esp_data.Box.Right.Visible = true
            esp_data.Box.Top.From = toV2(back.BL); esp_data.Box.Top.To = toV2(back.BR); esp_data.Box.Top.Visible = true
            esp_data.Box.Bottom.From = toV2(back.TL); esp_data.Box.Bottom.To = toV2(back.BL); esp_data.Box.Bottom.Visible = true
            
        elseif style == "Corner" then
            local cornerSize = boxWidth * 0.2
            esp_data.Box.TopLeft.From = boxPosition; esp_data.Box.TopLeft.To = boxPosition + Vector2.new(cornerSize, 0); esp_data.Box.TopLeft.Visible = true
            esp_data.Box.TopRight.From = boxPosition + Vector2.new(boxSize.X, 0); esp_data.Box.TopRight.To = boxPosition + Vector2.new(boxSize.X - cornerSize, 0); esp_data.Box.TopRight.Visible = true
            esp_data.Box.BottomLeft.From = boxPosition + Vector2.new(0, boxSize.Y); esp_data.Box.BottomLeft.To = boxPosition + Vector2.new(cornerSize, boxSize.Y); esp_data.Box.BottomLeft.Visible = true
            esp_data.Box.BottomRight.From = boxPosition + Vector2.new(boxSize.X, boxSize.Y); esp_data.Box.BottomRight.To = boxPosition + Vector2.new(boxSize.X - cornerSize, boxSize.Y); esp_data.Box.BottomRight.Visible = true
            esp_data.Box.Left.From = boxPosition; esp_data.Box.Left.To = boxPosition + Vector2.new(0, cornerSize); esp_data.Box.Left.Visible = true
            esp_data.Box.Right.From = boxPosition + Vector2.new(boxSize.X, 0); esp_data.Box.Right.To = boxPosition + Vector2.new(boxSize.X, cornerSize); esp_data.Box.Right.Visible = true
            esp_data.Box.Top.From = boxPosition + Vector2.new(0, boxSize.Y); esp_data.Box.Top.To = boxPosition + Vector2.new(0, boxSize.Y - cornerSize); esp_data.Box.Top.Visible = true
            esp_data.Box.Bottom.From = boxPosition + Vector2.new(boxSize.X, boxSize.Y); esp_data.Box.Bottom.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y - cornerSize); esp_data.Box.Bottom.Visible = true
        else -- Full box
            esp_data.Box.Left.From = boxPosition; esp_data.Box.Left.To = boxPosition + Vector2.new(0, boxSize.Y); esp_data.Box.Left.Visible = true
            esp_data.Box.Right.From = boxPosition + Vector2.new(boxSize.X, 0); esp_data.Box.Right.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y); esp_data.Box.Right.Visible = true
            esp_data.Box.Top.From = boxPosition; esp_data.Box.Top.To = boxPosition + Vector2.new(boxSize.X, 0); esp_data.Box.Top.Visible = true
            esp_data.Box.Bottom.From = boxPosition + Vector2.new(0, boxSize.Y); esp_data.Box.Bottom.To = boxPosition + Vector2.new(boxSize.X, boxSize.Y); esp_data.Box.Bottom.Visible = true
        end
        
        for _, obj in pairs(esp_data.Box) do
            if obj.Visible then obj.Color = color; obj.Thickness = flags["BoxThickness"] or 1 end
        end
    end
    
    -- TRACERS
    if flags["TracerESP"] then
        esp_data.Tracer.From = GetTracerOrigin()
        esp_data.Tracer.To = Vector2.new(pos.X, pos.Y)
        esp_data.Tracer.Color = color
        esp_data.Tracer.Visible = true
    end
    
    -- HEALTH
    if flags["HealthESP"] then
        local healthPercent = humanoid.Health/humanoid.MaxHealth
        local barHeight = screenSize * 0.8
        local barWidth = 4
        local barPos = Vector2.new(boxPosition.X - barWidth - 2, boxPosition.Y + (screenSize - barHeight)/2)
        
        esp_data.HealthBar.Outline.Size = Vector2.new(barWidth, barHeight)
        esp_data.HealthBar.Outline.Position = barPos
        esp_data.HealthBar.Outline.Color = Color3.new(0, 0, 0)
        esp_data.HealthBar.Outline.Visible = true
        
        esp_data.HealthBar.Fill.Size = Vector2.new(barWidth - 2, barHeight * healthPercent)
        esp_data.HealthBar.Fill.Position = Vector2.new(barPos.X + 1, barPos.Y + barHeight * (1-healthPercent))
        esp_data.HealthBar.Fill.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
        esp_data.HealthBar.Fill.Visible = true
    end
    
    -- NAMES & DISTANCE
    if flags["NameESP"] then
        esp_data.Info.Name.Text = player.DisplayName
        esp_data.Info.Name.Position = Vector2.new(boxPosition.X + boxWidth/2, boxPosition.Y - 20)
        esp_data.Info.Name.Color = color
        esp_data.Info.Name.Visible = true
    end
    
    if flags["ShowDistance"] then
        esp_data.Info.Distance.Text = math.floor(distance) .. " studs"
        esp_data.Info.Distance.Position = Vector2.new(boxPosition.X + boxWidth/2, boxPosition.Y + boxSize.Y + 5)
        esp_data.Info.Distance.Color = get_color("DistanceColor", Color3.fromRGB(200, 200, 200))
        esp_data.Info.Distance.Visible = true
    end
    
    -- CHAMS
    local highlight = Highlights[player]
    if highlight then
        if flags["ChamsEnabled"] and character then
            highlight.Parent = character
            highlight.FillColor = get_color("ChamsFillColor", Color3.fromRGB(255, 0, 0))
            highlight.OutlineColor = get_color("ChamsOutlineColor", Color3.fromRGB(255, 255, 255))
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Enabled = true
        else
            highlight.Enabled = false
        end
    end
    
    -- SKELETON
    if flags["SkeletonESP"] then
        local function getBones()
            local bones = {
                Head = character:FindFirstChild("Head"),
                UpperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso"),
                LowerTorso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso"),
                LeftUpperArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm"),
                LeftLowerArm = character:FindFirstChild("LeftLowerArm") or character:FindFirstChild("Left Arm"),
                LeftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm"),
                RightUpperArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm"),
                RightLowerArm = character:FindFirstChild("RightLowerArm") or character:FindFirstChild("Right Arm"),
                RightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"),
                LeftUpperLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg"),
                LeftLowerLeg = character:FindFirstChild("LeftLowerLeg") or character:FindFirstChild("Left Leg"),
                LeftFoot = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg"),
                RightUpperLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg"),
                RightLowerLeg = character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg"),
                RightFoot = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg")
            }
            return bones
        end
        
        local function drawBone(from, to, line)
            if not from or not to then line.Visible = false; return end
            local fromScreen, fromVis = camera:WorldToViewportPoint(from.CFrame.Position)
            local toScreen, toVis = camera:WorldToViewportPoint(to.CFrame.Position)
            if not (fromVis and toVis) or fromScreen.Z < 0 or toScreen.Z < 0 then line.Visible = false; return end
            
            line.From = Vector2.new(fromScreen.X, fromScreen.Y)
            line.To = Vector2.new(toScreen.X, toScreen.Y)
            line.Color = get_color("SkeletonColor", Color3.fromRGB(255,255,255))
            line.Thickness = 1.5
            line.Transparency = 1
            line.Visible = true
        end
        
        local skeleton = Drawings.Skeleton[player]
        local bones = getBones()
        if skeleton and bones.UpperTorso then
            drawBone(bones.Head, bones.UpperTorso, skeleton[1])
            drawBone(bones.UpperTorso, bones.LowerTorso, skeleton[2])
            drawBone(bones.UpperTorso, bones.LeftUpperArm, skeleton[3])
            drawBone(bones.LeftUpperArm, bones.LeftLowerArm, skeleton[4])
            drawBone(bones.LeftLowerArm, bones.LeftHand, skeleton[5])
            drawBone(bones.UpperTorso, bones.RightUpperArm, skeleton[6])
            drawBone(bones.RightUpperArm, bones.RightLowerArm, skeleton[7])
            drawBone(bones.RightLowerArm, bones.RightHand, skeleton[8])
            drawBone(bones.LowerTorso, bones.LeftUpperLeg, skeleton[9])
            drawBone(bones.LeftUpperLeg, bones.LeftLowerLeg, skeleton[10])
            drawBone(bones.LeftLowerLeg, bones.LeftFoot, skeleton[11])
            drawBone(bones.LowerTorso, bones.RightUpperLeg, skeleton[12])
            drawBone(bones.RightUpperLeg, bones.RightLowerLeg, skeleton[13])
            drawBone(bones.RightLowerLeg, bones.RightFoot, skeleton[14])
        end
    else
        local skeleton = Drawings.Skeleton[player]
        if skeleton then for _, line in pairs(skeleton) do line.Visible = false end end
    end
end

function esp:refresh_elements()
    -- handled by render stepped
end

function esp:init(opts)
    raw_flags = opts.flags
    build_flags_proxy()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then CreateESP(player) end
    end

    local lastUpdate = 0
    esp.connection = RunService.RenderStepped:Connect(function()
        camera = Workspace.CurrentCamera
        
        -- Refresh Rate Limiter
        local currentTime = tick()
        local refreshRate = flags["RefreshRate"] or 144
        if currentTime - lastUpdate < (1 / refreshRate) then return end
        lastUpdate = currentTime

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if not Drawings.ESP[player] then CreateESP(player) end
                UpdateESP(player)
            end
        end
    end)

    esp.player_added = Players.PlayerAdded:Connect(function(plr) task.wait(0.1) CreateESP(plr) end)
    esp.player_removed = Players.PlayerRemoving:Connect(RemoveESP)
end

-- THIS IS THE UNLOADER YOU REQUESTED
function esp:unload()
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveESP(player)
    end
    Drawings.ESP = {}
    Drawings.Skeleton = {}
    Highlights = {}

    if esp.connection then esp.connection:Disconnect() end
    if esp.player_added then esp.player_added:Disconnect() end
    if esp.player_removed then esp.player_removed:Disconnect() end
end

return esp
