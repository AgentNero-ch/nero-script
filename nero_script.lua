-- NERO SCRIPT v3.0
-- Powered by Fluent UI Library
-- Compatible: Ronix, Delta, Synapse, KRNL, Fluxus, dll

-- ══════════════════════════════════════════
-- ANTI-DETECT
-- ══════════════════════════════════════════
pcall(function()
    if hookmetamethod then
        local old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local name = self.Name:lower()
                if name:find("anticheat") or name:find("detect") or name:find("log") then return nil end
            end
            return old(self, ...)
        end)
    end
end)

-- ══════════════════════════════════════════
-- LOAD FLUENT UI
-- ══════════════════════════════════════════
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- ══════════════════════════════════════════
-- SETTINGS
-- ══════════════════════════════════════════
local S = {
    ESP = false, ESP_Box = true, ESP_Name = true, ESP_Health = true, ESP_Distance = true, ESP_TeamCheck = true,
    ESP_Color = Color3.fromRGB(255, 50, 50), ESP_TeamColor = Color3.fromRGB(50, 255, 50),
    Speed = false, SpeedMul = 2,
    Aimbot = false, AimbotFOV = 250, AimbotSmooth = 3, AimbotBone = "Head",
    AimbotTeam = true, AimbotVis = true, AimbotShowFOV = true, AimbotHeld = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
}

-- ══════════════════════════════════════════
-- CHECK CAPABILITIES
-- ══════════════════════════════════════════
local hasDrawing = false
pcall(function() if Drawing and Drawing.new then hasDrawing = true end end)

local hasMouse = false
pcall(function() if mousemoverel then hasMouse = true end end)

