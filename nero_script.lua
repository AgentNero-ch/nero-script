-- NERO SCRIPT v8.3
-- Custom UI (Rayfield-style) — guaranteed to work on all executors

local ok, err = pcall(function()

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

local function notify(t, m)
    pcall(function() StarterGui:SetCore("SendNotification", {Title=t, Text=m, Duration=5}) end)
end

notify("Nero Script", "Loading v8.3...")

while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") do task.wait(0.1) end
local Char = LP.Character

-- ══════════════════════════════════════════
-- SETTINGS
-- ══════════════════════════════════════════
local S = {
    Chams=false, Distance=false, TeamCheck=true,
    ChamsColor=Color3.fromRGB(255,50,50), ChamsTeamColor=Color3.fromRGB(50,255,50),
    Speed=false, SpeedMul=2,
    InfJump=false, Fly=false, FlySpeed=2,
    Aimbot=false, AimbotFOV=250, AimbotSmooth=0.4,
    AimbotBone="Head", AimbotTeam=true, AutoShoot=false, AimbotShowFOV=false,
}

-- ══════════════════════════════════════════
-- UI (Rayfield-style, native Roblox)
-- ══════════════════════════════════════════
local guiVisible = true
local currentTab = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeroUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ScreenGui.Parent then pcall(function() ScreenGui.Parent = LP:WaitForChild("PlayerGui") end) end

-- Main Window (Rayfield-style: dark, rounded, clean)
local Win = Instance.new("Frame")
Win.Size = UDim2.new(0, 500, 0, 380)
Win.Position = UDim2.new(0.5, -250, 0.5, -190)
Win.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = true
Win.Parent = ScreenGui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 10)

-- Topbar (Rayfield-style)
local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 42)
Topbar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
Topbar.BorderSizePixel = 0
Topbar.Parent = Win
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)
local TopbarFix = Instance.new("Frame")
TopbarFix.Size = UDim2.new(1, 0, 0, 10)
TopbarFix.Position = UDim2.new(0, 0, 1, -10)
TopbarFix.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
TopbarFix.BorderSizePixel = 0
TopbarFix.Parent = Topbar

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(0.5, 0, 1, 0)
TitleLbl.Position = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "Nero Script"
TitleLbl.TextColor3 = Color3.new(1, 1, 1)
TitleLbl.TextSize = 16
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = Topbar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Topbar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() guiVisible=false Win.Visible=false end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -66, 0, 7)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
MinBtn.BorderSizePixel = 0
MinBtn.Text = "–"
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.TextSize = 16
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = Topbar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

-- Tab bar (below topbar)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 30)
TabBar.Position = UDim2.new(0, 8, 0, 46)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Win

local TabBarLayout = Instance.new("UIListLayout")
TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
TabBarLayout.Padding = UDim.new(0, 4)
TabBarLayout.Parent = TabBar

-- Content area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -16, 1, -84)
Content.Position = UDim2.new(0, 8, 0, 80)
Content.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Content.BorderSizePixel = 0
Content.Parent = Win
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 8)

-- Tab system
local Tabs = {}
local TabButtons = {}

local function createTab(name, icon)
    -- Tab button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, 0)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.BorderSizePixel = 0
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(130, 130, 140)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = TabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 8) pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = btn

    -- Content page
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -12, 1, -8)
    page.Position = UDim2.new(0, 6, 0, 4)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = Content
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = page

    Tabs[name] = page
    TabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        currentTab = name
        for n, p in pairs(Tabs) do p.Visible = (n == name) end
        for n, b in pairs(TabButtons) do
            TweenService:Create(b, TweenInfo.new(0.2), {
                BackgroundColor3 = (n == name) and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(30, 30, 38),
                TextColor3 = (n == name) and Color3.new(1, 1, 1) or Color3.fromRGB(130, 130, 140)
            }):Play()
        end
    end)

    return page
end

