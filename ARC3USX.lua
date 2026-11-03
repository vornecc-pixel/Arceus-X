--[[
    ARC3USX.EXE  |  Roblox UI Library
    ----------------------------------------------------------------
    A dark, purple-accent UI library with:
      * Tabs, two-column groups
      * Toggle (+ keybind + color swatches), Slider, Dropdown,
        Textbox, Button, Label, Keybind, Color picker
      * In-memory (or file-based, if available) config system
      * Notifications, draggable window, mobile scaling
      * Animated intro: terminal typing + real compatibility checks,
        ACCESS GRANTED, logo reveal, slice, and smash into the window

    Usage: see example.lua and README.md
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer

local Library = {
    Name = "ARC3USX.EXE",
    Version = "1.0.0",
    Logo = "rbxassetid://89562860344178", -- upload your logo to Roblox and put the asset id here
    Accent = Color3.fromRGB(164, 60, 255),
    MenuKey = Enum.KeyCode.Insert,
    Parent = nil, -- optional: set a custom parent for the ScreenGui before CreateWindow
    ConfigFolder = "ARC3USX",
    ExtraChecks = {}, -- optional: { {"Name", function() return "ok"|"warn"|"fail", "detail" end} }
    Flags = {},
    Options = {},
    Configs = {},
    _conns = {},
    _accent = {},
    _accentFns = {},
    _binds = {},
    _windows = {},
}

local Theme = {
    Bg = Color3.fromRGB(13, 13, 15),
    P1 = Color3.fromRGB(20, 20, 22),
    P2 = Color3.fromRGB(26, 26, 29),
    Input = Color3.fromRGB(29, 29, 33),
    Line = Color3.fromRGB(43, 43, 48),
    Box = Color3.fromRGB(39, 39, 43),
    BoxLine = Color3.fromRGB(52, 52, 58),
    Text = Color3.fromRGB(201, 201, 208),
    Mute = Color3.fromRGB(114, 114, 125),
}

--------------------------------------------------------------------
-- helpers
--------------------------------------------------------------------
local function New(class, props, children)
    local o = Instance.new(class)
    if o:IsA("GuiObject") then
        o.BorderSizePixel = 0
    end
    if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
        o.Font = Enum.Font.SourceSans
        o.TextSize = 15
        o.TextColor3 = Theme.Text
        o.BackgroundTransparency = 1
    end
    if o:IsA("TextButton") then
        o.AutoButtonColor = false
    end
    if o:IsA("ImageLabel") or o:IsA("ImageButton") then
        o.BackgroundTransparency = 1
    end
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            o[k] = v
        end
    end
    for _, c in ipairs(children or {}) do
        c.Parent = o
    end
    if parent then
        o.Parent = parent
    end
    return o
end

local function Tween(o, t, props, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function Connect(sig, fn)
    local c = sig:Connect(fn)
    table.insert(Library._conns, c)
    return c
end

local function Acc(o, prop)
    o[prop] = Library.Accent
    table.insert(Library._accent, { o, prop })
end

local function Stroke(color, thickness)
    return New("UIStroke", { Color = color or Theme.Line, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

local function Drag(frame, fn)
    local dragging = false
    local conns = {}
    local function update(pos)
        local a, s = frame.AbsolutePosition, frame.AbsoluteSize
        fn(math.clamp((pos.X - a.X) / math.max(s.X, 1), 0, 1))
    end
    local function isPress(i)
        return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
    end
    table.insert(conns, Connect(frame.InputBegan, function(i)
        if isPress(i) then
            dragging = true
            update(i.Position)
        end
    end))
    table.insert(conns, Connect(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position)
        end
    end))
    table.insert(conns, Connect(UserInputService.InputEnded, function(i)
        if isPress(i) then
            dragging = false
        end
    end))
    return conns
end

function Library:SetAccent(c)
    self.Accent = c
    for _, pair in ipairs(self._accent) do
        pcall(function()
            pair[1][pair[2]] = c
        end)
    end
    for _, fn in ipairs(self._accentFns) do
        pcall(fn)
    end
end

function Library:OnAccent(fn)
    table.insert(self._accentFns, fn)
end

function Library:_gui()
    if self.Gui and self.Gui.Parent then
        return self.Gui
    end
    local gui = New("ScreenGui", {
        Name = "ARC3USX",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 1000,
    })
    gui.Parent = self.Parent or LocalPlayer:WaitForChild("PlayerGui")
    self.Gui = gui
    return gui
end

--------------------------------------------------------------------
-- keybinds
--------------------------------------------------------------------
local function BindButton(parent, default, press, changed)
    local st = { Key = default, Press = press }
    local btn = New("TextButton", {
        Text = default and ("[" .. default.Name .. "]") or "[...]",
        TextColor3 = Theme.Mute,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Parent = parent,
    })
    function st:SetKey(k)
        self.Key = k
        btn.Text = k and ("[" .. k.Name .. "]") or "[...]"
        if changed then
            changed(k)
        end
    end
    Connect(btn.MouseButton1Click, function()
        Library._listening = st
        btn.Text = "[press]"
    end)
    table.insert(Library._binds, st)
    return st, btn
end

function Library:_init()
    if self._inited then
        return
    end
    self._inited = true
    Connect(UserInputService.InputBegan, function(input, gp)
        if self._listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local st = self._listening
                self._listening = nil
                if input.KeyCode == Enum.KeyCode.Escape then
                    st:SetKey(nil)
                else
                    st:SetKey(input.KeyCode)
                end
            end
            return
        end
        if gp or input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        if input.KeyCode == self.MenuKey then
            for _, w in ipairs(self._windows) do
                w:Toggle()
            end
            return
        end
        for _, st in ipairs(self._binds) do
            if st.Key == input.KeyCode and st.Press then
                task.spawn(st.Press)
            end
        end
    end)
end

--------------------------------------------------------------------
-- notifications
--------------------------------------------------------------------
function Library:Notify(text, duration)
    local gui = self:_gui()
    if not self._notes then
        self._notes = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -24),
            Size = UDim2.fromOffset(300, 200),
            BackgroundTransparency = 1,
            ZIndex = 150,
            Parent = gui,
        }, {
            New("UIListLayout", {
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        })
    end
    local n = New("TextLabel", {
        Text = "  " .. tostring(text) .. "  ",
        BackgroundColor3 = Theme.P2,
        BackgroundTransparency = 1,
        TextTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 26),
        Parent = self._notes,
    }, { Stroke(self.Accent) })
    Tween(n, 0.2, { BackgroundTransparency = 0, TextTransparency = 0 })
    task.delay(duration or 3, function()
        if n.Parent then
            Tween(n, 0.25, { BackgroundTransparency = 1, TextTransparency = 1 })
            Debris:AddItem(n, 0.3)
        end
    end)
end

--------------------------------------------------------------------
-- config
--------------------------------------------------------------------
local function fsOK()
    return typeof(writefile) == "function" and typeof(readfile) == "function" and typeof(isfolder) == "function"
        and typeof(makefolder) == "function" and typeof(listfiles) == "function"
end

function Library:Serialize()
    local t = {}
    for flag, o in pairs(self.Options) do
        if o.Type == "Color" then
            t[flag] = { o.Value.R, o.Value.G, o.Value.B }
        elseif o.Type == "Keybind" then
            t[flag] = o.Key and o.Key.Name or ""
        elseif o.Value ~= nil then
            t[flag] = o.Value
        end
    end
    return HttpService:JSONEncode(t)
end

function Library:Deserialize(json)
    local ok, t = pcall(function()
        return HttpService:JSONDecode(json)
    end)
    if not ok or type(t) ~= "table" then
        return false
    end
    for flag, v in pairs(t) do
        local o = self.Options[flag]
        if o and o.Set then
            pcall(function()
                if o.Type == "Color" then
                    o:Set(Color3.new(v[1], v[2], v[3]))
                else
                    o:Set(v)
                end
            end)
        end
    end
    return true
end

function Library:SaveConfig(name)
    local s = self:Serialize()
    self.Configs[name] = s
    if fsOK() then
        pcall(function()
            if not isfolder(self.ConfigFolder) then
                makefolder(self.ConfigFolder)
            end
            writefile(self.ConfigFolder .. "/" .. name .. ".json", s)
        end)
    end
end

function Library:LoadConfig(name)
    local s = self.Configs[name]
    if not s and fsOK() then
        pcall(function()
            s = readfile(self.ConfigFolder .. "/" .. name .. ".json")
        end)
    end
    return s and self:Deserialize(s) or false
end

function Library:DeleteConfig(name)
    self.Configs[name] = nil
    if typeof(delfile) == "function" then
        pcall(delfile, self.ConfigFolder .. "/" .. name .. ".json")
    end
end

function Library:ListConfigs()
    local seen, names = {}, {}
    for n in pairs(self.Configs) do
        seen[n] = true
    end
    if fsOK() then
        pcall(function()
            if isfolder(self.ConfigFolder) then
                for _, f in ipairs(listfiles(self.ConfigFolder)) do
                    local n = tostring(f):match("([^/\\]+)%.json$")
                    if n then
                        seen[n] = true
                    end
                end
            end
        end)
    end
    for n in pairs(seen) do
        names[#names + 1] = n
    end
    table.sort(names)
    return names
end

function Library:Unload()
    for _, c in ipairs(self._conns) do
        pcall(function()
            c:Disconnect()
        end)
    end
    if self.Gui then
        self.Gui:Destroy()
    end
    self._conns, self._accent, self._accentFns, self._binds, self._windows = {}, {}, {}, {}, {}
    self.Flags, self.Options = {}, {}
    self.Gui, self._notes, self._inited = nil, nil, false
end

--------------------------------------------------------------------
-- group (controls)
--------------------------------------------------------------------
local Group = {}
Group.__index = Group

function Group:_o()
    self._n = (self._n or 0) + 1
    return self._n
end

local function Row(self, height)
    return New("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        LayoutOrder = self:_o(),
        Parent = self.Inner,
    })
end

local function Extras(row)
    return New("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Parent = row,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })
end

local function Swatch(win, parent, default, cb)
    local st = { Value = default }
    local b = New("TextButton", {
        Text = "",
        Size = UDim2.fromOffset(22, 10),
        BackgroundColor3 = default,
        BackgroundTransparency = 0,
        Parent = parent,
    }, { Stroke(Color3.new(0, 0, 0)) })
    function st:Set(c, silent)
        self.Value = c
        b.BackgroundColor3 = c
        if not silent and cb then
            task.spawn(cb, c)
        end
    end
    Connect(b.MouseButton1Click, function()
        win:_picker(b, st.Value, function(c)
            st:Set(c)
        end)
    end)
    return st
end

function Group:AddToggle(o)
    local flag = o.Flag or o.Name
    local row = Row(self, 20)
    local box = New("Frame", {
        Size = UDim2.fromOffset(10, 10),
        Position = UDim2.new(0, 0, 0.5, -5),
        BackgroundColor3 = Theme.Box,
        BackgroundTransparency = 0,
        Parent = row,
    }, { Stroke(Theme.BoxLine) })
    New("TextLabel", {
        Text = o.Name,
        Position = UDim2.fromOffset(18, 0),
        Size = UDim2.new(1, -18, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local hit = New("TextButton", { Text = "", Size = UDim2.new(1, 0, 1, 0), Parent = row })
    local extras = Extras(row)

    local obj = { Type = "Toggle", Value = false, Flag = flag }
    function obj:Refresh()
        box.BackgroundColor3 = self.Value and Library.Accent or Theme.Box
    end
    function obj:Set(v, silent)
        self.Value = v and true or false
        Library.Flags[flag] = self.Value
        Tween(box, 0.12, { BackgroundColor3 = self.Value and Library.Accent or Theme.Box })
        if not silent and o.Callback then
            task.spawn(o.Callback, self.Value)
        end
    end
    Connect(hit.MouseButton1Click, function()
        obj:Set(not obj.Value)
    end)
    Library:OnAccent(function()
        obj:Refresh()
    end)

    if o.Bind then
        local st = BindButton(extras, o.BindDefault, function()
            obj:Set(not obj.Value)
        end)
        Library.Options[flag .. "_bind"] = {
            Type = "Keybind",
            Key = st.Key,
            Set = function(_, name)
                st:SetKey(name ~= "" and Enum.KeyCode[name] or nil)
            end,
        }
        setmetatable(Library.Options[flag .. "_bind"], { __index = function(_, k) if k == "Key" then return st.Key end end })
        Library.Options[flag .. "_bind"].Key = nil
    end
    if o.Colors then
        obj.Colors = {}
        for i, c in ipairs(o.Colors) do
            local sw = Swatch(self.Window, extras, c, o.ColorCallback and function(col)
                o.ColorCallback(i, col)
            end or nil)
            obj.Colors[i] = sw
            Library.Options[flag .. "_c" .. i] = {
                Type = "Color",
                Value = c,
                Set = function(s, col)
                    sw:Set(col)
                    s.Value = col
                end,
            }
        end
    end

    obj:Set(o.Default or false, true)
    Library.Options[flag] = obj
    return obj
end

function Group:AddSlider(o)
    local flag = o.Flag or o.Name
    local min, max = o.Min or 0, o.Max or 100
    local rnd, suf = o.Rounding or 0, o.Suffix or ""
    local row = Row(self, 34)
    New("TextLabel", {
        Text = o.Name,
        TextColor3 = Theme.Mute,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -12, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local val = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        TextColor3 = Theme.Mute,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    local bar = New("Frame", {
        Position = UDim2.fromOffset(12, 21),
        Size = UDim2.new(1, -12, 0, 6),
        BackgroundColor3 = Theme.Box,
        BackgroundTransparency = 0,
        Parent = row,
    }, { Stroke(Theme.Line) })
    local fill = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundTransparency = 0, Parent = bar })
    Acc(fill, "BackgroundColor3")

    local obj = { Type = "Slider", Flag = flag }
    function obj:Set(v, silent)
        v = math.clamp(tonumber(v) or min, min, max)
        local m = 10 ^ rnd
        v = math.floor(v * m + 0.5) / m
        self.Value = v
        Library.Flags[flag] = v
        fill.Size = UDim2.fromScale((v - min) / math.max(max - min, 1e-9), 1)
        val.Text = tostring(v) .. suf
        if not silent and o.Callback then
            task.spawn(o.Callback, v)
        end
    end
    Drag(bar, function(r)
        obj:Set(min + (max - min) * r)
    end)
    obj:Set(o.Default or min, true)
    Library.Options[flag] = obj
    return obj
end

function Group:AddDropdown(o)
    local flag = o.Flag or o.Name
    local opts = o.Options or {}
    local row = Row(self, 44)
    New("TextLabel", {
        Text = o.Name,
        TextColor3 = Theme.Mute,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -12, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local btn = New("TextButton", {
        Text = "",
        Position = UDim2.fromOffset(12, 20),
        Size = UDim2.new(1, -12, 0, 22),
        BackgroundColor3 = Theme.Input,
        BackgroundTransparency = 0,
        Parent = row,
    }, { Stroke(Theme.Line) })
    local txt = New("TextLabel", {
        Position = UDim2.fromOffset(7, 0),
        Size = UDim2.new(1, -24, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })
    New("TextLabel", {
        Text = "v",
        TextColor3 = Theme.Mute,
        Size = UDim2.new(0, 18, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        Parent = btn,
    })
    local obj = { Type = "Dropdown", Flag = flag, Options = opts }
    function obj:Set(v, silent)
        self.Value = v
        Library.Flags[flag] = v
        txt.Text = tostring(v)
        if not silent and o.Callback then
            task.spawn(o.Callback, v)
        end
    end
    function obj:SetOptions(list)
        self.Options = list
        opts = list
    end
    Connect(btn.MouseButton1Click, function()
        self.Window:_list(btn, opts, obj.Value, function(v)
            obj:Set(v)
        end)
    end)
    obj:Set(o.Default or opts[1] or "", true)
    Library.Options[flag] = obj
    return obj
end

function Group:AddTextbox(o)
    local flag = o.Flag or o.Name
    local row = Row(self, 44)
    New("TextLabel", {
        Text = o.Name,
        TextColor3 = Theme.Mute,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -12, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local box = New("TextBox", {
        Text = o.Default or "",
        PlaceholderText = o.Placeholder or "",
        PlaceholderColor3 = Theme.Mute,
        ClearTextOnFocus = false,
        Position = UDim2.fromOffset(12, 20),
        Size = UDim2.new(1, -12, 0, 22),
        BackgroundColor3 = Theme.Input,
        BackgroundTransparency = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    }, { Stroke(Theme.Line), New("UIPadding", { PaddingLeft = UDim.new(0, 7) }) })
    local obj = { Type = "Textbox", Flag = flag }
    function obj:Set(v, silent)
        self.Value = tostring(v)
        box.Text = self.Value
        Library.Flags[flag] = self.Value
        if not silent and o.Callback then
            task.spawn(o.Callback, self.Value)
        end
    end
    Connect(box.FocusLost, function()
        obj:Set(box.Text)
    end)
    obj:Set(o.Default or "", true)
    Library.Options[flag] = obj
    return obj
end

function Group:AddButton(o)
    local b = New("TextButton", {
        Text = o.Name,
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = Theme.P2,
        BackgroundTransparency = 0,
        LayoutOrder = self:_o(),
        Parent = self.Inner,
    }, { Stroke(Theme.Line) })
    local s = b:FindFirstChildOfClass("UIStroke")
    Connect(b.MouseEnter, function()
        s.Color = Library.Accent
    end)
    Connect(b.MouseLeave, function()
        s.Color = Theme.Line
    end)
    Connect(b.MouseButton1Click, function()
        if o.Callback then
            task.spawn(o.Callback)
        end
    end)
    return b
end

function Group:AddLabel(text)
    local l = New("TextLabel", {
        Text = text,
        TextColor3 = Theme.Mute,
        Size = UDim2.new(1, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = self:_o(),
        Parent = self.Inner,
    })
    local obj = {}
    function obj:SetText(t)
        l.Text = t
    end
    return obj
end

function Group:AddKeybind(o)
    local flag = o.Flag or o.Name
    local row = Row(self, 20)
    New("TextLabel", {
        Text = o.Name,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local extras = Extras(row)
    local obj = { Type = "Keybind", Flag = flag }
    local st = BindButton(extras, o.Default, (not o.NoFire) and o.Callback or nil, function(k)
        obj.Key = k
        Library.Flags[flag] = k and k.Name or ""
        if o.Changed then
            task.spawn(o.Changed, k)
        end
    end)
    obj.Key = st.Key
    function obj:Set(name)
        st:SetKey(name ~= "" and Enum.KeyCode[name] or nil)
    end
    Library.Options[flag] = obj
    return obj
end

function Group:AddColor(o)
    local flag = o.Flag or o.Name
    local row = Row(self, 20)
    New("TextLabel", {
        Text = o.Name,
        TextColor3 = Theme.Mute,
        Size = UDim2.new(1, 0, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    local extras = Extras(row)
    local sw = Swatch(self.Window, extras, o.Default or Library.Accent, o.Callback)
    local obj = { Type = "Color", Flag = flag, Value = sw.Value }
    function obj:Set(c, silent)
        sw:Set(c, silent)
        self.Value = c
        Library.Flags[flag] = c
    end
    Library.Options[flag] = obj
    return obj
end

function Group:AddCustom(height)
    return New("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        LayoutOrder = self:_o(),
        Parent = self.Inner,
    })
end

--------------------------------------------------------------------
-- window
--------------------------------------------------------------------
local Window = {}
Window.__index = Window

function Window:_closePopup()
    if self._popup then
        for _, o in ipairs(self._popup) do
            if typeof(o) == "Instance" then
                o:Destroy()
            else
                pcall(function()
                    o:Disconnect()
                end)
            end
        end
        self._popup = nil
    end
end

function Window:_blocker()
    self:_closePopup()
    local b = New("TextButton", {
        Text = "",
        Size = UDim2.fromScale(1, 1),
        ZIndex = 59,
        Parent = self.Root,
    })
    Connect(b.MouseButton1Click, function()
        self:_closePopup()
    end)
    self._popup = { b }
    return b
end

function Window:_list(anchor, opts, cur, cb)
    self:_blocker()
    local sc = self.Scale.Scale
    local pos = (anchor.AbsolutePosition - self.Root.AbsolutePosition) / sc
    local w = anchor.AbsoluteSize.X / sc
    local f = New("ScrollingFrame", {
        Position = UDim2.fromOffset(pos.X, pos.Y + anchor.AbsoluteSize.Y / sc + 1),
        Size = UDim2.fromOffset(w, math.min(#opts, 6) * 20),
        CanvasSize = UDim2.fromOffset(0, #opts * 20),
        BackgroundColor3 = Theme.Input,
        BackgroundTransparency = 0,
        ScrollBarThickness = 2,
        ZIndex = 60,
        Parent = self.Root,
    }, { Stroke(Theme.Line), New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
    for i, opt in ipairs(opts) do
        local b = New("TextButton", {
            Text = "  " .. tostring(opt),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = (opt == cur) and Library.Accent or Theme.Text,
            Size = UDim2.new(1, 0, 0, 20),
            LayoutOrder = i,
            Parent = f,
        })
        Connect(b.MouseButton1Click, function()
            self:_closePopup()
            cb(opt)
        end)
    end
    table.insert(self._popup, f)
end

local function Bar(parent, y, val, grad, fn, conns)
    local f = New("Frame", {
        Position = UDim2.fromOffset(10, y),
        Size = UDim2.new(1, -20, 0, 12),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        ZIndex = 61,
        Parent = parent,
    }, { Stroke(Theme.Line) })
    local g = New("UIGradient", { Color = grad, Parent = f })
    local mk = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(val, 0, 0, -2),
        Size = UDim2.fromOffset(3, 16),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        ZIndex = 62,
        Parent = f,
    }, { Stroke(Color3.new(0, 0, 0)) })
    for _, c in ipairs(Drag(f, function(r)
        mk.Position = UDim2.new(r, 0, 0, -2)
        fn(r)
    end)) do
        table.insert(conns, c)
    end
    return g
end

function Window:_picker(anchor, color, cb)
    self:_blocker()
    local h, s, v = color:ToHSV()
    local sc = self.Scale.Scale
    local pos = (anchor.AbsolutePosition - self.Root.AbsolutePosition) / sc
    local p = New("Frame", {
        Position = UDim2.fromOffset(math.max(4, pos.X - 128), pos.Y + 16),
        Size = UDim2.fromOffset(150, 88),
        BackgroundColor3 = Theme.P2,
        BackgroundTransparency = 0,
        ZIndex = 60,
        Parent = self.Root,
    }, { Stroke(Theme.Line) })
    table.insert(self._popup, p)
    local conns = {}
    local gs, gv
    local function push()
        local c = Color3.fromHSV(h, s, v)
        if gs then
            gs.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1))
        end
        if gv then
            gv.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(h, s, 1))
        end
        cb(c)
    end
    local rainbow = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
    })
    Bar(p, 12, h, rainbow, function(r)
        h = r
        push()
    end, conns)
    gs = Bar(p, 38, s, ColorSequence.new(Color3.new(1, 1, 1), Color3.fromHSV(h, 1, 1)), function(r)
        s = r
        push()
    end, conns)
    gv = Bar(p, 64, v, ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(h, s, 1)), function(r)
        v = r
        push()
    end, conns)
    for _, c in ipairs(conns) do
        table.insert(self._popup, c)
    end
end

function Window:SelectTab(tab)
    self:_closePopup()
    for _, t in ipairs(self.Tabs) do
        local on = (t == tab)
        t.Page.Visible = on
        t.Button.TextColor3 = on and Library.Accent or Theme.Text
    end
end

function Window:AddTab(name)
    local tab = { Name = name, Window = self }
    tab.Button = New("TextButton", {
        Text = name,
        BackgroundColor3 = Theme.P2,
        BackgroundTransparency = 0,
        Size = UDim2.new(0.2, -1, 1, 0),
        Parent = self.TabBar,
    }, { Stroke(Theme.Line) })
    tab.Page = New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false,
        Parent = self.Pages,
    }, { New("UIPadding", {
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }) })
    Acc(tab.Page, "ScrollBarImageColor3")

    local function column(side)
        return New("Frame", {
            Position = side == "Left" and UDim2.new() or UDim2.new(0.5, 6, 0, 0),
            Size = UDim2.new(0.5, -6, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = tab.Page,
        }, { New("UIListLayout", { Padding = UDim.new(0, 14), SortOrder = Enum.SortOrder.LayoutOrder }),
            New("UIPadding", { PaddingTop = UDim.new(0, 8) }) })
    end
    tab.Left, tab.Right = column("Left"), column("Right")

    function tab:AddGroup(title, side)
        local parent = (side == "Right") and self.Right or self.Left
        local box = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = parent,
        }, { Stroke(Theme.Line) })
        local inner = New("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = box,
        }, {
            New("UIPadding", {
                PaddingTop = UDim.new(0, 14),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
            }),
            New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
        })
        New("TextLabel", {
            Text = title,
            BackgroundColor3 = Theme.P1,
            BackgroundTransparency = 0,
            Position = UDim2.fromOffset(8, -9),
            Size = UDim2.new(0, 0, 0, 16),
            AutomaticSize = Enum.AutomaticSize.X,
            ZIndex = 2,
            Parent = box,
        }, { New("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) }) })
        return setmetatable({ Inner = inner, Window = tab.Window, Tab = tab }, Group)
    end

    table.insert(self.Tabs, tab)
    for _, t in ipairs(self.Tabs) do
        t.Button.Size = UDim2.new(1 / #self.Tabs, -1, 1, 0)
    end
    Connect(tab.Button.MouseButton1Click, function()
        self:SelectTab(tab)
    end)
    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end
    return tab
end

function Window:Toggle()
    self.Root.Visible = not self.Root.Visible
    self.Fab.Visible = not self.Root.Visible
    self:_closePopup()
end

function Window:Replay()
    task.spawn(function()
        pcall(Library._RunIntro, Library, self)
    end)
end

function Window:AddSettingsTab()
    local tab = self:AddTab("Settings")
    local cfg = tab:AddGroup("Configs", "Left")
    local listHolder = cfg:AddCustom(150)
    local list = New("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Input,
        BackgroundTransparency = 0,
        ScrollBarThickness = 2,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Parent = listHolder,
    }, { Stroke(Theme.Line), New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }) })
    local selected
    local nameBox = cfg:AddTextbox({ Name = "Config Name", Flag = "__cfgname" })
    Library.Options.__cfgname = nil
    local function refresh()
        for _, c in ipairs(list:GetChildren()) do
            if c:IsA("TextButton") then
                c:Destroy()
            end
        end
        for i, n in ipairs(Library:ListConfigs()) do
            local b = New("TextButton", {
                Text = "  " .. n,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = (n == selected) and Library.Accent or Theme.Text,
                Size = UDim2.new(1, 0, 0, 20),
                LayoutOrder = i,
                Parent = list,
            })
            Connect(b.MouseButton1Click, function()
                selected = n
                refresh()
            end)
        end
    end
    cfg:AddButton({ Name = "Create", Callback = function()
        local n = (nameBox.Value or ""):gsub("[^%w_%-]", "")
        if n ~= "" then
            Library:SaveConfig(n)
            selected = n
            refresh()
            Library:Notify("Created " .. n)
        end
    end })
    cfg:AddButton({ Name = "Delete", Callback = function()
        if selected then
            Library:DeleteConfig(selected)
            Library:Notify("Deleted " .. selected)
            selected = nil
            refresh()
        end
    end })
    cfg:AddButton({ Name = "Load", Callback = function()
        if selected and Library:LoadConfig(selected) then
            Library:Notify("Loaded " .. selected)
        end
    end })
    cfg:AddButton({ Name = "Save", Callback = function()
        if selected then
            Library:SaveConfig(selected)
            Library:Notify("Saved " .. selected)
        end
    end })
    cfg:AddButton({ Name = "Refresh configs", Callback = refresh })
    cfg:AddKeybind({ Name = "Menu Bind", Flag = "__menubind", Default = Library.MenuKey, NoFire = true, Changed = function(k)
        if k then
            Library.MenuKey = k
        end
    end })
    Library.Options.__menubind = nil
    cfg:AddColor({ Name = "Accent", Flag = "__accent", Default = Library.Accent, Callback = function(c)
        Library:SetAccent(c)
    end })
    Library.Options.__accent = nil

    local other = tab:AddGroup("Other", "Right")
    other:AddButton({ Name = "Replay Intro", Callback = function()
        self:Replay()
    end })
    other:AddButton({ Name = "Unload Menu", Callback = function()
        Library:Unload()
    end })
    refresh()
    return tab
end

function Library:CreateWindow(opts)
    opts = opts or {}
    if opts.Name then self.Name = opts.Name end
    if opts.Logo then self.Logo = opts.Logo end
    if opts.Accent then self.Accent = opts.Accent end
    if opts.MenuKey then self.MenuKey = opts.MenuKey end
    local gui = self:_gui()
    self:_init()

    local size = opts.Size or Vector2.new(560, 500)
    local win = setmetatable({ Tabs = {} }, Window)

    local root = New("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size.X, size.Y),
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0,
        Parent = gui,
    }, { Stroke(Theme.Line) })
    win.Root = root
    win.Scale = New("UIScale", { Parent = root })
    local function rescale()
        local vp = workspace.CurrentCamera.ViewportSize
        win.Scale.Scale = math.min(1, (vp.X - 16) / size.X, (vp.Y - 16) / size.Y)
    end
    rescale()
    Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), rescale)

    -- title bar
    local top = New("Frame", {
        Position = UDim2.fromOffset(10, 4),
        Size = UDim2.new(1, -20, 0, 26),
        BackgroundTransparency = 1,
        Parent = root,
    })
    win.LogoImg = New("ImageLabel", {
        Image = self.Logo,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(9, 13),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Color3.fromRGB(232, 232, 238),
        BackgroundTransparency = 0,
        Parent = top,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    local title = New("TextLabel", {
        RichText = true,
        Position = UDim2.fromOffset(26, 0),
        Size = UDim2.new(1, -26, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top,
    })
    local function retitle()
        local c = self.Accent
        title.Text = string.format('<font color="rgb(%d,%d,%d)">%s</font> | %s',
            math.floor(c.R * 255), math.floor(c.G * 255), math.floor(c.B * 255), self.Name, os.date("%b %d %Y"))
    end
    retitle()
    self:OnAccent(retitle)
    local line = New("Frame", {
        Position = UDim2.fromOffset(10, 31),
        Size = UDim2.new(1, -20, 0, 1),
        BackgroundTransparency = 0,
        Parent = root,
    })
    Acc(line, "BackgroundColor3")

    -- drag
    local dragging, start, origin
    Connect(top.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, start, origin = true, i.Position, root.Position
        end
    end)
    Connect(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = (i.Position - start) / win.Scale.Scale
            root.Position = UDim2.new(origin.X.Scale, origin.X.Offset + d.X, origin.Y.Scale, origin.Y.Offset + d.Y)
        end
    end)
    Connect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    win.TabBar = New("Frame", {
        Position = UDim2.fromOffset(10, 40),
        Size = UDim2.new(1, -20, 0, 28),
        BackgroundTransparency = 1,
        Parent = root,
    }, { New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder }) })
    win.Pages = New("Frame", {
        Position = UDim2.fromOffset(10, 76),
        Size = UDim2.new(1, -20, 1, -86),
        BackgroundColor3 = Theme.P1,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        Parent = root,
    }, { Stroke(Theme.Line) })

    -- floating button (shown when the menu is hidden)
    win.Fab = New("ImageButton", {
        Image = self.Logo,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -14, 1, -14),
        Size = UDim2.fromOffset(44, 44),
        BackgroundColor3 = Color3.fromRGB(232, 232, 238),
        BackgroundTransparency = 0,
        Visible = false,
        Parent = gui,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }), Stroke(self.Accent) })
    Connect(win.Fab.MouseButton1Click, function()
        win:Toggle()
    end)

    table.insert(self._windows, win)
    if opts.Intro ~= false then
        win:Replay()
    end
    return win
end

--------------------------------------------------------------------
-- intro: terminal + compatibility checks + ACCESS GRANTED + smash
--------------------------------------------------------------------
local function hx(n)
    local s = ""
    for _ = 1, n do
        s = s .. string.format("%x", math.random(0, 15))
    end
    return s
end

local function noise()
    local m = {
        "0x" .. hx(8) .. "  mov eax, [ebp+0x" .. hx(2) .. "]",
        "alloc " .. hx(4) .. " bytes @ 0x" .. hx(6),
        "resolve sym_" .. hx(3) .. " = 0x" .. hx(8),
        "chunk[" .. math.random(0, 255) .. "] crc " .. hx(8) .. " ok",
        "hook.attach 0x" .. hx(6) .. " -> stub_" .. hx(2),
        "decrypt block " .. hx(4) .. "..." .. hx(4),
        "0x" .. hx(8) .. "  xor ecx, ecx",
        "stack.check " .. hx(6) .. " ok",
    }
    return m[math.random(1, #m)]
end

local function es(u)
    return u * u * (3 - 2 * u)
end

function Library:_RunIntro(win)
    local gui = self.Gui
    local vp = workspace.CurrentCamera.ViewportSize
    local accent = self.Accent
    local ov = New("Frame", {
        Name = "Intro",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(9, 9, 11),
        BackgroundTransparency = 0,
        Active = true,
        ZIndex = 100,
        Parent = gui,
    })
    win.Root.Visible = true
    win.Fab.Visible = false

    -- terminal background
    local term = New("TextLabel", {
        Size = UDim2.new(1, -24, 1, -20),
        Position = UDim2.fromOffset(12, 10),
        Font = Enum.Font.Code,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(47, 174, 99),
        TextTransparency = 0.35,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        RichText = true,
        Text = "",
        ZIndex = 101,
        Parent = ov,
    })
    local lines = {}
    local function typeLine(txt, col)
        lines[#lines + 1] = ""
        local idx = #lines
        if #lines > 45 then
            table.remove(lines, 1)
            idx = idx - 1
        end
        local function put(s, cursor)
            s = s .. (cursor and "_" or "")
            lines[idx] = col and ('<font color="' .. col .. '">' .. s .. "</font>") or s
            term.Text = table.concat(lines, "\n")
        end
        for i = 4, #txt + 3, 4 do
            put(txt:sub(1, math.min(i, #txt)), true)
            task.wait(0.016)
        end
        put(txt, false)
    end

    -- center panel
    local panel = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(360, 310),
        BackgroundTransparency = 1,
        ZIndex = 102,
        Parent = ov,
    }, { New("UIScale", { Scale = math.min(1, (vp.X - 24) / 360, (vp.Y - 24) / 310) }) })
    New("TextLabel", {
        Text = self.Name,
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        TextColor3 = Color3.fromRGB(236, 236, 241),
        Size = UDim2.new(1, 0, 0, 34),
        Parent = panel,
    })
    New("TextLabel", {
        Text = "32-bit compatibility check",
        TextColor3 = Theme.Mute,
        Position = UDim2.fromOffset(0, 34),
        Size = UDim2.new(1, 0, 0, 18),
        Parent = panel,
    })
    local listBox = New("Frame", {
        Position = UDim2.fromOffset(0, 62),
        Size = UDim2.new(1, 0, 0, 186),
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0.12,
        Parent = panel,
    }, { Stroke(Theme.Line) })
    local list = New("TextLabel", {
        Font = Enum.Font.Code,
        TextSize = 12,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Position = UDim2.fromOffset(10, 8),
        Size = UDim2.new(1, -20, 1, -16),
        Text = "",
        Parent = listBox,
    })
    local barBg = New("Frame", {
        Position = UDim2.fromOffset(0, 258),
        Size = UDim2.new(1, 0, 0, 5),
        BackgroundColor3 = Color3.fromRGB(37, 37, 44),
        BackgroundTransparency = 0,
        Parent = panel,
    })
    local fill = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = accent, BackgroundTransparency = 0, Parent = barBg })
    local status = New("TextLabel", {
        Text = "Starting up...",
        TextColor3 = Theme.Mute,
        Position = UDim2.fromOffset(0, 270),
        Size = UDim2.new(1, 0, 0, 18),
        RichText = true,
        Parent = panel,
    })

    -- real checks
    local function fps()
        local frames, t0 = 0, os.clock()
        local c = RunService.RenderStepped:Connect(function()
            frames = frames + 1
        end)
        task.wait(0.3)
        c:Disconnect()
        return frames / (os.clock() - t0)
    end
    local checks = {
        { "Platform", function()
            local t, k, g = UserInputService.TouchEnabled, UserInputService.KeyboardEnabled, UserInputService.GamepadEnabled
            return "ok", (t and not k) and "Mobile" or ((g and not k) and "Console" or "Desktop")
        end },
        { "Screen size", function()
            local v = workspace.CurrentCamera.ViewportSize
            return math.min(v.X, v.Y) >= 300 and "ok" or "fail", math.floor(v.X) .. "x" .. math.floor(v.Y)
        end },
        { "Client version", function()
            local ok, v = pcall(version)
            return ok and "ok" or "warn", ok and tostring(v) or "Unknown"
        end },
        { "Game loaded", function()
            local l = game:IsLoaded()
            return l and "ok" or "warn", l and "Loaded" or "Loading"
        end },
        { "Local player", function()
            return LocalPlayer and "ok" or "fail", LocalPlayer and LocalPlayer.Name or "Missing"
        end },
        { "PlayerGui", function()
            local pg = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
            return pg and "ok" or "warn", pg and "Found" or "Missing"
        end },
        { "Frame rate", function()
            local f = fps()
            return f >= 30 and "ok" or "warn", math.floor(f) .. " FPS"
        end },
        { "Network ping", function()
            local ok, p = pcall(function()
                return LocalPlayer:GetNetworkPing() * 1000
            end)
            if not ok then
                return "ok", "Not reported"
            end
            return p < 250 and "ok" or "warn", math.floor(p) .. " ms"
        end },
        { "Input", function()
            return "ok", UserInputService.KeyboardEnabled and "Keyboard + mouse" or "Touch"
        end },
    }
    for _, c in ipairs(self.ExtraChecks) do
        checks[#checks + 1] = c
    end

    local COL = { ok = "#4cd37b", warn = "#e5b13a", fail = "#ff5a5a" }
    local TAG = { ok = "OK", warn = "WARN", fail = "FAIL" }
    local rows, res = {}, { ok = 0, warn = 0, fail = 0 }
    local function render()
        list.Text = table.concat(rows, "\n")
    end

    typeLine("ARC3USX.EXE boot v" .. self.Version, "#c28bff")
    typeLine("init compat scanner ...", "#c28bff")
    for i, c in ipairs(checks) do
        typeLine(noise())
        typeLine(noise())
        rows[i] = string.format('%-17s %-17s <font color="#a43cff">...</font>', c[1], "")
        render()
        status.Text = "Checking " .. c[1]:lower() .. "..."
        typeLine("$ check " .. c[1]:lower() .. " ...", "#c28bff")
        task.wait(0.12)
        local okc, state, detail = pcall(c[2])
        if not okc or not COL[state] then
            state, detail = "warn", "Error"
        end
        detail = tostring(detail):sub(1, 17)
        res[state] = res[state] + 1
        rows[i] = string.format('%-17s <font color="#72727d">%-17s</font> <font color="%s">%s</font>', c[1], detail, COL[state], TAG[state])
        render()
        Tween(fill, 0.25, { Size = UDim2.fromScale(i / #checks, 1) })
        typeLine("  [" .. TAG[state] .. "] " .. detail, COL[state])
    end
    typeLine(noise())
    if res.fail > 0 then
        status.Text = '<font color="#ff5a5a">Not compatible: ' .. res.fail .. " check failed</font>"
        typeLine("compat: FAIL (" .. res.fail .. " failed)", "#ff6b6b")
        local btn = New("TextButton", {
            Text = "Continue anyway",
            BackgroundColor3 = Theme.P2,
            BackgroundTransparency = 0,
            Position = UDim2.fromOffset(110, 290),
            Size = UDim2.fromOffset(140, 22),
            Parent = panel,
        }, { Stroke(Theme.Line) })
        btn.MouseButton1Click:Wait()
        btn:Destroy()
    else
        local w = res.warn > 0
        status.Text = w and ('<font color="#e5b13a">Compatible with ' .. res.warn .. " warning(s)</font>")
            or '<font color="#4cd37b">Compatible: all checks passed</font>'
        typeLine("compat: PASS" .. (w and (" (" .. res.warn .. " warning(s))") or ""), w and "#ffd166" or "#6dffa5")
    end
    task.wait(0.6)

    -- layout for the reveal
    panel.Visible = false
    term.TextTransparency = 0.82
    local heroH = math.max(160, math.min(360, vp.Y - 200))
    local heroW = heroH * 500 / 654
    local boxW, boxH = math.min(420, vp.X - 24), 82
    local top = (vp.Y - (heroH + 14 + boxH)) / 2
    local cx, hy, by = vp.X / 2, top + heroH / 2, top + heroH + 14 + boxH / 2

    local function boxContent(f)
        f.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
        f.BackgroundTransparency = 0
        New("UIStroke", { Color = Color3.fromRGB(76, 211, 123), Thickness = 2, Parent = f })
        New("TextLabel", {
            Text = "ACCESS GRANTED",
            Font = Enum.Font.GothamBold,
            TextSize = math.floor(math.min(34, boxW / 12.5)),
            TextColor3 = Color3.fromRGB(109, 255, 165),
            Position = UDim2.fromOffset(0, 12),
            Size = UDim2.new(1, 0, 0, 44),
            Parent = f,
        })
        New("TextLabel", {
            Text = "COMPATIBILITY VERIFIED",
            Font = Enum.Font.Code,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(76, 211, 123),
            Position = UDim2.fromOffset(0, 58),
            Size = UDim2.new(1, 0, 0, 16),
            Parent = f,
        })
    end

    local hero = New("ImageLabel", {
        Image = self.Logo,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(cx, hy + 40),
        Size = UDim2.fromOffset(heroW, heroH),
        ImageTransparency = 1,
        ZIndex = 103,
        Parent = ov,
    })
    local glows = {}
    for _, g in ipairs({ { 0.42, 0.88 }, { 0.28, 0.72 }, { 0.17, 0.48 }, { 0.07, 0.12 } }) do
        local f = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.394, 0.124),
            Size = UDim2.fromScale(g[1], g[1]),
            SizeConstraint = Enum.SizeConstraint.RelativeYY,
            BackgroundColor3 = Color3.fromRGB(255, 40, 40),
            BackgroundTransparency = 1,
            Parent = hero,
        }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) })
        glows[#glows + 1] = { f, g[2] }
    end

    local box = New("CanvasGroup", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(cx, by),
        Size = UDim2.fromOffset(boxW, boxH),
        GroupTransparency = 1,
        ZIndex = 104,
        Parent = ov,
    })
    boxContent(box)
    local boxScale = New("UIScale", { Scale = 1.4, Parent = box })

    local function flash(col, tr)
        local f = New("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = col,
            BackgroundTransparency = tr or 0.55,
            ZIndex = 130,
            Parent = gui,
        })
        Tween(f, 0.5, { BackgroundTransparency = 1 })
        Debris:AddItem(f, 0.6)
    end

    -- ACCESS GRANTED pops up with the logo above it
    Tween(box, 0.35, { GroupTransparency = 0 })
    Tween(boxScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
    task.wait(0.25)
    Tween(hero, 0.8, { Position = UDim2.fromOffset(cx, hy), ImageTransparency = 0 }, Enum.EasingStyle.Back)
    task.wait(0.95)

    -- eye glow
    local glowing = true
    for _, g in ipairs(glows) do
        Tween(g[1], 0.4, { BackgroundTransparency = g[2] })
    end
    flash(Color3.fromRGB(255, 40, 40), 0.7)
    task.spawn(function()
        local t0 = os.clock()
        while glowing and hero.Parent do
            local k = 0.5 + 0.5 * math.sin((os.clock() - t0) * 5)
            for _, g in ipairs(glows) do
                g[1].BackgroundTransparency = math.clamp(g[2] - 0.1 * k, 0, 1)
            end
            task.wait()
        end
    end)
    task.wait(0.85)

    -- slice
    local slash = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(cx, by),
        Size = UDim2.fromOffset(0, 3),
        Rotation = -22,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        ZIndex = 110,
        Parent = ov,
    }, { New("UIStroke", { Color = accent, Thickness = 3 }) })
    Tween(hero, 0.14, { Position = UDim2.fromOffset(cx, hy + 40), Size = UDim2.fromOffset(heroW * 1.06, heroH * 1.06) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.wait(0.12)
    Tween(slash, 0.18, { Size = UDim2.fromOffset(boxW * 1.4, 3) })
    flash(Color3.new(1, 1, 1), 0.3)
    task.wait(0.16)

    box:Destroy()
    for _, side in ipairs({ -1, 1 }) do
        local half = New("CanvasGroup", {
            AnchorPoint = Vector2.new(side < 0 and 1 or 0, 0.5),
            Position = UDim2.fromOffset(cx, by),
            Size = UDim2.fromOffset(boxW / 2, boxH),
            BackgroundTransparency = 1,
            ZIndex = 104,
            Parent = ov,
        })
        local inner = New("Frame", {
            Position = UDim2.fromOffset(side < 0 and 0 or -boxW / 2, 0),
            Size = UDim2.fromOffset(boxW, boxH),
            Parent = half,
        })
        boxContent(inner)
        Tween(half, 1, {
            Position = UDim2.fromOffset(cx + side * boxW * 0.4, by + (side < 0 and 150 or 110)),
            Rotation = side * 14,
            GroupTransparency = 1,
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Debris:AddItem(half, 1.1)
    end
    Tween(slash, 0.3, { BackgroundTransparency = 1 })
    Tween(slash:FindFirstChildOfClass("UIStroke"), 0.3, { Transparency = 1 })
    Debris:AddItem(slash, 0.4)
    Tween(hero, 0.6, { Position = UDim2.fromOffset(cx, hy), Size = UDim2.fromOffset(heroW, heroH) }, Enum.EasingStyle.Quint)
    task.wait(0.75)

    -- pin on the logo slot of the real window
    local la, ls = win.LogoImg.AbsolutePosition, win.LogoImg.AbsoluteSize
    local tx, ty = la.X + ls.X / 2, la.Y + ls.Y / 2
    local pinParts = {}
    local function pin(p)
        p.Parent = ov
        p.ZIndex = 105
        pinParts[#pinParts + 1] = p
        return p
    end
    pin(New("Frame", { Position = UDim2.fromOffset(0, ty), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = accent, BackgroundTransparency = 0.55 }))
    pin(New("Frame", { Position = UDim2.fromOffset(tx, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = accent, BackgroundTransparency = 0.55 }))
    for i, d in ipairs({ 34, 58, 88 }) do
        local r = pin(New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(tx, ty),
            Size = UDim2.fromOffset(d * 3, d * 3),
            BackgroundTransparency = 1,
        }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }), New("UIStroke", { Color = accent, Thickness = 1.5, Transparency = 1 }) }))
        task.delay((i - 1) * 0.15, function()
            if r.Parent then
                Tween(r, 0.7, { Size = UDim2.fromOffset(d, d) }, Enum.EasingStyle.Quint)
                Tween(r:FindFirstChildOfClass("UIStroke"), 0.5, { Transparency = 0 })
            end
        end)
    end
    pin(New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(tx, ty),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = Color3.fromRGB(255, 60, 60),
        BackgroundTransparency = 0,
    }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }) }))
    pin(New("TextLabel", {
        Text = "LOGO SLOT // LOCKED",
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.fromOffset(tx + 30, ty + 26),
        Size = UDim2.fromOffset(200, 14),
    }))
    task.wait(1.3)

    -- circle in and smash
    glowing = false
    local X, Y = cx, hy
    local R0 = math.max(120, math.sqrt((X - tx) ^ 2 + (Y - ty) ^ 2))
    local Ro = math.max(60, math.min(130, tx - 8, R0))
    local th0 = math.atan2(Y - ty, X - tx)
    local s1 = 18 / heroH
    local done, t0 = false, os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local t = math.min(1, (os.clock() - t0) / 2.2)
        local R = t < 0.25 and (R0 + (Ro - R0) * es(t / 0.25)) or (Ro * (1 - ((t - 0.25) / 0.75) ^ 2.2))
        local f = t < 0.3 and (1 - 0.7 * es(t / 0.3)) or (0.3 + (s1 - 0.3) * ((t - 0.3) / 0.7) ^ 1.6)
        local th = th0 + t * 5 * math.pi
        hero.Position = UDim2.fromOffset(tx + R * math.cos(th), ty + R * math.sin(th))
        hero.Size = UDim2.fromOffset(heroW * f, heroH * f)
        hero.Rotation = math.deg(t * 10)
        if t >= 1 then
            conn:Disconnect()
            done = true
        end
    end)
    while not done do
        task.wait()
    end

    -- impact
    hero.Visible = false
    for _, p in ipairs(pinParts) do
        p:Destroy()
    end
    flash(Color3.new(1, 1, 1), 0.1)
    for i = 0, 1 do
        local ring = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(tx, ty),
            Size = UDim2.fromOffset(40, 40),
            BackgroundTransparency = 1,
            ZIndex = 125,
            Parent = gui,
        }, { New("UICorner", { CornerRadius = UDim.new(1, 0) }), New("UIStroke", { Color = accent, Thickness = 3 }) })
        task.delay(i * 0.12, function()
            Tween(ring, 0.8, { Size = UDim2.fromOffset(300, 300) })
            Tween(ring:FindFirstChildOfClass("UIStroke"), 0.8, { Transparency = 1 })
        end)
        Debris:AddItem(ring, 1.2)
    end
    for _ = 1, 18 do
        local p = New("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(tx, ty),
            Size = UDim2.fromOffset(4, 4),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 0,
            ZIndex = 125,
            Parent = gui,
        })
        local a, d = math.random() * math.pi * 2, 50 + math.random() * 110
        Tween(p, 0.6 + math.random() * 0.4, { Position = UDim2.fromOffset(tx + math.cos(a) * d, ty + math.sin(a) * d), BackgroundTransparency = 1 })
        Debris:AddItem(p, 1.1)
    end
    task.spawn(function()
        local base = win.Root.Position
        for _ = 1, 6 do
            win.Root.Position = base + UDim2.fromOffset(math.random(-7, 7), math.random(-5, 5))
            task.wait(0.045)
        end
        win.Root.Position = base
    end)
    win.LogoImg.Size = UDim2.fromOffset(54, 54)
    Tween(win.LogoImg, 0.5, { Size = UDim2.fromOffset(18, 18) }, Enum.EasingStyle.Back)
    term:Destroy()
    Tween(ov, 0.5, { BackgroundTransparency = 1 })
    task.wait(0.6)
    ov:Destroy()
end

return Library
