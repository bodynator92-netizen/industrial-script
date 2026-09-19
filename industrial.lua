local Library=loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager=loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local SaveManager=loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()
local P=game:GetService("Players") local U=game:GetService("UserInputService")
local R=game:GetService("RunService") local L=game:GetService("Lighting")
local me=P.LocalPlayer
pcall(function() U.MouseBehavior=Enum.MouseBehavior.Default U.MouseIconEnabled=true end)
local hasD=(type(Drawing)=="table" and type(Drawing.new)=="function")

local esp,names,health,dist,hideDead,espTeam=false,true,true,true,true,false
local espMax,grad=300,true
local espVisibleColor=Color3.fromRGB(0,255,0)
local espHiddenColor=Color3.fromRGB(255,0,0)
local espTeammateColor=Color3.fromRGB(0,100,255)
local espUseTeamColor=false
local espObjs={}

local aim,aimFov,aimSmooth,aimMax,aimTeam=false,150,0.05,100,false
local aimTarget,aimTargetRandom="Head",false
local aimParts={"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftArm","RightArm","LeftLeg","RightLeg"}
local trig,trigDelay,lastTrig=false,0.05,0
local fovC,fovFill,fovAlpha=Color3.fromRGB(255,60,60),false,0.85

local fly,flySpd,flyC,flyBV,flyBG=false,50,nil,nil,nil
local noclip,noclipC=false,nil
local infJump,infJumpC=false,nil
local raOn,raDist,raX,raY,raZ,raSpin=false,300,30,8,30,720
local rbOn,rbDist,rbH,rbRate,rbPos=false,3,0,0.02,"Front"
local vsOn,vsInt,vsBurst,vsSmooth,vsAlpha,vsPat=false,0.016,5,false,0.5,"random"
local vsAxX,vsAxY,vsAxZ=true,true,true
local vsXP,vsXN,vsYP,vsYN,vsZP,vsZN=2500,2500,1500,1500,2500,2500

local fovGui=Instance.new("ScreenGui") fovGui.ResetOnSpawn=false fovGui.IgnoreGuiInset=true fovGui.Parent=me:WaitForChild("PlayerGui")
local fovFillF=Instance.new("Frame") fovFillF.AnchorPoint=Vector2.new(0.5,0.5) fovFillF.BackgroundColor3=fovC
fovFillF.BackgroundTransparency=fovAlpha fovFillF.BorderSizePixel=0 fovFillF.Size=UDim2.new(0,aimFov*2,0,aimFov*2)
fovFillF.Visible=false fovFillF.ZIndex=99 fovFillF.Parent=fovGui Instance.new("UICorner",fovFillF).CornerRadius=UDim.new(1,0)
local fovCirc=Instance.new("Frame") fovCirc.AnchorPoint=Vector2.new(0.5,0.5) fovCirc.BackgroundTransparency=1 fovCirc.BorderSizePixel=0
fovCirc.Size=UDim2.new(0,aimFov*2,0,aimFov*2) fovCirc.Visible=false fovCirc.ZIndex=100 fovCirc.Parent=fovGui
Instance.new("UICorner",fovCirc).CornerRadius=UDim.new(1,0)
local fovStr=Instance.new("UIStroke") fovStr.Color=fovC fovStr.Thickness=1.5 fovStr.Parent=fovCirc

-- ============ TAB ICON PATCH ============
do
    local ICONS = {
        Main     = "rbxassetid://10723407389",
        Player   = "rbxassetid://10734950309",
        Visual   = "rbxassetid://10734898355",
        Fun      = "rbxassetid://10734932081",
        Settings = "rbxassetid://10734950020",
    }
    local oldAddTab = Library.AddTab
    function Library:AddTab(name, ...)
        local tab = oldAddTab(self, name, ...)
        task.defer(function()
            local icon = ICONS[name]
            if not icon then return end
            local coreGui = game:GetService("CoreGui")
            for _, g in ipairs(coreGui:GetChildren()) do
                if g:IsA("ScreenGui") and g.Name == "Obsidian" then
                    for _, btn in ipairs(g:GetDescendants()) do
                        if btn:IsA("TextButton") and btn:FindFirstChildOfClass("TextLabel") then
                            local lbl = btn:FindFirstChildOfClass("TextLabel")
                            if lbl.Text == name and not btn:FindFirstChild("IndustrialTabIcon") then
                                lbl.Position = UDim2.new(0, 34, 0, 0)
                                lbl.Size = UDim2.new(1, -34, 1, 0)
                                local img = Instance.new("ImageLabel")
                                img.Name = "IndustrialTabIcon"
                                img.Size = UDim2.new(0, 18, 0, 18)
                                img.AnchorPoint = Vector2.new(0, 0.5)
                                img.Position = UDim2.new(0, 10, 0.5, 0)
                                img.BackgroundTransparency = 1
                                img.Image = icon
                                img.ImageColor3 = Color3.fromRGB(125, 85, 255)
                                img.Parent = btn
                            end
                        end
                    end
                end
            end
        end)
        return tab
    end