-- Card factory (Rayfield-style: clean cards with toggle)
local function createToggle(parent, name, desc, default, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 56)
    card.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12) pad.PaddingRight = UDim.new(0, 12) pad.PaddingTop = UDim.new(0, 8)
    pad.Parent = card

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 13
    title.Font = Enum.Font.GothamSemibold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = card

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(1, -60, 0, 14)
    descLbl.Position = UDim2.new(0, 0, 0, 20)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = desc
    descLbl.TextColor3 = Color3.fromRGB(100, 100, 110)
    descLbl.TextSize = 11
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = card

    -- Toggle (Rayfield-style: pill shape)
    local pill = Instance.new("TextButton")
    pill.Size = UDim2.new(0, 40, 0, 22)
    pill.Position = UDim2.new(1, -52, 0.5, -11)
    pill.BackgroundColor3 = default and Color3.fromRGB(45, 180, 80) or Color3.fromRGB(45, 45, 55)
    pill.BorderSizePixel = 0
    pill.Text = ""
    pill.Parent = card
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 16, 0, 16)
    dot.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = Color3.new(1, 1, 1)
    dot.BorderSizePixel = 0
    dot.Parent = pill
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = default
    pill.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(45, 180, 80) or Color3.fromRGB(45, 45, 55)
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        callback(state)
    end)

    -- Hover effect
    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(24, 24, 32)}):Play()
    end)
end

local function createSection(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. text
    lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
end

local function createInfo(parent, title, content)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    card.BorderSizePixel = 0
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 12) pad.PaddingRight = UDim.new(0, 12) pad.PaddingTop = UDim.new(0, 8)
    pad.Parent = card
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 1, -16)
    lbl.BackgroundTransparency = 1
    lbl.Text = title .. "\n" .. content
    lbl.TextColor3 = Color3.fromRGB(140, 140, 150)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true
    lbl.Parent = card
end

-- ══════════════════════════════════════════
-- BUILD UI
-- ══════════════════════════════════════════
local espTab = createTab("ESP", "🎯")
createSection(espTab, "Player ESP")
createToggle(espTab, "Player Chams", "Highlight players through walls", false, function(v) S.Chams = v end)
createToggle(espTab, "Distance Display", "Show distance in meters", false, function(v) S.Distance = v end)
createToggle(espTab, "Team Check", "Hide teammates", true, function(v) S.TeamCheck = v end)

local playerTab = createTab("Player", "🏃")
createSection(playerTab, "Movement")
createToggle(playerTab, "Speed x2", "Double walk speed", false, function(v)
    S.Speed = v
    pcall(function() if not v and Char:FindFirstChild("Humanoid") then Char.Humanoid.WalkSpeed = 16 end end)
end)

createToggle(playerTab, "Infinite Jump", "Jump in mid-air when you press Space", false, function(v) S.InfJump = v end)

createToggle(playerTab, "Fly", "Fly with WASD + Space/Shift", false, function(v)
    S.Fly = v
    pcall(function()
        local hrp = Char and Char:FindFirstChild("HumanoidRootPart")
        local hum = Char and Char:FindFirstChild("Humanoid")
        if not v then
            -- Disable fly: remove BodyVelocity/BodyGyro
            if hrp then
                for _, obj in ipairs(hrp:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then obj:Destroy() end
                end
            end
            -- if hum then hum.PlatformStand = false end
        else
            -- Enable fly
            if hrp and hum then
                -- hum.PlatformStand = true -- removed for natural flying
                local bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.Parent = hrp
                local bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.D = 100
                bg.P = 10000
                bg.Parent = hrp
            end
        end
    end)
end)

local aimTab = createTab("Aimbot", "🔫")
createSection(aimTab, "Aimbot Settings")
createToggle(aimTab, "Aimbot", "Auto aim at visible enemies", false, function(v) S.Aimbot = v end)
createToggle(aimTab, "Auto Shoot", "Auto fire when locked", false, function(v) S.AutoShoot = v end)
createToggle(aimTab, "Show FOV Circle", "Display aim radius", false, function(v) S.AimbotShowFOV = v end)
createToggle(aimTab, "Team Check", "Skip teammates", true, function(v) S.AimbotTeam = v end)

local settingsTab = createTab("Settings", "⚙️")
createSection(settingsTab, "Info")
createInfo(settingsTab, "Nero Script v8.3", "UI: Custom (Rayfield-style)\nExecutor: " .. (identifyexecutor and identifyexecutor() or "Unknown") .. "\nAimbot: Camera CFrame + LOS\nESP: Highlight Chams")

-- Show first tab
espTab.Visible = true
TabButtons["ESP"].BackgroundColor3 = Color3.fromRGB(45, 45, 55)
TabButtons["ESP"].TextColor3 = Color3.new(1, 1, 1)

-- RightShift toggle
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        Win.Visible = guiVisible
    end
end)