-- ══════════════════════════════════════════
-- CREATE WINDOW
-- ══════════════════════════════════════════
local Window = Fluent:CreateWindow({
    Title = "NERO SCRIPT v3.0",
    SubTitle = "by Nero",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- Tabs
local Tabs = {
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- ══════════════════════════════════════════
-- ESP TAB
-- ══════════════════════════════════════════
Tabs.ESP:AddSection("ESP Settings")

Tabs.ESP:AddToggle("ESP_Master", {
    Title = "ESP Master",
    Default = false,
    Callback = function(v) S.ESP = v end
})

Tabs.ESP:AddToggle("ESP_Box", {
    Title = "Box",
    Default = true,
    Callback = function(v) S.ESP_Box = v end
})

Tabs.ESP:AddToggle("ESP_Name", {
    Title = "Name",
    Default = true,
    Callback = function(v) S.ESP_Name = v end
})

Tabs.ESP:AddToggle("ESP_HP", {
    Title = "Health Bar",
    Default = true,
    Callback = function(v) S.ESP_Health = v end
})

Tabs.ESP:AddToggle("ESP_Dist", {
    Title = "Distance",
    Default = true,
    Callback = function(v) S.ESP_Distance = v end
})

Tabs.ESP:AddToggle("ESP_Team", {
    Title = "Team Check",
    Default = true,
    Callback = function(v) S.ESP_TeamCheck = v end
})

-- ══════════════════════════════════════════
-- PLAYER TAB
-- ══════════════════════════════════════════
Tabs.Player:AddSection("Player Settings")

Tabs.Player:AddToggle("Speed", {
    Title = "Speed Hack",
    Default = false,
    Callback = function(v) S.Speed = v end
})

Tabs.Player:AddSlider("SpeedMul", {
    Title = "Speed Multiplier",
    Description = "WalkSpeed multiplier (16 base)",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(v) S.SpeedMul = v end
})

-- ══════════════════════════════════════════
-- AIMBOT TAB
-- ══════════════════════════════════════════
Tabs.Aimbot:AddSection("Aimbot Settings")

Tabs.Aimbot:AddToggle("Aimbot", {
    Title = "Aimbot Master",
    Default = false,
    Callback = function(v) S.Aimbot = v end
})

Tabs.Aimbot:AddToggle("Aimbot_Team", {
    Title = "Team Check",
    Default = true,
    Callback = function(v) S.AimbotTeam = v end
})

Tabs.Aimbot:AddToggle("Aimbot_Vis", {
    Title = "Visibility Check",
    Default = true,
    Callback = function(v) S.AimbotVis = v end
})

Tabs.Aimbot:AddToggle("Aimbot_FOV_Show", {
    Title = "Show FOV Circle",
    Default = true,
    Callback = function(v) S.AimbotShowFOV = v end
})

Tabs.Aimbot:AddSlider("Aimbot_FOV", {
    Title = "FOV Radius",
    Description = "Aimbot detection radius",
    Default = 250,
    Min = 50,
    Max = 800,
    Rounding = 0,
    Callback = function(v) S.AimbotFOV = v end
})

Tabs.Aimbot:AddSlider("Aimbot_Smooth", {
    Title = "Smoothness",
    Description = "Lower = faster lock",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(v) S.AimbotSmooth = v end
})

Tabs.Aimbot:AddDropdown("Aimbot_Bone", {
    Title = "Aim Bone",
    Values = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    Default = "Head",
    Callback = function(v) S.AimbotBone = v end
})

-- ══════════════════════════════════════════
-- SETTINGS TAB
-- ══════════════════════════════════════════
Tabs.Settings:AddSection("Info")
Tabs.Settings:AddParagraph({
    Title = "NERO SCRIPT v3.0",
    Content = "Executor: " .. (getexecutorname and getexecutorname() or "Unknown") .. "\nDrawing API: " .. (hasDrawing and "Supported" or "Not Supported") .. "\nmousemoverel: " .. (hasMouse and "Supported" or "Not Supported")
})

Tabs.Settings:AddParagraph({
    Title = "Keybinds",
    Content = "RightShift = Minimize/Show Panel\nRMB (Hold) = Aimbot Lock"
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("NeroScript")
SaveManager:SetFolder("NeroScript/saves")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Nero Script",
    Content = "Loaded successfully! RightShift = Toggle",
    Duration = 5
})

-- ══════════════════════════════════════════
-- ESP SYSTEM
-- ══════════════════════════════════════════
ESP_Objects = {}

local function createESP(player)
    if player == LP then return end
    local esp = {}
    
    if hasDrawing then
        pcall(function()
            esp.BoxOutline = Drawing.new("Square"); esp.BoxOutline.Visible = false; esp.BoxOutline.Color = Color3.new(0,0,0); esp.BoxOutline.Thickness = 3; esp.BoxOutline.Filled = false
            esp.Box = Drawing.new("Square"); esp.Box.Visible = false; esp.Box.Color = S.ESP_Color; esp.Box.Thickness = 1; esp.Box.Filled = false
            esp.Name = Drawing.new("Text"); esp.Name.Visible = false; esp.Name.Color = Color3.new(1,1,1); esp.Name.Size = 14; esp.Name.Center = true; esp.Name.Outline = true
            esp.HPOutline = Drawing.new("Line"); esp.HPOutline.Visible = false; esp.HPOutline.Color = Color3.new(0,0,0); esp.HPOutline.Thickness = 4
            esp.HP = Drawing.new("Line"); esp.HP.Visible = false; esp.HP.Color = Color3.fromRGB(0,255,0); esp.HP.Thickness = 2
            esp.Dist = Drawing.new("Text"); esp.Dist.Visible = false; esp.Dist.Color = Color3.fromRGB(200,200,200); esp.Dist.Size = 12; esp.Dist.Center = true; esp.Dist.Outline = true
            esp.UseDrawing = true
        end)
    end
    
    if not esp.UseDrawing then
        pcall(function()
            local bb = Instance.new("BillboardGui"); bb.Name = "NeroESP"; bb.Size = UDim2.new(4,0,6,0); bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.MaxDistance = 500
            local fr = Instance.new("Frame"); fr.Size = UDim2.new(1,0,1,0); fr.BackgroundTransparency = 1; fr.BorderSizePixel = 2; fr.BorderColor3 = S.ESP_Color; fr.Parent = bb
            local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1,0,0,16); nl.Position = UDim2.new(0,0,0,-18); nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.new(1,1,1); nl.TextStrokeTransparency = 0; nl.TextSize = 14; nl.Font = Enum.Font.GothamBold; nl.Parent = fr
            local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1,0,0,14); dl.Position = UDim2.new(0,0,1,2); dl.BackgroundTransparency = 1; dl.TextColor3 = Color3.fromRGB(200,200,200); dl.TextStrokeTransparency = 0; dl.TextSize = 12; dl.Font = Enum.Font.Gotham; dl.Parent = fr
            local hb = Instance.new("Frame"); hb.Size = UDim2.new(0.05,0,1,0); hb.Position = UDim2.new(0,-6,0,0); hb.BackgroundColor3 = Color3.fromRGB(0,255,0); hb.BorderSizePixel = 0; hb.Parent = fr
            esp.Billboard = bb; esp.Frame = fr; esp.NameLabel = nl; esp.DistLabel = dl; esp.HPBar = hb; esp.UseDrawing = false
        end)
    end
    
    ESP_Objects[player] = esp
end

local function removeESP(player)
    local esp = ESP_Objects[player]
    if esp then
        pcall(function()
            if esp.UseDrawing then
                for _, obj in pairs(esp) do if type(obj) ~= "boolean" then pcall(function() obj:Remove() end) end end
            else esp.Billboard:Destroy() end
        end)
        ESP_Objects[player] = nil
    end
end

local function updateESP()
    for player, esp in pairs(ESP_Objects) do
        local hide = function()
            if esp.UseDrawing then
                for _, obj in pairs(esp) do if type(obj) ~= "boolean" then pcall(function() obj.Visible = false end) end end
            elseif esp.Billboard then pcall(function() esp.Billboard.Enabled = false end) end
        end
        
        if not S.ESP or not player.Parent then hide() continue end
        
        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        if not char or not hum or not root or not head then hide() continue end
        
        if S.ESP_TeamCheck and player.Team == LP.Team and player.Team ~= nil then hide() continue end
        
        local col = (player.Team and player.Team == LP.Team) and S.ESP_TeamColor or S.ESP_Color
        
        if esp.UseDrawing then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            if not onScreen then hide() continue end
            
            local sf = 1 / (pos.Z * 0.04)
            local bw = math.clamp(4*sf, 2, 200)
            local bh = math.clamp(5.5*sf, 2, 280)
            local bx = pos.X - bw/2
            local by = pos.Y - bh/2
            
            if S.ESP_Box then
                esp.BoxOutline.Size = Vector2.new(bw,bh); esp.BoxOutline.Position = Vector2.new(bx,by); esp.BoxOutline.Visible = true
                esp.Box.Size = Vector2.new(bw,bh); esp.Box.Position = Vector2.new(bx,by); esp.Box.Color = col; esp.Box.Visible = true
            else esp.BoxOutline.Visible = false; esp.Box.Visible = false end
            
            if S.ESP_Name then esp.Name.Text = player.DisplayName or player.Name; esp.Name.Position = Vector2.new(pos.X, by-18); esp.Name.Visible = true
            else esp.Name.Visible = false end
            
            if S.ESP_Health then
                local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                esp.HPOutline.From = Vector2.new(bx-5,by); esp.HPOutline.To = Vector2.new(bx-5,by+bh); esp.HPOutline.Visible = true
                esp.HP.From = Vector2.new(bx-5,by+bh-(bh*hp)); esp.HP.To = Vector2.new(bx-5,by+bh); esp.HP.Color = Color3.fromRGB(255*(1-hp),255*hp,0); esp.HP.Visible = true
            else esp.HPOutline.Visible = false; esp.HP.Visible = false end
            
            if S.ESP_Distance then
                local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if mr then esp.Dist.Text = string.format("[%dm]", math.floor((mr.Position-root.Position).Magnitude)); esp.Dist.Position = Vector2.new(pos.X,by+bh+4); esp.Dist.Visible = true end
            else esp.Dist.Visible = false end
        else
            if not esp.Billboard then continue end
            local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            esp.Billboard.Enabled = true; esp.Billboard.Adornee = head; esp.NameLabel.Text = player.DisplayName or player.Name; esp.Frame.BorderColor3 = col
            if mr then esp.DistLabel.Text = string.format("[%dm]", math.floor((mr.Position-root.Position).Magnitude)) end
            local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
            esp.HPBar.Size = UDim2.new(0.05,0,hp,0); esp.HPBar.Position = UDim2.new(0,-6,1-hp,0); esp.HPBar.BackgroundColor3 = Color3.fromRGB(255*(1-hp),255*hp,0)
            esp.Frame.Visible = S.ESP_Box; esp.NameLabel.Visible = S.ESP_Name; esp.DistLabel.Visible = S.ESP_Distance; esp.HPBar.Visible = S.ESP_Health
        end
    end
end

-- ══════════════════════════════════════════
-- SPEED
-- ══════════════════════════════════════════
local function updateSpeed()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.WalkSpeed = S.Speed and (16 * S.SpeedMul) or 16
end

-- ══════════════════════════════════════════
-- AIMBOT
-- ══════════════════════════════════════════
local FOVCircle = nil
if hasDrawing then
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false; FOVCircle.Radius = S.AimbotFOV; FOVCircle.Color = Color3.fromRGB(255,255,255)
        FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.NumSides = 64; FOVCircle.Transparency = 0.7
    end)