end

local W=Library:CreateWindow({
    Title='Industrial',
    Center=true,
    AutoShow=true,
    Footer=''
})

-- ============ DELETE KEYBIND (гарантированное закрытие/открытие) ============
do
    local menuOpen = true
    U.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.H then
            menuOpen = not menuOpen
            local done = false
            if Library.Toggle then
                pcall(function() Library:Toggle() done = true end)
            end
            if not done and W and W.Toggle then
                pcall(function() W:Toggle() done = true end)
            end
            if not done then
                local coreGui = game:GetService("CoreGui")
                for _, g in ipairs(coreGui:GetChildren()) do
                    if g:IsA("ScreenGui") and g.Name == "Obsidian" then
                        g.Enabled = menuOpen
                    end
                end
            end
        end
    end)
end

local T={
    C=W:AddTab('Main'),
    P=W:AddTab('Player'),
    F=W:AddTab('Fun'),
    E=W:AddTab('Visual'),
    Settings=W:AddTab('Settings')
}

local function sameTeam(p)
    if p==me then return true end
    if me.Team and p.Team and me.Team==p.Team then return true end
    if me.TeamColor and p.TeamColor and me.TeamColor==p.TeamColor then return true end
    return false
end
local function hrp() return me.Character and me.Character:FindFirstChild("HumanoidRootPart") end
local function closest()
    local c,md=nil,math.huge local h=hrp() if not h then return nil end
    for _,p in pairs(P:GetPlayers()) do
        if p~=me and p.Character then
            local ph=p.Character:FindFirstChild("HumanoidRootPart")
            local hum=p.Character:FindFirstChildOfClass("Humanoid")
            if ph and hum and hum.Health>0 then
                local d=(h.Position-ph.Position).Magnitude
                if d<md then md=d c=p end
            end
        end
    end
    return c
end
local function rmESP(p)
    local d=espObjs[p] if not d then return end
    for _,k in ipairs({"box","out","hb","hg","nt","dt"}) do if d[k] then d[k]:Remove() end end
    espObjs[p]=nil
end
local function mkESP(p)
    if p==me or not hasD then return end
    if espTeam and sameTeam(p) then return end
    rmESP(p)
    local ch=p.Character if not ch then return end
    local h=ch:FindFirstChild("HumanoidRootPart")
    local hum=ch:FindFirstChildOfClass("Humanoid")
    if not h or not hum then return end
    local box=Drawing.new("Square") box.Visible,box.Color,box.Thickness,box.Filled=false,espVisibleColor,1,false
    local out=Drawing.new("Square") out.Visible,out.Color,out.Thickness,out.Filled=false,Color3.new(0,0,0),3,false
    local hb=Drawing.new("Square") hb.Visible,hb.Filled=false,true
    local hg=Drawing.new("Square") hg.Visible,hg.Color,hg.Filled=false,Color3.fromRGB(40,40,40),true
    local nt=Drawing.new("Text") nt.Visible,nt.Center,nt.Outline,nt.Size,nt.Color=false,true,true,13,Color3.new(1,1,1)
    nt.Font=Drawing.Fonts and Drawing.Fonts.Plex or 0
    local dt=Drawing.new("Text") dt.Visible,dt.Center,dt.Outline,dt.Size,dt.Color=false,true,true,12,Color3.fromRGB(180,180,180)
    dt.Font=Drawing.Fonts and Drawing.Fonts.Plex or 0
    espObjs[p]={box=box,out=out,hb=hb,hg=hg,nt=nt,dt=dt,hrp=h,hum=hum,char=ch}
