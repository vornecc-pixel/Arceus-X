-- ═══════════════════════════════════════════════════════════════
-- ESP MODULE (Fixed & Fully Compatible)
-- ═══════════════════════════════════════════════════════════════

local esp = { players = {}, connections = {} }

local Workspace    = cloneref(game:GetService("Workspace"))
local RunService   = cloneref(game:GetService("RunService"))
local HttpService  = cloneref(game:GetService("HttpService"))
local Players      = cloneref(game:GetService("Players"))

local vec2, vec3 = Vector2.new, Vector3.new
local dim2 = UDim2.new
local dim_offset = UDim2.fromOffset
local rgb = Color3.fromRGB

local camera
local raw_flags
local flags
local fonts = {}
local rainbow_hue = 0

local bones_r15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"UpperTorso", "RightUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"}, {"LowerTorso", "RightUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
}

local bones_r6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

local function build_flags_proxy()
    flags = setmetatable({}, {
        __index = function(_, key)
            local v = raw_flags[key]
            if v == nil then
                if key == "Box_Type" then return "Corner" end
                if key == "Chams_Mode" then return "AlwaysOnTop" end
                if key:find("_Color") or key:find("_Outline") or key == "Health_High" or key == "Health_Low" or key == "Head_Dot_Color" or key == "Tracer_Color" then
                    return {Color = Color3.new(1, 1, 1), Alpha = 1}
                end
                return false
            end
            if typeof(v) == "Color3" then return {Color = v, Alpha = 1} end
            return v
        end
    })
end

local function register_fonts()
    pcall(function()
        local function Register_Font(Name, Weight, Style, Asset)
            if not isfile(Asset.Id) then writefile(Asset.Id, Asset.Font) end
            if isfile(Name .. ".font") then delfile(Name .. ".font") end
            local Data = { name = Name, faces = {{name = "Normal", weight = Weight, style = Style, assetId = getcustomasset(Asset.Id)}} }
            writefile(Name .. ".font", HttpService:JSONEncode(Data))
            return getcustomasset(Name .. ".font")
        end
        local ProggyTiny = Register_Font("ProggyTiny", 100, "Normal", {
            Id = "ProggyTinyyyy.ttf",
            Font = game:HttpGet("https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/ProggyTiny.ttf"),
        })
        fonts.main = Font.new(ProggyTiny, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    end)
    if not fonts.main then
        fonts.main = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    end
end

function esp:get_screen_pos(world_position)
    local viewport_size = camera.ViewportSize
    local local_position = camera.CFrame:PointToObjectSpace(world_position)

    local aspect_ratio = viewport_size.x / viewport_size.y
    local half_height = -local_position.z * math.tan(math.rad(camera.FieldOfView / 2))
    local half_width = aspect_ratio * half_height

    local far_plane_corner = Vector3.new(-half_width, half_height, local_position.z)
    local relative_position = local_position - far_plane_corner

    local screen_x = relative_position.x / (half_width * 2)
    local screen_y = -relative_position.y / (half_height * 2)

    local is_on_screen = -local_position.z > 0 and screen_x >= 0 and screen_x <= 1 and screen_y >= 0 and screen_y <= 1
    return Vector3.new(screen_x * viewport_size.x, screen_y * viewport_size.y, -local_position.z), is_on_screen
end

function esp:box_solve(torso)
    if not torso then return nil, nil, nil, math.huge end
    local ViewportTop    = torso.Position + (torso.CFrame.UpVector * 1.8) + camera.CFrame.UpVector
    local ViewportBottom = torso.Position - (torso.CFrame.UpVector * 2.5) - camera.CFrame.UpVector
    local Distance       = (torso.Position - camera.CFrame.p).Magnitude

    local Top = esp:get_screen_pos(ViewportTop)
    local Bottom = esp:get_screen_pos(ViewportBottom)

    local Width  = math.max(math.floor(math.abs(Top.X - Bottom.X)), 3)
    local Height = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 3)
    local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
    local BoxPosition = Vector2.new(
        math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5),
        math.floor(math.min(Top.Y, Bottom.Y))
    )
    return BoxSize, BoxPosition, Top, Distance
