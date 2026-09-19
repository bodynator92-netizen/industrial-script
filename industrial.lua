local Library=loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager=loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local SaveManager=loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()
local P=game:GetService("Players") local U=game:GetService("UserInputService")
local R=game:GetService("RunService") local L=game:GetService("Lighting")
local me=P.LocalPlayer
pcall(function() U.MouseBehavior=Enum.MouseBehavior.Default U.MouseIconEnabled=true end)
local hasD=(type(Drawing)=="table" and type(Drawing.new)=="function")

-- ============ LANGUAGE ============
local Lang = "En"
local function TT(en, ru) if Lang == "Ru" then return ru else return en end end

local function getObsidianGui()
    local coreGui = game:GetService("CoreGui")
    for _, g in ipairs(coreGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name == "Obsidian" then return g end
    end
    return nil
end

-- ============ STATE ============
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

-- ============ BIND SYSTEM ============
local Binds = {}          -- id -> {key=..., state=bool, callback=fn, name_en, name_ru}
local BindButtons = {}    -- id -> {btn=TextButton, label=TextLabel}
local BindFile = "industrial_binds.txt"
local CurrentBindId = nil
local WaitingForBind = false

local function SaveBinds()
    if not writefile then return end
    local data = {}
    for id, b in pairs(Binds) do
        if b.key then
            table.insert(data, id .. "|" .. b.key.ClassName .. "|" .. b.key.Name)
        end
    end
    pcall(writefile, BindFile, table.concat(data, "\n"))
end

local function LoadBinds()
    if not readfile or not isfile then return end
    if not isfile(BindFile) then return end
    local ok, content = pcall(readfile, BindFile)
    if not ok then return end
    for line in content:gmatch("[^\n]+") do
        local id, keyType, keyName = line:match("^([^|]+)|([^|]+)|(.+)$")
        if id and keyType and keyName and Binds[id] then
            if keyType == "KeyCode" then
                local ok2, key = pcall(function() return Enum.KeyCode[keyName] end)
                if ok2 then Binds[id].key = key end
            elseif keyType == "UserInputType" then
                local ok2, key = pcall(function() return Enum.UserInputType[keyName] end)
                if ok2 then Binds[id].key = key end
            end
        end
    end
end

local function RefreshBindButton(id)
    local entry = BindButtons[id]
    if not entry or not entry.label then return end
    local b = Binds[id]
    if b and b.key then
        entry.label.Text = tostring(b.key.Name or b.key)
    else
        entry.label.Text = "—"
    end
end

local function BeginBind(id)
    CurrentBindId = id
    WaitingForBind = true
    -- визуально: делаем кнопку жёлтой и текст "..."
    for bid, entry in pairs(BindButtons) do
        if entry.label then entry.label.TextColor3 = Color3.fromRGB(200,200,200) end
    end
    local e = BindButtons[id]
    if e and e.label then
        e.label.Text = "..."
        e.label.TextColor3 = Color3.fromRGB(255, 220, 80)
    end
end

local function ClearBind(id)
    if Binds[id] then
        Binds[id].key = nil
        SaveBinds()
        RefreshBindButton(id)
    end
end

-- ловим нажатие для назначения
U.InputBegan:Connect(function(input, gp)
    if not WaitingForBind then return end
    if gp then return end
    local id = CurrentBindId
    if not id or not Binds[id] then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        Binds[id].key = input.KeyCode
    else
        Binds[id].key = input.UserInputType
    end
    WaitingForBind = false
    SaveBinds()
    RefreshBindButton(id)
    CurrentBindId = nil
end)

-- ловим срабатывание бинда
U.InputBegan:Connect(function(input, gp)
    if gp then return end
    for id, b in pairs(Binds) do
        if b.key and b.callback then
            local match = false
            if input.UserInputType == Enum.UserInputType.Keyboard and b.key == input.KeyCode then
                match = true
            elseif input.UserInputType ~= Enum.UserInputType.Keyboard and b.key == input.UserInputType then
                match = true
            end
            if match then
                b.state = not b.state
                pcall(b.callback, b.state)
            end
        end
    end
end)

local function RegisterBind(id, enName, ruName, callback)
    Binds[id] = { key = nil, state = false, callback = callback, name_en = enName, name_ru = ruName }
end

-- ============ FOV Circle ============
local fovGui=Instance.new("ScreenGui") fovGui.ResetOnSpawn=false fovGui.IgnoreGuiInset=true fovGui.Parent=me:WaitForChild("PlayerGui")
local fovFillF=Instance.new("Frame") fovFillF.AnchorPoint=Vector2.new(0.5,0.5) fovFillF.BackgroundColor3=fovC
fovFillF.BackgroundTransparency=fovAlpha fovFillF.BorderSizePixel=0 fovFillF.Size=UDim2.new(0,aimFov*2,0,aimFov*2)
fovFillF.Visible=false fovFillF.ZIndex=99 fovFillF.Parent=fovGui Instance.new("UICorner",fovFillF).CornerRadius=UDim.new(1,0)
local fovCirc=Instance.new("Frame") fovCirc.AnchorPoint=Vector2.new(0.5,0.5) fovCirc.BackgroundTransparency=1 fovCirc.BorderSizePixel=0
fovCirc.Size=UDim2.new(0,aimFov*2,0,aimFov*2) fovCirc.Visible=false fovCirc.ZIndex=100 fovCirc.Parent=fovGui
Instance.new("UICorner",fovCirc).CornerRadius=UDim.new(1,0)
local fovStr=Instance.new("UIStroke") fovStr.Color=fovC fovStr.Thickness=1.5 fovStr.Parent=fovCirc

-- ============ ASPECT RATIO ============
local aspectGui = Instance.new("ScreenGui")
aspectGui.Name = "IndustrialAspect"
aspectGui.ResetOnSpawn = false
aspectGui.IgnoreGuiInset = true
aspectGui.DisplayOrder = 5
aspectGui.Parent = me:WaitForChild("PlayerGui")

local topBar = Instance.new("Frame")
topBar.BackgroundColor3 = Color3.new(0,0,0) topBar.BorderSizePixel=0
topBar.Size=UDim2.new(1,0,0,0) topBar.Position=UDim2.new(0,0,0,0) topBar.Parent=aspectGui

local bottomBar = Instance.new("Frame")
bottomBar.BackgroundColor3 = Color3.new(0,0,0) bottomBar.BorderSizePixel=0
bottomBar.Size=UDim2.new(1,0,0,0) bottomBar.Position=UDim2.new(0,0,1,0) bottomBar.AnchorPoint=Vector2.new(0,1) bottomBar.Parent=aspectGui

local function ApplyAspect(ratio)
    local screenY = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 1080
    local barHeight = 0
    if ratio < 1 then barHeight = math.floor(screenY * (1 - ratio) * 0.5) end
    topBar.Size = UDim2.new(1, 0, 0, barHeight)
    bottomBar.Size = UDim2.new(1, 0, 0, barHeight)
end

-- ============ TAB ICON PATCH ============
do
    local ICONS = {
        Main="rbxassetid://10723407389", Player="rbxassetid://10734950309",
        Visual="rbxassetid://10734898355", Fun="rbxassetid://10734932081",
        Binds="rbxassetid://10734932081", Config="rbxassetid://10734950020",
        Settings="rbxassetid://10734950020", Language="rbxassetid://10734951660",
    }
    local oldAddTab = Library.AddTab
    function Library:AddTab(name, ...)
        local tab = oldAddTab(self, name, ...)
        task.defer(function()
            local icon = ICONS[name]; if not icon then return end
            local g = getObsidianGui(); if not g then return end
            for _, btn in ipairs(g:GetDescendants()) do
                if btn:IsA("TextButton") and btn:FindFirstChildOfClass("TextLabel") then
                    local lbl = btn:FindFirstChildOfClass("TextLabel")
                    if lbl.Text == name and not btn:FindFirstChild("IndustrialTabIcon") then
                        lbl.Position=UDim2.new(0,34,0,0); lbl.Size=UDim2.new(1,-34,1,0)
                        local img=Instance.new("ImageLabel")
                        img.Name="IndustrialTabIcon"; img.Size=UDim2.new(0,18,0,18)
                        img.AnchorPoint=Vector2.new(0,0.5); img.Position=UDim2.new(0,10,0.5,0)
                        img.BackgroundTransparency=1; img.Image=icon
                        img.ImageColor3=Color3.fromRGB(125,85,255); img.Parent=btn
                    end
                end
            end
        end)
        return tab
    end
end

local W=Library:CreateWindow({Title='Industrial',Center=true,AutoShow=true,Footer=''})

-- ============ KEYBIND (H) ============
do
    local menuOpen = true
    U.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.H then
            menuOpen = not menuOpen
            local done = false
            if Library.Toggle then pcall(function() Library:Toggle() done = true end) end
            if not done and W and W.Toggle then pcall(function() W:Toggle() done = true end) end
            if not done then
                local g = getObsidianGui(); if g then g.Enabled = menuOpen end
            end
        end
    end)
