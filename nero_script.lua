-- NERO SCRIPT v1.0
-- Roblox Universal Cheat - Delta Executor Compatible
-- Features: ESP, Speed, Aimbot, Anti-Detect

-- ══════════════════════════════════════════
-- ANTI-DETECT (LOAD FIRST)
-- ══════════════════════════════════════════
local AntiDetect = {}

-- Spoof memory fingerprint
AntiDetect.SpoofedId = game:GetService("HttpService"):GenerateGUID(false)

-- Hide from common AC detections
local function bypassChecks()
    -- Spoof HWID
    if gethwid then
        local old = gethwid
        gethwid = function()
            return AntiDetect.SpoofedId
        end
    end
    
    -- Anti-log
    if hookfunction then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Block telemetry/analytics
            if method == "FireServer" or method == "InvokeServer" then
                local name = self.Name:lower()
                if name:find("analytics") or name:find("telemetry") or name:find("log") 
                   or name:find("report") or name:find("anticheat") or name:find("detect") then
                    return nil
                end
            end
            
            return oldNamecall(self, ...)
        end)
    end
    
    -- Spoof tick/os.clock jitter to avoid timing detection
    local realTick = tick
    local jitter = math.random() * 0.01
    if hookfunction then
        hookfunction(tick, function()
            return realTick() + jitter
        end)
    end
end

pcall(bypassChecks)

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════
local Config = {
    -- ESP
    ESP_Enabled = true,
    ESP_Box = true,
    ESP_Name = true,
    ESP_Health = true,
    ESP_Distance = true,
    ESP_TeamCheck = true,
    ESP_Color = Color3.fromRGB(255, 50, 50),
    ESP_TeamColor = Color3.fromRGB(50, 255, 50),
    
    -- Speed
    Speed_Enabled = false,
    Speed_Value = 2, -- multiplier
    
    -- Aimbot
    Aimbot_Enabled = false,
    Aimbot_Key = Enum.UserInputType.MouseButton2, -- RMB
    Aimbot_FOV = 250,
    Aimbot_Smoothness = 3, -- lower = faster lock
    Aimbot_Bone = "Head", -- Head, HumanoidRootPart, UpperTorso
    Aimbot_TeamCheck = true,
    Aimbot_VisibleCheck = true,
    Aimbot_ShowFOV = true,
}

-- ══════════════════════════════════════════
-- ESP SYSTEM
-- ══════════════════════════════════════════
local ESP_Objects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    
    -- Box
    esp.BoxOutline = Drawing.new("Square")
    esp.BoxOutline.Visible = false
    esp.BoxOutline.Color = Color3.new(0, 0, 0)
    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Filled = false
    
    esp.Box = Drawing.new("Square")
    esp.Box.Visible = false
    esp.Box.Color = Config.ESP_Color
    esp.Box.Thickness = 1
    esp.Box.Filled = false
    
    -- Name
    esp.Name = Drawing.new("Text")
    esp.Name.Visible = false
    esp.Name.Color = Color3.new(1, 1, 1)
    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    
    -- Health bar
    esp.HealthBarOutline = Drawing.new("Line")
    esp.HealthBarOutline.Visible = false
    esp.HealthBarOutline.Color = Color3.new(0, 0, 0)
    esp.HealthBarOutline.Thickness = 4
    
    esp.HealthBar = Drawing.new("Line")
    esp.HealthBar.Visible = false
    esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    esp.HealthBar.Thickness = 2
    
    -- Distance
    esp.Distance = Drawing.new("Text")
    esp.Distance.Visible = false
    esp.Distance.Color = Color3.fromRGB(200, 200, 200)
    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    
    ESP_Objects[player] = esp
end

local function removeESP(player)
    local esp = ESP_Objects[player]
    if esp then
        for _, obj in pairs(esp) do
            pcall(function() obj:Remove() end)
        end
        ESP_Objects[player] = nil
    end
end