end

function esp:create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in pairs(options) do ins[prop] = value end
    return ins
end

function esp:create_object(player)
    if esp.players[player.Name] then esp:remove_object(player) end

    local data = { objects = {}, info = {}, drawings = { skeletons = {} } }
    esp.players[player.Name] = data
    local objects = data.objects

    objects["holder"] = esp:create("Frame", { Parent = esp.screengui; Name = "\0"; BackgroundTransparency = 1; Position = dim2(0, 0, 0, 0); Size = dim2(0, 0, 0, 0); BorderSizePixel = 0; BackgroundColor3 = rgb(255, 255, 255); })
    objects["box_outline"] = esp:create("UIStroke", { Parent = esp.cache; LineJoinMode = Enum.LineJoinMode.Miter })
    objects["name"] = esp:create("TextLabel", { FontFace = fonts.main; Parent = objects["holder"]; TextColor3 = flags["Name_Color"].Color; Text = string.format("%s (@%s)", player.DisplayName, player.Name); Name = "\0"; TextStrokeTransparency = 0; AnchorPoint = vec2(0, 1); Size = dim2(1, 0, 0, 0); BackgroundTransparency = 1; Position = dim2(0, 0, 0, -5); BorderSizePixel = 0; AutomaticSize = Enum.AutomaticSize.Y; TextSize = 9; })
    objects["box_handler"] = esp:create("Frame", { Parent = esp.cache; Name = "\0"; BackgroundTransparency = 1; Position = dim2(0, 1, 0, 1); Size = dim2(1, -2, 1, -2); BorderSizePixel = 0; BackgroundColor3 = rgb(255, 255, 255); })
    objects["box_color"] = esp:create("UIStroke", { Color = rgb(255, 255, 255); LineJoinMode = Enum.LineJoinMode.Miter; Name = "\0"; Parent = objects["box_handler"] })
    objects["outline"] = esp:create("Frame", { Parent = objects["box_handler"]; Name = "\0"; BackgroundTransparency = 1; Position = dim2(0, 1, 0, 1); Size = dim2(1, -2, 1, -2); BorderSizePixel = 0; BackgroundColor3 = rgb(255, 255, 255); })
    esp:create("UIStroke", { Parent = objects["outline"]; LineJoinMode = Enum.LineJoinMode.Miter })

    objects["corners"] = esp:create("Frame", { Visible = true; Parent = esp.cache; BackgroundTransparency = 1; Position = dim2(0, -1, 0, 2); Name = "\0"; Size = dim2(1, 0, 1, 0); BorderSizePixel = 0; BackgroundColor3 = rgb(255, 255, 255); })
    local corner_defs = {
        { Position = dim2(0, 0, 0, -2), Size = dim2(0.4, 0, 0, 3), Anchor = vec2(0, 0), Inner = dim2(0, 1, 0, 1) },
        { Position = dim2(0, 0, 0, 1), Size = dim2(0, 3, 0.25, 0), Anchor = vec2(0, 0), Inner = dim2(0, 1, 0, -2) },
        { Position = dim2(1, 0, 0, -2), Size = dim2(0.4, 0, 0, 3), Anchor = vec2(1, 0), Inner = dim2(0, 1, 0, 1) },
        { Position = dim2(1, 0, 0, 1), Size = dim2(0, 3, 0.25, 0), Anchor = vec2(1, 0), Inner = dim2(0, 1, 0, -2) },
        { Position = dim2(0, 0, 1, -2), Size = dim2(0.4, 0, 0, 3), Anchor = vec2(0, 1), Inner = dim2(0, 1, 0, 1) },
        { Position = dim2(0, 0, 1, -5), Size = dim2(0, 3, 0.25, 0), Anchor = vec2(0, 1), Inner = dim2(0, 1, 0, -2), Rot = 180 },
        { Position = dim2(1, 0, 1, -2), Size = dim2(0.4, 0, 0, 3), Anchor = vec2(1, 1), Inner = dim2(0, 1, 0, 1) },
        { Position = dim2(1, 0, 1, -5), Size = dim2(0, 3, 0.25, 0), Anchor = vec2(1, 1), Inner = dim2(0, 1, 0, -2), Rot = 180 },
    }
    for _, def in corner_defs do
        local line = esp:create("Frame", { Parent = objects["corners"]; Name = "line"; Position = def.Position; Size = def.Size; BorderSizePixel = 0; BackgroundColor3 = rgb(0, 0, 0); AnchorPoint = def.Anchor; Rotation = def.Rot or 0; })
        esp:create("Frame", { Parent = line; Position = def.Inner; Size = dim2(1, -2, 1, -2); BorderSizePixel = 0; BackgroundColor3 = flags["Box_Color"].Color })
    end

    objects["healthbar_holder"] = esp:create("Frame", { AnchorPoint = vec2(1, 0); Parent = esp.cache; Name = "\0"; Position = dim2(0, -5, 0, -1); Size = dim2(0, 4, 1, 2); BorderSizePixel = 0; BackgroundColor3 = rgb(0, 0, 0); })
    objects["healthbar"] = esp:create("Frame", { Parent = objects["healthbar_holder"]; Name = "\0"; Position = dim2(0, 1, 0, 1); Size = dim2(1, -2, 1, -2); BorderSizePixel = 0; BackgroundColor3 = rgb(255, 255, 255); })
    objects["distance"] = esp:create("TextLabel", { FontFace = fonts.main; Parent = esp.cache; TextColor3 = flags["Distance_Color"].Color; Text = "0st"; Name = "\0"; Size = dim2(1, 0, 0, 0); BackgroundTransparency = 1; Position = dim2(0, 0, 1, 5); AutomaticSize = Enum.AutomaticSize.Y; TextSize = 9; })
    objects["weapon"] = esp:create("TextLabel", { FontFace = fonts.main; Parent = esp.cache; TextColor3 = flags["Weapon_Color"].Color; Text = "[--]"; Name = "\0"; Size = dim2(1, 0, 0, 0); BackgroundTransparency = 1; Position = dim2(0, 0, 1, 19); AutomaticSize = Enum.AutomaticSize.Y; TextSize = 9; })

    local highlight = Instance.new("Highlight")
    highlight.FillColor = flags["Chams_Color"].Color
    highlight.OutlineColor = flags["Chams_Outline"].Color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    objects["chams"] = highlight

    data.update_health_chams = function()
        if not flags["Health_Chams"] or not flags["Chams"] then return end
        local humanoid = data.info.humanoid
        if not humanoid then return end
        local hp_percent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        highlight.FillColor = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hp_percent)
    end

    local head_dot = Drawing.new("Circle")
    head_dot.Thickness = 2; head_dot.Filled = true; head_dot.Visible = false; head_dot.Color = flags["Head_Dot_Color"].Color
    data.drawings["head_dot"] = head_dot

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1; tracer.Visible = false; tracer.Color = flags["Tracer_Color"].Color
    data.drawings["tracer"] = tracer

    -- Pre-allocate 15 skeleton lines to cover both R6 and R15 without dynamic allocation issues
    for i = 1, 15 do
        local line = Drawing.new("Line")
        line.Color = flags["Skeletons_Color"].Color; line.Thickness = 1; line.Visible = false
        table.insert(data.drawings.skeletons, line)
    end

    data.health_changed = function(value)
        if not flags["Healthbar"] then return end
        local humanoid = data.info.humanoid
        if not humanoid then return end
        local multiplier = math.clamp(value / humanoid.MaxHealth, 0, 1)
        local color = flags["Health_Low"].Color:Lerp(flags["Health_High"].Color, multiplier)
        objects["healthbar"].Size = UDim2.new(1, -2, multiplier, -2)
        objects["healthbar"].Position = UDim2.new(0, 1, 1 - multiplier, 1)
        objects["healthbar"].BackgroundColor3 = color
    end

    data.tool_added = function(item)
        if not item or not item:IsA("Tool") then return end
        if not data.info.character then return end
        objects["weapon"].Text = item.Name
    end

    data.refresh_descendants = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        data.info.character = character
        data.info.humanoid = humanoid
        data.info.rootpart = character:FindFirstChild("HumanoidRootPart")

        -- Re-parent chams safely
        if objects["chams"] then objects["chams"].Parent = character end

        humanoid.HealthChanged:Connect(data.health_changed)
        humanoid.HealthChanged:Connect(data.update_health_chams)
        character.ChildAdded:Connect(data.tool_added)
        character.ChildRemoved:Connect(data.tool_added)

        data.health_changed(humanoid.Health)
        data.update_health_chams()
    end

    data.refresh_descendants()
    player.CharacterAdded:Connect(data.refresh_descendants)

    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    if tool then data.tool_added(tool) end
