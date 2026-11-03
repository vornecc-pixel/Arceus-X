--[[
    ARC3USX x NH  |  mixes
    ----------------------------------------------------------------
    Layers NH-style looks and HUD widgets on top of ARC3USX.
    The ARC3USX intro (terminal, ACCESS GRANTED, slice, smash) is NOT touched:
    the window is created with the stock look, the intro plays out, and the mix
    is applied once it has finished.

    The logo (logo.lua) is passed in through CreateWindow, so it is the image
    used by the intro hero/eye glow, the title bar slot and the floating button.

    Usage:
        local Library = loadstring(readfile("ARC3USX.lua"))()
        local Logo    = loadstring(readfile("logo.lua"))()
        local Mix     = loadstring(readfile("ARC3USX_NH.lua"))()
        local Window  = Mix.CreateWindow(Library, { Logo = Logo, Mix = "NH Classic" })
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Mix = {}

local function C(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local function theme(bg, p1, p2, inp, line, box, boxline, text, mute, acc)
    return { Bg = bg, P1 = p1, P2 = p2, Input = inp, Line = line, Box = box, BoxLine = boxline, Text = text, Mute = mute, Accent = acc }
end

-- NH palettes expressed in ARC3USX theme keys
Mix.Themes = {
    ["NH Classic"] = theme(C(16, 17, 20), C(20, 21, 25), C(28, 29, 35), C(28, 29, 35), C(36, 38, 45), C(28, 29, 35), C(52, 55, 64), C(180, 180, 180), C(100, 100, 100), C(152, 188, 255)),
    ["NH Blood Eye"] = theme(C(14, 10, 11), C(20, 14, 15), C(28, 20, 22), C(30, 22, 24), C(48, 34, 37), C(28, 20, 22), C(70, 48, 52), C(200, 190, 190), C(118, 98, 100), C(255, 50, 50)),
    ["NH Frost"] = theme(C(12, 16, 22), C(17, 22, 30), C(24, 31, 42), C(26, 34, 46), C(40, 52, 70), C(24, 31, 42), C(58, 74, 98), C(205, 220, 235), C(112, 130, 155), C(140, 210, 255)),
    ["NH Terminal"] = theme(C(8, 11, 9), C(12, 17, 14), C(18, 25, 20), C(20, 28, 23), C(30, 52, 38), C(18, 25, 20), C(40, 72, 52), C(150, 225, 175), C(70, 120, 88), C(76, 211, 123)),
}

-- Each mix = a theme + font + opacity + which HUD widgets are shown.
-- "Purple" is the stock ARC3USX theme, so that mix is ARC3USX with NH widgets.
Mix.Mixes = {
    ["NH Classic"]   = { Theme = "NH Classic",   Font = "Code",      Opacity = 1,    Watermark = true, Keybinds = true },
    ["Arceus Purple"] = { Theme = "Purple",       Font = "SourceSans", Opacity = 1,   Watermark = true, Keybinds = true },
    ["Blood Eye"]    = { Theme = "NH Blood Eye", Font = "Gotham",    Opacity = 1,    Watermark = true, Keybinds = false },
    ["Frost Glass"]  = { Theme = "NH Frost",     Font = "RobotoMono", Opacity = 0.88, Watermark = false, Keybinds = true },
    ["Terminal"]     = { Theme = "NH Terminal",  Font = "Code",      Opacity = 1,    Watermark = true, Keybinds = true },
    ["Sakura"]       = { Theme = "Sakura",       Font = "Gotham",    Opacity = 1,    Watermark = true, Keybinds = true },
    ["Aurora"]       = { Theme = "Aurora",       Font = "Code",      Opacity = 1,    Watermark = true, Keybinds = true },
    ["Obsidian"]     = { Theme = "Obsidian",     Font = "SourceSans", Opacity = 1,  Watermark = true, Keybinds = true },
    ["Copper"]       = { Theme = "Copper",       Font = "Gotham",    Opacity = 1,    Watermark = true, Keybinds = true },
    ["Solarized"]    = { Theme = "Solarized",    Font = "Code",      Opacity = 1,    Watermark = true, Keybinds = true },
    ["Violet Ice"]   = { Theme = "Violet Ice",   Font = "RobotoMono", Opacity = 1, Watermark = true, Keybinds = true },
}
Mix.Order = { "NH Classic", "Arceus Purple", "Blood Eye", "Frost Glass", "Terminal", "Sakura", "Aurora", "Obsidian", "Copper", "Solarized", "Violet Ice" }

--------------------------------------------------------------------
-- HUD (watermark + keybind list), recolors with the library theme
--------------------------------------------------------------------
local function inst(class, props, parent)
    local o = Instance.new(class)
    if o:IsA("GuiObject") then
        o.BorderSizePixel = 0
    end
    for k, v in pairs(props or {}) do
        o[k] = v
    end
    o.Parent = parent
    return o
end

local function buildHud(Library)
    local gui = Library:_gui()
    local hud = { Watermark = true, Keybinds = true }

    local wm = inst("Frame", {
        Name = "NH_Watermark",
        Position = UDim2.fromOffset(12, 12),
        Size = UDim2.fromOffset(0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 0,
        ZIndex = 5,
    }, gui)
    local wmStroke = inst("UIStroke", {}, wm)
    local wmLine = inst("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0, ZIndex = 6 }, wm)
    local wmText = inst("TextLabel", {
        Position = UDim2.fromOffset(0, 2),
        Size = UDim2.new(0, 0, 1, -2),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        TextSize = 13,
        ZIndex = 6,
        Text = "",
    }, wm)
    inst("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, wmText)

    local kl = inst("Frame", {
        Name = "NH_KeybindList",
        Position = UDim2.fromOffset(12, 42),
        Size = UDim2.fromOffset(170, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 0,
        ZIndex = 5,
    }, gui)
    local klStroke = inst("UIStroke", {}, kl)
    local klLine = inst("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0, ZIndex = 6 }, kl)
    local klBody = inst("TextLabel", {
        Position = UDim2.fromOffset(0, 2),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        TextSize = 13,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 6,
        Text = "",
    }, kl)
    inst("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 5),
    }, klBody)

    local function hex(c)
        return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
    end

    local function recolor()
        local t = Library:GetTheme()
        wm.BackgroundColor3 = t.P1
        kl.BackgroundColor3 = t.P1
        wmStroke.Color = t.Line
        klStroke.Color = t.Line
        wmLine.BackgroundColor3 = t.Accent
        klLine.BackgroundColor3 = t.Accent
        wmText.TextColor3 = t.Text
        klBody.TextColor3 = t.Text
        wmText.Font = Library.FontEnum
        klBody.Font = Library.FontEnum
        hud._mute, hud._acc = hex(t.Mute), hex(t.Accent)
    end
    recolor()
    Library:OnTheme(recolor)
    Library:OnAccent(recolor)

    function hud:SetFont()
        wmText.Font = Library.FontEnum
        klBody.Font = Library.FontEnum
    end

    function hud:Apply(watermark, keybinds)
        self.Watermark, self.Keybinds = watermark, keybinds
        wm.Visible = watermark
        kl.Visible = keybinds
    end

    -- live updates
    local frames, fps = 0, 60
    local fc = RunService.RenderStepped:Connect(function()
        frames = frames + 1
    end)
    task.spawn(function()
        local last = os.clock()
        while gui.Parent do
            task.wait(0.5)
            local now = os.clock()
            fps = frames / (now - last)
            frames, last = 0, now

            local ping = 0
            pcall(function()
                ping = LocalPlayer:GetNetworkPing() * 1000
            end)
            wmText.Text = string.format("%s | %d fps | %d ms | %s", Library.Name, math.floor(fps + 0.5), math.floor(ping + 0.5), os.date("%H:%M"))

            local entries = {}
            for flag, opt in pairs(Library.Options) do
                if opt.Type == "Toggle" and opt.Value then
                    local b = Library.Options[flag .. "_bind"]
                    if b and b.Key then
                        entries[#entries + 1] = string.format('%s  <font color="%s">[%s]</font>', flag, hud._mute or "#888888", b.Key.Name)
                    end
                end
            end
            table.sort(entries)
            local rows = { string.format('<font color="%s">Keybinds</font>', hud._acc or "#ffffff") }
            for _, e in ipairs(entries) do
                rows[#rows + 1] = e
            end
            klBody.Text = table.concat(rows, "\n")
        end
        fc:Disconnect()
    end)

    return hud
end

--------------------------------------------------------------------
-- public API
--------------------------------------------------------------------
function Mix.Init(Library)
    if Mix._lib == Library then
        return
    end
    Mix._lib = Library
    for name, t in pairs(Mix.Themes) do
        Library:RegisterTheme(name, t)
    end
end

function Mix.Apply(Library, name)
    local m = Mix.Mixes[name]
    if not m then
        return false
    end
    Library:SetTheme(m.Theme)
    Library:SetFont(m.Font)
    Library:SetOpacity(m.Opacity, true)
    if Mix.Hud then
        Mix.Hud:Apply(m.Watermark, m.Keybinds)
        Mix.Hud:SetFont()
    end
    Mix.Current = name
    local options = Library.Options
    if options.NH_Mix then options.NH_Mix:Set(name, true) end
    if options.NH_Watermark then options.NH_Watermark:Set(m.Watermark, true) end
    if options.NH_KeybindList then options.NH_KeybindList:Set(m.Keybinds, true) end
    return true
end

-- Adds the "Mixes" tab (call it last so it sits at the end of the tab bar)
function Mix.AddTab(Library, win)
    local tab = win:AddTab("Mixes")
    local g = tab:AddGroup("Mix", "Left")
    g:AddDropdown({
        Name = "Mix",
        Flag = "NH_Mix",
        Options = Mix.Order,
        Default = Mix.Current,
        Callback = function(v)
            Mix.Apply(Library, v)
        end,
    })
    g:AddButton({
        Name = "Next mix",
        Callback = function()
            local idx = table.find(Mix.Order, Mix.Current) or 0
            local nxt = Mix.Order[(idx % #Mix.Order) + 1]
            Mix.Apply(Library, nxt)
            Library:Notify("Mix: " .. nxt, 2)
        end,
    })
    local h = tab:AddGroup("HUD", "Right")
    h:AddToggle({
        Name = "Watermark",
        Flag = "NH_Watermark",
        Default = Mix.Mixes[Mix.Current].Watermark,
        Callback = function(v)
            Mix.Hud:Apply(v, Mix.Hud.Keybinds)
        end,
    })
    h:AddToggle({
        Name = "Keybind list",
        Flag = "NH_KeybindList",
        Default = Mix.Mixes[Mix.Current].Keybinds,
        Callback = function(v)
            Mix.Hud:Apply(Mix.Hud.Watermark, v)
        end,
    })
end

-- opts: Logo (string asset), Mix (name), Name, Size, Intro (false to skip),
--       MixTab (true = add the Mixes tab right away), RememberSettings (default false so a mix is not overridden by saved settings)
function Mix.CreateWindow(Library, opts)
    opts = opts or {}
    Mix.Init(Library)
    Library.RememberSettings = opts.RememberSettings == true

    -- stock look on purpose: the intro plays exactly as ARC3USX ships it
    local win = Library:CreateWindow({
        Name = opts.Name,
        Logo = opts.Logo,
        Size = opts.Size,
        MenuKey = opts.MenuKey,
        Intro = opts.Intro,
    })
    win:WaitReady()
    if not Library.Gui or not Library.Gui.Parent then return nil end

    Mix.Hud = buildHud(Library)
    if not Mix.Apply(Library, opts.Mix or "NH Classic") then
        Mix.Apply(Library, "NH Classic")
    end

    if opts.MixTab == true then
        Mix.AddTab(Library, win)
    end

    return win
end

return Mix
