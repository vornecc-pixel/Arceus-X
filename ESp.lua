-- ═══════════════════════════════════════════════════════════════
-- ESP MODULE — self-contained, host-agnostic
-- usage: local esp = loadstring(...)(); esp:init({flags = library.flags})
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

local bones = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"UpperTorso", "RightUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
}

-- ── flag proxy ─────────────────────────────────────────────────
local function build_flags_proxy()
    flags = setmetatable({}, {
        __index = function(_, key)
            local v = raw_flags[key]
            if v == nil then
                if key == "Box_Type" then return "Corner" end
                if key:find("_Color") or key == "Health_High" or key == "Health_Low" then
                    return {Color = Color3.new(1, 1, 1), Alpha = 1}
                end
                return false
            end
            if typeof(v) == "Color3" then
                return {Color = v, Alpha = 1}
            end
            return v
        end
    })
end

-- ── font registration ──────────────────────────────────────────
local function register_fonts()
    pcall(function()
        local function Register_Font(Name, Weight, Style, Asset)
            if not isfile(Asset.Id) then
                writefile(Asset.Id, Asset.Font)
            end
            if isfile(Name .. ".font") then
                delfile(Name .. ".font")
            end
            local Data = {
                name = Name,
                faces = {{
                    name = "Normal",
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Asset.Id),
                }},
            }
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

-- ── helpers ────────────────────────────────────────────────────
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

    local is_on_screen = -local_position.z > 0
        and screen_x >= 0 and screen_x <= 1
        and screen_y >= 0 and screen_y <= 1

    return Vector3.new(screen_x * viewport_size.x, screen_y * viewport_size.y, -local_position.z), is_on_screen
end

function esp:box_solve(torso)
    if not torso then return nil, nil, nil, math.huge end

    local ViewportTop    = torso.Position + (torso.CFrame.UpVector * 1.8) + camera.CFrame.UpVector
    local ViewportBottom = torso.Position - (torso.CFrame.UpVector * 2.5) - camera.CFrame.UpVector
    local Distance       = (torso.Position - camera.CFrame.p).Magnitude

    local Top, TopIsRendered       = esp:get_screen_pos(ViewportTop)
    local Bottom, BottomIsRendered = esp:get_screen_pos(ViewportBottom)

    local Width  = math.max(math.floor(math.abs(Top.X - Bottom.X)), 3)
    local Height = math.max(math.floor(math.max(math.abs(Bottom.Y - Top.Y), Width / 2)), 3)
    local BoxSize = Vector2.new(math.floor(math.max(Height / 1.5, Width)), Height)
    local BoxPosition = Vector2.new(
        math.floor(Top.X * 0.5 + Bottom.X * 0.5 - BoxSize.X * 0.5),
        math.floor(math.min(Top.Y, Bottom.Y))
    )

    return BoxSize, BoxPosition, TopIsRendered, Distance
end

function esp:create(instance, options)
    local ins = Instance.new(instance)
    for prop, value in pairs(options) do
        ins[prop] = value
    end
    return ins
end

