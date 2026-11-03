-- Integration test for the real UI, intro, mix, logo, full script and unload.
-- Run with Lua 5.3 or fengari from the repository root; not a Roblox substitute.
local now = 0
os.clock = function() return now end
local tasks, failures = {}, {}
task = {}
local function schedule(fn, delay, ...)
    local args = {...}
    table.insert(tasks, { co = coroutine.create(function() fn(table.unpack(args)) end), wake = now + (delay or 0) })
end
function task.spawn(fn, ...) schedule(fn, 0, ...) end
function task.defer(fn, ...) schedule(fn, 0, ...) end
function task.delay(delay, fn, ...) schedule(fn, delay, ...) end
function task.wait(seconds) return coroutine.yield(seconds or 0.03) end
local function signal()
    local s = { listeners = {} }
    function s:Connect(fn)
        local c = { connected = true }
        function c:Disconnect() self.connected = false end
        table.insert(self.listeners, { fn = fn, connection = c })
        return c
    end
    function s:Fire(...)
        for _, item in ipairs(self.listeners) do if item.connection.connected then item.fn(...) end end
    end
    return s
end
local function enumSet()
    return setmetatable({}, { __index = function(t, key)
        local v = { Name = key }; rawset(t, key, v); return v
    end })
end
Enum = setmetatable({}, { __index = function(t, key) local e = enumSet(); rawset(t, key, e); return e end })
local function color(r,g,b)
    return { R = r, G = g, B = b, Lerp = function(a, b, t) return color(a.R+(b.R-a.R)*t, a.G+(b.G-a.G)*t, a.B+(b.B-a.B)*t) end }
