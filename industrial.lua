-- ============================================================
--  KEY SYSTEM (локальный ключ)
-- ============================================================
do
local Players = game:GetService("Players")
local me = Players.LocalPlayer
local plrGui = me:WaitForChild("PlayerGui")

local SECRET_KEY = "1"

local keyGui = Instance.new("ScreenGui")
keyGui.Name = "IndustrialKeySystem"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.DisplayOrder = 1000
keyGui.Parent = plrGui

local bg = Instance.new("Frame")
bg.Size = UDim2.new(0, 400, 0, 220)
bg.Position = UDim2.new(0.5, -200, 0.5, -110)
bg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
bg.BorderSizePixel = 0
bg.Parent = keyGui
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", bg)
stroke.Color = Color3.fromRGB(125, 85, 255)
stroke.Thickness = 2

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(230, 230, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Text = "Industrial — Key System"
title.Parent = bg

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 30)
info.Position = UDim2.new(0, 10, 0, 55)
info.BackgroundTransparency = 1
info.TextColor3 = Color3.fromRGB(160, 160, 175)
info.Font = Enum.Font.Gotham
info.TextSize = 13
info.Text = "Введите ключ доступа"
info.Parent = bg

local box = Instance.new("TextBox")
box.Size = UDim2.new(1, -40, 0, 40)
box.Position = UDim2.new(0, 20, 0, 95)
box.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
box.BorderSizePixel = 0
box.TextColor3 = Color3.fromRGB(230, 230, 240)
box.PlaceholderText = "XXXX-XXXX-XXXX"
box.PlaceholderColor3 = Color3.fromRGB(110, 110, 125)
box.Font = Enum.Font.Gotham
box.TextSize = 14
box.Text = ""
box.ClearTextOnFocus = false
box.Parent = bg
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -40, 0, 40)
btn.Position = UDim2.new(0, 20, 0, 150)
btn.BackgroundColor3 = Color3.fromRGB(80, 60, 180)
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Text = "Проверить ключ"
btn.Parent = bg
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.new(0, 10, 1, -22)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200, 80, 80)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.Text = ""
status.Parent = bg

local validKey = nil
local function tryKey()
    local k = box.Text
    if k == "" then status.Text = "Введите ключ" return end
    if k == SECRET_KEY then
        status.TextColor3 = Color3.fromRGB(80, 220, 120)
        status.Text = "Ключ принят"
        validKey = k
        task.wait(0.4)
        keyGui:Destroy()
    else
        status.TextColor3 = Color3.fromRGB(220, 80, 80)
        status.Text = "Неверный ключ"
    end
end
btn.MouseButton1Click:Connect(tryKey)
box.FocusLost:Connect(function(e) if e then tryKey() end end)
while not validKey do task.wait(0.1) end
end

-- ============================================================
--  ОСНОВНОЙ ЧИТ
-- ============================================================
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
local espFill,espFillA=false,0.4
local espObjs={}

local aim,aimFov,aimSmooth,aimMax,aimTeam=false,150,0.05,100,false
local aimTarget,aimTargetRandom="Head",false
local aimParts={"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftArm","RightArm","LeftLeg","RightLeg"}
local AT={on=false,lock=nil,a360=false}
local SKY={on=false,t=0,h=150}
local HBT={on=false,sz=5,orig={}}
local NS={on=false,saved={}}
local trig,trigDelay,lastTrig=false,0.05,0
local fovC,fovFill,fovAlpha=Color3.fromRGB(255,60,60),false,0.85

local fly,flySpd,flyC,flyBV,flyBG=false,50,nil,nil,nil
local noclip,noclipC=false,nil
local infJump,infJumpC=false,nil

local glow,glowColor=false,Color3.fromRGB(0,200,255)
local glowObjs={}
local tps,thirdPOff,thirdC=false,8,nil
local bhop,bhopC=false,nil
local ast,astSpeed,astC=false,55,nil
local AS={on=false,c=nil}
local night,nightOrig=false,nil

local vmOn,vmFov,vmC=false,25,nil
local camBaseFov=70
local hgOn, hgFill, hgOutline, hgFillT, hgOutlineT, hgDepth, hgNeon = false, Color3.fromRGB(0,180,255), Color3.fromRGB(255,255,160), 0.5, 0, true, false
local killSoundId=false
local lastHit,lastHealth,lastPlayed,le_conn={},{},{},{}

-- ============ BIND SYSTEM ============
local Binds = {}
local BindButtons = {}
local BindFile = "industrial_binds.txt"
local CurrentBindId = nil
local WaitingForBind = false
local showKeybindsHud = false
local showWatermark = false

local function MakeDraggable(frame, dragArea)
    dragArea = dragArea or frame
    local dragging, dragStart, startPos
    dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    dragArea.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

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
        Binds[id].state = false
        SaveBinds()
        RefreshBindButton(id)
        if _G.RefreshHud then _G.RefreshHud() end
    end
end

local suppressToggle = false
local lastToggleAt = {}
U.InputBegan:Connect(function(input, gp)
    if not WaitingForBind then return end
    local id = CurrentBindId
    if not id or not Binds[id] then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        Binds[id].key = input.KeyCode
    else
        Binds[id].key = input.UserInputType
    end
    WaitingForBind = false
    suppressToggle = true
    SaveBinds()
    RefreshBindButton(id)
    if _G.RefreshHud then _G.RefreshHud() end
    CurrentBindId = nil
end)

