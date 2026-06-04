-- NERO SCRIPT v6.5
-- Fix: target switching, camera movement, RightShift toggle

task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local TweenService = game:GetService("TweenService")
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
        Aimbot = false,
        AimbotFOV = 300,
        AimbotSmooth = 0.3,    -- 0.1 = very slow/smooth, 1.0 = instant snap
        AimbotBone = "Head",
        AimbotTeam = true, AimbotVis = false,
        AutoShoot = false,
        AimbotShowFOV = false,
    }

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Nero Script",
            Text = "v6.5 — RightShift: toggle menu",
            Duration = 5
        })
    end)

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
        local function onCharacter(char)
            task.wait(0.5)
            if Highlights[plr] then Highlights[plr].Adornee = char end
            if DistLabels[plr] then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then DistLabels[plr].Gui.Adornee = root end
            end
        end
        if plr.Character then onCharacter(plr.Character) end
        plr.CharacterAdded:Connect(onCharacter)
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
    -- AIMBOT (finds closest EVERY frame)
    -- ══════════════════════════════════════════
    local lastShoot = 0

    local function getClosestPlayer()
        local closest = nil
        local minDist = S.AimbotFOV

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LP then continue end
            if S.AimbotTeam and LP.Team and plr.Team == LP.Team then continue end

            local c = plr.Character
            if not c then continue end
            local hum = c:FindFirstChild("Humanoid")
            if not hum or hum.Health <= 0 then continue end

            local part = c:FindFirstChild(S.AimbotBone) or c:FindFirstChild("HumanoidRootPart")
            if not part then continue end

            if S.AimbotVis then
                local origin = Camera.CFrame.Position
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {Char}
                params.FilterType = Enum.RaycastFilterType.Exclude
                if workspace:Raycast(origin, part.Position - origin, params) then continue end
            end

            local sp, vis = Camera:WorldToViewportPoint(part.Position)
            if not vis then continue end
            local screenDist = (Vector2.new(sp.X, sp.Y) - UIS:GetMouseLocation()).Magnitude

            if screenDist < minDist then
                minDist = screenDist
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

        -- Smooth aim: blend player's current look with target direction
        -- This lets the player still move mouse while aimbot assists
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.new(camPos, part.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, S.AimbotSmooth)

        -- Auto-shoot
        if S.AutoShoot then
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

    -- FOV Circle
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Radius = S.AimbotFOV
    FOVCircle.Thickness = 1.5
    FOVCircle.Color = Color3.fromRGB(255, 80, 80)
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.6
    FOVCircle.Visible = false

    -- ══════════════════════════════════════════
    -- GUI
    -- ══════════════════════════════════════════
    local guiVisible = true
    local currentTab = "ESP"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeroScript"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then
        pcall(function() ScreenGui.Parent = LP:WaitForChild("PlayerGui") end)
    end

    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 520, 0, 400)
    Window.Position = UDim2.new(0.5, -260, 0.5, -200)
    Window.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.Draggable = true
    Window.Parent = ScreenGui
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 10)

    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.Parent = Window

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 44)
    TitleBar.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
    local TitleCover = Instance.new("Frame")
    TitleCover.Size = UDim2.new(1, 0, 0, 10)
    TitleCover.Position = UDim2.new(0, 0, 1, -10)
    TitleCover.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    TitleCover.BorderSizePixel = 0
    TitleCover.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.6, 0, 0, 22)
    TitleLabel.Position = UDim2.new(0, 16, 0, 6)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Nero Script"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0.6, 0, 0, 14)
    SubLabel.Position = UDim2.new(0, 16, 0, 28)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "v6.5"
    SubLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
    SubLabel.TextSize = 12
    SubLabel.Font = Enum.Font.Gotham
    SubLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubLabel.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 32, 0, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0, 6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    CloseBtn.TextSize = 22
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
    CloseBtn.MouseButton1Click:Connect(function() guiVisible = false Window.Visible = false end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 120, 1, -44)
    Sidebar.Position = UDim2.new(0, 0, 0, 44)
    Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Window

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -120, 1, -44)
    Content.Position = UDim2.new(0, 120, 0, 44)
    Content.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Content.BorderSizePixel = 0
    Content.Parent = Window

    local Pages = {}
    local TabButtons = {}

    local function createPage(name)
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -20, 1, -16)
        page.Position = UDim2.new(0, 10, 0, 8)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.Parent = Content
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = page
        Pages[name] = page
        return page
    end

    local function createTabBtn(name, icon, order)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 38)
        btn.Position = UDim2.new(0, 5, 0, 6 + (order * 42))
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        btn.BorderSizePixel = 0
        btn.Text = "  " .. icon .. "  " .. name
        btn.TextColor3 = Color3.fromRGB(140, 140, 150)
        btn.TextSize = 14
        btn.Font = Enum.Font.GothamSemibold
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = Sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseButton1Click:Connect(function()
            currentTab = name
            for n, page in pairs(Pages) do page.Visible = (n == name) end
            for n, b in pairs(TabButtons) do
                b.BackgroundColor3 = (n == name) and Color3.fromRGB(45, 45, 55) or Color3.fromRGB(30, 30, 35)
                b.TextColor3 = (n == name) and Color3.new(1, 1, 1) or Color3.fromRGB(140, 140, 150)
            end
        end)
        TabButtons[name] = btn
    end

    local function createCard(parent, title, desc, default, callback)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 62)
        card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
        card.BorderSizePixel = 0
        card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 14)
        pad.PaddingRight = UDim.new(0, 14)
        pad.PaddingTop = UDim.new(0, 10)
        pad.Parent = card

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -70, 0, 20)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.new(1, 1, 1)
        titleLabel.TextSize = 15
        titleLabel.Font = Enum.Font.GothamSemibold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = card

        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -70, 0, 16)
        descLabel.Position = UDim2.new(0, 0, 0, 24)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = desc
        descLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
        descLabel.TextSize = 12
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = card

        local toggleBg = Instance.new("TextButton")
        toggleBg.Size = UDim2.new(0, 48, 0, 26)
        toggleBg.Position = UDim2.new(1, -62, 0.5, -13)
        toggleBg.BackgroundColor3 = default and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(55, 55, 65)
        toggleBg.BorderSizePixel = 0
        toggleBg.Text = ""
        toggleBg.Parent = card
        Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

        local toggleCircle = Instance.new("Frame")
        toggleCircle.Size = UDim2.new(0, 20, 0, 20)
        toggleCircle.Position = default and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
        toggleCircle.BorderSizePixel = 0
        toggleCircle.Parent = toggleBg
        Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1, 0)

        local state = default
        toggleBg.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {
                BackgroundColor3 = state and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(55, 55, 65)
            }):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            }):Play()
            callback(state)
        end)
    end

    local function createSection(parent, icon, title)
        local sec = Instance.new("Frame")
        sec.Size = UDim2.new(1, 0, 0, 34)
        sec.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        sec.BorderSizePixel = 0
        sec.Parent = parent
        Instance.new("UICorner", sec).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -16, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = icon .. "  " .. title
        lbl.TextColor3 = Color3.fromRGB(255, 100, 100)
        lbl.TextSize = 14
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = sec
    end

    -- ══════════════════════════════════════════
    -- BUILD PAGES
    -- ══════════════════════════════════════════
    local espPage = createPage("ESP")
    createSection(espPage, "🎯", "Player ESP")
    createCard(espPage, "Player Chams", "Highlight players through walls (3D glow)", false, function(v) S.Chams = v end)
    createCard(espPage, "Distance Display", "Show distance to players in meters", false, function(v) S.Distance = v end)
    createCard(espPage, "Team Check", "Hide teammates from ESP", true, function(v) S.TeamCheck = v end)

    local playerPage = createPage("Player")
    createSection(playerPage, "⚡", "Movement")
    createCard(playerPage, "Speed x2", "Double walk speed", false, function(v)
        S.Speed = v
        pcall(function() if not v and Char and Char:FindFirstChild("Humanoid") then Char.Humanoid.WalkSpeed = 16 end end)
    end)

    local aimPage = createPage("Aimbot")
    createSection(aimPage, "🔫", "Aimbot Settings")
    createCard(aimPage, "Aimbot", "Auto aim at closest player", false, function(v) S.Aimbot = v end)
    createCard(aimPage, "Auto Shoot", "Auto fire when locked on", false, function(v) S.AutoShoot = v end)
    createCard(aimPage, "Show FOV Circle", "Display aim radius", false, function(v) S.AimbotShowFOV = v end)
    createCard(aimPage, "Visibility Check", "Only target visible players", false, function(v) S.AimbotVis = v end)
    createCard(aimPage, "Team Check", "Skip teammates", true, function(v) S.AimbotTeam = v end)

    local settingsPage = createPage("Settings")
    createSection(settingsPage, "⚙️", "Info")
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, 0, 0, 70)
    infoCard.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    infoCard.BorderSizePixel = 0
    infoCard.Parent = settingsPage
    Instance.new("UICorner", infoCard).CornerRadius = UDim.new(0, 8)
    local infoPad = Instance.new("UIPadding")
    infoPad.PaddingLeft = UDim.new(0, 14) infoPad.PaddingTop = UDim.new(0, 12)
    infoPad.Parent = infoCard
    local infoLbl = Instance.new("TextLabel")
    infoLbl.Size = UDim2.new(1, -28, 1, -24)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Text = "Nero Script v6.5\nRightShift to toggle menu\nExecutor: " .. (identifyexecutor and identifyexecutor() or "Unknown")
    infoLbl.TextColor3 = Color3.fromRGB(160, 160, 170)
    infoLbl.TextSize = 14
    infoLbl.Font = Enum.Font.Gotham
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left
    infoLbl.TextYAlignment = Enum.TextYAlignment.Top
    infoLbl.TextWrapped = true
    infoLbl.Parent = infoCard

    createTabBtn("ESP", "🎯", 0)
    createTabBtn("Player", "🏃", 1)
    createTabBtn("Aimbot", "🔫", 2)
    createTabBtn("Settings", "⚙️", 3)
    Pages["ESP"].Visible = true
    TabButtons["ESP"].BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    TabButtons["ESP"].TextColor3 = Color3.new(1, 1, 1)

    -- ══════════════════════════════════════════
    -- RIGHTSHIFT TOGGLE (AFTER guiVisible is declared)
    -- ══════════════════════════════════════════
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            guiVisible = not guiVisible
            Window.Visible = guiVisible
        end
    end)

    -- ══════════════════════════════════════════
    -- MAIN LOOP
    -- ══════════════════════════════════════════
    RunService.RenderStepped:Connect(function()
        pcall(function() Char = LP.Character end)

        -- Speed
        pcall(function()
            if S.Speed and Char and Char:FindFirstChild("Humanoid") then
                Char.Humanoid.WalkSpeed = 16 * S.SpeedMul
            end
        end)

        -- ESP
        pcall(updateESP)

        -- FOV circle
        FOVCircle.Visible = S.Aimbot and S.AimbotShowFOV
        FOVCircle.Position = UIS:GetMouseLocation()
        FOVCircle.Radius = S.AimbotFOV

        -- Aimbot (finds NEW closest target every frame)
        pcall(doAimbot)
    end)

    LP.CharacterAdded:Connect(function(newChar) Char = newChar end)

    print("[Nero] v6.5 loaded — RightShift to toggle")
end)