notify("Nero Script", "v8.3 loaded! RightShift: toggle")

-- ══════════════════════════════════════════
-- HIGHLIGHT CHAMS
-- ══════════════════════════════════════════
local HLs = {}
local DLs = {}

local function setupPlr(plr)
    if plr == LP then return end
    if not HLs[plr] then
        local hl = Instance.new("Highlight")
        hl.FillColor = S.ChamsColor hl.FillTransparency = 0.45
        hl.OutlineColor = Color3.new(1,1,1) hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Enabled = false hl.Parent = game:GetService("CoreGui")
        HLs[plr] = hl
    end
    if not DLs[plr] then
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,120,0,30) bb.StudsOffset = Vector3.new(0,3.8,0)
        bb.AlwaysOnTop = true bb.Enabled = false bb.Parent = game:GetService("CoreGui")
        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1,0,1,0) tl.BackgroundTransparency = 1
        tl.TextColor3 = Color3.new(1,1,1) tl.TextStrokeTransparency = 0.4
        tl.TextSize = 16 tl.Font = Enum.Font.GothamBold tl.Parent = bb
        DLs[plr] = {G=bb, L=tl}
    end
    local function onC(c)
        task.wait(0.5)
        if HLs[plr] then HLs[plr].Adornee = c end
        if DLs[plr] then local r=c:FindFirstChild("HumanoidRootPart") if r then DLs[plr].G.Adornee=r end end
    end
    if plr.Character then onC(plr.Character) end
    plr.CharacterAdded:Connect(onC)
end

local function removePlr(plr)
    if HLs[plr] then pcall(function() HLs[plr]:Destroy() end) HLs[plr]=nil end
    if DLs[plr] then pcall(function() DLs[plr].G:Destroy() end) DLs[plr]=nil end
end

for _,p in ipairs(Players:GetPlayers()) do if p~=LP then setupPlr(p) end end
Players.PlayerAdded:Connect(setupPlr)
Players.PlayerRemoving:Connect(removePlr)

local function updateESP()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        local hl=HLs[plr] local dl=DLs[plr]
        if not hl then setupPlr(plr) continue end
        local c=plr.Character local r=c and c:FindFirstChild("HumanoidRootPart")
        local h=c and c:FindFirstChild("Humanoid") local alive=r and h and h.Health>0
        local show=S.Chams and alive
        if show and S.TeamCheck and LP.Team and plr.Team and plr.Team==LP.Team then show=false end
        hl.Enabled=show
        if show then hl.Adornee=c hl.FillColor=(S.TeamCheck and LP.Team and plr.Team and plr.Team==LP.Team) and S.ChamsTeamColor or S.ChamsColor end
        if dl then
            local sd=S.Distance and alive and Char and Char:FindFirstChild("HumanoidRootPart")
            if showChams and S.TeamCheck and LP.Team and plr.Team and plr.Team == LP.Team then showChams = false end
            dl.G.Enabled=sd
            if sd then dl.G.Adornee=r dl.L.Text=math.floor((Char.HumanoidRootPart.Position-r.Position).Magnitude).."m" end
        end
    end
end

-- ══════════════════════════════════════════
-- AIMBOT
-- ══════════════════════════════════════════
local lastShoot=0

local function rayParams(tc)
    local p=RaycastParams.new() local f={}
    if Char then table.insert(f,Char) end if tc then table.insert(f,tc) end
    p.FilterDescendantsInstances=f p.FilterType=Enum.RaycastFilterType.Exclude p.IgnoreWater=true return p
end

local function onScreen(pos)
    local sp=Camera:WorldToViewportPoint(pos)
    if sp.Z<=0 then return false,Vector2.new(0,0) end
    local s=Vector2.new(sp.X,sp.Y) local vp=Camera.ViewportSize
    if sp.X<-50 or sp.X>vp.X+50 then return false,s end
    if sp.Y<-50 or sp.Y>vp.Y+50 then return false,s end
    return true,s
