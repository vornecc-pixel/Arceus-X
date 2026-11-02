-- ═══════════════════════════════════════════════════════════════
-- ESP MODULE — Fust Drawing Logic + Chams Occlusion
-- ═══════════════════════════════════════════════════════════════

local esp = { players = {}, connections = {} }

local Workspace    = cloneref(game:GetService("Workspace"))
local RunService   = cloneref(game:GetService("RunService"))
local Players      = cloneref(game:GetService("Players"))
local LocalPlayer  = Players.LocalPlayer
local camera       = Workspace.CurrentCamera

local raw_flags
local flags

local RIG_CONNS = {
    R6 = {
        {"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"},
        {"Torso","Left Leg"}, {"Torso","Right Leg"}, {"Torso","HumanoidRootPart"},
    },
    R15 = {
        {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"}, {"LowerTorso","HumanoidRootPart"},
        {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"},
    },
}

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude

local function build_flags_proxy()
    flags = setmetatable({}, {
        __index = function(_, key)
            local v = raw_flags[key]
            if v == nil then
                if key:find("_Color") then return {Color = Color3.new(1, 1, 1), Alpha = 1} end
                if key == "MaxDistance" then return 1000 end
                return false
            end
            if typeof(v) == "Color3" then return {Color = v, Alpha = 1} end
            return v
        end
    })
end

local function newDrawing(class)
    local d = Drawing.new(class)
    d.Visible = false
    return d
end

local function getRigType(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hum.RigType == Enum.HumanoidRigType.R15 then return "R15" end
        return "R6"
    end
    if char:FindFirstChild("UpperTorso") then return "R15" end
    return "R6"
end

local function clearPlayer(plr)
    local d = esp.players[plr]
    if not d then return end

    for _, obj in pairs(d.drawings) do
        if obj and obj.Remove then obj:Remove() end
    end
    for _, line in ipairs(d.skeletonLines) do
        if line and line.Remove then line:Remove() end
    end
    if d.chamsVisible then d.chamsVisible:Destroy() end
    if d.chamsHidden  then d.chamsHidden:Destroy()  end

    esp.players[plr] = nil
end

local function createPlayer(plr)
    clearPlayer(plr)
    local char = plr.Character
    if not char then return end

    local data = {
        drawings = {},
        skeletonLines = {},
        rigType = getRigType(char),
    }

    data.drawings.box      = newDrawing("Square")
    data.drawings.name     = newDrawing("Text")
    data.drawings.dist     = newDrawing("Text")
    data.drawings.health   = newDrawing("Line")
    data.drawings.tracer   = newDrawing("Line")
    data.drawings.headDot  = newDrawing("Circle")

    local conns = RIG_CONNS[data.rigType]
    for i = 1, #conns do
        local line = newDrawing("Line")
        line.Thickness = 1
        line.Transparency = 1
        data.skeletonLines[i] = line
    end

    -- Chams (Visible & Hidden)
    data.chamsVisible = Instance.new("Highlight")
    data.chamsVisible.FillTransparency = 0.5
    data.chamsVisible.OutlineTransparency = 0
    data.chamsVisible.DepthMode = Enum.HighlightDepthMode.Occluded
    data.chamsVisible.Adornee = char
    data.chamsVisible.Enabled = false
    data.chamsVisible.Parent = gethui() or game:GetService("CoreGui")

    data.chamsHidden = Instance.new("Highlight")
    data.chamsHidden.FillTransparency = 0.5
    data.chamsHidden.OutlineTransparency = 0
    data.chamsHidden.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    data.chamsHidden.Adornee = char
    data.chamsHidden.Enabled = false
    data.chamsHidden.Parent = gethui() or game:GetService("CoreGui")

    esp.players[plr] = data
end

local function lineOfSight(hrp, char)
    RayParams.FilterDescendantsInstances = { camera, LocalPlayer.Character, char, char }
    local result = Workspace:Raycast(camera.CFrame.Position, hrp.Position - camera.CFrame.Position, RayParams)
    return result == nil
end

local function updateDrawing(plr, d, char, hrp, hum)
    if not d.drawings.box then return end

    local rootPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then
        for _, obj in pairs(d.drawings) do obj.Visible = false end
        return
    end

    local color = flags["Box_Color"].Color

    local top = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(0, 3, 0)).Position)
    local bot = camera:WorldToViewportPoint((hrp.CFrame * CFrame.new(0, -3, 0)).Position)
    local height = math.abs(bot.Y - top.Y)
    local width  = height / 2

    -- Box
    local box = d.drawings.box
    box.Visible = flags["Boxes"]
    box.Color   = color
    box.Thickness = 1
    box.Filled  = false
    box.Size    = Vector2.new(width, height)
    box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)

    -- Name
    local nameTag = d.drawings.name
    nameTag.Visible = flags["Names"]
    nameTag.Text    = plr.Name
    nameTag.Color   = flags["Name_Color"].Color
    nameTag.Size    = 14
    nameTag.Center  = true
    nameTag.Outline = true
    nameTag.Position = Vector2.new(rootPos.X, rootPos.Y - height/2 - 16)

    -- Distance
    local dist = math.floor((camera.CFrame.Position - hrp.Position).Magnitude)
    local distTag = d.drawings.dist
    distTag.Visible = flags["Distances"]
    distTag.Text    = dist .. "m"
    distTag.Color   = flags["Distance_Color"].Color
    distTag.Size    = 12
    distTag.Center  = true
    distTag.Outline = true
    distTag.Position = Vector2.new(rootPos.X, rootPos.Y + height/2 + 2)

    -- Health Bar
    local hb = d.drawings.health
    hb.Visible    = flags["HealthBars"]
    hb.Color      = flags["Health_Color"].Color
    hb.Thickness  = 2
    hb.From = Vector2.new(rootPos.X - width/2 - 6, rootPos.Y + height/2)
    hb.To   = Vector2.new(rootPos.X - width/2 - 6, rootPos.Y + height/2 - (height * (hum.Health / hum.MaxHealth)))

    -- Tracer
    local tracer = d.drawings.tracer
    if flags["Tracers"] then
        local ss = camera.ViewportSize
        tracer.Visible = true
        tracer.Color   = flags["Tracer_Color"].Color
        tracer.Thickness = 1
        tracer.From = Vector2.new(ss.X/2, ss.Y)
        tracer.To   = Vector2.new(rootPos.X, rootPos.Y + height/2)
    else
        tracer.Visible = false
    end

    -- Head Dot
    local head = char:FindFirstChild("Head")
    local hd = d.drawings.headDot
    if flags["HeadDots"] and head then
        local hpos, hon = camera:WorldToViewportPoint(head.Position)
        hd.Visible = hon
        hd.Color   = flags["Dot_Color"].Color
        hd.Position = Vector2.new(hpos.X, hpos.Y)
        hd.Radius  = 4
        hd.Filled  = true
    else
        hd.Visible = false
    end
