-- NERO SCRIPT v2.1
-- Ronix/Studios Compatible - Full Error Handling
-- Execute di Ronix Studios, GUI muncul di layar

-- Debug mode
local DEBUG = true
local function log(msg)
    if DEBUG then warn("[Nero] " .. msg) end
end

log("Starting Nero Script v2.1...")

-- ══════════════════════════════════════════
-- SAFE SERVICES
-- ══════════════════════════════════════════
local success, err = pcall(function()
    Players = game:GetService("Players")
    RunService = game:GetService("RunService")
    UIS = game:GetService("UserInputService")
    Camera = workspace.CurrentCamera
    LP = Players.LocalPlayer
end)

if not success then
    warn("[Nero] Failed to get services: " .. tostring(err))
    return
end

log("Services loaded OK")

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
-- ESP OBJECTS
-- ══════════════════════════════════════════
ESP_Objects = {}

-- Check Drawing support
local hasDrawing = false
pcall(function()
    if Drawing and Drawing.new then
        hasDrawing = true
        log("Drawing API: Supported")
    end
end)

if not hasDrawing then
    log("Drawing API: NOT supported, using BillboardGui fallback")
end

-- Check mousemoverel
local hasMouse = false
pcall(function()
    if mousemoverel then hasMouse = true end
end)
log("mousemoverel: " .. tostring(hasDrawing))

-- ══════════════════════════════════════════
-- GUI - SIMPLE & SAFE
-- ══════════════════════════════════════════
local function CreateGUI()
    log("Creating GUI...")
    
    -- Try CoreGui first, fallback to PlayerGui
    local parent
    local ok1, err1 = pcall(function()
        parent = game:GetService("CoreGui")
    end)
    
    if not ok1 or not parent then
        log("CoreGui failed, trying PlayerGui...")
        local ok2, err2 = pcall(function()
            parent = LP:WaitForChild("PlayerGui")
        end)
        if not ok2 then
            warn("[Nero] Cannot access any GUI parent: " .. tostring(err2))
            return nil
        end
    end
    
    log("GUI parent: " .. parent:GetFullName())
    
    -- ScreenGui
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "NeroPanel"
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Protect if possible
    pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(Gui) end
        if protect_gui then protect_gui(Gui) end
    end)
    
    Gui.Parent = parent
    log("ScreenGui created and parented")
    
    -- MAIN FRAME
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 260, 0, 400)
    Main.Position = UDim2.new(0, 20, 0.2, 0)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.Draggable = true
    Main.Parent = Gui
    
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 10)
    mc.Parent = Main
    
    log("Main frame created")
    
    -- HEADER
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    Header.BorderSizePixel = 0
    Header.Parent = Main
    
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 10)
    hc.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "NERO SCRIPT v2.1"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.TextSize = 15
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Header
    
    -- Close
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 26, 0, 26)
    CloseBtn.Position = UDim2.new(1, -32, 0, 6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(160, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Header
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
    
    log("Header created")
    
    -- CONTENT FRAME (scrollable)
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -12, 1, -46)
    Content.Position = UDim2.new(0, 6, 0, 42)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 4
    Content.ScrollBarImageColor3 = Color3.fromRGB(200, 50, 50)
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.Parent = Main
    
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 4)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Content
    
    log("Content frame created")
    
    -- ══════════════════════════════════════════
    -- WIDGET HELPERS
    -- ══════════════════════════════════════════
    local order = 0
    
    local function Section(text)
        order = order + 1
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 26)
        f.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        f.Parent = Content
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -8, 1, 0)
        l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(200, 50, 50)
        l.TextSize = 13
        l.Font = Enum.Font.GothamBold
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = f
        
        return f
    end
    
    local function Toggle(text, default, callback)
        order = order + 1
        local state = default
        
        local f = Instance.new("TextButton")
        f.Size = UDim2.new(1, 0, 0, 32)
        f.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        f.BorderSizePixel = 0
        f.Text = ""
        f.LayoutOrder = order
        f.Parent = Content
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -55, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.TextSize = 12
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f
        
        -- Toggle pill
        local pill = Instance.new("Frame")
        pill.Size = UDim2.new(0, 36, 0, 18)
        pill.Position = UDim2.new(1, -44, 0.5, -9)
        pill.BackgroundColor3 = state and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(50, 50, 55)
        pill.BorderSizePixel = 0
        pill.Parent = f
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        dot.BackgroundColor3 = Color3.new(1, 1, 1)
        dot.BorderSizePixel = 0
        dot.Parent = pill
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        
        f.MouseButton1Click:Connect(function()
            state = not state
            pill.BackgroundColor3 = state and Color3.fromRGB(50, 180, 80) or Color3.fromRGB(50, 50, 55)
            dot.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            pcall(function() callback(state) end)
        end)
        
        return f
    end
    
    local function Slider(text, min, max, default, callback)
        order = order + 1
        local value = default
        
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 46)
        f.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        f.Parent = Content
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(230, 230, 230)
        label.TextSize = 12
        label.Font = Enum.Font.GothamSemibold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f
        
        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0.35, -10, 0, 20)
        valLabel.Position = UDim2.new(0.65, 0, 0, 2)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(value)
        valLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
        valLabel.TextSize = 13
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = f
        
        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(1, -20, 0, 8)
        barBg.Position = UDim2.new(0, 10, 0, 30)
        barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        barBg.BorderSizePixel = 0
        barBg.Parent = f
        Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
        
        local pct = (value - min) / (max - min)
        
        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(pct, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        barFill.BorderSizePixel = 0
        barFill.Parent = barBg
        Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(pct, -7, 0.5, -7)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.BorderSizePixel = 0
        knob.ZIndex = 2
        knob.Parent = barBg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        
        barBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        
        UIS.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local barPos = barBg.AbsolutePosition
                local barSize = barBg.AbsoluteSize
                local mouseX = input.Position.X
                local newPct = math.clamp((mouseX - barPos.X) / barSize.X, 0, 1)
                value = math.floor(min + (max - min) * newPct)
                barFill.Size = UDim2.new(newPct, 0, 1, 0)
                knob.Position = UDim2.new(newPct, -7, 0.5, -7)
                valLabel.Text = tostring(value)
                pcall(function() callback(value) end)
            end
        end)
        
        return f
    end
    
    local function Label(text, order_override)
        order = order + 1
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 20)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(140, 140, 145)
        l.TextSize = 10
        l.Font = Enum.Font.Gotham
        l.LayoutOrder = order_override or order
        l.Parent = Content
        return l
    end
    
    log("Widget helpers created")
    
    -- ══════════════════════════════════════════
    -- BUILD PANEL
    -- ══════════════════════════════════════════
    
    -- ESP
    Section("ESP")
    Toggle("ESP Master", false, function(v) S.ESP = v end)
    Toggle("Box", true, function(v) S.ESP_Box = v end)
    Toggle("Name", true, function(v) S.ESP_Name = v end)
    Toggle("Health Bar", true, function(v) S.ESP_Health = v end)
    Toggle("Distance", true, function(v) S.ESP_Distance = v end)
    Toggle("Team Check", true, function(v) S.ESP_TeamCheck = v end)
    
    -- Speed
    Section("SPEED")
    Toggle("Speed Hack", false, function(v) S.Speed = v end)
    Slider("Multiplier", 1, 10, 2, function(v) S.SpeedMul = v end)
    
    -- Aimbot
    Section("AIMBOT")
    Toggle("Aimbot Master", false, function(v) S.Aimbot = v end)
    Toggle("Team Check", true, function(v) S.AimbotTeam = v end)
    Toggle("Visibility Check", true, function(v) S.AimbotVis = v end)
    Toggle("Show FOV Circle", true, function(v) S.AimbotShowFOV = v end)
    Slider("FOV Radius", 50, 800, 250, function(v) S.AimbotFOV = v end)
    Slider("Smoothness", 1, 10, 3, function(v) S.AimbotSmooth = v end)
    
    Label("RMB = Aimbot Lock | RightShift = Hide Panel")
    
    log("Panel built OK")
    
    -- ══════════════════════════════════════════
    -- CLOSE BUTTON
    -- ══════════════════════════════════════════
    CloseBtn.MouseButton1Click:Connect(function()
        log("Closing script...")
        Gui:Destroy()
        for _, esp in pairs(ESP_Objects) do
            pcall(function()
                if esp.UseDrawing then
                    for _, obj in pairs(esp) do
                        if type(obj) ~= "boolean" then pcall(function() obj:Remove() end) end
                    end
                else
                    esp.Billboard:Destroy()
                end
            end)
        end
        if FOVCircle then pcall(function() FOVCircle:Remove() end) end
    end)
    
    -- RightShift toggle
    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            Main.Visible = not Main.Visible
        end
    end)
    
    return Gui