local function updateESP()
    for player, esp in pairs(ESP_Objects) do
        if not Config.ESP_Enabled or not player.Parent then
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
            continue
        end
        
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        
        if not character or not humanoid or not rootPart or not head then
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
            continue
        end
        
        -- Team check
        if Config.ESP_TeamCheck and player.Team == LocalPlayer.Team and player.Team ~= nil then
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
            continue
        end
        
        local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if not onScreen then
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
            continue
        end
        
        -- Calculate box
        local scaleFactor = 1 / (pos.Z * 0.04)
        local boxWidth = math.clamp(4 * scaleFactor, 2, 200)
        local boxHeight = math.clamp(5.5 * scaleFactor, 2, 280)
        local boxX = pos.X - boxWidth / 2
        local boxY = pos.Y - boxHeight / 2
        
        -- Team color
        local espColor = Config.ESP_Color
        if player.Team and player.Team == LocalPlayer.Team then
            espColor = Config.ESP_TeamColor
        end
        
        -- Box
        if Config.ESP_Box then
            esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
            esp.BoxOutline.Position = Vector2.new(boxX, boxY)
            esp.BoxOutline.Visible = true
            
            esp.Box.Size = Vector2.new(boxWidth, boxHeight)
            esp.Box.Position = Vector2.new(boxX, boxY)
            esp.Box.Color = espColor
            esp.Box.Visible = true
        else
            esp.BoxOutline.Visible = false
            esp.Box.Visible = false
        end
        
        -- Name
        if Config.ESP_Name then
            esp.Name.Text = player.DisplayName or player.Name
            esp.Name.Position = Vector2.new(pos.X, boxY - 18)
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- Health bar
        if Config.ESP_Health then
            local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barHeight = boxHeight * healthPct
            
            esp.HealthBarOutline.From = Vector2.new(boxX - 5, boxY)
            esp.HealthBarOutline.To = Vector2.new(boxX - 5, boxY + boxHeight)
            esp.HealthBarOutline.Visible = true
            
            esp.HealthBar.From = Vector2.new(boxX - 5, boxY + boxHeight - barHeight)
            esp.HealthBar.To = Vector2.new(boxX - 5, boxY + boxHeight)
            esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
            esp.HealthBar.Visible = true
        else
            esp.HealthBarOutline.Visible = false
            esp.HealthBar.Visible = false
        end
        
        -- Distance
        if Config.ESP_Distance then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local dist = (myRoot.Position - rootPart.Position).Magnitude
                esp.Distance.Text = string.format("[%dm]", math.floor(dist))
                esp.Distance.Position = Vector2.new(pos.X, boxY + boxHeight + 4)
                esp.Distance.Visible = true
            end
        else
            esp.Distance.Visible = false
        end
    end
end

-- ══════════════════════════════════════════
-- SPEED HACK
-- ══════════════════════════════════════════
local SpeedConnection

local function updateSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    if Config.Speed_Enabled then
        humanoid.WalkSpeed = 16 * Config.Speed_Value
    else
        humanoid.WalkSpeed = 16
    end
end

-- ══════════════════════════════════════════
-- AIMBOT SYSTEM
-- ══════════════════════════════════════════
local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Visible = false
AimbotFOVCircle.Radius = Config.Aimbot_FOV
AimbotFOVCircle.Color = Color3.fromRGB(255, 255, 255)
AimbotFOVCircle.Thickness = 1
AimbotFOVCircle.Filled = false
AimbotFOVCircle.NumSides = 64
AimbotFOVCircle.Transparency = 0.7

local function getClosestPlayer()
    local closest = nil
    local closestDist = Config.Aimbot_FOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        -- Team check
        if Config.Aimbot_TeamCheck and player.Team and player.Team == LocalPlayer.Team then
            continue
        end
        
        local targetPart = player.Character:FindFirstChild(Config.Aimbot_Bone)
        if not targetPart then continue end
        
        -- Visibility check
        if Config.Aimbot_VisibleCheck then
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                
                local direction = (targetPart.Position - myRoot.Position)
                local rayResult = workspace:Raycast(myRoot.Position, direction, rayParams)
                
                if rayResult then
                    local hitPart = rayResult.Instance
                    if not hitPart:IsDescendantOf(player.Character) then
                        continue
                    end
                end
            end
        end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        
        if dist < closestDist then
            closest = player
            closestDist = dist
        end
    end
    
    return closest
end

local function aimAt(target)
    if not target or not target.Character then return end
    local bone = target.Character:FindFirstChild(Config.Aimbot_Bone)
    if not bone then return end
    
    local screenPos = Camera:WorldToViewportPoint(bone.Position)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
    
    local delta = (targetPos - screenCenter) / Config.Aimbot_Smoothness
    
    mousemoverel(delta.X, delta.Y)