end

function esp:remove_object(player)
    local holder = esp.players[player.Name]
    if not holder then return end
    if holder.objects["chams"] then holder.objects["chams"]:Destroy() end
    for _, obj in pairs(holder.drawings) do
        if type(obj) == "table" then for _, line in ipairs(obj) do line:Remove() end else obj:Remove() end
    end
    if holder.objects["holder"] then holder.objects["holder"]:Destroy() end
    esp.players[player.Name] = nil
end

function esp:refresh_elements()
    for _, v in Players:GetPlayers() do
        if v == Players.LocalPlayer then continue end
        if not v.Character then continue end

        local path = esp.players[v.Name]
        local objects = path and path.objects
        if not objects then continue end

        local is_teammate = flags["Team_Check"] and (v.Team == Players.LocalPlayer.Team)
        
        if is_teammate then
            objects["holder"].Parent = esp.cache
            if objects["chams"] then objects["chams"].Enabled = false end
            if path.drawings["head_dot"] then path.drawings["head_dot"].Visible = false end
            if path.drawings["tracer"] then path.drawings["tracer"].Visible = false end
            continue
        end

        objects["holder"].Parent = flags["Enabled"] and esp.screengui or esp.cache
        objects["name"].Parent = flags["Names"] and objects["holder"] or esp.cache
        objects["name"].TextColor3 = flags["Name_Color"].Color

        local is_corner = flags["Box_Type"] == "Corner"
        if flags["Boxes"] then
            objects["corners"].Parent     = is_corner and objects["holder"] or esp.cache
            objects["box_handler"].Parent = is_corner and esp.cache or objects["holder"]
            objects["box_outline"].Parent = is_corner and esp.cache or objects["holder"]
        else
            objects["corners"].Parent     = esp.cache
            objects["box_handler"].Parent = esp.cache
            objects["box_outline"].Parent = esp.cache
        end

        objects["box_color"].Color = flags["Box_Color"].Color
        for _, corner in objects["corners"]:GetChildren() do
            local inner = corner:FindFirstChildOfClass("Frame")
            if inner then inner.BackgroundColor3 = flags["Box_Color"].Color end
        end

        for _, line in path.drawings.skeletons do line.Color = flags["Skeletons_Color"].Color end
        objects["healthbar_holder"].Parent = flags["Healthbar"] and objects["holder"] or esp.cache
        objects["weapon"].TextColor3 = flags["Weapon_Color"].Color
        objects["weapon"].Parent = (flags["Weapon"] and v.Character:FindFirstChildOfClass("Tool")) and objects["holder"] or esp.cache
        objects["distance"].TextColor3 = flags["Distance_Color"].Color
        objects["distance"].Parent = flags["Distance"] and objects["holder"] or esp.cache

        local chams = objects["chams"]
        if chams then
            chams.Enabled = flags["Chams"]
            if flags["Chams"] then
                chams.DepthMode = Enum.HighlightDepthMode[flags["Chams_Mode"]]
                if flags["Rainbow"] then
                    chams.FillColor = Color3.fromHSV(rainbow_hue, 1, 1)
                    chams.OutlineColor = Color3.fromHSV(rainbow_hue, 1, 1)
                else
                    chams.FillColor = flags["Chams_Color"].Color
                    chams.OutlineColor = flags["Chams_Outline"].Color
                end
                if flags["Health_Chams"] then path.update_health_chams() end
            end
        end

        local head_dot = path.drawings["head_dot"]
        if head_dot then head_dot.Color = flags["Rainbow"] and Color3.fromHSV(rainbow_hue, 1, 1) or flags["Head_Dot_Color"].Color end
        local tracer = path.drawings["tracer"]
        if tracer then tracer.Color = flags["Rainbow"] and Color3.fromHSV(rainbow_hue, 1, 1) or flags["Tracer_Color"].Color end
    end