end

local function getClosest()
    local closest, closestDist = nil, S.AimbotFOV
    local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in pairs(Players:GetPlayers()) do
        if p == LP then continue end
        if not p.Character then continue end
        if S.AimbotTeam and p.Team and p.Team == LP.Team then continue end
        local bp = p.Character:FindFirstChild(S.AimbotBone)
        if not bp then continue end
        if S.AimbotVis then
            local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if mr then
                local rp = RaycastParams.new(); rp.FilterType = Enum.RaycastFilterType.Exclude; rp.FilterDescendantsInstances = {LP.Character}
                local r = workspace:Raycast(mr.Position, (bp.Position-mr.Position), rp)
                if r and not r.Instance:IsDescendantOf(p.Character) then continue end
            end
        end
        local sp, onScr = Camera:WorldToViewportPoint(bp.Position)
        if not onScr then continue end
        local d = (Vector2.new(sp.X,sp.Y) - sc).Magnitude
        if d < closestDist then closest = p; closestDist = d end
    end
    return closest
end

local function aimAt(target)
    if not target or not target.Character then return end
    if not hasMouse then return end
    local bp = target.Character:FindFirstChild(S.AimbotBone)
    if not bp then return end
    local sp = Camera:WorldToViewportPoint(bp.Position)
    local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local d = (Vector2.new(sp.X,sp.Y) - sc) / S.AimbotSmooth
    mousemoverel(d.X, d.Y)
end

-- ══════════════════════════════════════════
-- MAIN LOOPS
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(updateESP)
RunService.Heartbeat:Connect(updateSpeed)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        FOVCircle.Radius = S.AimbotFOV
        FOVCircle.Visible = S.Aimbot and S.AimbotShowFOV
    end
    if S.Aimbot and S.AimbotHeld then
        local t = getClosest()
        if t then aimAt(t) end
    end
end)

-- Input
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == S.AimbotKey then S.AimbotHeld = true end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == S.AimbotKey then S.AimbotHeld = false end
end)

-- Player tracking
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
LP.CharacterAdded:Connect(function() task.wait(1) updateSpeed() end)
