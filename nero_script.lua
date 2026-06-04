-- NERO SCRIPT v1.1
-- Roblox Universal Cheat - Universal Executor Compatible
-- Compatible: Delta, Ronix, Synapse X, KRNL, Fluxus, Hydrogen, Vega, Arceus X
-- Features: ESP, Speed, Aimbot, Anti-Detect

-- ══════════════════════════════════════════
-- COMPATIBILITY LAYER (WAJIB DI ATAS)
-- ══════════════════════════════════════════
local isSynapse = syn ~= nil
local isRonix = identifyexecutor and identifyexecutor():find("Ronix") ~= nil
local isDelta = getexecutorname and getexecutorname():find("Delta") ~= nil
local isFluxus = getexecutorname and getexecutorname():find("Fluxus") ~= nil

-- Function compatibility wrappers
if not getexecutorname then
    getexecutorname = function() return "Unknown" end
end

-- ══════════════════════════════════════════
-- ANTI-DETECT (LOAD FIRST)
-- ══════════════════════════════════════════
local AntiDetect = {}
AntiDetect.SpoofedId = game:GetService("HttpService"):GenerateGUID(false)

local function bypassChecks()
    -- Spoof HWID (jika support)
    pcall(function()
        if gethwid then
            local old = gethwid
            gethwid = function()
                return AntiDetect.SpoofedId
            end
        end
    end)
    
    -- Hook metamethod (Synapse/Ronix/Delta)
    pcall(function()
        if hookmetamethod then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                
                if method == "FireServer" or method == "InvokeServer" then
                    local name = self.Name:lower()
                    if name:find("analytics") or name:find("telemetry") or name:find("log") 
                       or name:find("report") or name:find("anticheat") or name:find("detect")
                       or name:find("banned") or name:find("kick") then
                        return nil
                    end
                end
                
                return oldNamecall(self, ...)
            end)
        end
    end)
    
    -- Tick jitter
    pcall(function()
        if hookfunction then
            local realTick = tick
            local jitter = math.random() * 0.01
            hookfunction(tick, function()
                return realTick() + jitter
            end)
        end
    end)
    
    -- Protect GUI (Synapse only)
    pcall(function()
        if syn and syn.protect_gui then
            -- handled later when GUI is created
        end
    end)
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
    Speed_Value = 2,
    
    -- Aimbot
    Aimbot_Enabled = false,
    Aimbot_Key = Enum.UserInputType.MouseButton2,
    Aimbot_FOV = 250,
    Aimbot_Smoothness = 3,
    Aimbot_Bone = "Head",
    Aimbot_TeamCheck = true,
    Aimbot_VisibleCheck = true,
    Aimbot_ShowFOV = true,
}

-- ══════════════════════════════════════════
-- DRAWING COMPATIBILITY (Ronix/Fluxus/KRNL)
-- ══════════════════════════════════════════
local DrawingNew = (Drawing and Drawing.new) or nil
local MouseMoveRel = mousemoverel or (Input and Input.MouseMove) or nil

if not DrawingNew then
    -- Fallback: gunakan BillboardGui buat ESP kalau Drawing gak support
    warn("[Nero] Drawing API not supported, using BillboardGui fallback for ESP")
end

-- ══════════════════════════════════════════
-- ESP SYSTEM
-- ══════════════════════════════════════════
local ESP_Objects = {}