U.InputBegan:Connect(function(input, gp)
    if suppressToggle then suppressToggle = false return end
    if gp then return end
    if WaitingForBind then return end
    for id, b in pairs(Binds) do
        if b.key and b.callback then
            local match = false
            if input.UserInputType == Enum.UserInputType.Keyboard and b.key == input.KeyCode then
                match = true
            elseif input.UserInputType ~= Enum.UserInputType.Keyboard and b.key == input.UserInputType then
                match = true
            end
            if match then
                local now = os.clock()
                if now - (lastToggleAt[id] or 0) >= 0.15 then
                    b.state = not b.state
                    lastToggleAt[id] = now
                    pcall(b.callback, b.state)
                    if _G.RefreshHud then _G.RefreshHud() end
                end
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

-- ============ KEYBINDS HUD ============
local hudGui = Instance.new("ScreenGui")
hudGui.Name = "IndustrialKeybindsHUD"
hudGui.ResetOnSpawn = false
hudGui.IgnoreGuiInset = true
hudGui.DisplayOrder = 50
hudGui.Parent = me:WaitForChild("PlayerGui")

local hudFrame = Instance.new("Frame")
hudFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
hudFrame.BackgroundTransparency = 0.25
hudFrame.BorderSizePixel = 0
hudFrame.Size = UDim2.new(0, 240, 0, 30)
hudFrame.Position = UDim2.new(0, 15, 0, 15)
hudFrame.Visible = false
hudFrame.Parent = hudGui
Instance.new("UICorner", hudFrame).CornerRadius = UDim.new(0, 6)
local hudStroke = Instance.new("UIStroke", hudFrame)
hudStroke.Color = Color3.fromRGB(125, 85, 255)
hudStroke.Thickness = 1

local hudTitle = Instance.new("TextLabel")
hudTitle.Size = UDim2.new(1, 0, 0, 22)
hudTitle.BackgroundTransparency = 1
hudTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
hudTitle.Font = Enum.Font.GothamBold
hudTitle.TextSize = 12
hudTitle.Text = "Keybinds"
hudTitle.Parent = hudFrame

local hudList = Instance.new("Frame")
hudList.BackgroundTransparency = 1
hudList.Size = UDim2.new(1, 0, 0, 0)
hudList.Position = UDim2.new(0, 0, 0, 24)
hudList.Parent = hudFrame
local hudLayout = Instance.new("UIListLayout")
hudLayout.Padding = UDim.new(0, 2)
hudLayout.Parent = hudList

local hudRows = {}
local function RefreshHud()
    for _, row in pairs(hudRows) do row:Destroy() end
    hudRows = {}
    local y = 0
    for id, b in pairs(Binds) do
        if b.key and b.state then
            local row = Instance.new("Frame")
            row.BackgroundTransparency = 1
            row.Size = UDim2.new(1, 0, 0, 16)
            row.Parent = hudList
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -10, 1, 0)
            lbl.Position = UDim2.new(0, 5, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 11
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextColor3 = Color3.fromRGB(120, 230, 120)
            lbl.Text = string.format("%s %s", tostring(b.name_en or id), tostring(b.key.Name or b.key))
            lbl.Parent = row
            y = y + 18
        end
    end
    hudFrame.Size = UDim2.new(0, 240, 0, 30 + y)
end
_G.RefreshHud = RefreshHud

-- ============ WATERMARK ============
local wmGui = Instance.new("ScreenGui")
wmGui.Name = "IndustrialWatermark"
wmGui.ResetOnSpawn = false
wmGui.IgnoreGuiInset = true
wmGui.DisplayOrder = 50
wmGui.Parent = me:WaitForChild("PlayerGui")

local wmFrame = Instance.new("Frame")
wmFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
wmFrame.BackgroundTransparency = 0.25
wmFrame.BorderSizePixel = 0
wmFrame.Size = UDim2.new(0, 340, 0, 28)
wmFrame.Position = UDim2.new(0.5, -170, 0, 15)
wmFrame.Visible = false
wmFrame.Parent = wmGui
Instance.new("UICorner", wmFrame).CornerRadius = UDim.new(0, 6)
local wmStroke = Instance.new("UIStroke", wmFrame)
wmStroke.Color = Color3.fromRGB(125, 85, 255)
wmStroke.Thickness = 1

local wmText = Instance.new("TextLabel")
wmText.Size = UDim2.new(1, -10, 1, 0)
wmText.Position = UDim2.new(0, 5, 0, 0)
wmText.BackgroundTransparency = 1
wmText.TextColor3 = Color3.fromRGB(220, 220, 240)
wmText.Font = Enum.Font.GothamBold
wmText.TextSize = 13
wmText.Text = "Industrial"
wmText.Parent = wmFrame

MakeDraggable(hudFrame, hudFrame)
MakeDraggable(wmFrame, wmFrame)

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

-- ============ NO SCOPE BARS ============
NS.saved={}
local function isScopeBar(o)
    if not (o:IsA("Frame") or o:IsA("ImageLabel") or o:IsA("TextLabel")) then return false end
    local bg=o.BackgroundColor3
    if not (bg.R<0.15 and bg.G<0.15 and bg.B<0.15) then return false end
    if not (o.Size.X.Scale>=0.9 and o.AbsolutePosition.X<=2) then return false end
    local sy=o.Size.Y.Scale
    return (o.Position.Y.Scale<=0.35 and sy<0.6) or (o.Position.Y.Scale>=0.65 and sy<0.6) or sy>=0.9
end
local function scanScopeBars()
    local pg=me:FindFirstChild("PlayerGui") if not pg then return end
    for _,o in ipairs(pg:GetDescendants()) do
        if isScopeBar(o) then
            if NS.saved[o]==nil then NS.saved[o]=o.Visible end
            if o.Visible then o.Visible=false end
        end
    end
end
local function hideScopeBars()
    if not NS.on then return end
    NS.n=(NS.n or 0)+1
    if NS.n%180==0 then scanScopeBars() end
    for o in pairs(NS.saved) do
        if not o.Parent then NS.saved[o]=nil
        elseif o.Visible then o.Visible=false end
    end
end
local function restoreScope()
    for o,v in pairs(NS.saved) do
        if o and o.Parent then o.Visible=v end
    end
    NS.saved={}
end
local function setScopeBars(v)
    NS.on=v
    if NS.conn then NS.conn:Disconnect() NS.conn=nil end
    if v then
        scanScopeBars()
        local pg=me:FindFirstChild("PlayerGui")
        if pg then
            NS.conn=pg.DescendantAdded:Connect(function(o)
                if not NS.on then return end
                if isScopeBar(o) then
                    if NS.saved[o]==nil then NS.saved[o]=o.Visible end
                    o.Visible=false
                end
            end)
        end
    else
        restoreScope()
    end
end

-- ============ BIG HITBOX (scale target parts so sky-shots instantly land) ============
local function hbRestoreAll()
    for part,orig in pairs(HBT.orig) do
        if part and part.Parent then part.Size=orig end
    end
    HBT.orig={}
end
local function hbScaleTarget(p)
    local ch=p.Character if not ch then hbRestoreAll() return false end
    local done=false
    for _,part in ipairs(ch:GetChildren()) do
        if part:IsA("BasePart") and part.Name~="HumanoidRootPart" then
            if not HBT.orig[part] then HBT.orig[part]=part.Size end
            local o=HBT.orig[part]
            local f=math.max(HBT.sz,0.1)
            local want=Vector3.new(math.max(o.X*f,1),math.max(o.Y*f,1),math.max(o.Z*f,1))
            local cur=part.Size
            if math.abs(cur.X-want.X)>0.5 or math.abs(cur.Y-want.Y)>0.5 or math.abs(cur.Z-want.Z)>0.5 then
                part.Size=want
            end
            done=true
        end
    end
    if not done then hbRestoreAll() return false end
    return true
end

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

-- ============ GLOW ============
local glowFillT,glowOutlineT=0.75,0
local function rmGlow(p)
    local d=glowObjs[p] if not d then return end
    if d.g then pcall(function() d.g.Adornee=nil d.g:Destroy() end) end
    glowObjs[p]=nil
end
local function mkGlow(p)
    if p==me then return end
    local ch=p.Character if not ch then return end
    rmGlow(p)
    local g=Instance.new("Highlight")
    g.Adornee=ch
    g.FillColor=glowColor
    g.FillTransparency=glowFillT
    g.OutlineColor=glowColor
    g.OutlineTransparency=glowOutlineT
    g.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    g.Parent=me:WaitForChild("PlayerGui")
    glowObjs[p]={g=g}
end
local function refreshGlow()
    for p in pairs(glowObjs) do rmGlow(p) end
    if not glow then return end
    for _,p in ipairs(P:GetPlayers()) do if p~=me then mkGlow(p) end end
end
local function updateGlowColor()
    for _,d in pairs(glowObjs) do if d.g then d.g.FillColor=glowColor d.g.OutlineColor=glowColor end end
end
P.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() task.wait(1) if glow then mkGlow(p) end end) end)
for _,p in ipairs(P:GetPlayers()) do if p~=me then p.CharacterAdded:Connect(function() task.wait(1) if glow then mkGlow(p) end end) end end
P.PlayerRemoving:Connect(rmGlow)

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
        if U:IsKeyDown(Enum.KeyCode.A) then mv=mv-cam.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.D) then mv=mv+cam.CFrame.RightVector end
        if U:IsKeyDown(Enum.KeyCode.Space) then mv=mv+Vector3.new(0,1,0) end
        if U:IsKeyDown(Enum.KeyCode.LeftControl) then mv=mv-Vector3.new(0,1,0) end
        if mv.Magnitude>0 then mv=mv.Unit*flySpd end
        flyBV.Velocity=mv flyBG.CFrame=cam.CFrame
    end)