end

local T={
    C=W:AddTab('Main'), P=W:AddTab('Player'), F=W:AddTab('Fun'),
    E=W:AddTab('Visual'), B=W:AddTab('Binds'),
    Config=W:AddTab('Config'), Settings=W:AddTab('Settings'),
    Lang=W:AddTab('Language')
}

-- ============ UTILITY ============
local function sameTeam(p)
    if p==me then return true end
    if me.Team and p.Team and me.Team==p.Team then return true end
    if me.TeamColor and p.TeamColor and me.TeamColor==p.TeamColor then return true end
    return false
end
local function hrp() return me.Character and me.Character:FindFirstChild("HumanoidRootPart") end

-- ============ ESP ============
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

-- ============ MOVEMENT ============
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

-- ============ REGISTER BINDS ============
RegisterBind('flyE','Fly','Полёт', function(v) fly=v if v then startFly() else killFly() end end)
RegisterBind('ncE','Noclip','Проход сквозь стены', function(v) noclip=v if not v and noclipC then noclipC:Disconnect() noclipC=nil end if v then startNoclip() end end)
RegisterBind('ijE','Infinite Jump','Бесконечный прыжок', function(v) infJump=v if v then startInfJump() elseif infJumpC then infJumpC:Disconnect() infJumpC=nil end end)
RegisterBind('aimE','Aimbot','Аимбот', function(v) aim=v fovCirc.Visible=v fovFillF.Visible=v and fovFill end)
RegisterBind('espE','ESP','ESP', function(v) esp=v refreshESP() end)
RegisterBind('trigE','Triggerbot','Триггербот', function(v) trig=v end)