end

esp.connection = RunService.RenderStepped:Connect(function()
    camera = Workspace.CurrentCamera
    if not flags["Enabled"] then return end
    if flags["Rainbow"] then rainbow_hue = (tick() * 0.5) % 1 end

    for _, player in Players:GetPlayers() do
        local data = esp.players[player.Name]
        if not data then continue end
        if flags["Team_Check"] and (player.Team == Players.LocalPlayer.Team) then continue end

        local character = data.info.character
        local humanoid  = data.info.humanoid
        if not (character and humanoid) then continue end
        local objects = data.objects
        if not objects then continue end

        local box_size, box_pos, on_screen, distance = esp:box_solve(humanoid.RootPart)
        local holder = objects["holder"]
        if holder.Visible ~= on_screen then holder.Visible = on_screen end

        -- Skeletons
        if flags["Skeletons"] and on_screen then
            local is_r6 = character:FindFirstChild("Torso") ~= nil
            local active_bones = is_r6 and bones_r6 or bones_r15
            
            for i = 1, #active_bones do
                local origin_name, dest_name = active_bones[i][1], active_bones[i][2]
                local path = data.drawings.skeletons[i]
                local origin_3d = character:FindFirstChild(origin_name)
                local dest_3d = character:FindFirstChild(dest_name)

                if origin_3d and dest_3d then
                    local o2d, s_on  = esp:get_screen_pos(origin_3d.Position)
                    local d2d, d_on  = esp:get_screen_pos(dest_3d.Position)
                    if s_on and d_on then
                        path.Visible = true
                        path.From = Vector2.new(o2d.X, o2d.Y)
                        path.To   = Vector2.new(d2d.X, d2d.Y)
                    else
                        path.Visible = false
                    end
                else
                    path.Visible = false
                end
            end
            for i = #active_bones + 1, #data.drawings.skeletons do
                data.drawings.skeletons[i].Visible = false
            end
        else
            for _, line in data.drawings.skeletons do line.Visible = false end
        end

        local head_dot = data.drawings["head_dot"]
        if head_dot then
            if flags["Head_Dot"] and on_screen then
                local head = character:FindFirstChild("Head")
                if head then
                    local screen_pos, h_on = esp:get_screen_pos(head.Position)
                    if h_on then
                        head_dot.Position = Vector2.new(screen_pos.X, screen_pos.Y)
                        head_dot.Visible = true
                    else head_dot.Visible = false end
                else head_dot.Visible = false end
            else head_dot.Visible = false end
        end

        local tracer = data.drawings["tracer"]
        if tracer then
            if flags["Tracers"] and on_screen then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    local screen_pos, t_on = esp:get_screen_pos(root.Position)
                    if t_on then
                        tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                       