local function createESP(player)
    if player == LocalPlayer then return end
    
    local esp = {}
    
    if DrawingNew then
        -- Native Drawing API (Synapse/Ronix/Delta)
        esp.BoxOutline = DrawingNew("Square")
        esp.BoxOutline.Visible = false
        esp.BoxOutline.Color = Color3.new(0, 0, 0)
        esp.BoxOutline.Thickness = 3
        esp.BoxOutline.Filled = false
        
        esp.Box = DrawingNew("Square")
        esp.Box.Visible = false
        esp.Box.Color = Config.ESP_Color
        esp.Box.Thickness = 1
        esp.Box.Filled = false
        
        esp.Name = DrawingNew("Text")
        esp.Name.Visible = false
        esp.Name.Color = Color3.new(1, 1, 1)
        esp.Name.Size = 14
        esp.Name.Center = true
        esp.Name.Outline = true
        
        esp.HealthBarOutline = DrawingNew("Line")
        esp.HealthBarOutline.Visible = false
        esp.HealthBarOutline.Color = Color3.new(0, 0, 0)
        esp.HealthBarOutline.Thickness = 4
        
        esp.HealthBar = DrawingNew("Line")
        esp.HealthBar.Visible = false
        esp.HealthBar.Color = Color3.fromRGB(0, 255, 0)
        esp.HealthBar.Thickness = 2
        
        esp.Distance = DrawingNew("Text")
        esp.Distance.Visible = false
        esp.Distance.Color = Color3.fromRGB(200, 200, 200)
        esp.Distance.Size = 12
        esp.Distance.Center = true
        esp.Distance.Outline = true
        
        esp.UseDrawing = true
    else
        -- BillboardGui fallback (executor gak support Drawing)
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "NeroESP"
        billboard.Size = UDim2.new(4, 0, 6, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.MaxDistance = 500
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Config.ESP_Color
        frame.Parent = billboard
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, -18)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = player.Name
        nameLabel.Parent = frame
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0, 14)
        distLabel.Position = UDim2.new(0, 0, 1, 2)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distLabel.TextStrokeTransparency = 0
        distLabel.TextSize = 12
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = frame
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(0.05, 0, 1, 0)
        healthBar.Position = UDim2.new(0, -6, 0, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = frame
        
        esp.Billboard = billboard
        esp.Frame = frame
        esp.NameLabel = nameLabel
        esp.DistLabel = distLabel
        esp.HealthBar = healthBar
        esp.UseDrawing = false
    end
    
    ESP_Objects[player] = esp
end

local function removeESP(player)
    local esp = ESP_Objects[player]
    if esp then
        if esp.UseDrawing then
            for _, obj in pairs(esp) do
                if type(obj) == "table" or type(obj) == "userdata" then
                    pcall(function() obj:Remove() end)
                end
            end
        else
            pcall(function()
                if esp.Billboard then esp.Billboard:Destroy() end
            end)
        end
        ESP_Objects[player] = nil
    end
end

local function updateESP()
    for player, esp in pairs(ESP_Objects) do
        if not Config.ESP_Enabled or not player.Parent then
            if esp.UseDrawing then
                for _, obj in pairs(esp) do
                    if type(obj) ~= "boolean" then
                        pcall(function() obj.Visible = false end)
                    end
                end
            else
                pcall(function() esp.Billboard.Enabled = false end)
            end
            continue
        end
        
        local character = player.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        
        if not character or not humanoid or not rootPart or not head then
            if esp.UseDrawing then
                for _, obj in pairs(esp) do
                    if type(obj) ~= "boolean" then
                        pcall(function() obj.Visible = false end)
                    end
                end
            else
                pcall(function() esp.Billboard.Enabled = false end)
            end
            continue
        end
        
        -- Team check
        if Config.ESP_TeamCheck and player.Team == LocalPlayer.Team and player.Team ~= nil then
            if esp.UseDrawing then
                for _, obj in pairs(esp) do
                    if type(obj) ~= "boolean" then
                        pcall(function() obj.Visible = false end)
                    end
                end
            else
                pcall(function() esp.Billboard.Enabled = false end)
            end
            continue
        end
        
        -- Team color
        local espColor = Config.ESP_Color
        if player.Team and player.Team == LocalPlayer.Team then
            espColor = Config.ESP_TeamColor
        end
        
        if esp.UseDrawing then
            -- Drawing-based ESP
            local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            
            if not onScreen then
                for _, obj in pairs(esp) do
                    if type(obj) ~= "boolean" then
                        pcall(function() obj.Visible = false end)
                    end
                end
                continue
            end
            
            local scaleFactor = 1 / (pos.Z * 0.04)
            local boxWidth = math.clamp(4 * scaleFactor, 2, 200)
            local boxHeight = math.clamp(5.5 * scaleFactor, 2, 280)
            local boxX = pos.X - boxWidth / 2
            local boxY = pos.Y - boxHeight / 2
            
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
            
            if Config.ESP_Name then
                esp.Name.Text = player.DisplayName or player.Name
                esp.Name.Position = Vector2.new(pos.X, boxY - 18)
                esp.Name.Visible = true
            else
                esp.Name.Visible = false
            end
            
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
        else
            -- BillboardGui fallback ESP
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            esp.Billboard.Enabled = true
            esp.Billboard.Adornee = head
            esp.NameLabel.Text = player.DisplayName or player.Name
            esp.Frame.BorderColor3 = espColor
            
            if myRoot then
                local dist = (myRoot.Position - rootPart.Position).Magnitude
                esp.DistLabel.Text = string.format("[%dm]", math.floor(dist))
            end
            
            local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            esp.HealthBar.Size = UDim2.new(0.05, 0, healthPct, 0)
            esp.HealthBar.Position = UDim2.new(0, -6, 1 - healthPct, 0)
            esp.HealthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPct), 255 * healthPct, 0)
            
            esp.Frame.Visible = Config.ESP_Box
            esp.NameLabel.Visible = Config.ESP_Name
            esp.DistLabel.Visible = Config.ESP_Distance
            esp.HealthBar.Visible = Config.ESP_Health
        end
    end
end

-- ══════════════════════════════════════════
-- SPEED HACK
-- ══════════════════════════════════════════
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
local AimbotFOVCircle = nil