end

local AimbotActive = false

-- ══════════════════════════════════════════
-- FOV CIRCLE UPDATE
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    AimbotFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    AimbotFOVCircle.Radius = Config.Aimbot_FOV
    AimbotFOVCircle.Visible = Config.Aimbot_Enabled and Config.Aimbot_ShowFOV
end)

-- ══════════════════════════════════════════
-- MAIN LOOPS
-- ══════════════════════════════════════════

-- ESP Loop
RunService.RenderStepped:Connect(updateESP)

-- Speed Loop
RunService.Heartbeat:Connect(updateSpeed)

-- Aimbot Loop
RunService.RenderStepped:Connect(function()
    if Config.Aimbot_Enabled and AimbotActive then
        local target = getClosestPlayer()
        if target then
            aimAt(target)
        end
    end
end)

-- ══════════════════════════════════════════
-- INPUT HANDLING
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Aimbot toggle (hold RMB)
    if input.UserInputType == Config.Aimbot_Key then
        AimbotActive = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Config.Aimbot_Key then
        AimbotActive = false
    end
end)

-- ══════════════════════════════════════════
-- PLAYER TRACKING
-- ══════════════════════════════════════════
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- ══════════════════════════════════════════
-- SIMPLE GUI (Delta Compatible)
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeroScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Anti-detect: hide from CoreGui scan
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
end)

ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0, 10, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
Title.BorderSizePixel = 0
Title.Text = "⚡ NERO SCRIPT v1.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Toggle button factory
local function createToggle(name, yPos, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 200, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = default and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 65)
    btn.BorderSizePixel = 0
    btn.Text = (default and "✅ " or "⬜ ") .. name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = MainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    local state = default
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 65)
        btn.Text = (state and "✅ " or "⬜ ") .. name
        callback(state)
    end)
    
    return btn
end

-- Create toggles
createToggle("ESP", 38, Config.ESP_Enabled, function(v)
    Config.ESP_Enabled = v
    if not v then
        for _, esp in pairs(ESP_Objects) do
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
    end
end)

createToggle("ESP Box", 72, Config.ESP_Box, function(v)
    Config.ESP_Box = v
end)

createToggle("ESP Name", 106, Config.ESP_Name, function(v)
    Config.ESP_Name = v
end)

createToggle("ESP Health", 140, Config.ESP_Health, function(v)
    Config.ESP_Health = v
end)

createToggle("ESP Distance", 174, Config.ESP_Distance, function(v)
    Config.ESP_Distance = v
end)

createToggle("Speed x" .. Config.Speed_Value, 208, Config.Speed_Enabled, function(v)
    Config.Speed_Enabled = v
end)

createToggle("Aimbot (Hold RMB)", 242, Config.Aimbot_Enabled, function(v)
    Config.Aimbot_Enabled = v
end)

-- ══════════════════════════════════════════
-- KEYBINDS
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    -- Right Shift to toggle GUI
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
    
    -- F1 = Toggle ESP
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESP_Enabled = not Config.ESP_Enabled
    end
    
    -- F2 = Toggle Speed
    if input.KeyCode == Enum.KeyCode.F2 then
        Config.Speed_Enabled = not Config.Speed_Enabled
    end
    
    -- F3 = Toggle Aimbot
    if input.KeyCode == Enum.KeyCode.F3 then
        Config.Aimbot_Enabled = not Config.Aimbot_Enabled
    end
end)

-- ══════════════════════════════════════════
-- ANTI-DETECT PERIODIC SPOOF
-- ══════════════════════════════════════════
spawn(function()
    while wait(math.random(30, 60)) do
        pcall(function()
            -- Randomize jitter periodically
            jitter = math.random() * 0.01
            
            -- Clear logs if possible
            if clearconsole then
                clearconsole()
            end
        end)
    end
end)

-- ══════════════════════════════════════════
-- CLEANUP ON CHARACTER RESPAWN
-- ══════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    updateSpeed()
end)

print("═══════════════════════════════════════")
print("  ⚡ NERO SCRIPT v1.0 LOADED")
print("  RightShift = Toggle GUI")
print("  F1 = ESP | F2 = Speed | F3 = Aimbot")
print("  Hold RMB = Aimbot Lock")
print("═══════════════════════════════════════")
