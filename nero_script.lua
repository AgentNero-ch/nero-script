-- NERO SCRIPT v4.0
-- Lightweight GUI — no external libraries
-- Compatible: Ronix, Delta, Synapse, KRNL, Fluxus, dll

-- ══════════════════════════════════════════
-- SAFE ANTI-DETECT (wrapped in pcall)
-- ══════════════════════════════════════════
pcall(function()
    if hookmetamethod then
        local old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local name = self.Name:lower()
                if name:find("anticheat") or name:find("detect") or name:find("log") then
                    return nil
                end
            end
            return old(self, ...)
        end)
    end
end)

-- ══════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer

-- wait for character
repeat task.wait() until LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local Char = LP.Character
local Humanoid = Char:WaitForChild("Humanoid")

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
-- NOTIFICATION (before GUI)
-- ══════════════════════════════════════════
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚡ Nero Script v4.0",
        Text = "Loaded! Press RightShift to toggle GUI",
        Duration = 5
    })
end)

-- ══════════════════════════════════════════
-- ESP DRAWINGS
-- ══════════════════════════════════════════
local ESPObjects = {}

local function createESP(plr)
    local drawings = {
        BoxOutline = Drawing.new("Square"), Box = Drawing.new("Square"),
        Name = Drawing.new("Text"), Health = Drawing.new("Text"), Distance = Drawing.new("Text"),
        TracerOutline = Drawing.new("Line"), Tracer = Drawing.new("Line"),
        HPBarOutline = Drawing.new("Line"), HPBar = Drawing.new("Line"),
    }
    drawings.BoxOutline.Thickness = 3 drawings.BoxOutline.Filled = false drawings.BoxOutline.Color = Color3.new(0,0,0) drawings.BoxOutline.Visible = false
    drawings.Box.Thickness = 1 drawings.Box.Filled = false drawings.Box.Visible = false
    drawings.Name.Size = 14 drawings.Name.Center = true drawings.Name.Outline = true drawings.Name.Visible = false
    drawings.Health.Size = 12 drawings.Health.Center = true drawings.Health.Outline = true drawings.Health.Visible = false
    drawings.Distance.Size = 12 drawings.Distance.Center = true drawings.Distance.Outline = true drawings.Distance.Visible = false
    drawings.TracerOutline.Thickness = 3 drawings.TracerOutline.Color = Color3.new(0,0,0) drawings.TracerOutline.Visible = false
    drawings.Tracer.Thickness = 1 drawings.Tracer.Visible = false
    drawings.HPBarOutline.Thickness = 4 drawings.HPBarOutline.Color = Color3.new(0,0,0) drawings.HPBarOutline.Visible = false
    drawings.HPBar.Thickness = 2 drawings.HPBar.Visible = false
    ESPObjects[plr] = drawings
end

local function removeESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do pcall(function() obj:Remove() end) end
        ESPObjects[plr] = nil
    end
end

local function worldToScreen(pos)
    local sp, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), onScreen
end

local function getBoundingBox(char)
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local top = char:FindFirstChild("Head") and char.Head.Position or (root.Position + Vector3.new(0, 3, 0))
    local bottom = root.Position - Vector3.new(0, 3, 0)
    local topScreen, topVis = worldToScreen(top)
    local bottomScreen, bottomVis = worldToScreen(bottom)
    if not topVis and not bottomVis then return nil end
    local height = math.abs(topScreen.Y - bottomScreen.Y)
    local width = height / 1.8
    local center = (topScreen + bottomScreen) / 2
    return {Pos = center, Width = width, Height = height}
end

-- ══════════════════════════════════════════
-- AIMBOT FUNCTIONS
-- ══════════════════════════════════════════
local function isAlive(plr)
    local c = plr.Character
    return c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0
end

local function isVisible(plr)
    local c = plr.Character
    if not c then return false end
    local head = c:FindFirstChild("Head")
    if not head then return false end
    local origin = Camera.CFrame.Position
    local dir = (head.Position - origin)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {Char, c}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, dir, params)
    return result == nil
end