if DrawingNew then
    AimbotFOVCircle = DrawingNew("Circle")
    AimbotFOVCircle.Visible = false
    AimbotFOVCircle.Radius = Config.Aimbot_FOV
    AimbotFOVCircle.Color = Color3.fromRGB(255, 255, 255)
    AimbotFOVCircle.Thickness = 1
    AimbotFOVCircle.Filled = false
    AimbotFOVCircle.NumSides = 64
    AimbotFOVCircle.Transparency = 0.7
end

local function getClosestPlayer()
    local closest = nil
    local closestDist = Config.Aimbot_FOV
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        if Config.Aimbot_TeamCheck and player.Team and player.Team == LocalPlayer.Team then
            continue
        end
        
        local targetPart = player.Character:FindFirstChild(Config.Aimbot_Bone)
        if not targetPart then continue end
        
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
    
    if not MouseMoveRel then return end
    
    local screenPos = Camera:WorldToViewportPoint(bone.Position)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetPos = Vector2.new(screenPos.X, screenPos.Y)
    
    local delta = (targetPos - screenCenter) / Config.Aimbot_Smoothness
    
    MouseMoveRel(delta.X, delta.Y)
end

local AimbotActive = false

-- ══════════════════════════════════════════
-- FOV CIRCLE UPDATE
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if AimbotFOVCircle then
        AimbotFOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        AimbotFOVCircle.Radius = Config.Aimbot_FOV
        AimbotFOVCircle.Visible = Config.Aimbot_Enabled and Config.Aimbot_ShowFOV
    end
end)

-- ══════════════════════════════════════════
-- MAIN LOOPS
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(updateESP)
RunService.Heartbeat:Connect(updateSpeed)

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
-- GUI
-- ══════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeroScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protect GUI
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    elseif protect_gui then
        protect_gui(ScreenGui)
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
Title.Text = "⚡ NERO SCRIPT v1.1"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

local ExecutorLabel = Instance.new("TextLabel")
ExecutorLabel.Size = UDim2.new(1, 0, 0, 14)
ExecutorLabel.Position = UDim2.new(0, 0, 0, 30)
ExecutorLabel.BackgroundTransparency = 1
ExecutorLabel.Text = "Executor: " .. getexecutorname()
ExecutorLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
ExecutorLabel.TextSize = 10
ExecutorLabel.Font = Enum.Font.Gotham
ExecutorLabel.Parent = MainFrame

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

createToggle("ESP", 48, Config.ESP_Enabled, function(v)
    Config.ESP_Enabled = v
    if not v then
        for _, esp in pairs(ESP_Objects) do
            if esp.UseDrawing then
                for _, obj in pairs(esp) do
                    if type(obj) ~= "boolean" then
                        pcall(function() obj.Visible = false end)
                    end
                end
            else
                pcall(function() esp.Billboard.Enabled = false end)
            end
        end
    end
end)

createToggle("ESP Box", 82, Config.ESP_Box, function(v)
    Config.ESP_Box = v
end)

createToggle("ESP Name", 116, Config.ESP_Name, function(v)
    Config.ESP_Name = v
end)

createToggle("ESP Health", 150, Config.ESP_Health, function(v)
    Config.ESP_Health = v
end)

createToggle("ESP Distance", 184, Config.ESP_Distance, function(v)
    Config.ESP_Distance = v
end)

createToggle("Speed x" .. Config.Speed_Value, 218, Config.Speed_Enabled, function(v)
    Config.Speed_Enabled = v
end)

createToggle("Aimbot (Hold RMB)", 252, Config.Aimbot_Enabled, function(v)
    Config.Aimbot_Enabled = v
end)

-- ══════════════════════════════════════════
-- KEYBINDS
-- ══════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        Config.ESP_Enabled = not Config.ESP_Enabled
    end
    
    if input.KeyCode == Enum.KeyCode.F2 then
        Config.Speed_Enabled = not Config.Speed_Enabled
    end
    
    if input.KeyCode == Enum.KeyCode.F3 then
        Config.Aimbot_Enabled = not Config.Aimbot_Enabled
    end
end)

-- ══════════════════════════════════════════
-- ANTI-DETECT PERIODIC SPOOF
-- ══════════════════════════════════════════
task.spawn(function()
    while task.wait(math.random(30, 60)) do
        pcall(function()
            jitter = math.random() * 0.01
            if clearconsole then clearconsole() end
        end)
    end
end)

-- ══════════════════════════════════════════
-- RESPAWN HANDLER
-- ══════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    updateSpeed()
end)

print("═══════════════════════════════════════")
print("  ⚡ NERO SCRIPT v1.1 LOADED")
print("  Executor: " .. getexecutorname())
print("  Drawing API: " .. (DrawingNew and "✅ Supported" or "❌ BillboardGui fallback"))
print("  mousemoverel: " .. (MouseMoveRel and "✅ Supported" or "❌ Aimbot disabled"))
print("  RightShift = Toggle GUI")
print("  F1 = ESP | F2 = Speed | F3 = Aimbot")
print("  Hold RMB = Aimbot Lock")
print("═══════════════════════════════════════")