end

-- ══════════════════════════════════════════
-- ESP SYSTEM
-- ══════════════════════════════════════════
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
            else
                esp.Billboard:Destroy()
            end
        end)
        ESP_Objects[player] = nil
    end
end

local function updateESP()
    for player, esp in pairs(ESP_Objects) do
        local hide = function()
            if esp.UseDrawing then
                for _, obj in pairs(esp) do if type(obj) ~= "boolean" then pcall(function() obj.Visible = false end) end end
            elseif esp.Billboard then
                pcall(function() esp.Billboard.Enabled = false end)
            end
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
log("Starting main loops...")

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

-- ══════════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════════
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == S.AimbotKey then
        S.AimbotHeld = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == S.AimbotKey then
        S.AimbotHeld = false
    end
end)

-- ══════════════════════════════════════════
-- PLAYER TRACKING
-- ══════════════════════════════════════════
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(function(p) createESP(p) end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)
LP.CharacterAdded:Connect(function() task.wait(1) updateSpeed() end)

-- ══════════════════════════════════════════
-- CREATE GUI (LAST - after all functions defined)
-- ══════════════════════════════════════════
local guiOk, guiErr = pcall(CreateGUI)

if guiOk then
    log("GUI created successfully!")
else
    warn("[Nero] GUI creation failed: " .. tostring(guiErr))
end

print("═══════════════════════════════════════")
print("  NERO SCRIPT v2.1 LOADED")
print("  RightShift = Toggle Panel")
print("  RMB = Aimbot Lock")
print("═══════════════════════════════════════")
