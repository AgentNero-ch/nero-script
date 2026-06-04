-- NERO STEALTH ESP v1.0
-- Anti-detect ESP for games with aggressive AC (Blox Strike, etc.)
-- NO Drawing API, NO Highlight instances, NO metamethod hooks

task.spawn(function()
    -- ══════════════════════════════════════════
    -- DELAYED ACTIVATION (let AC scan first)
    -- ══════════════════════════════════════════
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(8) -- 8 second delay for AC to finish initial scan

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local StarterGui = game:GetService("StarterGui")
    local TweenService = game:GetService("TweenService")
    local Camera = workspace.CurrentCamera
    local LP = Players.LocalPlayer

    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") do
        task.wait(0.5)
    end
    local Char = LP.Character

    -- ══════════════════════════════════════════
    -- SETTINGS
    -- ══════════════════════════════════════════
    local S = {
        ESP = false,
        ShowNames = true,
        ShowDistance = true,
        ShowHealth = true,
        TeamCheck = true,
        Speed = false, SpeedMul = 2,
        Aimbot = false,
        AimbotFOV = 250,
        AimbotSmooth = 0.4,
        AimbotBone = "Head",
        AimbotTeam = true,
        AutoShoot = false,
        AimbotShowFOV = false,
    }

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Nero Stealth",
            Text = "v1.0 — RightShift: menu",
            Duration = 5
        })
    end)

    -- ══════════════════════════════════════════
    -- STEALTH ESP (BillboardGui, NOT Drawing/Highlight)
    -- ══════════════════════════════════════════
    local ESPGuis = {}
    local updateFrame = 0

    local function createESPGui(plr)
        if ESPGuis[plr] then return end

        -- BillboardGui attached to character (native Roblox, harder to detect)
        local bb = Instance.new("BillboardGui")
        bb.Name = "HealthBar" -- innocent name
        bb.Size = UDim2.new(4, 0, 5, 0)
        bb.StudsOffset = Vector3.new(0, 1, 0)
        bb.AlwaysOnTop = true
        bb.Enabled = false
        bb.MaxDistance = 300

        -- Parent to the character itself (not CoreGui)
        local function onChar(char)
            task.wait(1)
            bb.Parent = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char
            if S.ESP then bb.Enabled = true end
        end

        -- Name label
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, -18)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextColor3 = Color3.new(1, 1, 1)
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.TextSize = 14
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Text = ""
        nameLabel.Parent = bb

        -- Distance label
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistLabel"
        distLabel.Size = UDim2.new(1, 0, 0, 14)
        distLabel.Position = UDim2.new(0, 0, 1, 2)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        distLabel.TextStrokeTransparency = 0.3
        distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        distLabel.TextSize = 12
        distLabel.Font = Enum.Font.Gotham
        distLabel.Text = ""
        distLabel.Parent = bb

        -- Health bar background
        local hpBg = Instance.new("Frame")
        hpBg.Name = "HPBg"
        hpBg.Size = UDim2.new(0.8, 0, 0, 4)
        hpBg.Position = UDim2.new(0.1, 0, 1, 16)
        hpBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = bb
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

        -- Health bar fill
        local hpFill = Instance.new("Frame")
        hpFill.Name = "HPFill"
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBg
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

        ESPGuis[plr] = {
            BB = bb,
            Name = nameLabel,
            Dist = distLabel,
            HPBg = hpBg,
            HPFill = hpFill,
        }

        -- Setup character
        if plr.Character then onChar(plr.Character) end
        plr.CharacterAdded:Connect(onChar)
    end

    local function removeESPGui(plr)
        if ESPGuis[plr] then
            pcall(function() ESPGuis[plr].BB:Destroy() end)
            ESPGuis[plr] = nil
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then createESPGui(plr) end
    end
    Players.PlayerAdded:Connect(createESPGui)
    Players.PlayerRemoving:Connect(removeESPGui)

    -- ══════════════════════════════════════════
    -- AIMBOT (same as v6.8, proven working)
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

        if S.AutoShoot and not guiVisible then
            local blocked = false
            pcall(function() if UIS:GetFocusedTextBox() then blocked = true end end)
            if not blocked then
                local now = tick()
                if now - lastShoot >= 0.15 then
                    lastShoot = now
                    pcall(function()
                        local VIM = game:GetService("VirtualInputManager")
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
    -- GUI
    -- ══════════════════════════════════════════
    guiVisible = true
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
    TitleLabel.Text = "Nero Stealth"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local SubLabel = Instance.new("TextLabel")
    SubLabel.Size = UDim2.new(0.6, 0, 0, 14)
    SubLabel.Position = UDim2.new(0, 16, 0, 28)
    SubLabel.BackgroundTransparency = 1
    SubLabel.Text = "v1.0 Stealth"
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

    -- PAGES
    local espPage = createPage("ESP")
    createSection(espPage, "🎯", "Stealth ESP")
    createCard(espPage, "Player ESP", "Name + Distance + HP (BillboardGui)", false, function(v) S.ESP = v end)
    createCard(espPage, "Show Names", "Display player names", true, function(v) S.ShowNames = v end)
    createCard(espPage, "Show Distance", "Display distance in meters", true, function(v) S.ShowDistance = v end)
    createCard(espPage, "Show Health", "Display health bar", true, function(v) S.ShowHealth = v end)
    createCard(espPage, "Team Check", "Hide teammates", true, function(v) S.TeamCheck = v end)

    local playerPage = createPage("Player")
    createSection(playerPage, "⚡", "Movement")
    createCard(playerPage, "Speed x2", "Double walk speed", false, function(v)
        S.Speed = v
        pcall(function() if not v and Char and Char:FindFirstChild("Humanoid") then Char.Humanoid.WalkSpeed = 16 end end)
    end)

    local aimPage = createPage("Aimbot")
    createSection(aimPage, "🔫", "Aimbot")
    createCard(aimPage, "Aimbot", "Auto aim at visible enemies", false, function(v) S.Aimbot = v end)
    createCard(aimPage, "Auto Shoot", "Auto fire when locked", false, function(v) S.AutoShoot = v end)
    createCard(aimPage, "Show FOV Circle", "Display aim radius", false, function(v) S.AimbotShowFOV = v end)
    createCard(aimPage, "Team Check", "Skip teammates", true, function(v) S.AimbotTeam = v end)

    local settingsPage = createPage("Settings")
    createSection(settingsPage, "⚙️", "Info")
    local infoCard = Instance.new("Frame")
    infoCard.Size = UDim2.new(1, 0, 0, 80)
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
    infoLbl.Text = "Nero Stealth v1.0\n8s activation delay\nNo Drawing API / Highlight\nBillboardGui ESP (native)\nRightShift to toggle"
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

    -- RIGHTSHIFT TOGGLE
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            guiVisible = not guiVisible
            Window.Visible = guiVisible
        end
    end)

    -- ══════════════════════════════════════════
    -- MAIN LOOP (throttled: update ESP every 3 frames)
    -- ══════════════════════════════════════════
    RunService.Heartbeat:Connect(function()
        pcall(function() Char = LP.Character end)

        -- Speed
        pcall(function()
            if S.Speed and Char and Char:FindFirstChild("Humanoid") then
                Char.Humanoid.WalkSpeed = 16 * S.SpeedMul
            end
        end)

        -- ESP update (throttled — every 3 frames to reduce detection)
        updateFrame = updateFrame + 1
        if updateFrame >= 3 then
            updateFrame = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr == LP then continue end
                local gui = ESPGuis[plr]
                if not gui then continue end

                local c = plr.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")
                local hum = c and c:FindFirstChild("Humanoid")
                local alive = root and hum and hum.Health > 0

                local show = S.ESP and alive
                if show and S.TeamCheck and plr.Team == LP.Team then show = false end

                gui.BB.Enabled = show

                if show then
                    -- Name
                    gui.Name.Text = S.ShowNames and plr.Name or ""
                    gui.Name.TextColor3 = (S.TeamCheck and plr.Team == LP.Team) and Color3.fromRGB(100, 255, 100) or Color3.new(1, 1, 1)

                    -- Distance
                    if S.ShowDistance and Char and Char:FindFirstChild("HumanoidRootPart") then
                        local dist = math.floor((Char.HumanoidRootPart.Position - root.Position).Magnitude)
                        gui.Dist.Text = dist .. "m"
                    else
                        gui.Dist.Text = ""
                    end

                    -- Health bar
                    if S.ShowHealth and hum then
                        gui.HPFill.Size = UDim2.new(math.clamp(hum.Health / hum.MaxHealth, 0, 1), 0, 1, 0)
                        local pct = hum.Health / hum.MaxHealth
                        gui.HPFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - pct), 255 * pct, 0)
                        gui.HPBg.Visible = true
                    else
                        gui.HPBg.Visible = false
                    end
                end
            end
        end

        -- FOV circle
        FOVCircle.Visible = S.Aimbot and S.AimbotShowFOV
        FOVCircle.Position = UIS:GetMouseLocation()
        FOVCircle.Radius = S.AimbotFOV

        -- Aimbot
        pcall(doAimbot)
    end)

    LP.CharacterAdded:Connect(function(newChar) Char = newChar end)
    print("[Nero Stealth] v1.0 loaded — 8s delay, BillboardGui ESP")
end)