LoadBinds()

-- ============ MAIN TAB ============
local AG=T.C:AddLeftGroupbox(TT('Combat','Бой'))
AG:AddToggle('aimE',{Text=TT('Aimbot','Аимбот'),Default=false,Callback=function(v) aim=v fovCirc.Visible=v fovFillF.Visible=v and fovFill end})
AG:AddToggle('aimT',{Text=TT('Team Check','Проверка команды'),Default=false,Callback=function(v) aimTeam=v end})
AG:AddDropdown('aimPart',{Text=TT('Lock Part','Часть захвата'),Default='Head',Values={'Head','UpperTorso','LowerTorso','HumanoidRootPart','LeftArm','RightArm','LeftLeg','RightLeg'},Callback=function(v) aimTarget=v end})
AG:AddToggle('aimRand',{Text=TT('Random Part','Случайная часть'),Default=false,Callback=function(v) aimTargetRandom=v end})
AG:AddSlider('aimF',{Text=TT('FOV','Радиус'),Default=150,Min=0,Max=400,Rounding=0,Suffix='',Callback=function(v) aimFov=v fovCirc.Size=UDim2.new(0,v*2,0,v*2) fovFillF.Size=UDim2.new(0,v*2,0,v*2) end})
AG:AddSlider('aimS',{Text=TT('Smooth','Плавность'),Default=5,Min=0,Max=100,Rounding=0,Suffix='%',Callback=function(v) aimSmooth=v/100 end})
AG:AddSlider('aimM',{Text=TT('Max Dist','Макс. дистанция'),Default=100,Min=10,Max=500,Rounding=0,Suffix='',Callback=function(v) aimMax=v end})
local TG=T.C:AddRightGroupbox(TT('Trigger Bot','Триггер-бот'))
TG:AddToggle('trigE',{Text=TT('Triggerbot','Триггербот'),Default=false,Callback=function(v) trig=v end})
TG:AddSlider('trigD',{Text=TT('Delay (ms)','Задержка (мс)'),Default=50,Min=10,Max=500,Rounding=0,Suffix='',Callback=function(v) trigDelay=v/1000 end})
local FG=T.C:AddRightGroupbox(TT('FOV Circle','Круг FOV'))
FG:AddLabel(TT('FOV Color','Цвет FOV')):AddColorPicker('fovC',{Default=fovC,Title=TT('FOV Color','Цвет FOV'),Transparency=0,Callback=function(v) fovC=v fovStr.Color=v fovFillF.BackgroundColor3=v end})
FG:AddToggle('fovFillE',{Text=TT('Fill','Заливка'),Default=false,Callback=function(v) fovFill=v fovFillF.Visible=v and aim end})
FG:AddSlider('fovA',{Text=TT('Fill Alpha','Прозрачность заливки'),Default=85,Min=0,Max=100,Rounding=0,Suffix='%',Callback=function(v) fovAlpha=v/100 fovFillF.BackgroundTransparency=v/100 end})
local EC=T.C:AddLeftGroupbox(TT('ESP Colors','Цвета ESP'))
EC:AddLabel(TT('Visible Color','Видимый цвет')):AddColorPicker('espVisC',{Default=espVisibleColor,Title=TT('Visible Color','Видимый цвет'),Transparency=0,
    Callback=function(v) espVisibleColor=v for _,d in pairs(espObjs) do if d.box then d.box.Color=v end end end})
