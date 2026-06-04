-- NERO SCRIPT v5.0
-- Based on Infinite Yield patterns (non-blocking)
-- Compatible: Ronix, Delta, Synapse, KRNL, Fluxus, dll

-- ══════════════════════════════════════════
-- SAFE STARTUP (non-blocking, wrapped in task.spawn)
-- ══════════════════════════════════════════
task.spawn(function()
    -- wait for game to fully load
    if not game:IsLoaded() then game.Loaded:Wait() end

    -- services (cached once)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local Camera = workspace.CurrentCamera
    local LP = Players.LocalPlayer

    -- wait for character safely
    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") do
        task.wait(0.1)
    end

    local Char = LP.Character
    local Humanoid = Char:WaitForChild("Humanoid")

    -- ══════════════════════════════════════════
    -- SETTINGS
    -- ══════════════════════════════════════════
    local S = {
        ESP = false, ESP_TeamCheck = true,
        ESP_Color = Color3.fromRGB(255, 50, 50), ESP_TeamColor = Color3.fromRGB(50, 255, 50),
        Speed = false, SpeedMul = 2,
        Aimbot = false, AimbotFOV = 250, AimbotSmooth = 3, AimbotBone = "Head",
        AimbotTeam = true, AimbotVis = true, AimbotShowFOV = false,
    }

    -- ══════════════════════════════════════════
    -- NOTIFICATION
    -- ══════════════════════════════════════════
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Nero Script v5.0",
            Text = "Loaded! RightShift to toggle",
            Duration = 5
        })
    end)

    -- ══════════════════════════════════════════
    -- ESP DRAWINGS (cached)
    -- ══════════════════════════════════════════
    local ESPObjects = {}
    local DrawingNew = Drawing.new
    local Vector2New = Vector2.new
    local mathFloor = math.floor
    local mathAbs = math.abs

    local function createESP(plr)
        local d = {
            BoxOutline = DrawingNew("Square"), Box = DrawingNew("Square"),
            Name = DrawingNew("Text"), Distance = DrawingNew("Text"),
            TracerOutline = DrawingNew("Line"), Tracer = DrawingNew("Line"),
            HPBarOutline = DrawingNew("Line"), HPBar = DrawingNew("Line"),
        }
        d.BoxOutline.Thickness = 3 d.BoxOutline.Filled = false d.BoxOutline.Color = Color3.new(0,0,0) d.BoxOutline.Visible = false
        d.Box.Thickness = 1 d.Box.Filled = false d.Box.Visible = false
        d.Name.Size = 14 d.Name.Center = true d.Name.Outline = true d.Name.Visible = false
        d.Distance.Size = 12 d.Distance.Center = true d.Distance.Outline = true d.Distance.Visible = false
        d.TracerOutline.Thickness = 3 d.TracerOutline.Color = Color3.new(0,0,0) d.TracerOutline.Visible = false
        d.Tracer.Thickness = 1 d.Tracer.Visible = false
        d.HPBarOutline.Thickness = 4 d.HPBarOutline.Color = Color3.new(0,0,0) d.HPBarOutline.Visible = false
        d.HPBar.Thickness = 2 d.HPBar.Visible = false
        ESPObjects[plr] = d
    end

    local function removeESP(plr)
        if ESPObjects[plr] then
            for _, obj in pairs(ESPObjects[plr]) do pcall(function() obj:Remove() end) end
            ESPObjects[plr] = nil
        end
    end

    local function w2s(pos)
        local sp, onScreen = Camera:WorldToViewportPoint(pos)
        return Vector2New(sp.X, sp.Y), onScreen
    end

    -- ══════════════════════════════════════════
    -- AIMBOT HELPERS
    -- ══════════════════════════════════════════
    local function isAlive(plr)
        local c = plr.Character
        return c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0
    end

    local function isVisible(targetPart)
        local origin = Camera.CFrame.Position
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {Char}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(origin, targetPart.Position - origin, params)
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
            if S.AimbotVis and not isVisible(part) then continue end
            local sp, vis = w2s(part.Position)
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
    -- GUI (lightweight, no external libs)
    -- ══════════════════════════════════════════
    local guiVisible = true

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeroScript"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- safe parent
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then
        pcall(function() ScreenGui.Parent = LP:WaitForChild("PlayerGui") end)
    end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 260, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -130, 0.5, -170)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Title.BorderSizePixel = 0
    Title.Text = "NERO SCRIPT v5.0"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

    local yOff = 35

    local function createToggle(name, default, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 28)
        btn.Position = UDim2.new(0, 10, 0, yOff)
        btn.BackgroundColor3 = default and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(60, 60, 65)
        btn.BorderSizePixel = 0
        btn.Text = (default and "[ON]  " or "[OFF] ") .. name
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamSemibold
        btn.Parent = MainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(60, 60, 65)
            btn.Text = (state and "[ON]  " or "[OFF] ") .. name
            callback(state)
        end)
        yOff = yOff + 32
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
    end

    -- BUILD GUI
    createLabel("─── ESP ───")
    createToggle("ESP", false, function(v) S.ESP = v end)
    createToggle("Team Check", true, function(v) S.ESP_TeamCheck = v end)

    createLabel("─── PLAYER ───")
    createToggle("Speed x2", false, function(v)
        S.Speed = v
        pcall(function()
            if not v and Char and Char:FindFirstChild("Humanoid") then
                Char.Humanoid.WalkSpeed = 16
            end
        end)
    end)

    createLabel("─── AIMBOT ───")
    createToggle("Aimbot", false, function(v) S.Aimbot = v end)
    createToggle("Vis Check", true, function(v) S.AimbotVis = v end)
    createToggle("Team Check", true, function(v) S.AimbotTeam = v end)
    createToggle("Show FOV", false, function(v) S.AimbotShowFOV = v end)

    -- FOV Circle
    local FOVCircle = DrawingNew("Circle")
    FOVCircle.Radius = S.AimbotFOV
    FOVCircle.Thickness = 1
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.7
    FOVCircle.Visible = false

    -- ══════════════════════════════════════════
    -- ESP LOOP (RenderStepped — visual only)
    -- ══════════════════════════════════════════
    RunService.RenderStepped:Connect(function()
        -- FOV circle
        FOVCircle.Visible = S.Aimbot and S.AimbotShowFOV
        FOVCircle.Position = UIS:GetMouseLocation()

        -- Speed
        pcall(function()
            if S.Speed and Char and Char:FindFirstChild("Humanoid") then
                Char.Humanoid.WalkSpeed = 16 * S.SpeedMul
            end
        end)

        if not S.ESP then
            for _, drawings in pairs(ESPObjects) do
                for _, obj in pairs(drawings) do pcall(function() obj.Visible = false end) end
            end
            return
        end

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LP then continue end
            if not ESPObjects[plr] then createESP(plr) end
            local d = ESPObjects[plr]

            local c = plr.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChild("Humanoid")
            local show = root and hum and hum.Health > 0

            if show and S.ESP_TeamCheck and plr.Team == LP.Team then show = false end

            if show and Char and Char:FindFirstChild("HumanoidRootPart") then
                local topPos = c:FindFirstChild("Head") and c.Head.Position or (root.Position + Vector3.new(0, 3, 0))
                local botPos = root.Position - Vector3.new(0, 3, 0)
                local topScreen, topVis = w2s(topPos)
                local botScreen, botVis = w2s(botPos)

                if topVis or botVis then
                    local height = mathAbs(topScreen.Y - botScreen.Y)
                    local width = height / 1.8
                    local center = (topScreen + botScreen) / 2
                    local color = (S.ESP_TeamCheck and plr.Team == LP.Team) and S.ESP_TeamColor or S.ESP_Color

                    -- Box
                    d.BoxOutline.Size = Vector2New(width, height)
                    d.BoxOutline.Position = Vector2New(center.X - width/2, center.Y - height/2)
                    d.BoxOutline.Visible = true
                    d.Box.Size = d.BoxOutline.Size
                    d.Box.Position = d.BoxOutline.Position
                    d.Box.Color = color
                    d.Box.Visible = true

                    -- Name
                    d.Name.Position = Vector2New(center.X, center.Y - height/2 - 16)
                    d.Name.Text = plr.Name
                    d.Name.Color = color
                    d.Name.Visible = true

                    -- Distance
                    local dist = mathFloor((Char.HumanoidRootPart.Position - root.Position).Magnitude)
                    d.Distance.Position = Vector2New(center.X, center.Y + height/2 + 4)
                    d.Distance.Text = dist .. "m"
                    d.Distance.Color = color
                    d.Distance.Visible = true

                    -- Tracer
                    local screenBot = Vector2New(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    d.TracerOutline.From = screenBot
                    d.TracerOutline.To = center
                    d.TracerOutline.Visible = true
                    d.Tracer.From = screenBot
                    d.Tracer.To = center
                    d.Tracer.Color = color
                    d.Tracer.Visible = true

                    -- HP Bar
                    local hpPct = hum.Health / hum.MaxHealth
                    local barX = center.X - width/2 - 6
                    d.HPBarOutline.From = Vector2New(barX, center.Y - height/2)
                    d.HPBarOutline.To = Vector2New(barX, center.Y + height/2)
                    d.HPBarOutline.Visible = true
                    d.HPBar.From = Vector2New(barX, center.Y + height/2)
                    d.HPBar.To = Vector2New(barX, center.Y + height/2 - height * hpPct)
                    d.HPBar.Color = Color3.fromRGB(255 * (1-hpPct), 255 * hpPct, 0)
                    d.HPBar.Visible = true
                else
                    for _, obj in pairs(d) do pcall(function() obj.Visible = false end) end
                end
            else
                for _, obj in pairs(d) do pcall(function() obj.Visible = false end) end
            end
        end
    end)

    -- ══════════════════════════════════════════
    -- AIMBOT LOOP (Heartbeat — after physics)
    -- ══════════════════════════════════════════
    RunService.Heartbeat:Connect(function()
        if not S.Aimbot then return end
        local target = getClosest()
        if target then
            local sp = Camera:WorldToViewportPoint(target.Position)
            local mousePos = UIS:GetMouseLocation()
            local dx = (sp.X - mousePos.X) / S.AimbotSmooth
            local dy = (sp.Y - mousePos.Y) / S.AimbotSmooth
            pcall(function() mousemoverel(dx, dy) end)
        end
    end)

    -- ══════════════════════════════════════════
    -- CHARACTER RESPAWN
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

    print("[Nero] v5.0 loaded — RightShift to toggle")
end) -- end of task.spawn