end

local function hasLOS(tc)
    local th=tc:FindFirstChild("Head") if not th then return false end
    local o=Camera.CFrame.Position local d=th.Position-o local dist=d.Magnitude
    if dist>1000 then return false end if dist<30 then return true end
    local r=workspace:Raycast(o,d,rayParams(tc))
    if r then return r.Instance:IsDescendantOf(tc) end return true
end

local function getClosest()
    local cl=nil local md=S.AimbotFOV
    local vp=Camera.ViewportSize local sc=Vector2.new(vp.X/2,vp.Y/2)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr==LP then continue end
        if S.AimbotTeam and LP.Team and plr.Team and plr.Team == LP.Team then
                            -- Only skip if both players have a team AND they match
                            continue
                        end
        local c=plr.Character if not c then continue end
        local h=c:FindFirstChild("Humanoid") if not h or h.Health<=0 then continue end
        local p=c:FindFirstChild(S.AimbotBone) or c:FindFirstChild("HumanoidRootPart") if not p then continue end
        local os,sp=onScreen(p.Position) if not os then continue end
        if not hasLOS(c) then continue end
        local d=(sp-sc).Magnitude if d<md then md=d cl=plr end
    end
    return cl
end

local function doAimbot()
    if not S.Aimbot then return end
    local tp=getClosest() if not tp then return end
    local c=tp.Character if not c then return end
    local p=c:FindFirstChild(S.AimbotBone) or c:FindFirstChild("HumanoidRootPart") if not p then return end
    Camera.CFrame=CFrame.new(Camera.CFrame.Position,p.Position):Lerp(Camera.CFrame,S.AimbotSmooth)
    if S.AutoShoot then
        local blocked=false
        pcall(function() if UIS:GetFocusedTextBox() then blocked=true end end)
        if not blocked then
            local now=tick() if now-lastShoot>=0.15 then lastShoot=now
                pcall(function() VIM:SendMouseButtonEvent(0,0,0,true,game,1) task.wait(0.05) VIM:SendMouseButtonEvent(0,0,0,false,game,1) end)
            end
        end
    end
end

local FOV=Drawing.new("Circle") FOV.Radius=S.AimbotFOV FOV.Thickness=1.5
FOV.Color=Color3.fromRGB(255,80,80) FOV.Filled=false FOV.Transparency=0.6 FOV.Visible=false

-- ══════════════════════════════════════════
-- MAIN LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    pcall(function() Char=LP.Character end)
    pcall(function() if S.Speed and Char:FindFirstChild("Humanoid") then Char.Humanoid.WalkSpeed=16*S.SpeedMul end end)
    -- Infinite Jump (only when player actually presses jump)
    -- handled via UIS.JumpRequest below
    -- Fly movement
    pcall(function()
        if S.Fly then
            local hrp = Char:FindFirstChild("HumanoidRootPart")
            local bv = hrp and hrp:FindFirstChildOfClass("BodyVelocity")
            local bg = hrp and hrp:FindFirstChildOfClass("BodyGyro")
            if bv and bg then
                bg.CFrame = Camera.CFrame
                local dir = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
                local targetVel = dir.Magnitude > 0 and (dir.Unit * S.FlySpeed * 20) or Vector3.zero
                    bv.Velocity = bv.Velocity:Lerp(targetVel, 0.15)
            end
        end
    end)
    pcall(updateESP)
    FOV.Visible=S.Aimbot and S.AimbotShowFOV FOV.Position=UIS:GetMouseLocation() FOV.Radius=S.AimbotFOV
    pcall(doAimbot)
end)

LP.CharacterAdded:Connect(function(c) Char=c end)

-- Infinite Jump: only trigger when player presses Space/taps jump
UIS.JumpRequest:Connect(function()
    if S.InfJump and Char and Char:FindFirstChild("Humanoid") then
        Char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

end) -- end pcall

if not ok then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title="Nero Error", Text=tostring(err), Duration=10
        })
    end)
end
