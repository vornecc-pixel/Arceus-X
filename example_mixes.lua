local Library = loadstring(readfile("ARC3USX.lua"))()
local Logo = loadstring(readfile("logo.lua"))()
local Mix = loadstring(readfile("ARC3USX_NH.lua"))()

local Window = Mix.CreateWindow(Library, {
    Logo = Logo,
    Mix = "NH Classic", -- NH Classic | Arceus Purple | Blood Eye | Frost Glass | Terminal
})

local Combat = Window:AddTab("Combat")
local Main = Combat:AddGroup("Main", "Left")
Main:AddToggle({ Name = "Aimbot", Bind = true, BindDefault = Enum.KeyCode.E })
Main:AddToggle({ Name = "Fly", Bind = true, BindDefault = Enum.KeyCode.F })
Main:AddSlider({ Name = "Smoothing", Min = 0, Max = 100, Default = 35 })
Main:AddDropdown({ Name = "Target part", Options = { "Head", "Torso", "Legs" }, Default = "Head" })

local Visuals = Window:AddTab("Visuals")
local Esp = Visuals:AddGroup("ESP", "Left")
Esp:AddToggle({ Name = "Boxes", Colors = { Color3.fromRGB(152, 188, 255) } })
Esp:AddToggle({ Name = "Names" })

Mix.AddTab(Library, Window)
Window:AddSettingsTab()