end
local function refreshESP()
    for p in pairs(espObjs) do rmESP(p) end
    if not esp or not hasD then return end
    for _,p in ipairs(P:GetPlayers()) do if p~=me then mkESP(p) end end
end
P.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1) if esp then mkESP(p) end end) end)
for _,p in ipairs(P:GetPlayers()) do if p~=me then p.CharacterAdded:Connect(function() task.wait(1) if esp then mkESP(p) end end) end end
P.PlayerRemoving:Connect(rmESP)
local function killFly() if flyC then flyC:Disconnect() flyC=nil end if flyBV then flyBV:Destroy() flyBV=nil end if flyBG then flyBG:Destroy() flyBG=nil end end
local function startFly()
    killFly()
    local h=hrp() if not h then return end
    flyBV=Instance.new("BodyVelocity") flyBV.MaxForce=Vector3.new(9e9,9e9,9e9) flyBV.Velocity=Vector3.zero flyBV.Parent=h
    flyBG=Instance.new("BodyGyro") flyBG.MaxTorque=Vector3.new(9e9,9e9,9e9) flyBG.P=1000 flyBG.D=50 flyBG.CFrame=h.CFrame flyBG.Parent=h
    flyC=R.RenderStepped:Connect(function()
        if not fly then return end
        local hh=hrp() if not hh or not flyBV or not flyBG then return end
        local cam=workspace.CurrentCamera local mv=Vector3.zero
        if U:IsKeyDown(Enum.KeyCode.W) then mv=mv+cam.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.S) then mv=mv-cam.CFrame.LookVector end
        if U:IsKeyDown(Enum.KeyCode.A) then mv=mv+cam.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.D) then mv=mv+cam.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
        if U:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
        if mv.Magnitude>0 then mv=mv.Unit*flySpd end
        flyBV.Velocity=mv flyBG.CFrame=cam.CFrame
    end)
end
local function startNoclip()
    if noclipC then noclipC:Disconnect() end
    noclipC=R.Stepped:Connect(function()
        if not noclip then return end
        local c=me.Character if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end
    end)