EC:AddLabel(TT('Hidden Color','Цвет за укрытием')):AddColorPicker('espHidC',{Default=espHiddenColor,Title=TT('Hidden Color','Цвет за укрытием'),Transparency=0,
    Callback=function(v) espHiddenColor=v end})
EC:AddLabel(TT('Teammate Color','Цвет союзника')):AddColorPicker('espTeamC',{Default=espTeammateColor,Title=TT('Teammate Color','Цвет союзника'),Transparency=0,
    Callback=function(v) espTeammateColor=v end})
EC:AddToggle('espUseTeamC',{Text=TT('Use Teammate Color','Использовать цвет союзника'),Default=false,Callback=function(v) espUseTeamColor=v end})

-- ============ PLAYER TAB ============
local MG=T.P:AddLeftGroupbox(TT('Movement','Движение'))
MG:AddToggle('flyE',{Text=TT('Fly','Полёт'),Default=false,Callback=function(v) fly=v if v then startFly() else killFly() end end})
MG:AddSlider('flyS',{Text=TT('Speed','Скорость'),Default=50,Min=10,Max=300,Rounding=0,Suffix='',Callback=function(v) flySpd=v end})
MG:AddToggle('ncE',{Text=TT('Noclip','Проход сквозь стены'),Default=false,Callback=function(v) noclip=v if not v and noclipC then noclipC:Disconnect() noclipC=nil end if v then startNoclip() end end})
MG:AddToggle('ijE',{Text=TT('Infinite Jump','Бесконечный прыжок'),Default=false,Callback=function(v) infJump=v if v then startInfJump() elseif infJumpC then infJumpC:Disconnect() infJumpC=nil end end})

-- ============ FUN TAB ============
local FL=T.F:AddLeftGroupbox(TT('Fun','Развлечения'))
FL:AddLabel(TT('Fun features coming soon.','Развлекательные функции скоро.'))
FL:AddButton({Text=TT('Jump Scare (sound)','Пугнуть (звук)'),Func=function()
    local s=Instance.new("Sound") s.SoundId="rbxassetid://130777695" s.Volume=5
    s.Parent=me:WaitForChild("PlayerGui") s:Play()
    task.delay(3,function() if s then s:Destroy() end end)
end})
FL:AddButton({Text=TT('Flip Character','Перевернуть персонажа'),Func=function()
    local h=hrp() if h then h.CFrame=h.CFrame*CFrame.Angles(math.rad(180),0,0) end
end})