end

local function setNoclipParts(state)
    local c = me.Character
    if not c then return end
    local bodyParts = {
        HumanoidRootPart = true, Head = true,
        UpperTorso = true, LowerTorso = true,
        LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
        RightUpperArm = true, RightLowerArm = true, RightHand = true,
        LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
        RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
        Torso = true,
    }
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            if state then
                p.CanCollide = false
            else
                if bodyParts[p.Name] then
                    p.CanCollide = true
                end
            end
        end
    end
end

local function startNoclip()
    if noclipC then noclipC:Disconnect() end
    noclipC = R.Stepped:Connect(function()
        setNoclipParts(noclip)
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

-- ============ BUNNY HOP ============
local function startBhop()
    if bhopC then bhopC:Disconnect() end
    bhopC=R.Heartbeat:Connect(function()
        if not bhop then return end
        local h=me.Character and me.Character:FindFirstChildOfClass("Humanoid")
        if not h then return end
        if not U:IsKeyDown(Enum.KeyCode.Space) then return end
        local st=h:GetState()
        if st==Enum.HumanoidStateType.Running or st==Enum.HumanoidStateType.Idle or h.FloorMaterial~=Enum.Material.Air then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- ============ AIR STRAFE (WASD) ============
local function startAirStrafe()
    if astC then astC:Disconnect() end
    astC=R.RenderStepped:Connect(function(dt)
        if not ast then return end
        local h=hrp() if not h then return end
        local hum=me.Character and me.Character:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local st=hum:GetState()
        local inAir=(st==Enum.HumanoidStateType.Freefall or st==Enum.HumanoidStateType.Jumping or hum.FloorMaterial==Enum.Material.Air)
        if not inAir then return end
        local md=hum.MoveDirection
        if md.Magnitude<0.01 then return end
        local move=md.Unit
        local v=h.AssemblyLinearVelocity
        local hv=Vector3.new(v.X,0,v.Z)
        local add=move*astSpeed-hv
        if add.Magnitude>0.05 then
            local accel=math.min(add.Magnitude,astSpeed*dt*8)
            h.AssemblyLinearVelocity=v+add.Unit*accel
        end
    end)
end

-- ============ AUTO STOP (freeze movement while aiming) ============
local function startAutoStop()
    if AS.c then AS.c:Disconnect() end
    AS.c=R.RenderStepped:Connect(function()
        if not AS.on then return end
        if not U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        local h=hrp() if not h then return end
        local v=h.AssemblyLinearVelocity
        h.AssemblyLinearVelocity=Vector3.new(0,v.Y,0)
    end)
end

-- ============ VIEWMODEL (push hands away) ============
local function ApplyFov()
    local cam=workspace.CurrentCamera
    if not cam then return end
    if vmOn then
        cam.FieldOfView=math.clamp(camBaseFov+vmFov,30,140)
    else
        cam.FieldOfView=camBaseFov
    end
end
local function startViewmodel()
    if vmC then vmC:Disconnect() end
    vmC=R.RenderStepped:Connect(function()
        if vmOn then
            local cam=workspace.CurrentCamera
            if cam then cam.FieldOfView=math.clamp(camBaseFov+vmFov,30,140) end
        end
    end)
end
local function setViewmodel(v)
    vmOn=v
    if v then startViewmodel() else if vmC then vmC:Disconnect() vmC=nil end ApplyFov() end
end

-- ============ HANDS GLOW ============
local hgHighlights={}
local hgOrig={}
local handGlowNames={"LeftHand","RightHand","LeftLowerArm","RightLowerArm","LeftUpperArm","RightUpperArm","Left Arm","Right Arm","LeftFoot","RightFoot"}
local function getHandParts()
    local c=me.Character if not c then return {} end
    local t={}
    for _,n in ipairs(handGlowNames) do
        local p=c:FindFirstChild(n)
        if p and p:IsA("BasePart") then t[#t+1]=p end
    end
    return t
end
local function restoreHandParts()
    for p,orig in pairs(hgOrig) do
        if p and p.Parent then
            pcall(function() p.Material=orig.m p.Color=orig.c end)
        end
    end
    hgOrig={}
end
local function applyHandNeon()
    for _,p in ipairs(getHandParts()) do
        if not hgOrig[p] then
            hgOrig[p]={m=p.Material,c=p.Color}
        end
        p.Material=Enum.Material.Neon
        p.Color=hgFill
    end
end
local function refreshHandGlow()
    for p,h in pairs(hgHighlights) do
        if not h or not h.Parent or not p or not p.Parent then
            if h then pcall(function() h:Destroy() end) end
            hgHighlights[p]=nil
        end
    end
    for p in pairs(hgOrig) do
        if not p or not p.Parent then hgOrig[p]=nil end
    end
    if not hgOn then return end
    if hgNeon then applyHandNeon() else restoreHandParts() end
    for _,p in ipairs(getHandParts()) do
        local h=hgHighlights[p]
        if not h then
            h=Instance.new("Highlight")
            h.Name="IndustrialHandGlow"
            h.Adornee=p
            h.Parent=p
            hgHighlights[p]=h
        end
        h.FillColor=hgFill
        h.FillTransparency=hgFillT
        h.OutlineColor=hgOutline
        h.OutlineTransparency=hgOutlineT
        h.DepthMode=hgDepth and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    end
end
local function stopHandGlow()
    for p,h in pairs(hgHighlights) do pcall(function() h:Destroy() end) end
    hgHighlights={}
    restoreHandParts()
end

-- ============ KILLSOUND ============
local ksFiles={}
local loadKS
do
    local function loadKSImpl(name, path)
        if not getcustomasset then return nil end
        local ok,id=pcall(getcustomasset,path)
        if ok and type(id)=="string" and #id>0 and id:sub(1,8)=="rbxasset" then return id end
        if isfile and isfile(path) and readfile and writefile then
            local ok2,data=pcall(readfile,path)
            if ok2 and data then
                local dest=name
                if makefolder and (not isfolder or not isfolder("killsounds")) then
                    pcall(makefolder,"killsounds")
                    if isfolder and isfolder("killsounds") then dest="killsounds/"..name end
                end
                local ok3=pcall(writefile,dest,data)
                if ok3 then
                    local ok4,id2=pcall(getcustomasset,dest)
                    if ok4 and type(id2)=="string" and #id2>0 then return id2 end
                end
            end
        end
        return nil
    end
    loadKS=loadKSImpl
    ksFiles.NeverLose=loadKS("neverlose.wav","C:\\Users\\Administrator\\Desktop\\neverlose.wav")
    ksFiles.Skeet=loadKS("skeet.wav","C:\\Users\\Administrator\\Desktop\\skeet.wav")
end
local function PlayKillSound()
    if not killSoundId then return end
    local s=Instance.new("Sound")
    s.SoundId=killSoundId
    s.Volume=2
    s.Parent=workspace.CurrentCamera or workspace
    s:Play()
    task.spawn(function() task.wait(3) pcall(function() s:Destroy() end) end)
end
local function TrackPlayer(p)
    if p==me then return end
    local function tryKill()
        if not killSoundId then return end
        if os.clock()-(lastHit[p] or -9)>3 then return end
        if os.clock()-(lastPlayed[p] or -9)<1 then return end
        lastPlayed[p]=os.clock()
        PlayKillSound()
    end
    local function onHP(hum,hp)
        local prev=lastHealth[hum]
        if prev and hp<prev then lastHit[p]=os.clock() end
        lastHealth[hum]=hp
        if hp<=0 then tryKill() end
    end
    local function hook(char)
        if not char then return end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            lastHealth[hum]=hum.Health
            hum.HealthChanged:Connect(function(hp) onHP(hum,hp) end)
            hum.Died:Connect(tryKill)
            le_conn[p]=char.AncestryChanged:Connect(function(_,parent)
                if parent==nil then tryKill() end
            end)
        end
    end
    hook(p.Character)
    p.CharacterAdded:Connect(hook)
    le_conn["rem_"..p.Name]=p.CharacterRemoving:Connect(function(char)
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then lastHealth[hum]=0 end
        tryKill()
    end)
end
P.PlayerAdded:Connect(TrackPlayer)
for _,p in ipairs(P:GetPlayers()) do TrackPlayer(p) end

-- ============ THIRD PERSON ============
local function setThird(v)
    tps=v
    if v then
        if not thirdC then
            thirdC=R.RenderStepped:Connect(function()
                if not tps then return end
                local h=hrp() if not h then return end
                local cam=workspace.CurrentCamera
                if not cam then return end
                local pos=h.Position+Vector3.new(0,2.5,0)
                cam.CFrame=CFrame.lookAt(pos-cam.CFrame.LookVector*thirdPOff,pos)
            end)
        end
        local cam=workspace.CurrentCamera
        if cam then cam.CameraType=Enum.CameraType.Scriptable end
    else
        if thirdC then thirdC:Disconnect() thirdC=nil end
        local cam=workspace.CurrentCamera
        if cam then cam.CameraType=Enum.CameraType.Custom end
    end
end

-- ============ NIGHT MODE (winter vibe) ============
local function setNight(v)
    night=v
    if v then
        if not nightOrig then
            nightOrig={
                Brightness=L.Brightness,
                Ambient=L.Ambient,
                OutdoorAmbient=L.OutdoorAmbient,
                GlobalShadows=L.GlobalShadows,
                FogStart=L.FogStart,
                FogEnd=L.FogEnd,
                FogColor=L.FogColor,
                ClockTime=L.ClockTime,
                TimeOfDay=L.TimeOfDay,
            }
        end
        L.Brightness=0.55
        L.Ambient=Color3.fromRGB(140,165,210)
        L.OutdoorAmbient=Color3.fromRGB(110,140,190)
        L.GlobalShadows=true
        pcall(function()
            L.ClockTime=0.05
            L.TimeOfDay="01:15:00"
        end)
        L.FogStart=40
        L.FogEnd=420
        L.FogColor=Color3.fromRGB(200,215,240)
        if not L:FindFirstChild("IndustrialSnowTint") then
            local cc=Instance.new("ColorCorrectionEffect")
            cc.Name="IndustrialSnowTint"
            cc.Brightness=0.05
            cc.Saturation=-0.25
            cc.Contrast=0.1
            cc.TintColor=Color3.fromRGB(190,205,235)
            cc.Parent=L
        end
    else
        if nightOrig then
            L.Brightness=nightOrig.Brightness
            L.Ambient=nightOrig.Ambient
            L.OutdoorAmbient=nightOrig.OutdoorAmbient
            L.GlobalShadows=nightOrig.GlobalShadows
            L.FogStart=nightOrig.FogStart
            L.FogEnd=nightOrig.FogEnd
            L.FogColor=nightOrig.FogColor
            pcall(function()
                L.ClockTime=nightOrig.ClockTime
                L.TimeOfDay=nightOrig.TimeOfDay
            end)
        end
        local cc=L:FindFirstChild("IndustrialSnowTint")
        if cc then cc:Destroy() end
    end
end

me.CharacterAdded:Connect(function()
    task.wait(1)
    if fly then startFly() end
    if noclip then startNoclip() end
    if bhop then startBhop() end
    if ast then startAirStrafe() end
    if AS.on then startAutoStop() end
    if tps then setThird(true) end
    if vmOn then startViewmodel() end
    if hgOn then refreshHandGlow() end
end)

-- ============ REGISTER BINDS ============
RegisterBind('flyE','Fly','Полёт', function(v) fly=v if v then startFly() else killFly() end end)
RegisterBind('ncE','Noclip','Проход сквозь стены', function(v)
    noclip=v
    if v then
        if not noclipC then startNoclip() end
        setNoclipParts(true)
    else
        setNoclipParts(false)
        if noclipC then noclipC:Disconnect() noclipC=nil end
    end
end)
RegisterBind('ijE','Infinite Jump','Бесконечный прыжок', function(v) infJump=v if v then startInfJump() elseif infJumpC then infJumpC:Disconnect() infJumpC=nil end end)
RegisterBind('aimE','Aimbot','Аимбот', function(v) aim=v fovCirc.Visible=v fovFillF.Visible=v and fovFill end)
RegisterBind('espE','ESP','ESP', function(v) esp=v refreshESP() end)
RegisterBind('trigE','Triggerbot','Триггербот', function(v) trig=v end)
RegisterBind('glowE','Glow','Глоу', function(v)
    glow=v
    if v then refreshGlow() else for p in pairs(glowObjs) do rmGlow(p) end end
end)
RegisterBind('bhopE','BunnyHop','Баннихоп', function(v)
    bhop=v
    if v then startBhop() elseif bhopC then bhopC:Disconnect() bhopC=nil end
end)
RegisterBind('astE','AirStrafe','Эйрстрайф', function(v)
    ast=v
    if v then startAirStrafe() elseif astC then astC:Disconnect() astC=nil end
end)
RegisterBind('vmE','Viewmodel','Вьюмодель', function(v) setViewmodel(v) end)
RegisterBind('hgE','Hands Glow','Свечение рук', function(v)
    hgOn=v
    if v then refreshHandGlow() else stopHandGlow() end
end)
RegisterBind('tpsE','Third Person','Вид от 3-го лица', function(v) setThird(v) end)
RegisterBind('nmE','Night Mode','Ночной режим', function(v) setNight(v) end)

LoadBinds()

-- ============ MAIN TAB ============
local AG=T.C:AddLeftGroupbox(TT('Combat','Бой'))
AG:AddToggle('aimE',{Text=TT('Aimbot','Аимбот'),Default=false,Callback=function(v) aim=v fovCirc.Visible=v fovFillF.Visible=v and fovFill end})
AG:AddToggle('aimT',{Text=TT('Team Check','Проверка команды'),Default=false,Callback=function(v) aimTeam=v end})
AG:AddDropdown('aimPart',{Text=TT('Lock Part','Часть захвата'),Default='Head',Values={'Head','UpperTorso','LowerTorso','HumanoidRootPart','LeftArm','RightArm','LeftLeg','RightLeg'},Callback=function(v) aimTarget=v end})
AG:AddToggle('aimRand',{Text=TT('Random Part','Случайная часть'),Default=false,Callback=function(v) aimTargetRandom=v end})
AG:AddSlider('aimF',{Text=TT('FOV','Радиус'),Default=150,Min=0,Max=180,Rounding=0,Suffix='',Callback=function(v) aimFov=v fovCirc.Size=UDim2.new(0,v*2,0,v*2) fovFillF.Size=UDim2.new(0,v*2,0,v*2) end})
AG:AddSlider('aimS',{Text=TT('Smooth','Плавность'),Default=5,Min=0,Max=100,Rounding=0,Suffix='%',Callback=function(v) aimSmooth=v/100 end})
AG:AddSlider('aimM',{Text=TT('Max Dist','Макс. дистанция'),Default=100,Min=10,Max=500,Rounding=0,Suffix='',Callback=function(v) aimMax=v end})
AG:AddToggle('lockE',{Text=TT('Aim Lock','Лок цели'),Default=false,Callback=function(v) AT.on=v if not v then AT.lock=nil end end})
AG:AddToggle('a360E',{Text=TT('360 Aimbot','Аимбот 360'),Default=false,Callback=function(v) AT.a360=v end})
AG:AddToggle('skyE',{Text=TT('Sky Aim','Стрельба в небо'),Default=false,Callback=function(v) SKY.on=v end})
AG:AddSlider('skyH',{Text=TT('Sky Height','Высота неба'),Default=150,Min=50,Max=500,Rounding=0,Suffix='',Callback=function(v) SKY.h=v end})
AG:AddToggle('scopeBarE',{Text=TT('Remove Scope Bars','Убрать полосы прицела'),Default=false,Callback=function(v) setScopeBars(v) end})
AG:AddToggle('hbE',{Text=TT('Big Hitbox','Большой хитбокс'),Default=false,Callback=function(v) HBT.on=v if not v then hbRestoreAll() end end})
AG:AddSlider('hbS',{Text=TT('Hitbox Size','Размер хитбокса'),Default=5,Min=1,Max=15,Rounding=0,Suffix='x',Callback=function(v) HBT.sz=v end})
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
MG:AddToggle('ncE',{Text=TT('Noclip','Проход сквозь стены'),Default=false,Callback=function(v)
    noclip=v
    if v then
        if not noclipC then startNoclip() end
        setNoclipParts(true)
    else
        setNoclipParts(false)
        if noclipC then noclipC:Disconnect() noclipC=nil end
    end
end})
MG:AddToggle('ijE',{Text=TT('Infinite Jump','Бесконечный прыжок'),Default=false,Callback=function(v) infJump=v if v then startInfJump() elseif infJumpC then infJumpC:Disconnect() infJumpC=nil end end})
MG:AddToggle('bhopE',{Text=TT('BunnyHop','Баннихоп'),Default=false,Callback=function(v)
    bhop=v
    if v then startBhop() elseif bhopC then bhopC:Disconnect() bhopC=nil end
end})
MG:AddToggle('astE',{Text=TT('AirStrafe','Эйрстрайф'),Default=false,Callback=function(v)
    ast=v
    if v then startAirStrafe() elseif astC then astC:Disconnect() astC=nil end
end})
MG:AddSlider('astS',{Text=TT('AirStrafe Speed','Макс. скорость воздуха'),Default=55,Min=10,Max=250,Rounding=0,Suffix='',Callback=function(v) astSpeed=v end})
MG:AddToggle('asE',{Text=TT('Auto Stop (hold RMB)','Авто-стоп (ПКМ)'),Default=false,Callback=function(v)
    AS.on=v
    if v then startAutoStop() elseif AS.c then AS.c:Disconnect() AS.c=nil end
end})

-- ============ FUN TAB ============
local FL=T.F:AddLeftGroupbox(TT('Fun','Развлечения'))
FL:AddDropdown('ksS',{Text=TT('Kill Sound','Звук убийства'),Default='Off',Values={'Off','NeverLose','Skeet'},Callback=function(v)
    if v=='Off' then killSoundId=false return end
    local file,path
    if v=='NeverLose' then
        file=ksFiles.NeverLose path="C:\\Users\\Administrator\\Desktop\\neverlose.wav"
    else
        file=ksFiles.Skeet path="C:\\Users\\Administrator\\Desktop\\skeet.wav"
    end
    if not file then file=loadKS(v=="NeverLose" and "neverlose.wav" or "skeet.wav",path) end
    local id=file
    if id then
        killSoundId=id
        Library:Notify(TT('KillSound: '..v,'Звук убийства: '..v),2)
    else
        killSoundId=false
        Library:Notify(TT('Sound file not found','Файл звука не найден на рабочем столе'),2)
    end
end})
FL:AddButton({Text=TT('Test Kill Sound','Тест звука убийства'),Func=function()
    if not killSoundId then
        Library:Notify(TT('Select a kill sound first','Сначала выберите звук убийства'),2)
        return
    end
    PlayKillSound()
    Library:Notify(TT('Playing kill sound...','Играет звук убийства...'),2)
end})
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
    camBaseFov = v
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = v end
end})
CamBox:AddButton({Text=TT('Reset Camera FOV','Сбросить FOV камеры'),Func=function()
    camBaseFov = 70
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = 70 end
end})
CamBox:AddSlider('aspectS',{Text=TT('Aspect Ratio','Соотношение сторон'),Default=100,Min=50,Max=100,Rounding=0,Suffix='%',Callback=function(v) ApplyAspect(v/100) end})
CamBox:AddButton({Text=TT('Reset Aspect','Сбросить Aspect'),Func=function() ApplyAspect(1) end})

local EM=T.E:AddLeftGroupbox(TT('Visual','Визуал'))
EM:AddToggle('espE',{Text=TT('ESP','ESP'),Default=false,Callback=function(v) esp=v refreshESP() end})
EM:AddToggle('espT',{Text=TT('Team Check','Проверка команды'),Default=false,Callback=function(v) espTeam=v refreshESP() end})
EM:AddToggle('espFillE',{Text=TT('ESP Fill','Заливка ESP'),Default=false,Callback=function(v) espFill=v end})
EM:AddSlider('espFillA',{Text=TT('Fill Transparency','Прозрачность заливки'),Default=40,Min=0,Max=90,Rounding=0,Suffix='%',Callback=function(v) espFillA=v/100 end})
EM:AddToggle('glowE',{Text=TT('Glow','Глоу'),Default=false,Callback=function(v)
    glow=v
    if v then refreshGlow() else for p in pairs(glowObjs) do rmGlow(p) end end
end})
EM:AddLabel(TT('Glow Color','Цвет глоу')):AddColorPicker('glowC',{Default=glowColor,Title=TT('Glow Color','Цвет глоу'),Transparency=0,
    Callback=function(v) glowColor=v updateGlowColor() end})
local CM=T.E:AddRightGroupbox(TT('Viewmodel','Вьюмодель'))
CM:AddToggle('vmE',{Text=TT('Viewmodel','Вьюмодель'),Default=false,Callback=function(v) setViewmodel(v) end})
CM:AddSlider('vmD',{Text=TT('Hands Distance','Отдаление рук'),Default=25,Min=0,Max=60,Rounding=0,Suffix='',Callback=function(v) vmFov=v end})
CM:AddToggle('hgE',{Text=TT('Hands Glow','Свечение рук'),Default=false,Callback=function(v)
    hgOn=v
    if v then refreshHandGlow() else stopHandGlow() end
end})
CM:AddLabel(TT('Fill Color','Цвет заливки')):AddColorPicker('hgFC',{Default=hgFill,Title=TT('Fill Color','Цвет заливки'),Transparency=0,
    Callback=function(v) hgFill=v refreshHandGlow() end})
CM:AddLabel(TT('Outline Color','Цвет обводки')):AddColorPicker('hgOC',{Default=hgOutline,Title=TT('Outline Color','Цвет обводки'),Transparency=0,
    Callback=function(v) hgOutline=v refreshHandGlow() end})
CM:AddSlider('hgFT',{Text=TT('Fill Transparency','Прозрачность заливки'),Default=50,Min=0,Max=100,Rounding=0,Suffix='%',Callback=function(v) hgFillT=v/100 refreshHandGlow() end})
CM:AddSlider('hgOT',{Text=TT('Outline Transparency','Прозрачность обводки'),Default=0,Min=0,Max=100,Rounding=0,Suffix='%',Callback=function(v) hgOutlineT=v/100 refreshHandGlow() end})
CM:AddToggle('hgDepthE',{Text=TT('Always On Top','Поверх всего'),Default=true,Callback=function(v) hgDepth=v refreshHandGlow() end})
CM:AddToggle('hgNeonE',{Text=TT('Neon Material','Неоновая текстура'),Default=false,Callback=function(v) hgNeon=v refreshHandGlow() end})
CM:AddToggle('tpsE',{Text=TT('Third Person','Вид от 3-го лица'),Default=false,Callback=function(v) setThird(v) end})
CM:AddSlider('tpsD',{Text=TT('Camera Distance','Дистанция камеры'),Default=8,Min=3,Max=30,Rounding=0,Suffix='',Callback=function(v) thirdPOff=v end})
local NM=T.E:AddRightGroupbox(TT('Environment','Окружение'))
NM:AddToggle('nmE',{Text=TT('Night Mode','Ночной режим'),Default=false,Callback=function(v) setNight(v) end})
local ED=T.E:AddLeftGroupbox(TT('Display','Отображение'))
ED:AddToggle('nE',{Text=TT('Names','Имена'),Default=true,Callback=function(v) names=v end})
ED:AddToggle('hE',{Text=TT('Health','Здоровье'),Default=true,Callback=function(v) health=v end})
ED:AddToggle('dE',{Text=TT('Distance','Дистанция'),Default=true,Callback=function(v) dist=v end})
ED:AddToggle('gE',{Text=TT('Gradient','Градиент'),Default=true,Callback=function(v) grad=v end})
ED:AddToggle('ddE',{Text=TT('Hide Dead','Скрывать мёртвых'),Default=true,Callback=function(v) hideDead=v end})

local ExtraV = T.E:AddRightGroupbox(TT('Overlay','Оверлей'))
ExtraV:AddToggle('kbHudE',{Text=TT('Keybinds HUD','Кейбинды на экране'),Default=false,Callback=function(v)
    showKeybindsHud = v
    hudFrame.Visible = v
    if v then RefreshHud() end
end})
ExtraV:AddToggle('wmE',{Text=TT('Watermark','Ватермарка'),Default=false,Callback=function(v)
    showWatermark = v
    wmFrame.Visible = v
end})
ExtraV:AddLabel(TT('Drag HUD/Watermark with mouse to move.','Перетаскивай HUD/Ватермарку мышкой.'))

T.E:AddRightGroupbox(TT('Range','Дальность')):AddSlider('eMax',{Text=TT('Max Dist','Макс. дистанция'),Default=300,Min=10,Max=1000,Rounding=0,Suffix='',Callback=function(v) espMax=v end})

-- ============ BINDS TAB ============
local BB = T.B:AddLeftGroupbox(TT('Keybinds','Бинды'))
BB:AddLabel(TT('Click "—" to bind, "✕" to clear.','Нажми "—" чтобы забиндить, "✕" чтобы сбросить.'))

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
listFrame.Size = UDim2.new(0, 360, 0, 260)
listFrame.Position = UDim2.new(0.5, -180, 0.5, -130)
listFrame.Visible = false
listFrame.Parent = bindListGui
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)
local lstroke = Instance.new("UIStroke", listFrame)
lstroke.Color = Color3.fromRGB(125, 85, 255)
lstroke.Thickness = 1

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
    lbl.Size = UDim2.new(1, -150, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = nameText
    lbl.Parent = row

    local btnBind = Instance.new("TextButton")
    btnBind.Size = UDim2.new(0, 100, 0, 24)
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

local order = 0
for _, entry in ipairs({
    {'flyE','Fly','Полёт'},
    {'ncE','Noclip','Проход сквозь стены'},
    {'ijE','Infinite Jump','Бесконечный прыжок'},
    {'aimE','Aimbot','Аимбот'},
    {'espE','ESP','ESP'},
    {'trigE','Triggerbot','Триггербот'},
    {'glowE','Glow','Глоу'},
    {'bhopE','BunnyHop','Баннихоп'},
    {'astE','AirStrafe','Эйрстрайф'},
    {'vmE','Viewmodel','Вьюмодель'},
    {'hgE','Hands Glow','Свечение рук'},
    {'tpsE','Third Person','Вид от 3-го лица'},
    {'nmE','Night Mode','Ночной режим'},
}) do
    order = order + 1
    makeRow(entry[1], TT(entry[2], entry[3]), order)
end
scroll.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 10)