end
Color3 = { new = color, fromRGB = function(r,g,b) return color(r/255,g/255,b/255) end }
local v2meta = { __add = function(a,b) return setmetatable({ X = a.X+b.X, Y = a.Y+b.Y }, getmetatable(a)) end,
    __div = function(a,b) return setmetatable({ X = a.X/b, Y = a.Y/b }, getmetatable(a)) end,
    __sub = function(a,b) return setmetatable({ X = a.X-b.X, Y = a.Y-b.Y }, getmetatable(a)) end,
    __index = function(a,k) if k == "Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y) end end }
Vector2 = { new = function(x,y) return setmetatable({X=x,Y=y},v2meta) end }
local v3meta = { __sub = function(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y,Z=a.Z-b.Z},getmetatable(a)) end,
    __index = function(a,k) if k == "Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end end }
Vector3 = { new = function(x,y,z) return setmetatable({X=x,Y=y,Z=z},v3meta) end }
local udmeta = { __add = function(a,b) return a end }
local function udim2(xs,xo,ys,yo)
    xs,xo,ys,yo=xs or 0,xo or 0,ys or 0,yo or 0
    return setmetatable({xs,xo,ys,yo,X={Scale=xs,Offset=xo},Y={Scale=ys,Offset=yo}},udmeta)
end
UDim2 = { new = udim2, fromOffset = function(x,y) return udim2(0,x,0,y) end, fromScale = function(x,y) return udim2(x,0,y,0) end }
UDim = { new = function(...) return {...} end }
TweenInfo = { new = function(...) return {...} end }
CFrame = { new = function(p) return { Position = p } end }
math.clamp = function(n,lo,hi) return math.max(lo,math.min(hi,n)) end
math.atan2 = math.atan2 or function(y,x) return math.atan(y,x) end
table.find = function(t, value) for i,v in ipairs(t) do if v == value then return i end end end
typeof = type
warn = function(s) io.stderr:write(tostring(s) .. "\n") end
local objects = {}
local guiClasses = { ScreenGui=true,Frame=true,TextLabel=true,TextButton=true,TextBox=true,ImageLabel=true,ImageButton=true,ScrollingFrame=true,CanvasGroup=true }
local function object(class)
    local o = { ClassName=class, Name=class, children={}, signals={}, AbsolutePosition=Vector2.new(100,100), AbsoluteSize=Vector2.new(400,400), Position=UDim2.new(), Visible=true }
    table.insert(objects,o)
    function o:IsA(name) return self.ClassName == name or (name == "GuiObject" and guiClasses[self.ClassName] and self.ClassName ~= "ScreenGui") end
    function o:GetChildren() local r={}; for _,v in ipairs(objects) do if v.Parent==self then r[#r+1]=v end end; return r end
    function o:FindFirstChild(name) for _,v in ipairs(self:GetChildren()) do if v.Name==name then return v end end end
    function o:FindFirstChildOfClass(name) for _,v in ipairs(self:GetChildren()) do if v.ClassName==name then return v end end end
    function o:FindFirstChildWhichIsA(name) return self:FindFirstChildOfClass(name) end
    function o:GetPropertyChangedSignal(name) self.signals[name]=self.signals[name] or signal(); return self.signals[name] end
    function o:Destroy() self.Parent=nil; self.destroyed=true; for _,v in ipairs(self:GetChildren()) do v:Destroy() end end
    function o:IsDescendantOf(other) local p=self.Parent; while p do if p==other then return true end; p=p.Parent end; return false end
    return setmetatable(o, { __index=function(t,k)
        if k=="MouseButton1Click" or k=="MouseEnter" or k=="MouseLeave" or k=="InputBegan" or k=="InputChanged" or k=="InputEnded" or k=="FocusLost" or k=="Changed" then
            local s=signal(); rawset(t,k,s); return s
        end
    end })
end
Instance={ new=object }
local root=object("Workspace")
workspace=root
root.DescendantAdded,root.DescendantRemoving=signal(),signal()
function root:GetDescendants() return {} end
function root:Raycast() return nil end
root.CurrentCamera=object("Camera")
root.CurrentCamera.Parent=root
root.CurrentCamera.ViewportSize=Vector2.new(1280,720)
root.CurrentCamera.CFrame={Position=Vector3.new(0,0,0)}
function root.CurrentCamera:WorldToViewportPoint() return {X=500,Y=300,Z=10} end
local player=object("Player"); player.Name="Local"; player.CharacterAdded=signal(); player.CharacterRemoving=signal()
local pg=object("PlayerGui"); pg.Parent=player; pg.ScreenOrientation=Enum.ScreenOrientation.Sensor
function player:WaitForChild() return pg end
function player:GetNetworkPing() return 0.05 end
local players={LocalPlayer=player,PlayerAdded=signal(),PlayerRemoving=signal()}
function players:GetPlayers() return {player} end
function players:GetPlayerFromCharacter() return nil end
local render,heartbeat=signal(),signal()
local run={RenderStepped=render,Heartbeat=heartbeat}
local tween={}
function tween:Create(o,_,props) return {Play=function() for k,v in pairs(props) do o[k]=v end end} end
local input={TouchEnabled=false, KeyboardEnabled=true, MouseEnabled=true, GamepadEnabled=false, InputBegan=signal(), InputChanged=signal(), InputEnded=signal()}
function input:GetPlatform() return {Name = self.platformName or "Windows"} end
local http={JSONEncode=function() return "{}" end,JSONDecode=function() return {} end}
local debris={AddItem=function(_,o,seconds) task.delay(seconds, function() o:Destroy() end) end}
local rep=object("ReplicatedStorage"); function rep:WaitForChild() return nil end
local services={Players=players,RunService=run,TweenService=tween,UserInputService=input,HttpService=http,Debris=debris,CoreGui=object("CoreGui"),ReplicatedStorage=rep,StarterGui={SetCore=function() end}}
game={ GetService=function(_,name) assert(services[name],name); return services[name] end,
    HttpGet=function(_,url) return url end, IsLoaded=function() return true end }
version=function() return "test" end
local environment={}; getgenv=function() return environment end
local filesystem={}; local dirs={}
isfolder=function(p) return dirs[p] or false end
makefolder=function(p) dirs[p]=true end
isfile=function(p) return filesystem[p] ~= nil end
writefile=function(p,data) filesystem[p]=data end
readfile=function(p) return filesystem[p] or error("missing " .. p) end
getcustomasset=function(p) return "mockasset://"..p end
Drawing={new=function(class) return { Visible=false, Remove=function(self) self.removed=true end } end}
RaycastParams={new=function() return {} end}
local sampleGun={ rate=1, auto=false, spread=0.5, adsSpread=0.5, moveSpread=0.5, EQUIP_TIME=2, SpreadPx=4, equipAt=5 }
getgc=function() return {sampleGun} end
setreadonly=function() end
local loadedLibrary, disableMix
loadstring=function(url)
    local path=url:match("refs/heads/arena/da1d5ede%-arceus%-x/(.+)$")
    if not path then error("Unexpected URL " .. url) end
    if disableMix and path == "ARC3USX_NH.lua" then error("simulated missing mix") end
    local chunk=assert(loadfile(path))
    if path=="ARC3USX.lua" then return function() loadedLibrary=chunk(); return loadedLibrary end end
    return chunk
end
local function step(seconds)
    for _=1,math.floor(seconds/0.05) do
        now=now+0.05
        render:Fire(0.05); heartbeat:Fire(0.05)
        local copy=tasks; tasks={}
        for _,t in ipairs(copy) do
            if t.wake<=now then
                local ok,delay=coroutine.resume(t.co)
                if not ok then failures[#failures+1]=delay
                elseif coroutine.status(t.co)~="dead" then t.wake=now+(tonumber(delay) or 0.03); tasks[#tasks+1]=t end
            else tasks[#tasks+1]=t end
        end
    end
end
schedule(assert(loadfile("scripts/main.lua")),0)
step(3)
local loadingGui=pg:FindFirstChild("ARC3USX")
assert(loadingGui and loadingGui:FindFirstChild("Intro"), "intro appears while loading")
step(57)
assert(#failures==0, table.concat(failures,"; "))
assert(type(environment.ARC3USX_MAIN_UNLOAD)=="function", "main loaded")
assert(type(environment.ARC3USX_ESP_UNLOAD)=="function", "ESP loaded")
assert(filesystem["ARC3USX/logo-embedded.png"]:sub(1,8)=="\137PNG\r\n\26\n", "embedded PNG created")
local gui=pg:FindFirstChild("ARC3USX")
assert(gui and not gui:FindFirstChild("Intro"), "intro completed")
local foundHud,foundLogo,foundIntroLogo=false,false,false
for _,o in ipairs(objects) do
    if o.Parent and o.Name=="NH_Watermark" then foundHud=true end
    if (o.ClassName=="ImageLabel" or o.ClassName=="ImageButton") and o.Image=="mockasset://ARC3USX/logo-embedded.png" then
        if o.Parent then foundLogo=true end
        if o.destroyed then foundIntroLogo=true end
    end
end
assert(foundHud and foundLogo and foundIntroLogo, "mix HUD, title logo and intro logo applied")
for _, flag in ipairs({ "esp_master", "esp_rate", "plr_enabled", "plr_tracer", "plr_visible_only", "plr_ignore_team", "npc_enabled", "npc_health", "npc_skel", "npc_tracer", "npc_visible_only", "ore_enabled", "ore_name", "ore_marker", "heli_enabled", "loot_master", "loot_enabled", "loot_name", "loot_dist", "loot_chams", "dep_master", "dep_enabled", "dep_turret", "dep_bag", "dep_cupboard", "dep_other", "dep_name", "dep_dist", "dep_chams", "staff_monitor", "staff_esp", "gunmods_enabled", "bowmods_enabled", "universal_ammo", "universal_noair", "weakspot_enabled", "NH_Mix" }) do
    assert(loadedLibrary.Options[flag], "control missing: "..flag)
end
loadedLibrary.Options.NH_Mix:Set("Blood Eye")
step(0.2)
assert(loadedLibrary.ThemeName=="NH Blood Eye" and loadedLibrary.Flags.NH_KeybindList==false, "mix selector applies and synchronizes HUD controls")
loadedLibrary.Options.gunmods_enabled:Set(true)
loadedLibrary.Options.gunmods_inst_equip:Set(true)
loadedLibrary.Options.gunmods_nospread:Set(true)
step(2.2)
assert(sampleGun.EQUIP_TIME==0.001 and sampleGun.rate==0.05 and sampleGun.SpreadPx==0, "combat callbacks and scanner work on matching tables")
loadedLibrary.Options.gunmods_enabled:Set(false)
step(2.2)
assert(sampleGun.EQUIP_TIME==2 and sampleGun.rate==1 and sampleGun.spread==0.5, "combat settings restored when disabled")
local oldIntro = loadedLibrary._RunIntro
loadedLibrary._RunIntro = function(self)
    local overlay=object("Frame"); overlay.Name="Intro"; overlay.Parent=self.Gui
    error("simulated intro failure")
end
local activeWindow = loadedLibrary._windows[1]
activeWindow:Replay()
step(0.2)
assert(activeWindow._ready and activeWindow.Root.Visible and not gui:FindFirstChild("Intro"), "intro failure opens menu and cleans overlay")
loadedLibrary._RunIntro = oldIntro
loadedLibrary:Unload() -- Settings' Unload Menu calls this path.
step(1)
assert(environment.ARC3USX_MAIN_UNLOAD==nil and environment.ARC3USX_ESP_UNLOAD==nil and not gui.Parent, "library unload cleans all")
assert(#failures==0, table.concat(failures,"; "))

-- Missing logo APIs and a failed mix download should not prevent the stock UI opening.
disableMix=true
getcustomasset=nil
schedule(assert(loadfile("scripts/main.lua")),0)
step(60)
assert(type(environment.ARC3USX_MAIN_UNLOAD)=="function" and type(environment.ARC3USX_ESP_UNLOAD)=="function", "fallback still loads all modules")
local fallback=pg:FindFirstChild("ARC3USX")
assert(fallback and not fallback:FindFirstChild("Intro"), "fallback intro completes")
assert(loadedLibrary.Options.plr_enabled and loadedLibrary.Options.gunmods_enabled, "fallback has feature controls")
environment.ARC3USX_MAIN_UNLOAD()
step(1)
assert(#failures==0, table.concat(failures,"; "))

-- Reinjection while the first intro is still running must cancel the first startup.
disableMix=false
getcustomasset=function(p) return "mockasset://"..p end
schedule(assert(loadfile("scripts/main.lua")),0)
step(3)
schedule(assert(loadfile("scripts/main.lua")),0)
step(60)
local guis=0
for _,o in ipairs(objects) do if o.ClassName=="ScreenGui" and o.Name=="ARC3USX" and o.Parent==pg then guis=guis+1 end end
assert(guis==1 and type(environment.ARC3USX_ESP_UNLOAD)=="function", "reinjection cancels in-flight startup")
environment.ARC3USX_MAIN_UNLOAD()
step(1)
assert(#failures==0, table.concat(failures,"; "))

-- iOS portrait: show a touch profile and a readable single-column layout.
input.TouchEnabled, input.KeyboardEnabled, input.MouseEnabled, input.platformName = true, false, false, "IOS"
root.CurrentCamera.ViewportSize = Vector2.new(390, 844)
schedule(assert(loadfile("scripts/main.lua")), 0)
step(8)
local mobileGui = pg:FindFirstChild("ARC3USX")
local reportedMobile = false
for _, o in ipairs(objects) do
    if o:IsDescendantOf(mobileGui) and type(o.Text)=="string" and o.Text:find("Mobile IOS",1,true) then reportedMobile=true end
end
assert(reportedMobile, "intro displays detected device")
assert(pg.ScreenOrientation==Enum.ScreenOrientation.LandscapeSensor, "mobile requests landscape orientation")
step(52)
local mobileWindow = loadedLibrary._windows[1]
assert(loadedLibrary.Device.Kind=="Mobile" and loadedLibrary.Device.Touch and loadedLibrary.Device.Orientation=="Portrait", "iOS touch device detected")
input.platformName="Android"
assert(loadedLibrary:DetectDevice().Kind=="Mobile", "Android detected")
input.platformName="Windows"; input.KeyboardEnabled=true; input.MouseEnabled=true
assert(loadedLibrary:DetectDevice().Kind=="Hybrid", "touch desktop detected as hybrid")
input.platformName="XboxOne"; input.TouchEnabled=false; input.KeyboardEnabled=false; input.MouseEnabled=false; input.GamepadEnabled=true
assert(loadedLibrary:DetectDevice().Kind=="Console", "gamepad console detected")
input.platformName="IOS"; input.TouchEnabled=true; input.KeyboardEnabled=false; input.MouseEnabled=false; input.GamepadEnabled=false
assert(mobileWindow.Touch and mobileWindow.SingleColumn and mobileWindow._logicalWidth==374 and mobileWindow.Scale.Scale==1, "portrait uses full-size one-column layout")
assert(mobileWindow.Tabs[1].Left.Size[1]==1 and mobileWindow.Tabs[1].Right.Size[1]==1, "portrait stacks full-width columns")
local hide
for _, o in ipairs(objects) do if o.Name=="HideMenu" and o:IsDescendantOf(mobileGui) then hide=o end end
assert(hide, "touch close button exists")
hide.MouseButton1Click:Fire()
assert(not mobileWindow.Root.Visible and mobileWindow.Fab.Visible, "touch close shows floating reopen button")
mobileWindow.Fab.MouseButton1Click:Fire()
assert(mobileWindow.Root.Visible and mobileWindow.Fab.Visible, "floating button reopens menu and stays visible")
mobileWindow.Fab.MouseButton1Click:Fire()
assert(not mobileWindow.Root.Visible and mobileWindow.Fab.Visible, "floating button minimizes menu")
mobileWindow.Fab.MouseButton1Click:Fire()
mobileWindow.Fab.AbsolutePosition=Vector2.new(300,300)
mobileWindow.Fab.AbsoluteSize=Vector2.new(52,52)
local fabFinger={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(310,310,0)}
local otherFinger={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(900,900,0)}
mobileWindow.Fab.InputBegan:Fire(fabFinger)
input.InputChanged:Fire(otherFinger)
assert(mobileWindow.Fab.Position.X.Scale==1, "another touch cannot drag the floating button")
fabFinger.Position=Vector3.new(1000,1000,0)
input.InputChanged:Fire(fabFinger)
assert(mobileWindow.Fab.Position.X.Offset==364 and mobileWindow.Fab.Position.Y.Offset==818, "floating button drag clamps to screen")
input.InputEnded:Fire(fabFinger)
mobileWindow.Fab.MouseButton1Click:Fire()
assert(mobileWindow.Root.Visible, "drag does not toggle menu")
mobileWindow.Root.AbsolutePosition=Vector2.new(20,100)
mobileWindow.Root.AbsoluteSize=Vector2.new(300,500)
local dragTouch={UserInputType=Enum.UserInputType.Touch,Position=Vector3.new(30,110,0)}
hide.Parent.InputBegan:Fire(dragTouch)
dragTouch.Position=Vector3.new(1000,1000,0)
input.InputChanged:Fire(dragTouch)
assert(mobileWindow.Root.Position.X.Offset==70 and mobileWindow.Root.Position.Y.Offset==244, "touch dragging keeps the menu on screen")
input.InputEnded:Fire(dragTouch)
local bar
for _, o in ipairs(objects) do
    if o.ClassName=="TextLabel" and o.Text=="Max Distance" and o:IsDescendantOf(mobileWindow.Tabs[1].Left) then
        bar=o.Parent:FindFirstChild("SliderBar"); if bar then break end
    end
end
assert(bar and bar.Active and bar:FindFirstChild("SliderThumb"), "touch slider has an active hit target and thumb")
local minus, plus = bar.Parent:FindFirstChild("SliderDecrease"), bar.Parent:FindFirstChild("SliderIncrease")
assert(minus and plus, "touch slider has step buttons")
local before = loadedLibrary.Options.plr_max_dist.Value
plus.MouseButton1Click:Fire()
assert(loadedLibrary.Options.plr_max_dist.Value == before + 1, "plus increases slider")
minus.MouseButton1Click:Fire()
assert(loadedLibrary.Options.plr_max_dist.Value == before, "minus decreases slider")
local first={UserInputType=Enum.UserInputType.Touch, Position=Vector3.new(150,100,0)}
local second={UserInputType=Enum.UserInputType.Touch, Position=Vector3.new(450,100,0)}
bar.InputBegan:Fire(first)
local initialValue=loadedLibrary.Options.plr_max_dist.Value
input.InputChanged:Fire(second)
assert(loadedLibrary.Options.plr_max_dist.Value==initialValue, "other finger does not move slider")
first.Position=Vector3.new(350,100,0)
input.InputChanged:Fire(first)
assert(loadedLibrary.Options.plr_max_dist.Value~=initialValue, "original finger moves slider")
input.InputEnded:Fire(first)

root.CurrentCamera.ViewportSize=Vector2.new(844,390)
root.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Fire()
assert(not mobileWindow.SingleColumn and loadedLibrary.Device.Orientation=="Landscape", "rotation switches to landscape layout")
assert(mobileWindow.Tabs[1].Left.Size[1]==0.5, "landscape restores two columns")
local oldCamera=root.CurrentCamera
local newCamera=object("Camera"); newCamera.Parent=root; newCamera.ViewportSize=Vector2.new(390,844); newCamera.CFrame={Position=Vector3.new(0,0,0)}
function newCamera:WorldToViewportPoint() return {X=500,Y=300,Z=10} end
root.CurrentCamera=newCamera
root:GetPropertyChangedSignal("CurrentCamera"):Fire()
assert(mobileWindow.SingleColumn and loadedLibrary.Device.Orientation=="Portrait", "camera replacement updates layout")
oldCamera.ViewportSize=Vector2.new(1000,600)
oldCamera:GetPropertyChangedSignal("ViewportSize"):Fire()
assert(mobileWindow.SingleColumn, "old camera no longer drives layout")
loadedLibrary.Options.NH_Mix:Set("Sakura")
step(0.2)
assert(loadedLibrary.ThemeName=="Sakura", "new mix is selectable")
environment.ARC3USX_MAIN_UNLOAD()
step(1)
assert(pg.ScreenOrientation==Enum.ScreenOrientation.Sensor, "unload restores original orientation")

-- Rotation arriving during startup uses landscape for the initial window.
local rotatedWindow
schedule(function() rotatedWindow=loadedLibrary:CreateWindow({MobileLandscape=true,Intro=false}) end,0)
step(0.2)
assert(pg.ScreenOrientation==Enum.ScreenOrientation.LandscapeSensor and not rotatedWindow, "startup waits for rotation")
root.CurrentCamera.ViewportSize=Vector2.new(844,390)
step(0.2)
assert(rotatedWindow and not rotatedWindow.SingleColumn, "startup continues with landscape layout")
pg.ScreenOrientation=Enum.ScreenOrientation.Portrait
loadedLibrary:Unload()
assert(pg.ScreenOrientation==Enum.ScreenOrientation.Portrait, "unload preserves another orientation change")

-- Cancel an in-flight orientation wait without leaving a window or changing orientation.
pg.ScreenOrientation=Enum.ScreenOrientation.Sensor
root.CurrentCamera.ViewportSize=Vector2.new(390,844)
local cancelledWindow="pending"
schedule(function() cancelledWindow=loadedLibrary:CreateWindow({MobileLandscape=true,Intro=false}) end,0)
step(0.2)
loadedLibrary:Unload()
step(0.2)
assert(cancelledWindow==nil and pg.ScreenOrientation==Enum.ScreenOrientation.Sensor and #loadedLibrary._windows==0, "unload cancels orientation wait")
assert(#failures==0, table.concat(failures,"; "))
print("Real UI, mobile layout, device checks, controls, themes, intro, reinjection, unload and fallback mock integration passed")