end

local function updateChams(plr, d, char, hrp)
    if not d.chamsVisible then return end

    if not flags["Chams"] then
        d.chamsVisible.Enabled = false
        d.chamsHidden.Enabled  = false
        return
    end

    local _, onScreen = camera:WorldToViewportPoint(hrp.Position)
    if not onScreen then
        d.chamsVisible.Enabled = false
        d.chamsHidden.Enabled  = false
        return
    end

    d.chamsVisible.Adornee = char
    d.chamsHidden.Adornee  = char
    d.chamsVisible.FillColor    = flags["Chams_Visible_Color"].Color
    d.chamsVisible.OutlineColor = flags["Chams_Visible_Color"].Color
    d.chamsHidden.FillColor     = flags["Chams_Hidden_Color"].Color
    d.chamsHidden.OutlineColor  = flags["Chams_Hidden_Color"].Color

    local visible = lineOfSight(hrp, char)
    d.chamsVisible.Enabled = visible and flags["VisibleChams"]
    d.chamsHidden.Enabled  = (not visible) and flags["HiddenChams"]
end

local function updateSkeleton(plr, d, char)
    if #d.skeletonLines == 0 then return end

    if not flags["Skeleton"] then
        for _, line in ipairs(d.skeletonLines) do
            if line then line.Visible = false end
        end
        return
    end

    local conns = RIG_CONNS[d.rigType]
    if not conns then return end

    for i, pair in ipairs(conns) do
        local line = d.skeletonLines[i]
        if line then
            local p1 = char:FindFirstChild(pair[1])
            local p2 = char:FindFirstChild(pair[2])
            if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                local v1, on1 = camera:WorldToViewportPoint(p1.Position)
                local v2, on2 = camera:WorldToViewportPoint(p2.Position)
                if on1 or on2 then
                    line.From = Vector2.new(v1.X, v1.Y)
                    line.To   = Vector2.new(v2.X, v2.Y)
                    line.Color = flags["Skeleton_Color"].Color
                    line.Visible = true
                else
                    line.Visible = false
                end
            else
                line.Visible = false
            end
        end
    end
end

function esp:refresh_elements()
    -- flags proxy handles live updates automatically
end

function esp:init(opts)
    raw_flags = opts.flags
    build_flags_proxy()

    esp.player_added = Players.PlayerAdded:Connect(function(plr)
        plr.CharacterAdded:Connect(function() task.wait(0.15) createPlayer(plr) end)
        if plr.Character then createPlayer(plr) end
    end)
    esp.player_removed = Players.PlayerRemoving:Connect(clearPlayer)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Character then createPlayer(plr) end
            plr.CharacterAdded:Connect(function() task.wait(0.15) createPlayer(plr) end)
        end
    end

    esp.connection = RunService.RenderStepped:Connect(function()
        camera = Workspace.CurrentCamera
        if not flags["Enabled"] then
            for _, d in pairs(esp.players) do
                for _, obj in pairs(d.drawings) do obj.Visible = false end
                for _, line in ipairs(d.skeletonLines) do if line then line.Visible = false end end
                if d.chamsVisible then d.chamsVisible.Enabled = false; d.chamsHidden.Enabled = false end
            end
            return
        end

        for plr, d in pairs(esp.players) do
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")

            -- Team check
            if flags["Team_Check"] and plr.Team == LocalPlayer.Team then
                for _, obj in pairs(d.drawings) do obj.Visible = false end
                for _, line in ipairs(d.skeletonLines) do if line then line.Visible = false end end
                if d.chamsVisible then d.chamsVisible.Enabled = false; d.chamsHidden.Enabled = false end
                continue
            end

            if not char or not hrp or not hum or hum.Health <= 0 then
                for _, obj in pairs(d.drawings) do obj.Visible = false end
                for _, line in ipairs(d.skeletonLines) do if line then line.Visible = false end end
                if d.chamsVisible then d.chamsVisible.Enabled = false; d.chamsHidden.Enabled = false end
                continue
            end

            local dist = (camera.CFrame.Position - hrp.Position).Magnitude
            if dist > flags["MaxDistance"] then
                for _, obj in pairs(d.drawings) do obj.Visible = false end
                for _, line in ipairs(d.skeletonLines) do if line then line.Visible = false end end
                if d.chamsVisible then d.chamsVisible.Enabled = false; d.chamsHidden.Enabled = false end
                continue
            end

            updateDrawing(plr, d, char, hrp, hum)
            updateChams(plr, d, char, hrp)
            updateSkeleton(plr, d, char)
        end
    end)
end

return esp