BB:AddButton({Text = TT('Open Bind List','Открыть список биндов'), Func=function()
    listFrame.Visible = not listFrame.Visible
    scroll.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 10)
end})

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
    if bhopC then bhopC:Disconnect() end
    if astC then astC:Disconnect() end
    setThird(false)
    setNight(false)
    setViewmodel(false)
    hgOn=false
    stopHandGlow()
    setScopeBars(false)
    HBT.on=false
    hbRestoreAll()
    killSoundId=false
    for p in pairs(glowObjs) do rmGlow(p) end
    if fovGui then fovGui:Destroy() end
    if aspectGui then aspectGui:Destroy() end
    if bindListGui then bindListGui:Destroy() end
    if hudGui then hudGui:Destroy() end
    if wmGui then wmGui:Destroy() end
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

-- ============ WATERMARK LOOP ============
task.spawn(function()
    while true do
        task.wait(0.5)
        if showWatermark then
            local ping = 0
            pcall(function()
                ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            local fps = math.floor(1 / math.max(R.RenderStepped:Wait(), 1e-6))
            local h = os.date("%H:%M:%S")
            wmText.Text = string.format("Industrial | Ping: %dms | FPS: %d | %s", ping, fps, h)
        end
    end
end)

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
        d.box.Filled=espFill
        if espFill then d.box.Transparency=espFillA end
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
    local lh=hrp()
    for _,p in ipairs(P:GetPlayers()) do
        if p==me then continue end
        if aimTeam and sameTeam(p) then continue end
        local ch=p.Character if not ch then continue end
        local hum=ch:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local partName=aimTargetRandom and aimParts[math.random(1,#aimParts)] or aimTarget
        local part=ch:FindFirstChild(partName) or ch:FindFirstChild("Head")
        if not part then continue end
        local h=ch:FindFirstChild("HumanoidRootPart")
        local wd=(h and lh) and (h.Position-lh.Position).Magnitude or math.huge
        if wd>aimMax then continue end
        if AT.a360 then
            if wd<bd then bd=wd best=p end
        else
            local sc,on=Cam:WorldToViewportPoint(part.Position)
            if not on then continue end
            local d2=(Vector2.new(sc.X,sc.Y)-mp).Magnitude
            if d2<aimFov and d2<bd then bd=d2 best=p end
        end
    end
    return best
end
R.RenderStepped:Connect(function()
    if not aim then return end
    if not U:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then hbRestoreAll() return end

    if SKY.on then
        local st=AT.lock
        if st then
            local sh=st.Character and st.Character:FindFirstChildOfClass("Humanoid")
            if not (sh and sh.Health>0) then st=nil AT.lock=nil end
        end
        if not st then st=getTarget() AT.lock=st end
        if not st then hbRestoreAll() return end
        local ch=st.Character
        local hh=ch and ch:FindFirstChild("HumanoidRootPart")
        if not hh then hbRestoreAll() return end
        local lh=hrp() if not lh then hbRestoreAll() return end
        if HBT.on then hbScaleTarget(st) end
        local skyPos=lh.Position+Vector3.new(0,SKY.h,0)
        pcall(function()
            ch:PivotTo(CFrame.new(skyPos))
            hh.AssemblyLinearVelocity=Vector3.new(0,0,0)
        end)
        if tick()-SKY.t<0.05 then return end
        SKY.t=tick()
        local cam=workspace.CurrentCamera if not cam then return end
        cam.CFrame=CFrame.lookAt(lh.Position+Vector3.new(0,2.5,0),skyPos)
        mouse1click()
        return
    end

    local t
    if AT.on and AT.lock and AT.lock.Parent then
        local hum=AT.lock.Character and AT.lock.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health>0 then t=AT.lock end
    end
    if not t then t=getTarget() if AT.on then AT.lock=t end end
    if not t then return end
    local ch=t.Character if not ch then return end
    if HBT.on then hbScaleTarget(t) end
    local partName=aimTargetRandom and aimParts[math.random(1,#aimParts)] or aimTarget
    local part=ch:FindFirstChild(partName) or ch:FindFirstChild("Head")
    if not part then return end
    if AT.a360 then
        local cam=Cam
        local toT=part.Position-cam.CFrame.Position
        if toT.Magnitude<0.01 then return end
        toT=toT.Unit
        local cf=cam.CFrame
        local x=toT:Dot(cf.RightVector)
        local y=toT:Dot(cf.UpVector)
        local z=toT:Dot(cf.LookVector)
        local vp=cam.ViewportSize
        local vf=math.rad(cam.FieldOfView)
        local tanV=math.max(math.tan(vf/2),0.01)
        local tanH=math.max(tanV*(vp.X/math.max(vp.Y,1)),0.01)
        local yaw=math.atan2(x,z)
        local pitch=math.atan2(y,math.sqrt(x*x+z*z))
        local k=1-(math.clamp(aimSmooth,0,0.9)*0.9)
        local dx=math.clamp(yaw*((vp.X/2)/tanH)*k,-700,700)
        local dy=math.clamp(-pitch*((vp.Y/2)/tanV)*k,-700,700)
        mousemoverel(dx,dy)
        return
    end
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

-- ============ HANDS GLOW KEEPER (re-applies every frame so it stays in 1st person and survives respawns) ============
local hgKeepTick=0
R.RenderStepped:Connect(function()
    hgKeepTick=hgKeepTick+1
    if NS.on then hideScopeBars() end
    if not hgOn then return end
    if hgKeepTick%5~=0 then return end
    refreshHandGlow()
end)

-- ============ SAVE/THEME SETUP ============
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:BuildConfigSection(T.Config)
ThemeManager:ApplyToTab(T.E)
SaveManager:LoadAutoloadConfig()