-- ============ VISUAL TAB ============
local Gfx=T.E:AddLeftGroupbox(TT('Graphics','Графика'))
Gfx:AddButton({Text=TT('RTX Toggle','Переключить RTX'),Func=function()
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
local CamBox = T.E:AddRightGroupbox(TT('Camera','Камера'))
CamBox:AddSlider('camFovS',{Text=TT('Camera FOV','Угол обзора камеры'),Default=70,Min=30,Max=120,Rounding=0,Suffix='',Callback=function(v)
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = v end
end})
CamBox:AddButton({Text=TT('Reset Camera FOV','Сбросить FOV камеры'),Func=function()
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = 70 end
end})
CamBox:AddSlider('aspectS',{Text=TT('Aspect Ratio','Соотношение сторон'),Default=100,Min=50,Max=100,Rounding=0,Suffix='%',Callback=function(v) ApplyAspect(v/100) end})
CamBox:AddButton({Text=TT('Reset Aspect','Сбросить Aspect'),Func=function() ApplyAspect(1) end})

local EM=T.E:AddLeftGroupbox(TT('Visual','Визуал'))
EM:AddToggle('espE',{Text=TT('ESP','ESP'),Default=false,Callback=function(v) esp=v refreshESP() end})
EM:AddToggle('espT',{Text=TT('Team Check','Проверка команды'),Default=false,Callback=function(v) espTeam=v refreshESP() end})
local ED=T.E:AddLeftGroupbox(TT('Display','Отображение'))
ED:AddToggle('nE',{Text=TT('Names','Имена'),Default=true,Callback=function(v) names=v end})
ED:AddToggle('hE',{Text=TT('Health','Здоровье'),Default=true,Callback=function(v) health=v end})
ED:AddToggle('dE',{Text=TT('Distance','Дистанция'),Default=true,Callback=function(v) dist=v end})
ED:AddToggle('gE',{Text=TT('Gradient','Градиент'),Default=true,Callback=function(v) grad=v end})
ED:AddToggle('ddE',{Text=TT('Hide Dead','Скрывать мёртвых'),Default=true,Callback=function(v) hideDead=v end})
T.E:AddRightGroupbox(TT('Range','Дальность')):AddSlider('eMax',{Text=TT('Max Dist','Макс. дистанция'),Default=300,Min=10,Max=1000,Rounding=0,Suffix='',Callback=function(v) espMax=v end})

-- ============ BINDS TAB (собственный список) ============
local BB = T.B:AddLeftGroupbox(TT('Keybinds','Бинды'))
BB:AddLabel(TT('Click "—" to bind, "✕" to clear.','Нажми "—" чтобы забиндить, "✕" чтобы сбросить.'))

-- Создаём отдельный ScreenGui со списком биндов (только для вкладки Binds)
local bindListGui = Instance.new("ScreenGui")
bindListGui.Name = "IndustrialBindsList"
bindListGui.ResetOnSpawn = false
bindListGui.IgnoreGuiInset = true
bindListGui.DisplayOrder = 3
bindListGui.Parent = me:WaitForChild("PlayerGui")

local listFrame = Instance.new("Frame")
listFrame.Name = "ListFrame"
listFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
listFrame.BorderSizePixel = 0
listFrame.Size = UDim2.new(0, 320, 0, 250)
listFrame.Position = UDim2.new(0.5, -160, 0.5, -125)
listFrame.Visible = false
listFrame.Parent = bindListGui
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", listFrame)
stroke.Color = Color3.fromRGB(125, 85, 255)
stroke.Thickness = 1

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, 0, 0, 28)
listTitle.BackgroundTransparency = 1
listTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
listTitle.Font = Enum.Font.GothamBold
listTitle.TextSize = 14
listTitle.Text = "Binds"
listTitle.Parent = listFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -40)
scroll.Position = UDim2.new(0, 5, 0, 32)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 4
scroll.Parent = listFrame

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 6)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scroll