local function getClosest()
    local closest, minDist = nil, S.AimbotFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if S.AimbotTeam and plr.Team == LP.Team then continue end
        if not isAlive(plr) then continue end
        local c = plr.Character
        local part = c:FindFirstChild(S.AimbotBone)
        if not part then continue end
        if S.AimbotVis and not isVisible(plr) then continue end
        local sp, vis = worldToScreen(part.Position)
        if not vis then continue end
        local dist = (sp - UIS:GetMouseLocation()).Magnitude
        if dist < minDist then
            minDist = dist
            closest = part
        end
    end
    return closest
end

-- ══════════════════════════════════════════
-- GUI (Lightweight — no external libs)
-- ══════════════════════════════════════════
local guiVisible = true

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NeroScriptGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function safeParent(gui)
    pcall(function() gui.Parent = game:GetService("CoreGui") end)
    if not gui.Parent then
        pcall(function() gui.Parent = LP:WaitForChild("PlayerGui") end)
    end
end
safeParent(ScreenGui)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 340)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Title.BorderSizePixel = 0
Title.Text = "⚡ NERO SCRIPT v4.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- ══════════════════════════════════════════
-- TOGGLE BUTTON FACTORY
-- ══════════════════════════════════════════
local yOff = 35

local function createToggle(name, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, yOff)
    btn.BackgroundColor3 = default and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(60, 60, 65)
    btn.BorderSizePixel = 0
    btn.Text = (default and "✅ " or "❌ ") .. name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(60, 60, 65)
        btn.Text = (state and "✅ " or "❌ ") .. name
        callback(state)
    end)

    yOff = yOff + 32
    return btn
end

local function createLabel(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, yOff)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = MainFrame
    yOff = yOff + 22
    return lbl
end

-- ══════════════════════════════════════════
-- GUI ELEMENTS
-- ══════════════════════════════════════════
createLabel("━━━━ ESP ━━━━")
createToggle("ESP", false, function(v) S.ESP = v end)
createToggle("ESP Team Check", true, function(v) S.ESP_TeamCheck = v end)

createLabel("━━━━ PLAYER ━━━━")
createToggle("Speed Hack", false, function(v)
    S.Speed = v
    pcall(function()
        if not v and Char and Char:FindFirstChild("Humanoid") then
            Char.Humanoid.WalkSpeed = 16
        end
    end)
end)

createLabel("━━━━ AIMBOT ━━━━")
createToggle("Aimbot", false, function(v) S.Aimbot = v end)
createToggle("Visibility Check", true, function(v) S.AimbotVis = v end)
createToggle("Team Check", true, function(v) S.AimbotTeam = v end)
createToggle("Show FOV Circle", false, function(v) S.AimbotShowFOV = v end)

-- ══════════════════════════════════════════
-- FOV CIRCLE
-- ══════════════════════════════════════════
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = S.AimbotFOV
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