end
local function startInfJump()
    if infJumpC then infJumpC:Disconnect() end
    infJumpC=U.JumpRequest:Connect(function()
        if not infJump then return end
        local h=me.Character and me.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end
me.CharacterAdded:Connect(function() task.wait(1) if fly then startFly() end if noclip then startNoclip() end end)
local raC=nil
local function startRA()
    if raC then raC:Disconnect() end
    local t0,seed=tick(),math.random(1e3,9e3)
    local h=hrp() if h then _G.raOrig=h.CFrame end
    raC=R.Heartbeat:Connect(function(dt)
        if not raOn then return end
        local hh=hrp() if not hh then return end
        local t=tick()-t0
        local y=math.rad(raSpin*dt) local p=math.rad(raSpin*0.37*dt*math.sin(t*3.1)) local r=math.rad(raSpin*0.19*dt*math.cos(t*5.7+seed))
        local sc=hh.CFrame*CFrame.Angles(p,y,r)
        local s=raDist/300
        local jx=(math.random()-0.5)*raX*s*2+math.noise(t*9,seed,0)*raX*s
        local jy=(math.random()-0.5)*raY*s+math.noise(0,t*9,seed)*raY*s*0.3
        local jz=(math.random()-0.5)*raZ*s*2+math.noise(0,0,t*9+seed)*raZ*s
        hh.CFrame=sc+Vector3.new(jx,math.max(sc.Position.Y+jy,2)-sc.Position.Y,jz)
    end)
end
local function stopRA()
    if raC then raC:Disconnect() raC=nil end
    if hrp() and _G.raOrig then hrp().CFrame=_G.raOrig end
end
local rbC,rbT,rbLast=nil,nil,0
local function startRB()
    if rbC then rbC:Disconnect() end
    rbC=R.Heartbeat:Connect(function()
        if not rbOn then return end
        local h=hrp() if not h then return end
        if not rbT or not rbT.Character or not rbT.Character:FindFirstChild("Humanoid") or rbT.Character.Humanoid.Health<=0 then rbT=closest() return end
        local tr=rbT.Character:FindFirstChild("HumanoidRootPart") if not tr then return end
        local now=tick() if (now-rbLast)<rbRate then return end
        rbLast=now
        local tp,tl=tr.Position,tr.CFrame.LookVector
        local d,ho=rbDist,rbH
        local cf=h.CFrame
        if rbPos=="Front" then cf=CFrame.lookAt(tp+tl*d+Vector3.new(0,ho,0),tp+Vector3.new(0,ho,0))
        elseif rbPos=="Back" then cf=CFrame.lookAt(tp-tl*d+Vector3.new(0,ho,0),tp+Vector3.new(0,ho,0))
        elseif rbPos=="Above" then cf=CFrame.lookAt(tp+Vector3.new(0,d+ho,0),tp+Vector3.new(0,ho,0))
        elseif rbPos=="Below" then cf=CFrame.lookAt(tp+Vector3.new(0,-d+ho,0),tp+Vector3.new(0,ho,0)) end
        h.CFrame=cf h.AssemblyLinearVelocity=Vector3.zero h.AssemblyAngularVelocity=Vector3.zero
    end)
end
local function stopRB()
    if rbC then rbC:Disconnect() rbC=nil end
    rbT=nil rbLast=0
end
local vsC,vsCC=nil,nil
local vsSpiral,vsWave,vsHelix,vsStrobe=0,0,0,false
local vsBounce={X=1,Y=1,Z=1} local vsChaos={math.random(),math.random(),math.random()}
local function vsDelta(dt)
    local ax,ay,az=vsAxX,vsAxY,vsAxZ local p=vsPat
    if p=="spiral" then vsSpiral=vsSpiral+0.35 return Vector3.new(ax and math.cos(vsSpiral)*(vsXP+vsXN)/2 or 0,ay and math.sin(vsSpiral*0.6)*(vsYP+vsYN)/2 or 0,az and math.sin(vsSpiral)*(vsZP+vsZN)/2 or 0)
    elseif p=="wave" then vsWave=vsWave+dt*8 return Vector3.new(ax and math.sin(vsWave)*(vsXP+vsXN)/2 or 0,ay and math.sin(vsWave*1.7)*(vsYP+vsYN)/2 or 0,az and math.cos(vsWave*0.9)*(vsZP+vsZN)/2 or 0)
    elseif p=="bounce" then
        local s=Vector3.new(ax and vsBounce.X*(vsXP+vsXN)/3 or 0,ay and vsBounce.Y*(vsYP+vsYN)/3 or 0,az and vsBounce.Z*(vsZP+vsZN)/3 or 0)
        if math.random()<0.25 then vsBounce.X=-vsBounce.X end
        if math.random()<0.25 then vsBounce.Y=-vsBounce.Y end
        if math.random()<0.25 then vsBounce.Z=-vsBounce.Z end
        return s
    elseif p=="chaos" then
        vsChaos[1]=(vsChaos[1]*1664525+1013904223)%1 vsChaos[2]=(vsChaos[2]*22695477+1)%1 vsChaos[3]=(vsChaos[3]*214013+2531011)%1
        return Vector3.new(ax and (vsChaos[1]*(vsXP+vsXN)-vsXN) or 0,ay and (vsChaos[2]*(vsYP+vsYN)-vsYN) or 0,az and (vsChaos[3]*(vsZP+vsZN)-vsZN) or 0)
    elseif p=="cross" then
        local tog=math.floor(tick()*10)%2==0
        return Vector3.new(ax and (tog and math.random()*(vsXP+vsXN)-vsXN or 0) or 0,ay and (not tog and math.random()*(vsYP+vsYN)-vsYN or 0) or 0,az and (tog and math.random()*(vsZP+vsZN)-vsZN or 0) or 0)
    elseif p=="helix" then vsHelix=vsHelix+dt*6 return Vector3.new(ax and math.cos(vsHelix*2)*(vsXP+vsXN)/2 or 0,ay and math.sin(vsHelix)*(vsYP+vsYN)/8 or 0,az and math.sin(vsHelix*2)*(vsZP+vsZN)/2 or 0)
    elseif p=="strobe" then vsStrobe=not vsStrobe local s=vsStrobe and 1 or -1 return Vector3.new(ax and s*vsXP or 0,ay and s*vsYP or 0,az and s*vsZP or 0)
    else return Vector3.new(ax and math.random()*(vsXP+vsXN)-vsXN or 0,ay and math.random()*(vsYP+vsYN)-vsYN or 0,az and math.random()*(vsZP+vsZN)-vsZN or 0) end
end
local function startVS()
    if vsC then return end
    vsSpiral,vsWave,vsHelix,vsStrobe=0,0,0,false
    vsBounce={X=1,Y=1,Z=1} vsChaos={math.random(),math.random(),math.random()}
    local root,hum
    local function rf()
        local c=me.Character if not c then root=nil hum=nil return end
        root=c:FindFirstChild("HumanoidRootPart") hum=c:FindFirstChildOfClass("Humanoid")
    end
    rf()
    vsCC=me.CharacterAdded:Connect(function(c) root=c:WaitForChild("HumanoidRootPart") hum=c:WaitForChild("Humanoid") task.wait(0.2) if vsOn and hum then hum:ChangeState(Enum.HumanoidStateType.Physics) end end)
    local acc,dtBuf=0,0
    vsC=R.Heartbeat:Connect(function(dt)
        if not vsOn then stopVS() return end
        if not root or not root.Parent then rf() return end
        if hum and hum.Health<=0 then return end
        dtBuf=dtBuf+dt acc=acc+dt
        local iv=math.max(vsInt,0.005)
        if acc<iv then return end
        acc=acc%iv
        local burst=math.clamp(vsBurst,1,20)
        for _=1,burst do
            if not root or not root.Parent then break end
            local pos=root.Position local look=root.CFrame.LookVector
            local dl=vsDelta(dtBuf/burst)
            local np=vsSmooth and pos:Lerp(pos+dl,math.clamp(vsAlpha,0.01,1)) or (pos+dl)
            root.CFrame=CFrame.new(np,np+look)
        end
        dtBuf=0
    end)
end
local function stopVS() if vsC then vsC:Disconnect() vsC=nil end if vsCC then vsCC:Disconnect() vsCC=nil end end

-- ============ MAIN TAB ============
local AG=T.C:AddLeftGroupbox('Combat')
AG:AddToggle('aimE',{Text='Aimbot',Default=false,Callback=function(v) aim=v fovCirc.Visible=v fovFillF.Visible=v and fovFill end})
AG:AddToggle('aimT',{Text='Team Check',Default=false,Callback=function(v) aimTeam=v end})
AG:AddDropdown('aimPart',{Text='Lock Part',Default='Head',Values={'Head','UpperTorso','LowerTorso','HumanoidRootPart','LeftArm','RightArm','LeftLeg','RightLeg'},Callback=function(v) aimTarget=v end})
AG:AddToggle('aimRand',{Text='Random Part',Default=false,Callback=function(v) aimTargetRandom=v end})
AG:AddSlider('aimF',{Text='FOV',Default=150,Min=0,Max=400,Rounding=0,Suffix='',Callback=function(v) aimFov=v fovCirc.Size=UDim2.new(0,v*2,0,v*2) fovFillF.Size=UDim2.new(0,v*2,0,v*2) end})
AG:AddSlider('aimS',{Text='Smooth',Default=5,Min=0,Max=100,Rounding=0,Suffix='%',Callback=function(v) aimSmooth=v/100 end})
AG:AddSlider('aimM',{Text='Max Dist',Default=100,Min=10,Max=500,Rounding=0,Suffix='',Callback=function(v) aimMax=v end})
local TG=T.C:AddRightGroupbox('Trigger Bot')
TG:AddToggle('trigE',{Text='Triggerbot',Default=false,Callback=function(v) trig=v end})
TG:AddSlider('trigD',{Text='Delay (ms)',Default=50,Min=10,Max=500,Rounding=0,Suffix='',Callback=function(v) trigDelay=v/1000 end})
local FG=T.C:AddRightGroupbox('FOV Circle')
FG:AddLabel('FOV Color'):AddColorPicker('fovC',{Default=fovC,Title='FOV Color',Transparency=0,Callback=function(v) fovC=v fovStr.Color=v fovFillF.BackgroundColor3=v end})
FG:AddToggle('fovFillE',{Text='Fill',Default=false,Callback=function(v) fovFill=v fovFillF.Visible=v and aim end})
FG:AddSlider('fovA',{Text='Fill Alpha',Default=85,Min=0,Max=100,Rounding=0,Suffix='%',Callback=function(v) fovAlpha=v/100 fovFillF.BackgroundTransparency=v/100 end})
local EC=T.C:AddLeftGroupbox('ESP Colors')
EC:AddLabel('Visible Color'):AddColorPicker('espVisC',{Default=espVisibleColor,Title='Visible Color',Transparency=0,
    Callback=function(v) espVisibleColor=v for _,d in pairs(espObjs) do if d.box then d.box.Color=v end end end})
EC:AddLabel('Hidden Color'):AddColorPicker('espHidC',{Default=espHiddenColor,Title='Hidden Color',Transparency=0,
    Callback=function(v) espHiddenColor=v end})
EC:AddLabel('Teammate Color'):AddColorPicker('espTeamC',{Default=espTeammateColor,Title='Teammate Color',Transparency=0,
    Callback=function(v) espTeammateColor=v end})
EC:AddToggle('espUseTeamC',{Text='Use Teammate Color',Default=false,Callback=function(v) espUseTeamColor=v end})

-- ============ PLAYER TAB ============
local MG=T.P:AddLeftGroupbox('Movement')
MG:AddToggle('flyE',{Text='Fly',Default=false,Callback=function(v) fly=v if v then startFly() else killFly() end end})
MG:AddSlider('flyS',{Text='Speed',Default=50,Min=10,Max=300,Rounding=0,Suffix='',Callback=function(v) flySpd=v end})
MG:AddToggle('ncE',{Text='Noclip',Default=false,Callback=function(v) noclip=v if not v and noclipC then noclipC:Disconnect() noclipC=nil end if v then startNoclip() end end})
MG:AddToggle('ijE',{Text='Infinite Jump',Default=false,Callback=function(v) infJump=v if v then startInfJump() elseif infJumpC then infJumpC:Disconnect() infJumpC=nil end end})
local RA=T.P:AddLeftGroupbox('Extra')
RA:AddToggle('raE',{Text='Riot Abuser',Default=false,Callback=function(v) raOn=v if v then startRA() else stopRA() end end})
RA:AddSlider('raD',{Text='Spread',Default=300,Min=10,Max=1000,Rounding=0,Suffix='',Callback=function(v) raDist=v end})
RA:AddSlider('raX',{Text='X',Default=30,Min=0,Max=200,Rounding=0,Suffix='',Callback=function(v) raX=v end})
RA:AddSlider('raY',{Text='Y',Default=8,Min=0,Max=100,Rounding=0,Suffix='',Callback=function(v) raY=v end})
RA:AddSlider('raZ',{Text='Z',Default=30,Min=0,Max=200,Rounding=0,Suffix='',Callback=function(v) raZ=v end})
RA:AddSlider('raS',{Text='Spin',Default=720,Min=0,Max=2000,Rounding=0,Suffix='',Callback=function(v) raSpin=v end})
local RB=T.P:AddRightGroupbox('Riot Bypass')
RB:AddToggle('rbE',{Text='Riot Bypass',Default=false,Callback=function(v) rbOn=v if v then startRB() else stopRB() end end})
RB:AddSlider('rbD',{Text='Dist',Default=3,Min=0,Max=20,Rounding=1,Suffix='',Callback=function(v) rbDist=v end})
RB:AddSlider('rbH',{Text='Height',Default=0,Min=-20,Max=20,Rounding=1,Suffix='',Callback=function(v) rbH=v end})
RB:AddSlider('rbR',{Text='Rate',Default=20,Min=1,Max=500,Rounding=0,Suffix='',Callback=function(v) rbRate=v/1000 end})
RB:AddDropdown('rbP',{Text='Position',Default='Front',Values={'Front','Back','Above','Below'},Callback=function(v) rbPos=v end})

-- ============ FUN TAB ============
local FL=T.F:AddLeftGroupbox('Fun')
FL:AddLabel('Fun features coming soon.')
FL:AddButton({Text='Jump Scare (sound)',Func=function()
    local s=Instance.new("Sound")
    s.SoundId="rbxassetid://130777695"
    s.Volume=5
    s.Parent=me:WaitForChild("PlayerGui")
    s:Play()
    task.delay(3,function() if s then s:Destroy() end end)
end})
FL:AddButton({Text='Flip Character',Func=function()
    local h=hrp()
    if h then h.CFrame=h.CFrame*CFrame.Angles(math.rad(180),0,0) end
end})

-- ============ VISUAL TAB ============
local Gfx=T.E:AddLeftGroupbox('Graphics')
Gfx:AddButton({Text='RTX Toggle',Func=function()
    if not _G.RTX then _G.RTX={on=false,orig={Technology=L.Technology,Brightness=L.Brightness},refl={}} end
    local r=_G.RTX r.on=not r.on
    if r.on then
        L.Technology=Enum.Technology.Future L.Brightness=3
        for _,fx in ipairs(L:GetChildren()) do if fx.Name=="RTX_Bloom" then fx:Destroy() end end
        local b=Instance.new("BloomEffect") b.Name="RTX_Bloom" b.Intensity=1.6 b.Size=56 b.Threshold=0.8 b.Parent=L
        r.refl={} for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("BasePart") and not v:IsA("Terrain") then r.refl[v]=v.Reflectance v.Reflectance=math.max(v.Reflectance,0.35) v.Material=Enum.Material.SmoothPlastic end end
    else
        L.Technology=r.orig.Technology L.Brightness=r.orig.Brightness
        for _,fx in ipairs(L:GetChildren()) do if fx.Name=="RTX_Bloom" then fx:Destroy() end end
        for v,rf in pairs(r.refl) do if v and v.Parent then v.Reflectance=rf end end
        r.refl={}
    end
end})
local EM=T.E:AddLeftGroupbox('Visual')
EM:AddToggle('espE',{Text='ESP',Default=false,Callback=function(v) esp=v refreshESP() end})
EM:AddToggle('espT',{Text='Team Check',Default=false,Callback=function(v) espTeam=v refreshESP() end})
local ED=T.E:AddLeftGroupbox('Display')
ED:AddToggle('nE',{Text='Names',Default=true,Callback=function(v) names=v end})
ED:AddToggle('hE',{Text='Health',Default=true,Callback=function(v) health=v end})
ED:AddToggle('dE',{Text='Distance',Default=true,Callback=function(v) dist=v end})
ED:AddToggle('gE',{Text='Gradient',Default=true,Callback=function(v) grad=v end})
ED:AddToggle('ddE',{Text='Hide Dead',Default=true,Callback=function(v) hideDead=v end})
T.E:AddRightGroupbox('Range'):AddSlider('eMax',{Text='Max Dist',Default=300,Min=10,Max=1000,Rounding=0,Suffix='',Callback=function(v) espMax=v end})

-- ============ RENDER LOOPS ============
local Cam=workspace.CurrentCamera

R.RenderStepped:Connect(function()
    if not aim then fovCirc.Visible=false fovFillF.Visible=false return end
    local m=U:GetMouseLocation()
    fovCirc.Position=UDim2.new(0,m.X,0,m.Y)
    fovFillF.Position=UDim2.new(0,m.X,0,m.Y)
    fovCirc.Visible=true
    fovFillF.Visible=fovFill
end)

R.RenderStepped:Connect(function()
    local lh=me.Character and me.Character:FindFirstChild("HumanoidRootPart")
    for p,d in pairs(espObjs) do
        if not p.Character or not d.hrp or not d.hrp.Parent then rmESP(p) continue end
        local hum=d.hum
        local dead=not hum or not hum.Parent or hum.Health<=0
        local function hide() for _,k in ipairs({"box","out","hb","hg","nt","dt"}) do d[k].Visible=false end end
        if hideDead and dead then hide() continue end
        if espTeam and sameTeam(p) then hide() continue end
        local ch=p.Character local hd=ch:FindFirstChild("Head") local h=ch:FindFirstChild("HumanoidRootPart")
        if not hd or not h then hide() continue end
        local hT=hd.Position+Vector3.new(0,hd.Size.Y/2,0)
        local ft=h.Position-Vector3.new(0,3,0)
        local hs,ho=Cam:WorldToViewportPoint(hT)
        local fs,fo=Cam:WorldToViewportPoint(ft)
        local cs,co=Cam:WorldToViewportPoint(h.Position)
        if not ho or not fo or not co then hide() continue end
        local dd,ir=0,true
        if lh then dd=(h.Position-lh.Position).Magnitude if dd>espMax then ir=false end end
        if not esp or not ir then hide() continue end
        local bh=math.abs(fs.Y-hs.Y) local bw=bh*0.6 local bx=cs.X-bw/2 local by=hs.Y
        local col=(espUseTeamColor and sameTeam(p)) and espTeammateColor or espVisibleColor
        d.out.Visible=true d.out.Size=Vector2.new(bw,bh) d.out.Position=Vector2.new(bx,by)
        d.box.Visible=true d.box.Size=Vector2.new(bw,bh) d.box.Position=Vector2.new(bx,by) d.box.Color=col
        if health then
            local pc=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
            local hh=bh*pc local hx,hy=bx-6,by+(bh-hh)
            d.hg.Visible=true d.hg.Size=Vector2.new(3,bh) d.hg.Position=Vector2.new(hx,by)
            d.hb.Visible=true d.hb.Size=Vector2.new(3,hh) d.hb.Position=Vector2.new(hx,hy)
            d.hb.Color=grad and Color3.new(math.clamp(2*(1-pc),0,1),math.clamp(2*pc,0,1),0.1) or Color3.fromRGB(80,220,80)
        else d.hb.Visible=false d.hg.Visible=false end
        d.nt.Visible=names if names then d.nt.Text=p.DisplayName d.nt.Position=Vector2.new(cs.X,by-18) end
        d.dt.Visible=dist if dist then d.dt.Text=math.floor(dd).." studs" d.dt.Position=Vector2.new(cs.X,by+bh+4) end
    end
end)

local function getTarget()
    local mp=U:GetMouseLocation() local best,bd=nil,math.huge
    for _,p in ipairs(P:GetPlayers()) do
        if p==me then continue end
        if aimTeam and sameTeam(p) then continue end
        local ch=p.Character if not ch then continue end
        local hum=ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local partName=aimTargetRandom and aimParts[math.random(1,#aimParts)] or aimTarget
        local part=ch:FindFirstChild(partName) or ch:FindFirstChild("Head")
        if not part then continue end
        local sc,on=Cam:WorldToViewportPoint(part.Position)
        if not on then continue end
        local d2=(Vector2.new(sc.X,sc.Y)-mp).Magnitude
        local h=ch:FindFirstChild("HumanoidRootPart")
        local lh=me.Character and me.Character:FindFirstChild("HumanoidRootPart")
        local wd=(h and lh) and (h.Position-lh.Position).Magnitude or math.huge
        if d2<aimFov and d2<bd and wd<=aimMax then bd=d2 best=p end
    end
    return best
end
R.RenderStepped:Connect(function()
    if not aim then return end
    if not U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local t=getTarget() if not t then return end
    local ch=t.Character if not ch then return end
    local partName=aimTargetRandom and aimParts[math.random(1,#aimParts)] or aimTarget
    local part=ch:FindFirstChild(partName) or ch:FindFirstChild("Head")
    if not part then return end
    local sc,on=Cam:WorldToViewportPoint(part.Position)
    if not on then return end
    local cur=U:GetMouseLocation() local goal=Vector2.new(sc.X,sc.Y)
    local a=1-(math.clamp(aimSmooth,0,0.9)*0.9) local dl=(goal-cur)*a
    mousemoverel(dl.X,dl.Y)
end)
R.RenderStepped:Connect(function()
    if not trig then return end
    local now=tick() if now-lastTrig<trigDelay then return end
    local t=me:GetMouse().Target if not t then return end
    local ch=t:FindFirstAncestorOfClass("Model") if not ch then return end
    local tp=P:GetPlayerFromCharacter(ch) if not tp or tp==me then return end
    if aimTeam and sameTeam(tp) then return end
    local hum=ch:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health>0 then mouse1click() lastTrig=now end
end)

-- ============ SETTINGS TAB ============
local Menu=T.Settings:AddLeftGroupbox('Menu')
Menu:AddButton({Text='Unload',Func=function()
    killFly()
    if noclipC then noclipC:Disconnect() end
    if infJumpC then infJumpC:Disconnect() end
    stopRA() stopRB() stopVS()
    Library:Unload()
end})

ThemeManager:SetLibrary(Library) SaveManager:SetLibrary(Library) SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(T.Settings) ThemeManager:ApplyToTab(T.Settings)
SaveManager:LoadAutoloadConfig()
