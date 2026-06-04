-- NERO SCRIPT v7.0
-- Rayfield UI + all features from v6.8

task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local VIM = game:GetService("VirtualInputManager")
    local Camera = workspace.CurrentCamera
    local LP = Players.LocalPlayer

    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") do
        task.wait(0.1)
    end
    local Char = LP.Character

    -- ══════════════════════════════════════════
    -- SETTINGS
    -- ══════════════════════════════════════════
    local S = {
        Chams = false, Distance = false, TeamCheck = true,
        ChamsColor = Color3.fromRGB(255, 50, 50),
        ChamsTeamColor = Color3.fromRGB(50, 255, 50),
        Speed = false, SpeedMul = 2,
        Aimbot = false, AimbotFOV = 250, AimbotSmooth = 0.4,
        AimbotBone = "Head", AimbotTeam = true,
        AutoShoot = false, AimbotShowFOV = false,
    }

    -- ══════════════════════════════════════════
    -- RAYFIELD UI
    -- ══════════════════════════════════════════
    local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/sirius-menu/rayfield/main/source.lua'))()

    local Window = Rayfield:CreateWindow({
        Name = "⚡ Nero Script",
        LoadingTitle = "Nero Script",
        LoadingSubtitle = "v7.0 loading...",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false,
    })

    Rayfield:Notify({Title = "Nero Script", Content = "v7.0 loaded!", Duration = 4})

    -- ──── ESP TAB ────
    local ESPTab = Window:CreateTab("ESP", 4483362458)

    ESPTab:CreateSection("Player ESP")

    ESPTab:CreateToggle({
        Name = "Player Chams",
        CurrentValue = false,
        Flag = "Chams",
        Callback = function(v) S.Chams = v end,
    })

    ESPTab:CreateToggle({
        Name = "Distance Display",
        CurrentValue = false,
        Flag = "Distance",
        Callback = function(v) S.Distance = v end,
    })

    ESPTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = true,
        Flag = "TeamCheck",
        Callback = function(v) S.TeamCheck = v end,
    })

    -- ──── PLAYER TAB ────
    local PlayerTab = Window:CreateTab("Player", 4483362458)

    PlayerTab:CreateSection("Movement")

    PlayerTab:CreateToggle({
        Name = "Speed x2",
        CurrentValue = false,
        Flag = "Speed",
        Callback = function(v)
            S.Speed = v
            pcall(function()
                if not v and Char and Char:FindFirstChild("Humanoid") then
                    Char.Humanoid.WalkSpeed = 16
                end
            end)
        end,
    })

    -- ──── AIMBOT TAB ────
    local AimTab = Window:CreateTab("Aimbot", 4483362458)

    AimTab:CreateSection("Aimbot Settings")

    AimTab:CreateToggle({
        Name = "Aimbot",
        CurrentValue = false,
        Flag = "Aimbot",
        Callback = function(v) S.Aimbot = v end,
    })

    AimTab:CreateToggle({
        Name = "Auto Shoot",
        CurrentValue = false,
        Flag = "AutoShoot",
        Callback = function(v) S.AutoShoot = v end,
    })

    AimTab:CreateToggle({
        Name = "Show FOV Circle",
        CurrentValue = false,
        Flag = "ShowFOV",
        Callback = function(v) S.AimbotShowFOV = v end,
    })

    AimTab:CreateToggle({
        Name = "Team Check",
        CurrentValue = true,
        Flag = "AimTeam",
        Callback = function(v) S.AimbotTeam = v end,
    })

    AimTab:CreateSlider({
        Name = "FOV Size",
        Range = {100, 800},
        Increment = 10,
        Suffix = "px",
        CurrentValue = 250,
        Flag = "FOV",
        Callback = function(v) S.AimbotFOV = v end,
    })

    AimTab:CreateSlider({
        Name = "Aim Smooth",
        Range = {1, 10},
        Increment = 1,
        Suffix = "",
        CurrentValue = 4,
        Flag = "Smooth",
        Callback = function(v) S.AimbotSmooth = v / 10 end,
    })

    -- ──── SETTINGS TAB ────
    local SettingsTab = Window:CreateTab("Settings", 4483362458)

    SettingsTab:CreateSection("Info")

    SettingsTab:CreateParagraph({
        Title = "Nero Script v7.0",
        Content = "UI: Rayfield\nExecutor: " .. (identifyexecutor and identifyexecutor() or "Unknown") .. "\nAimbot: Camera CFrame + LOS\nESP: Highlight Chams"
    })

    -- ══════════════════════════════════════════
    -- HIGHLIGHT CHAMS
    -- ══════════════════════════════════════════
    local Highlights = {}
    local DistLabels = {}

    local function setupPlayer(plr)
        if plr == LP then return end
        if not Highlights[plr] then
            local hl = Instance.new("Highlight")
            hl.FillColor = S.ChamsColor
            hl.FillTransparency = 0.45
            hl.OutlineColor = Color3.new(1, 1, 1)
            hl.OutlineTransparency = 0.2
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Enabled = false
            hl.Parent = game:GetService("CoreGui")
            Highlights[plr] = hl
        end
        if not DistLabels[plr] then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 120, 0, 30)
            bb.StudsOffset = Vector3.new(0, 3.8, 0)
            bb.AlwaysOnTop = true
            bb.Enabled = false
            bb.Parent = game:GetService("CoreGui")
            local tl = Instance.new("TextLabel")
            tl.Size = UDim2.new(1, 0, 1, 0)
            tl.BackgroundTransparency = 1
            tl.TextColor3 = Color3.new(1, 1, 1)
            tl.TextStrokeTransparency = 0.4
            tl.TextStrokeColor3 = Color3.new(0, 0, 0)
            tl.TextSize = 16
            tl.Font = Enum.Font.GothamBold
            tl.Parent = bb
            DistLabels[plr] = {Gui = bb, Label = tl}
        end
        local function onChar(char)
            task.wait(0.5)
            if Highlights[plr] then Highlights[plr].Adornee = char end
            if DistLabels[plr] then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then DistLabels[plr].Gui.Adornee = root end
            end
        end
        if plr.Character then onChar(plr.Character) end
        plr.CharacterAdded:Connect(onChar)
    end

    local function removePlayer(plr)
        if Highlights[plr] then pcall(function() Highlights[plr]:Destroy() end) Highlights[plr] = nil end
        if DistLabels[plr] then pcall(function() DistLabels[plr].Gui:Destroy() end) DistLabels[plr] = nil end
    end

    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LP then setupPlayer(plr) end end
    Players.PlayerAdded:Connect(setupPlayer)
    Players.PlayerRemoving:Connect(removePlayer)

    local function updateESP()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LP then continue end
            local hl = Highlights[plr]
            local dl = DistLabels[plr]
            if not hl then setupPlayer(plr) continue end
            local c = plr.Character
            local root = c and c:FindFirstChild("HumanoidRootPart")
            local hum = c and c:FindFirstChild("Humanoid")
            local alive = root and hum and hum.Health > 0
            local showChams = S.Chams and alive
            if showChams and S.TeamCheck and plr.Team == LP.Team then showChams = false end
            hl.Enabled = showChams
            if showChams then
                hl.Adornee = c
                hl.FillColor = (S.TeamCheck and plr.Team == LP.Team) and S.ChamsTeamColor or S.ChamsColor
            end
            if dl then
                local showDist = S.Distance and alive and Char and Char:FindFirstChild("HumanoidRootPart")
                if showDist and S.TeamCheck and plr.Team == LP.Team then showDist = false end
                dl.Gui.Enabled = showDist
                if showDist then
                    dl.Gui.Adornee = root
                    dl.Label.Text = math.floor((Char.HumanoidRootPart.Position - root.Position).Magnitude) .. "m"
                end
            end
        end
    end

    -- ══════════════════════════════════════════
    -- AIMBOT
    -- ══════════════════════════════════════════
    local lastShoot = 0

    local function makeRayParams(targetChar)
        local params = RaycastParams.new()
        local filter = {}
        if Char then table.insert(filter, Char) end
        if targetChar then table.insert(filter, targetChar) end
        params.FilterDescendantsInstances = filter
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.IgnoreWater = true
        return params
    end

    local function isOnScreen(worldPos)
        local sp = Camera:WorldToViewportPoint(worldPos)
        if sp.Z <= 0 then return false, Vector2.new(0, 0) end
        local screenPos = Vector2.new(sp.X, sp.Y)
        local vp = Camera.ViewportSize
        if sp.X < -50 or sp.X > vp.X + 50 then return false, screenPos end
        if sp.Y < -50 or sp.Y > vp.Y + 50 then return false, screenPos end
        return true, screenPos
    end

    local function hasLineOfSight(targetChar)
        local targetHead = targetChar:FindFirstChild("Head")
        if not targetHead then return false end
        local camPos = Camera.CFrame.Position
        local targetPos = targetHead.Position
        local direction = targetPos - camPos
        local distance = direction.Magnitude
        if distance > 1000 then return false end
        if distance < 30 then return true end
        local params = makeRayParams(targetChar)
        local result = workspace:Raycast(camPos, direction, params)
        if result then
            return result.Instance:IsDescendantOf(targetChar)
        end
        return true
    end

    local function getClosestPlayer()
        local closest = nil
        local minDist = S.AimbotFOV
        local vp = Camera.ViewportSize
        local screenCenter = Vector2.new(vp.X / 2, vp.Y / 2)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LP then continue end
            if S.AimbotTeam and LP.Team and plr.Team == LP.Team then continue end
            local c = plr.Character
            if not c then continue end
            local hum = c:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local part = c:FindFirstChild(S.AimbotBone) or c:FindFirstChild("HumanoidRootPart")
            if not part then continue end
            local onScreen, screenPos = isOnScreen(part.Position)
            if not onScreen then continue end
            if not hasLineOfSight(c) then continue end
            local distFromCenter = (screenPos - screenCenter).Magnitude
            if distFromCenter < minDist then
                minDist = distFromCenter
                closest = plr
            end
        end
        return closest
    end

    local function doAimbot()
        if not S.Aimbot then return end
        local targetPlr = getClosestPlayer()
        if not targetPlr then return end
        local c = targetPlr.Character
        if not c then return end
        local part = c:FindFirstChild(S.AimbotBone) or c:FindFirstChild("HumanoidRootPart")
        if not part then return end
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.new(camPos, part.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, S.AimbotSmooth)
        if S.AutoShoot then
            local blocked = false
            pcall(function() if UIS:GetFocusedTextBox() then blocked = true end end)
            if not blocked then
                local now = tick()
                if now - lastShoot >= 0.15 then
                    lastShoot = now
                    pcall(function()
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.05)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end)
                end
            end
        end
    end

    -- FOV Circle
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Radius = S.AimbotFOV
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(255, 80, 80)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.6
    FOVCircle.Visible = false

    -- ══════════════════════════════════════════
    -- MAIN LOOP
    -- ══════════════════════════════════════════
    RunService.RenderStepped:Connect(function()
        pcall(function() Char = LP.Character end)
        pcall(function()
            if S.Speed and Char and Char:FindFirstChild("Humanoid") then
                Char.Humanoid.WalkSpeed = 16 * S.SpeedMul
            end
        end)
        pcall(updateESP)
        FOVCircle.Visible = S.Aimbot and S.AimbotShowFOV
        FOVCircle.Position = UIS:GetMouseLocation()
        FOVCircle.Radius = S.AimbotFOV
        pcall(doAimbot)
    end)

    LP.CharacterAdded:Connect(function(newChar) Char = newChar end)
    print("[Nero] v7.0 Rayfield loaded")
end)