-- ══════════════════════════════════════════
-- MAIN LOOP
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    FOVCircle.Visible = S.Aimbot and S.AimbotShowFOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Radius = S.AimbotFOV

    -- Speed Hack
    pcall(function()
        if S.Speed and Char and Char:FindFirstChild("Humanoid") then
            Char.Humanoid.WalkSpeed = 16 * S.SpeedMul
        end
    end)

    -- ESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not ESPObjects[plr] then createESP(plr) end
        local drawings = ESPObjects[plr]

        local show = S.ESP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if show and S.ESP_TeamCheck and plr.Team == LP.Team then show = false end

        if show then
            local bb = getBoundingBox(plr.Character)
            if bb then
                local color = S.ESP_Color
                if S.ESP_TeamCheck and plr.Team == LP.Team then color = S.ESP_TeamColor end

                -- Box
                drawings.BoxOutline.Size = Vector2.new(bb.Width, bb.Height)
                drawings.BoxOutline.Position = Vector2.new(bb.Pos.X - bb.Width/2, bb.Pos.Y - bb.Height/2)
                drawings.BoxOutline.Visible = true
                drawings.Box.Size = drawings.BoxOutline.Size
                drawings.Box.Position = drawings.BoxOutline.Position
                drawings.Box.Color = color
                drawings.Box.Visible = true

                -- Name
                if S.ESP_Name then
                    drawings.Name.Position = Vector2.new(bb.Pos.X, bb.Pos.Y - bb.Height/2 - 16)
                    drawings.Name.Text = plr.Name
                    drawings.Name.Color = color
                    drawings.Name.Visible = true
                else drawings.Name.Visible = false end

                -- Health
                if S.ESP_Health then
                    local hp = plr.Character:FindFirstChild("Humanoid") and math.floor(plr.Character.Humanoid.Health) or "?"
                    drawings.Health.Position = Vector2.new(bb.Pos.X, bb.Pos.Y - bb.Height/2 - 30)
                    drawings.Health.Text = "HP: " .. hp
                    drawings.Health.Color = color
                    drawings.Health.Visible = true
                else drawings.Health.Visible = false end

                -- Distance
                if S.ESP_Distance then
                    local dist = math.floor((Char.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude)
                    drawings.Distance.Position = Vector2.new(bb.Pos.X, bb.Pos.Y + bb.Height/2 + 4)
                    drawings.Distance.Text = dist .. "m"
                    drawings.Distance.Color = color
                    drawings.Distance.Visible = true
                else drawings.Distance.Visible = false end

                -- Tracer
                drawings.TracerOutline.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                drawings.TracerOutline.To = bb.Pos
                drawings.TracerOutline.Visible = true
                drawings.Tracer.From = drawings.TracerOutline.From
                drawings.Tracer.To = bb.Pos
                drawings.Tracer.Color = color
                drawings.Tracer.Visible = true

                -- HP Bar
                if plr.Character:FindFirstChild("Humanoid") then
                    local hpPct = plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth
                    local barX = bb.Pos.X - bb.Width/2 - 6
                    drawings.HPBarOutline.From = Vector2.new(barX, bb.Pos.Y - bb.Height/2)
                    drawings.HPBarOutline.To = Vector2.new(barX, bb.Pos.Y + bb.Height/2)
                    drawings.HPBarOutline.Visible = true
                    drawings.HPBar.From = Vector2.new(barX, bb.Pos.Y + bb.Height/2)
                    drawings.HPBar.To = Vector2.new(barX, bb.Pos.Y + bb.Height/2 - bb.Height * hpPct)
                    drawings.HPBar.Color = Color3.fromRGB(255 * (1-hpPct), 255 * hpPct, 0)
                    drawings.HPBar.Visible = true
                end
            else
                for _, obj in pairs(drawings) do
                    if typeof(obj) ~= "Instance" then pcall(function() obj.Visible = false end) end
                end
            end
        else
            for _, obj in pairs(drawings) do
                if typeof(obj) ~= "Instance" then pcall(function() obj.Visible = false end) end
            end
        end
    end
end)

-- ══════════════════════════════════════════
-- AIMBOT LOOP (separate, smoother)
-- ══════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if not S.Aimbot then return end
    local holding = S.AimbotHeld and UIS:IsMouseButtonPressed(S.AimbotKey)
    if S.AimbotHeld and not holding then return end
    local target = getClosest()
    if target then
        local sp = Camera:WorldToViewportPoint(target.Position)
        local mousePos = UIS:GetMouseLocation()
        local moveX = (sp.X - mousePos.X) / S.AimbotSmooth
        local moveY = (sp.Y - mousePos.Y) / S.AimbotSmooth
        mousemoverel(moveX, moveY)
    end
end)

-- ══════════════════════════════════════════
-- CHARACTER RESPAWN HANDLER
-- ══════════════════════════════════════════
LP.CharacterAdded:Connect(function(newChar)
    Char = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
end)

-- ══════════════════════════════════════════
-- PLAYER LEAVE CLEANUP
-- ══════════════════════════════════════════
Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

-- ══════════════════════════════════════════
-- TOGGLE GUI (RightShift)
-- ══════════════════════════════════════════
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        guiVisible = not guiVisible
        MainFrame.Visible = guiVisible
    end
end)

print("[Nero Script] v4.0 loaded — RightShift to toggle GUI")
