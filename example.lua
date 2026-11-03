-- ARC3USX.EXE UI Library | example.lua
-- Load the library (pick ONE):
--   A) From your GitHub repo (replace USER / REPO / BRANCH):
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/BRANCH/ARC3USX.lua"))()
--   B) As a ModuleScript in Roblox Studio:
--   local Library = require(script.Parent:WaitForChild("ARC3USX"))

-- Optional settings (set BEFORE CreateWindow)
-- Option 1: use the PNG straight from your GitHub repo (executors with file support)
Library.LogoUrl = "https://raw.githubusercontent.com/USER/REPO/BRANCH/logo.png"
-- Option 2 / fallback: an uploaded Roblox asset id
Library.Logo = "rbxassetid://0"
-- Library.Accent = Color3.fromRGB(164, 60, 255)
-- Library.MenuKey = Enum.KeyCode.Insert

local Window = Library:CreateWindow({
    Name = "ARC3USX.EXE",
    Size = Vector2.new(560, 500),
    Intro = true, -- set to false to skip the loading / ACCESS GRANTED animation
    Theme = "Purple", -- any built-in theme name (see README) or one you registered
})

-- Make your own theme (shows up in Settings > Theme automatically):
-- Library:RegisterTheme("My Theme", {
--     Bg = Color3.fromRGB(12, 12, 12), P1 = Color3.fromRGB(20, 20, 20), P2 = Color3.fromRGB(28, 28, 28),
--     Input = Color3.fromRGB(32, 32, 32), Line = Color3.fromRGB(50, 50, 50), Box = Color3.fromRGB(44, 44, 44),
--     BoxLine = Color3.fromRGB(64, 64, 64), Text = Color3.fromRGB(220, 220, 220), Mute = Color3.fromRGB(120, 120, 120),
--     Accent = Color3.fromRGB(255, 80, 80),
-- })
-- Library:SetTheme("My Theme")

------------------------------------------------------------------
-- Main tab
------------------------------------------------------------------
local Main = Window:AddTab("Main")

local General = Main:AddGroup("General", "Left")
General:AddToggle({
    Name = "Enabled",
    Flag = "enabled",
    Bind = true, -- adds a [...] keybind button that toggles this option
    Callback = function(v)
        print("Enabled:", v)
    end,
})
General:AddToggle({ Name = "Auto Select", Flag = "autoselect" })
General:AddDropdown({
    Name = "Mode",
    Flag = "mode",
    Options = { "Mouse", "Center", "Closest" },
    Default = "Mouse",
    Callback = function(v)
        print("Mode:", v)
    end,
})
General:AddSlider({ Name = "Range", Flag = "range", Min = 0, Max = 180, Default = 100, Suffix = "°" })
General:AddSlider({ Name = "Delay", Flag = "delay", Min = 0, Max = 500, Default = 40, Suffix = "ms" })
General:AddLabel("Welcome to ARC3USX.EXE >_<")

local Display = Main:AddGroup("Display", "Right")
Display:AddToggle({
    Name = "Outline",
    Flag = "outline",
    Colors = { Color3.fromRGB(106, 31, 196) }, -- color swatch(es) next to the toggle
    ColorCallback = function(index, color)
        print("Outline color", index, color)
    end,
})
Display:AddToggle({
    Name = "Labels",
    Flag = "labels",
    Colors = { Color3.new(0, 0, 0), Color3.fromRGB(106, 31, 196) },
})
Display:AddColor({ Name = "Accent preview", Flag = "preview", Default = Color3.fromRGB(176, 112, 224) })
Display:AddTextbox({
    Name = "Custom text",
    Flag = "text",
    Placeholder = "Type here",
    Callback = function(v)
        print("Text:", v)
    end,
})
Display:AddKeybind({
    Name = "Quick action",
    Flag = "quick",
    Default = Enum.KeyCode.F,
    Callback = function()
        Library:Notify("Quick action pressed")
    end,
})
Display:AddButton({
    Name = "Say hello",
    Callback = function()
        Library:Notify("Hello from ARC3USX.EXE!")
    end,
})

------------------------------------------------------------------
-- Visuals tab: ESP options + live ESP preview
-- (the preview only shows how your settings would look; it does not draw anything in the game)
------------------------------------------------------------------
local Visuals = Window:AddTab("Visuals")
local white, accent = Color3.new(1, 1, 1), Color3.fromRGB(164, 60, 255)

local ESP = Visuals:AddGroup("ESP", "Left")
ESP:AddToggle({ Name = "Box", Flag = "esp_box", Default = true, Colors = { white, accent } }) -- [1] outline, [2] fill
ESP:AddDropdown({ Name = "Box Style", Flag = "esp_style", Options = { "Full", "Corners" }, Default = "Full" })
ESP:AddToggle({ Name = "Box Fill", Flag = "esp_fill" })
ESP:AddToggle({ Name = "Name", Flag = "esp_name", Default = true, Colors = { white } })
ESP:AddToggle({ Name = "Health Bar", Flag = "esp_health", Default = true })
ESP:AddToggle({ Name = "Distance", Flag = "esp_dist", Default = true, Colors = { white } })
ESP:AddToggle({ Name = "Tool", Flag = "esp_tool", Colors = { white } })
ESP:AddToggle({ Name = "Tracer", Flag = "esp_tracer", Colors = { accent } })
ESP:AddToggle({ Name = "Skeleton", Flag = "esp_skel", Colors = { white } })
ESP:AddToggle({ Name = "Chams", Flag = "esp_chams", Colors = { accent, white } }) -- [1] fill, [2] outline

local Preview = Visuals:AddGroup("ESP Preview", "Right")
Preview:AddESPPreview({
    Height = 280,
    PlayerName = "Player",
    Elements = {
        Box = "esp_box", BoxStyle = "esp_style", BoxFill = "esp_fill",
        Name = "esp_name", Health = "esp_health", Distance = "esp_dist", Tool = "esp_tool",
        Tracer = "esp_tracer", Skeleton = "esp_skel", Chams = "esp_chams",
    },
})

------------------------------------------------------------------
-- Extra tabs (same API)
------------------------------------------------------------------
local Misc = Window:AddTab("Misc")
local Utility = Misc:AddGroup("Utility", "Left")
Utility:AddToggle({ Name = "Show watermark", Flag = "watermark" })
Utility:AddToggle({ Name = "Show FPS", Flag = "fps" })
local Info = Misc:AddGroup("Info", "Right")
Info:AddLabel("Version " .. Library.Version)

------------------------------------------------------------------
-- Settings tab: configs, menu bind, accent color, replay intro, unload
------------------------------------------------------------------
Window:AddSettingsTab()

-- Reading values anywhere:
--   Library.Flags.enabled        --> true / false
--   Library.Options.range:Set(50)
--   Library:Serialize()          --> JSON string of every option
--   Library:Deserialize(json)

-- Auto-load: in Settings > Configs, select a config and enable "Auto Load Selected".
-- If you add controls after Window:AddSettingsTab() with a delay, call Window:AutoLoad() at the end.
-- Appearance: Library:SetFont("Gotham"), Library:SetUIScale(1.1), Library:SetOpacity(0.9)