local function makeRow(id, nameText, order)
    local row = Instance.new("Frame")
    row.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, -8, 0, 36)
    row.LayoutOrder = order
    row.Parent = scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = nameText
    lbl.Parent = row

    local btnBind = Instance.new("TextButton")
    btnBind.Size = UDim2.new(0, 60, 0, 24)
    btnBind.Position = UDim2.new(1, -100, 0.5, 0)
    btnBind.AnchorPoint = Vector2.new(1, 0.5)
    btnBind.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    btnBind.TextColor3 = Color3.fromRGB(220, 220, 220)
    btnBind.Font = Enum.Font.Gotham
    btnBind.TextSize = 12
    btnBind.Text = "—"
    btnBind.Parent = row
    Instance.new("UICorner", btnBind).CornerRadius = UDim.new(0, 5)

    local btnClear = Instance.new("TextButton")
    btnClear.Size = UDim2.new(0, 28, 0, 24)
    btnClear.Position = UDim2.new(1, -36, 0.5, 0)
    btnClear.AnchorPoint = Vector2.new(1, 0.5)
    btnClear.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
    btnClear.TextColor3 = Color3.fromRGB(240, 180, 180)
    btnClear.Font = Enum.Font.GothamBold
    btnClear.TextSize = 12
    btnClear.Text = "✕"
    btnClear.Parent = row
    Instance.new("UICorner", btnClear).CornerRadius = UDim.new(0, 5)

    btnBind.MouseButton1Click:Connect(function() BeginBind(id) end)
    btnClear.MouseButton1Click:Connect(function() ClearBind(id) end)

    BindButtons[id] = {btn=btnBind, label=btnBind}
    RefreshBindButton(id)
end

-- Заполняем список
local order = 0
for _, entry in ipairs({
    {'flyE','Fly','Полёт'},
    {'ncE','Noclip','Проход сквозь стены'},
    {'ijE','Infinite Jump','Бесконечный прыжок'},
    {'aimE','Aimbot','Аимбот'},
    {'espE','ESP','ESP'},
    {'trigE','Triggerbot','Триггербот'},
}) do
    order = order + 1
    makeRow(entry[1], TT(entry[2], entry[3]), order)
end
scroll.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 10)

-- Кнопка в Obsidian для открытия списка
BB:AddButton({Text = TT('Open Bind List','Открыть список биндов'), Func=function()
    listFrame.Visible = not listFrame.Visible
    scroll.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 10)
end})

-- Закрытие списка по крестику/клику вне не нужен — можно закрыть той же кнопкой
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeBtn.TextColor3 = Color3.fromRGB(240, 180, 180)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.Text = "✕"
closeBtn.Parent = listFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)
closeBtn.MouseButton1Click:Connect(function() listFrame.Visible = false end)

-- ============ CONFIG TAB ============
T.Config:AddLeftGroupbox(TT('Configuration','Конфигурация'))

-- ============ SETTINGS TAB ============
local Menu=T.Settings:AddLeftGroupbox(TT('Menu','Меню'))
Menu:AddButton({Text=TT('Unload','Выгрузить'),Func=function()
    killFly()
    if noclipC then noclipC:Disconnect() end
    if infJumpC then infJumpC:Disconnect() end
    if fovGui then fovGui:Destroy() end
    if aspectGui then aspectGui:Destroy() end
    if bindListGui then bindListGui:Destroy() end
    Library:Unload()
end})

-- ============ LANGUAGE TAB ============
local LB = T.Lang:AddLeftGroupbox(TT('Language','Язык'))
LB:AddLabel(TT('Select interface language:','Выберите язык интерфейса:'))
LB:AddButton({Text='English',Func=function()
    Lang = "En"
    Library:Notify("Language: English (reopen H to apply)", 2)
end})
LB:AddButton({Text='Русский',Func=function()
    Lang = "Ru"
    Library:Notify("Язык: Русский (переоткрой H для применения)", 2)
end})
LB:AddLabel(TT('Note: reopen the menu (H) to fully apply.','Примечание: переоткрой меню (H) чтобы язык применился.'))

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

-- ============ SAVE/THEME SETUP ============
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(T.Config)
ThemeManager:ApplyToTab(T.E)
SaveManager:LoadAutoloadConfig()