function esp:create_object(player)
    if esp.players[player.Name] then
        esp:remove_object(player)
    end

    local data = { objects = {}, info = {}, drawings = {} }
    esp.players[player.Name] = data
    local objects = data.objects

    objects["holder"] = esp:create("Frame", {
        Parent = esp.screengui;
        Name = "\0";
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 0, 0);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 0, 0, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255);
    })

    objects["box_outline"] = esp:create("UIStroke", {
        Parent = (flags["Boxes"] and flags["Box_Type"] ~= "Corner" and objects["holder"]) or esp.cache;
        LineJoinMode = Enum.LineJoinMode.Miter;
    })

    objects["name"] = esp:create("TextLabel", {
        FontFace = fonts.main;
        Parent = objects["holder"];
        TextColor3 = flags["Name_Color"].Color;
        BorderColor3 = rgb(0, 0, 0);
        Text = string.format("%s (@%s)", player.DisplayName, player.Name);
        Name = "\0";
        TextStrokeTransparency = 0;
        AnchorPoint = vec2(0, 1);
        Size = dim2(1, 0, 0, 0);
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 0, -5);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        TextSize = 9;
    })

    objects["box_handler"] = esp:create("Frame", {
        Parent = (flags["Boxes"] and flags["Box_Type"] ~= "Corner" and objects["holder"]) or esp.cache;
        Name = "\0";
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255);
    })

    objects["box_color"] = esp:create("UIStroke", {
        Color = rgb(255, 255, 255);
        LineJoinMode = Enum.LineJoinMode.Miter;
        Name = "\0";
        Parent = objects["box_handler"];
    })

    objects["outline"] = esp:create("Frame", {
        Parent = objects["box_handler"];
        Name = "\0";
        BackgroundTransparency = 1;
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255);
    })

    esp:create("UIStroke", {
        Parent = objects["outline"];
        LineJoinMode = Enum.LineJoinMode.Miter;
    })

    -- corner pieces
    objects["corners"] = esp:create("Frame", {
        Visible = true;
        BorderColor3 = rgb(0, 0, 0);
        Parent = flags["Boxes"] and flags["Box_Type"] == "Corner" and objects["holder"] or esp.cache;
        BackgroundTransparency = 1;
        Position = dim2(0, -1, 0, 2);
        Name = "\0";
        Size = dim2(1, 0, 1, 0);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255);
    })

    local corner_defs = {
        { Name = "1", Position = dim2(0, 0, 0, -2),    Size = dim2(0.4, 0, 0, 3),    Anchor = vec2(0, 0),   Inner = dim2(0, 1, 0, 1) },
        { Name = "2", Position = dim2(0, 0, 0, 1),     Size = dim2(0, 3, 0.25, 0),   Anchor = vec2(0, 0),   Inner = dim2(0, 1, 0, -2) },
        { Name = "3", Position = dim2(1, 0, 0, -2),    Size = dim2(0.4, 0, 0, 3),    Anchor = vec2(1, 0),   Inner = dim2(0, 1, 0, 1) },
        { Name = "4", Position = dim2(1, 0, 0, 1),     Size = dim2(0, 3, 0.25, 0),   Anchor = vec2(1, 0),   Inner = dim2(0, 1, 0, -2) },
        { Name = "5", Position = dim2(0, 0, 1, -2),    Size = dim2(0.4, 0, 0, 3),    Anchor = vec2(0, 1),   Inner = dim2(0, 1, 0, 1) },
        { Name = "6", Position = dim2(0, 0, 1, -5),    Size = dim2(0, 3, 0.25, 0),   Anchor = vec2(0, 1),   Inner = dim2(0, 1, 0, -2), Rot = 180 },
        { Name = "7", Position = dim2(1, 0, 1, -2),    Size = dim2(0.4, 0, 0, 3),    Anchor = vec2(1, 1),   Inner = dim2(0, 1, 0, 1) },
        { Name = "8", Position = dim2(1, 0, 1, -5),    Size = dim2(0, 3, 0.25, 0),   Anchor = vec2(1, 1),   Inner = dim2(0, 1, 0, -2), Rot = 180 },
    }
    for _, def in corner_defs do
        local line = esp:create("Frame", {
            Parent = objects["corners"];
            Name = "line";
            Position = def.Position;
            BorderColor3 = rgb(0, 0, 0);
            Size = def.Size;
            BorderSizePixel = 0;
            BackgroundColor3 = rgb(0, 0, 0);
            AnchorPoint = def.Anchor;
            Rotation = def.Rot or 0;
        })
        esp:create("Frame", {
            Parent = line;
            Position = def.Inner;
            BorderColor3 = rgb(0, 0, 0);
            Size = dim2(1, -2, 1, -2);
            BorderSizePixel = 0;
            BackgroundColor3 = flags["Box_Color"].Color;
        })
    end

    -- healthbar
    objects["healthbar_holder"] = esp:create("Frame", {
        AnchorPoint = vec2(1, 0);
        Parent = flags["Healthbar"] and objects["holder"] or esp.cache;
        Name = "\0";
        Position = dim2(0, -5, 0, -1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(0, 4, 1, 2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(0, 0, 0);
    })

    objects["healthbar"] = esp:create("Frame", {
        Parent = objects["healthbar_holder"];
        Name = "\0";
        Position = dim2(0, 1, 0, 1);
        BorderColor3 = rgb(0, 0, 0);
        Size = dim2(1, -2, 1, -2);
        BorderSizePixel = 0;
        BackgroundColor3 = rgb(255, 255, 255);
    })

    -- distance
    objects["distance"] = esp:create("TextLabel", {
        FontFace = fonts.main;
        TextColor3 = flags["Distance_Color"].Color;
        BorderColor3 = rgb(0, 0, 0);
        Text = "0st";
        Parent = flags["Distance"] and objects["holder"] or esp.cache;
        TextStrokeTransparency = 0;
        Name = "\0";
        Size = dim2(1, 0, 0, 0);
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 1, 5);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        TextSize = 9;
    })

    -- weapon
    objects["weapon"] = esp:create("TextLabel", {
        FontFace = fonts.main;
        TextColor3 = flags["Weapon_Color"].Color;
        BorderColor3 = rgb(0, 0, 0);
        Text = "[--]";
        Parent = esp.cache;
        TextStrokeTransparency = 0;
        Name = "\0";
        Size = dim2(1, 0, 0, 0);
        BackgroundTransparency = 1;
        Position = dim2(0, 0, 1, 19);
        BorderSizePixel = 0;
        AutomaticSize = Enum.AutomaticSize.Y;
        TextSize = 9;
    })

    -- skeleton drawings
    for _ = 1, #bones do
        local line = Drawing.new("Line")
        line.Color = flags["Skeletons_Color"].Color
        line.Thickness = 1
        line.Visible = false
        data.drawings[#data.drawings + 1] = line
    end

    -- per-player helpers
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

        local exists = data.info.character:FindFirstChild(item.Name)
        objects["weapon"].Text = item.Name
        objects["weapon"].Parent = (exists and flags["Weapon"]) and objects["holder"] or esp.cache
    end

    data.refresh_descendants = function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        data.info.character = character
        data.info.humanoid = humanoid
        data.info.rootpart = character:FindFirstChild("HumanoidRootPart")

        humanoid.HealthChanged:Connect(data.health_changed)
        character.ChildAdded:Connect(data.tool_added)
        character.ChildRemoved:Connect(data.tool_added)

        data.health_changed(humanoid.Health)
    end

    data.refresh_descendants()
    data.health_changed(data.info.humanoid.Health)
    player.CharacterAdded:Connect(data.refresh_descendants)

    local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
    if tool then
        data.tool_added(tool)
    end
end

function esp:remove_object(player)
    local holder = esp.players[player.Name]
    if not holder then return end

    for _, line in holder.drawings do
        line:Remove()
    end
    holder.objects["holder"]:Destroy()
    esp.players[player.Name] = nil
end

function esp:refresh_elements()
    for _, v in Players:GetPlayers() do
        if v == Players.LocalPlayer then continue end
        if not v.Character then continue end

        local path = esp.players[v.Name]
        local objects = path and path.objects
        if not objects then continue end

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
            if inner then
                inner.BackgroundColor3 = flags["Box_Color"].Color
            end
        end

        for _, line in path.drawings do
            line.Color = flags["Skeletons_Color"].Color
            line.Visible = flags["Skeletons"]
        end

        objects["healthbar_holder"].Parent = flags["Healthbar"] and objects["holder"] or esp.cache

        objects["weapon"].TextColor3 = flags["Weapon_Color"].Color
        objects["weapon"].Parent = (flags["Weapon"] and v.Character:FindFirstChildOfClass("Tool")) and objects["holder"] or esp.cache

        objects["distance"].TextColor3 = flags["Distance_Color"].Color
        objects["distance"].Parent = flags["Distance"] and objects["holder"] or esp.cache
    end
end

function esp:unload()
    for _, player in Players:GetPlayers() do
        esp:remove_object(player)
    end
    if esp.connection then esp.connection:Disconnect() end
    if esp.player_added then esp.player_added:Disconnect() end
    if esp.player_removed then esp.player_removed:Disconnect() end
    if esp.cache then esp.cache:Destroy() end
    if esp.screengui then esp.screengui:Destroy() end
    esp.cache, esp.screengui = nil, nil
end

function esp:init(opts)
    raw_flags = opts.flags
    build_flags_proxy()
    register_fonts()

    esp.screengui = Instance.new("ScreenGui", gethui())
    esp.screengui.IgnoreGuiInset = true
    esp.screengui.Name = "\0"

    esp.cache = Instance.new("ScreenGui", gethui())
    esp.cache.Enabled = false

    camera = Workspace.CurrentCamera

    for _, v in Players:GetPlayers() do
        if v ~= Players.LocalPlayer then
            esp:create_object(v)
        end
    end

    esp.player_added = Players.PlayerAdded:Connect(function(v)
        esp:create_object(v)
    end)

    esp.player_removed = Players.PlayerRemoving:Connect(function(v)
        esp:remove_object(v)
    end)

    esp.connection = RunService.RenderStepped:Connect(function()
        camera = Workspace.CurrentCamera
        if not flags["Enabled"] then return end

        for _, player in Players:GetPlayers() do
            local data = esp.players[player.Name]
            if not data then continue end

            local character = data.info.character
            local humanoid  = data.info.humanoid
            if not (character and humanoid) then continue end

            local objects = data.objects
            if not objects then continue end

            local box_size, box_pos, on_screen, distance = esp:box_solve(humanoid.RootPart)
            local holder = objects["holder"]

            if holder.Visible ~= on_screen then
                holder.Visible = on_screen
            end

            if flags["Skeletons"] and character:FindFirstChild("UpperTorso") then
                for i = 1, #bones do
                    local origin, destination = bones[i][1], bones[i][2]
                    local path = data.drawings[i]
                    if not path then continue end

                    local origin_3d = character:FindFirstChild(origin)
                    local destination_3d = character:FindFirstChild(destination)

                    if origin_3d and destination_3d then
                        local o2d, s_on  = esp:get_screen_pos(origin_3d.Position)
                        local d2d, d_on  = esp:get_screen_pos(destination_3d.Position)
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
            end

            if not on_screen then continue end

            local pos = dim_offset(box_pos.X, box_pos.Y)
            if pos ~= holder.Position then holder.Position = pos end

            local size = dim_offset(box_size.X, box_size.Y)
            if size ~= holder.Size then holder.Size = size end

            local dist_label = objects["distance"]
            local txt = tostring(math.round(distance)) .. "st"
            if dist_label.Text ~= txt then dist_label.Text = txt end
        end
    end)

    task.wait()
    esp:refresh_elements()
end

return esp