-- Main-script silent aim integration with a mocked game and executor (not Roblox).
local now, queue, errors = 0, {}, {}
os.clock = function() return now end
task = {}
function task.spawn(fn, ...) local args={...}; queue[#queue+1]={co=coroutine.create(function() fn(table.unpack(args)) end),at=now} end
function task.wait(n) return coroutine.yield(n or 0.05) end
function task.delay(n,fn,...) local args={...}; task.spawn(function() task.wait(n); fn(table.unpack(args)) end) end
local function signal()
    local s={listeners={}}
    function s:Connect(fn) local c={connected=true}; function c:Disconnect() self.connected=false end; self.listeners[#self.listeners+1]={fn=fn,c=c}; return c end
    function s:Fire(...) for _,v in ipairs(self.listeners) do if v.c.connected then v.fn(...) end end end
    return s
end
local function step(n)
    for _=1,math.floor(n/0.05) do
        now=now+0.05
        local pending=queue;queue={}
        for _,v in ipairs(pending) do
            if v.at<=now then
                local ok,delay=coroutine.resume(v.co)
                if not ok then errors[#errors+1]=delay
                elseif coroutine.status(v.co)~="dead" then v.at=now+(tonumber(delay) or 0.05);queue[#queue+1]=v end
            else queue[#queue+1]=v end
        end
    end
end
local V={}
local mt={
    __add=function(a,b) return V.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end,
    __sub=function(a,b) return V.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end,
    __mul=function(a,b) if type(a)=="number" then a,b=b,a end;return V.new(a.X*b,a.Y*b,a.Z*b) end,
    __index=function(a,k) local m=math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z); if k=="Magnitude" then return m elseif k=="Unit" then return V.new(a.X/m,a.Y/m,a.Z/m) end end,
}
function V.new(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},mt) end
Vector3=V
Vector2={new=function(x,y) return {X=x,Y=y} end}
typeof=function(v) if getmetatable(v)==mt then return "Vector3" end;return type(v) end
math.clamp=function(n,a,b) return math.max(a,math.min(b,n)) end
Enum={KeyCode={F={Name="F"}},RaycastFilterType={Exclude=1}}
RaycastParams={new=function() return {} end}
local warnings={};warn=function(s) warnings[#warnings+1]=s end
local function node(class,name,parent)
    local n={ClassName=class,Name=name,Parent=parent,children={}}
    if parent then parent.children[#parent.children+1]=n end
    function n:IsA(c) return self.ClassName==c end
    function n:FindFirstChild(name) for _,o in ipairs(self.children) do if o.Parent==self and o.Name==name then return o end end end
    function n:FindFirstChildOfClass(class) for _,o in ipairs(self.children) do if o.Parent==self and o.ClassName==class then return o end end end
    function n:GetChildren() local a={};for _,o in ipairs(self.children) do if o.Parent==self then a[#a+1]=o end end;return a end
    function n:IsDescendantOf(other) local p=self.Parent;while p do if p==other then return true end;p=p.Parent end;return false end
    function n:GetAttribute(k) return self.attributes and self.attributes[k] end
    return n
end
workspace=node("Workspace","Workspace")
workspace.DescendantAdded,workspace.DescendantRemoving=signal(),signal()
function workspace:GetDescendants() return {} end
function workspace:Raycast() return self.rayResult end
local function camera(x)
    local c={ViewportSize={X=800,Y=600},CFrame={Position=V.new(0,0,0)}}
    function c:WorldToViewportPoint(p) return {X=400+p.X*2+x,Y=300-p.Y*2,Z=p.Z},true end
    return c
end
workspace.CurrentCamera=camera(0)
local rep=node("ReplicatedStorage","ReplicatedStorage")
local fust=node("Folder","Fust",rep);local remotes=node("Folder","Remotes",fust)
local shoot=node("RemoteEvent","Shoot",remotes);local itemsModule=node("ModuleScript","Items",fust)
local defs={ rifle={weapon="gun",name="Rifle",speedBase=100,speedCharge=0,gravity=20}, bow={weapon="bow",name="Bow",speedBase=100,speedCharge=0,gravity=20}, rock={kind="melee"} }
local items={Get=function(id) return defs[id] end,BOW_DRAW={scale=function(c) return c end}}
local originalRequire=require;require=function(m) if m==itemsModule then return items end;return originalRequire(m) end
local players={list={}}
function players:GetPlayers() return self.list end
local localPlayer=node("Player","Local");players.LocalPlayer=localPlayer
localPlayer.Character=node("Model","LocalCharacter",workspace)
local tool=node("Tool","Gun",localPlayer.Character);tool.attributes={ItemId="rifle"}
local function target(name,pos,team)
    local p=node("Player",name);p.Team=team
    local char=node("Model",name.."Character",workspace);p.Character=char
    local hum=node("Humanoid","Humanoid",char);hum.Health=100
    local part=node("BasePart","Head",char);part.Position=pos;part.AssemblyLinearVelocity=V.new(10,0,0)
    players.list[#players.list+1]=p
    return p,part,hum
end
players.list[1]=localPlayer
local enemy,part,hum=target("Enemy",V.new(0,0,100))
local run={Heartbeat=signal(),RenderStepped=signal()}
local services={Players=players,RunService=run,ReplicatedStorage=rep,StarterGui={SetCore=function() end}}
game={GetService=function(_,n) assert(services[n],n);return services[n] end,HttpGet=function(_,u) return u end}
local env={};getgenv=function() return env end
local flags,options={},{}
local library={Flags=flags,Options=options}
local group={}
function group:AddToggle(o)
    flags[o.Flag]=o.Default or false
    local opt={Value=flags[o.Flag]};function opt:Set(v) self.Value=v;flags[o.Flag]=v;if o.Callback then task.spawn(o.Callback,v) end end;options[o.Flag]=opt
end
function group:AddSlider(o) flags[o.Flag]=o.Default end
function group:AddLabel() return {SetText=function(self,text) self.text=text end} end
function group:AddButton(o) if o.Name=="Unload Script & Clear Memory" then library.button=o.Callback end end
local tab={AddGroup=function() return group end}
local window={AddTab=function() return tab end,AddSettingsTab=function() end}
function library:Unload() if self.unloading then return end;self.unloading=true;local cb=self.OnUnload;self.OnUnload=nil;if cb then cb() end;self.unloading=false end
loadstring=function(url)
    if url:find("ui_bootstrap.lua",1,true) then return function() return function(o) o.OnLibrary(library);return {Library=library,Window=window} end end end
    if url:find("esp.lua",1,true) then return function() return function() end end end
    error("unexpected url: "..url)
end
local hook, hookCount, captured, originalCalls, method, caller
method="FireServer";caller=false;originalCalls=0;hookCount=0
local function original(remote,...) originalCalls=originalCalls+1;captured=table.pack(...);return "sent" end
hook=original
function hookmetamethod(_,name,fn) assert(name=="__namecall");local old=hook;hook=fn;hookCount=hookCount+1;return old end
function getnamecallmethod() return method end
function checkcaller() return caller end
local function start() assert(loadfile("scripts/main.lua"))();step(0.2) end
local function send(data,remote)
    captured=nil;local result=hook(remote or shoot,data,nil,"tail");assert(result=="sent" and captured.n==3 and captured[3]=="tail");return captured[1]
end
local function approx(a,b) return math.abs(a-b)<0.01 end
start()
assert(not flags.silent_enabled and hookCount==0,"off by default and no hook installed")
local savedHook=hookmetamethod
hookmetamethod=nil
options.silent_enabled:Set(true);step(1.2)
assert(hookCount==0 and #warnings>0,"missing hook API is reported without breaking startup")
hookmetamethod=savedHook
shoot.Parent=nil;step(1.2)
assert(hookCount==0,"missing Shoot remote is tolerated")
shoot.Parent=remotes;step(1.2)
assert(hookCount==1 and env.ARC3USX_SILENT_AIM_HOOK.handler,"late remote installs hook")
local payload={origin=V.new(),dir=V.new(0,0,1),charge=1,extra="preserved"}
local rewritten=send(payload)
assert(rewritten~=payload and rewritten.extra=="preserved" and payload.dir.X==0,"payload copied without mutation")
assert(rewritten.dir.X>0 and rewritten.dir.Y>0,"lead and upward drop compensation")
local t=100/(100*rewritten.dir.Z)
assert(approx(100*rewritten.dir.X*t,10*t) and approx(100*rewritten.dir.Y*t-10*t*t,0),"predicted projectile intercepts moving target")
flags.silent_prediction=false
rewritten=send(payload);assert(approx(rewritten.dir.X,0) and approx(rewritten.dir.Y,0),"prediction off still redirects directly")
flags.silent_prediction=true
flags.silent_visibility=true;workspace.rayResult={Instance=node("BasePart","Wall",workspace)}
assert(send(payload)==payload,"visibility blocks obstructed target")
workspace.rayResult={Instance=part};assert(send(payload)~=payload,"visibility accepts target hit")
workspace.rayResult=nil;assert(send(payload)~=payload,"empty visibility ray is clear")
flags.silent_visibility=false
part.Position=V.new(0,0,1000);assert(send(payload)==payload,"range guard leaves impossible shot unchanged")
part.Position=V.new(0,0,100)
hum.Health=0;assert(send(payload)==payload,"dead targets skipped");hum.Health=100
localPlayer.Team="red";enemy.Team="red";assert(send(payload)==payload,"teammates ignored")
flags.silent_ignore_team=false;assert(send(payload)~=payload,"team filter toggle works");flags.silent_ignore_team=true;enemy.Team="blue"
flags.silent_players=false;assert(send(payload)==payload,"player category toggle works")
local npcs=node("Folder","Npcs",workspace);local npc=node("Model","NPC",npcs);local nh=node("Humanoid","Humanoid",npc);nh.Health=100;local np=node("BasePart","Head",npc);np.Position=V.new(0,0,100);np.AssemblyLinearVelocity=V.new(0,0,0)
assert(send(payload)~=payload,"new NPC targeted without restart")
flags.silent_npcs=false;assert(send(payload)==payload,"NPC category toggle works")
flags.silent_players=true;flags.silent_npcs=true
local farCamera=camera(1000);workspace.CurrentCamera=farCamera;assert(send(payload)==payload,"current camera replacement used")
workspace.CurrentCamera=camera(0)
tool.attributes.ItemId="rock";assert(send(payload)==payload,"unknown weapon left unchanged")
tool.attributes.ItemId="bow";local bow={origin=V.new(),dir=V.new(0,0,1),charge=0.5};rewritten=send(bow);assert(rewritten~=bow and rewritten.dir.Y>0,"bow charge scale used")
local uncharged=send({origin=V.new(),direction=V.new(0,0,1),charge=0});assert(uncharged.direction.Z==1,"zero-speed bow remains unchanged")
local override={pos=V.new(),lookVector=V.new(0,0,1),charge=0,speed=200,gravity=V.new(0,0,0)}
rewritten=send(override);assert(rewritten~=override and rewritten.lookVector.X>0 and approx(rewritten.lookVector.Y,0),"shot speed and vector gravity override weapon values")
assert(send({draw=true,origin=V.new(),dir=V.new(0,0,1)}).draw,"draw messages pass through")
local malformed={origin="bad",dir=V.new()};assert(send(malformed)==malformed,"malformed payload unchanged")
method="InvokeServer";assert(send(payload)==payload,"other methods unchanged");method="FireServer"
caller=true;assert(send(payload)==payload,"executor calls unchanged");caller=false
local other=node("RemoteEvent","Other",remotes);assert(send(payload,other)==payload,"other remotes unchanged")
options.silent_enabled:Set(false);assert(send(payload)==payload,"turning off immediately disables redirect")
options.silent_enabled:Set(true);step(1.2);assert(send(payload)~=payload,"turning back on works")
library.button();assert(env.ARC3USX_SILENT_AIM_HOOK.handler==nil and send(payload)==payload,"unload disables hook")
start();options.silent_enabled:Set(true);step(1.2);assert(hookCount==1 and send(payload)~=payload,"reinjection reuses hook")
-- A fault inside target selection must not block the original remote.
local prior=players.GetPlayers;players.GetPlayers=function() error("simulated targeting error") end
assert(send(payload)==payload,"handler errors pass shot through")
players.GetPlayers=prior
library.button();step(0.2)
assert(#errors==0,table.concat(errors,"; "))
print("Silent aim UI, interception, filters, hook, unload and reinjection mock tests passed")
