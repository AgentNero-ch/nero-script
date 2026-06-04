-- NERO SCRIPT v2.0
-- Roblox Universal Cheat - Full GUI Control Panel
-- Compatible: Delta, Ronix, Synapse X, KRNL, Fluxus, Hydrogen, Vega, Arceus X

-- ══════════════════════════════════════════
-- COMPATIBILITY
-- ══════════════════════════════════════════
if not getexecutorname then getexecutorname = function() return "Unknown" end end

local DrawingNew = (Drawing and Drawing.new) or nil
local MouseMoveRel = mousemoverel or (Input and Input.MouseMove) or nil

-- ══════════════════════════════════════════
-- ANTI-DETECT
-- ══════════════════════════════════════════
pcall(function()
    if hookmetamethod then
        local old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if method == "FireServer" or method == "InvokeServer" then
                local name = self.Name:lower()
                if name:find("analytics") or name:find("telemetry") or name:find("log") 
                   or name:find("report") or name:find("anticheat") or name:find("detect") then
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

-- ══════════════════════════════════════════
-- SETTINGS (semua diatur dari GUI)
-- ══════════════════════════════════════════
local S = {
    ESP = false,
    ESP_Box = true,
    ESP_Name = true,
    ESP_Health = true,
    ESP_Distance = true,
    ESP_TeamCheck = true,
    ESP_Color = Color3.fromRGB(255, 50, 50),
    ESP_TeamColor = Color3.fromRGB(50, 255, 50),
    
    Speed = false,
    SpeedMul = 2,
    
    Aimbot = false,
    AimbotKey = "RMB",
    AimbotFOV = 250,
    AimbotSmooth = 3,
    AimbotBone = "Head",
    AimbotTeam = true,
    AimbotVis = true,
    AimbotShowFOV = true,
    AimbotHeld = false,
}

-- ══════════════════════════════════════════
-- COLORS
-- ══════════════════════════════════════════
local C = {
    bg = Color3.fromRGB(18, 18, 22),
    header = Color3.fromRGB(200, 40, 40),
    section = Color3.fromRGB(25, 25, 30),
    toggle_on = Color3.fromRGB(50, 180, 80),
    toggle_off = Color3.fromRGB(55, 55, 60),
    text = Color3.fromRGB(240, 240, 240),
    sub = Color3.fromRGB(160, 160, 165),
    accent = Color3.fromRGB(200, 50, 50),
    slider_bg = Color3.fromRGB(40, 40, 45),
    slider_fill = Color3.fromRGB(200, 50, 50),
    input_bg = Color3.fromRGB(35, 35, 40),
    btn = Color3.fromRGB(45, 45, 50),
    btn_hover = Color3.fromRGB(60, 60, 65),
}

-- ══════════════════════════════════════════
-- GUI BUILDER
-- ══════════════════════════════════════════
local Gui = Instance.new("ScreenGui")
Gui.Name = "NeroPanel"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    if syn and syn.protect_gui then syn.protect_gui(Gui) end
    if protect_gui then protect_gui(Gui) end
end)
Gui.Parent = game:GetService("CoreGui")

-- Main Frame
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 280, 0, 520)
Main.Position = UDim2.new(0, 20, 0.15, 0)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6014261993"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
Shadow.ZIndex = -1
Shadow.Parent = Main

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = C.header
Header.BorderSizePixel = 0
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

-- Header bottom fix
local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = C.header
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ NERO SCRIPT v2.0"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Close btn
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- Scroll Frame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -52)
Scroll.Position = UDim2.new(0, 8, 0, 46)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = C.accent
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

-- ══════════════════════════════════════════
-- WIDGET FACTORIES
-- ══════════════════════════════════════════

-- Section Header
local function Section(text, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 28)
    f.BackgroundColor3 = C.section
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -12, 1, 0)
    l.Position = UDim2.new(0, 8, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = "▎ " .. text
    l.TextColor3 = C.accent
    l.TextSize = 13
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    
    return f
end

-- Toggle
local function Toggle(text, order, default, callback)
    local state = default
    
    local f = Instance.new("TextButton")
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = C.btn
    f.BorderSizePixel = 0
    f.Text = ""
    f.LayoutOrder = order
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = f
    
    -- Toggle switch
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 40, 0, 20)
    switchBg.Position = UDim2.new(1, -50, 0.5, -10)
    switchBg.BackgroundColor3 = state and C.toggle_on or C.toggle_off
    switchBg.BorderSizePixel = 0
    switchBg.Parent = f
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)
    
    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.new(0, 16, 0, 16)
    switchCircle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    switchCircle.BackgroundColor3 = Color3.new(1, 1, 1)
    switchCircle.BorderSizePixel = 0
    switchCircle.Parent = switchBg
    Instance.new("UICorner", switchCircle).CornerRadius = UDim.new(1, 0)
    
    f.MouseButton1Click:Connect(function()
        state = not state
        switchBg.BackgroundColor3 = state and C.toggle_on or C.toggle_off
        switchCircle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        callback(state)
    end)
    
    return f
end

-- Slider
local function Slider(text, order, min, max, default, callback)
    local value = default
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundColor3 = C.btn
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 2)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = f
    
    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.3, -10, 0, 20)
    valLabel.Position = UDim2.new(0.7, 0, 0, 2)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(value)
    valLabel.TextColor3 = C.accent
    valLabel.TextSize = 13
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = f
    
    -- Slider bar
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -20, 0, 8)
    barBg.Position = UDim2.new(0, 10, 0, 32)
    barBg.BackgroundColor3 = C.slider_bg
    barBg.BorderSizePixel = 0
    barBg.Parent = f
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    
    local pct = (value - min) / (max - min)
    
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(pct, 0, 1, 0)
    barFill.BackgroundColor3 = C.slider_fill
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
    
    -- Drag logic
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
            
            callback(value)
        end
    end)
    
    return f
end

-- Dropdown
local function Dropdown(text, order, options, default, callback)
    local selected = default
    local isOpen = false
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = C.btn
    f.BorderSizePixel = 0
    f.LayoutOrder = order
    f.ClipsDescendants = true
    f.Parent = Scroll
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 34)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = C.text
    label.TextSize = 13
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -14, 0, 26)
    btn.Position = UDim2.new(0.5, 2, 0, 4)
    btn.BackgroundColor3 = C.input_bg
    btn.Text = "  " .. selected .. " ▾"
    btn.TextColor3 = C.accent
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local optY = 36
    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, -16, 0, 26)
        optBtn.Position = UDim2.new(0, 8, 0, optY)
        optBtn.BackgroundColor3 = opt == selected and C.accent or C.input_bg
        optBtn.Text = "  " .. opt
        optBtn.TextColor3 = Color3.new(1, 1, 1)
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextXAlignment = Enum.TextXAlignment.Left
        optBtn.Parent = f
        Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)
        
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            btn.Text = "  " .. selected .. " ▾"
            for _, child in ipairs(f:GetChildren()) do
                if child:IsA("TextButton") and child ~= btn then
                    child.BackgroundColor3 = child.Text:sub(3) == selected and C.accent or C.input_bg
                end
            end
            isOpen = false
            f.Size = UDim2.new(1, 0, 0, 34)
            callback(selected)
        end)
        
        optY = optY + 30
    end
    
    btn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        f.Size = isOpen and UDim2.new(1, 0, 0, 34 + #options * 30) or UDim2.new(1, 0, 0, 34)
        btn.Text = isOpen and "  " .. selected .. " ▴" or "  " .. selected .. " ▾"
    end)
    
    return f
end

-- ══════════════════════════════════════════
-- BUILD GUI PANEL
-- ══════════════════════════════════════════

-- ── ESP SECTION ──
Section("👁 ESP", 1)

Toggle("ESP Master", 2, false, function(v)
    S.ESP = v
    if not v then
        for _, esp in pairs(ESP_Objects or {}) do
            pcall(function()
                if esp.UseDrawing then
                    for k, obj in pairs(esp) do
                        if type(obj) ~= "boolean" then pcall(function() obj.Visible = false end) end
                    end
                else
                    esp.Billboard.Enabled = false
                end
            end)
        end
    end
end)

Toggle("Box", 3, true, function(v) S.ESP_Box = v end)
Toggle("Name", 4, true, function(v) S.ESP_Name = v end)
Toggle("Health Bar", 5, true, function(v) S.ESP_Health = v end)
Toggle("Distance", 6, true, function(v) S.ESP_Distance = v end)
Toggle("Team Check", 7, true, function(v) S.ESP_TeamCheck = v end)

-- ── SPEED SECTION ──
Section("🏃 Speed", 8)

Toggle("Speed Hack", 9, false, function(v)
    S.Speed = v
end)

Slider("Speed Multiplier", 10, 1, 10, 2, function(v)
    S.SpeedMul = v
end)

-- ── AIMBOT SECTION ──
Section("🎯 Aimbot", 11)

Toggle("Aimbot Master", 12, false, function(v)
    S.Aimbot = v
end)

Toggle("Team Check", 13, true, function(v) S.AimbotTeam = v end)
Toggle("Visibility Check", 14, true, function(v) S.AimbotVis = v end)
Toggle("Show FOV Circle", 15, true, function(v) S.AimbotShowFOV = v end)

Slider("FOV Radius", 16, 50, 800, 250, function(v)
    S.AimbotFOV = v
end)

Slider("Smoothness", 17, 1, 10, 3, function(v)
    S.AimbotSmooth = v
end)

Dropdown("Aim Bone", 18, {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(v)
    S.AimbotBone = v
end)

Dropdown("Aim Key", 19, {"RMB", "LMB", "LShift", "LAlt", "E", "Q"}, "RMB", function(v)
    S.AimbotKey = v
end)

-- ══════════════════════════════════════════
-- ESP SYSTEM
-- ══════════════════════════════════════════
ESP_Objects = {}

local function createESP(player)
    if player == LP then return end
    local esp = {}
    
    if DrawingNew then
        esp.BoxOutline = DrawingNew("Square"); esp.BoxOutline.Visible = false; esp.BoxOutline.Color = Color3.new(0,0,0); esp.BoxOutline.Thickness = 3; esp.BoxOutline.Filled = false
        esp.Box = DrawingNew("Square"); esp.Box.Visible = false; esp.Box.Color = S.ESP_Color; esp.Box.Thickness = 1; esp.Box.Filled = false
        esp.Name = DrawingNew("Text"); esp.Name.Visible = false; esp.Name.Color = Color3.new(1,1,1); esp.Name.Size = 14; esp.Name.Center = true; esp.Name.Outline = true
        esp.HPOutline = DrawingNew("Line"); esp.HPOutline.Visible = false; esp.HPOutline.Color = Color3.new(0,0,0); esp.HPOutline.Thickness = 4
        esp.HP = DrawingNew("Line"); esp.HP.Visible = false; esp.HP.Color = Color3.fromRGB(0,255,0); esp.HP.Thickness = 2
        esp.Dist = DrawingNew("Text"); esp.Dist.Visible = false; esp.Dist.Color = Color3.fromRGB(200,200,200); esp.Dist.Size = 12; esp.Dist.Center = true; esp.Dist.Outline = true
        esp.UseDrawing = true
    else
        local bb = Instance.new("BillboardGui"); bb.Name = "NeroESP"; bb.Size = UDim2.new(4,0,6,0); bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.MaxDistance = 500
        local fr = Instance.new("Frame"); fr.Size = UDim2.new(1,0,1,0); fr.BackgroundTransparency = 1; fr.BorderSizePixel = 2; fr.BorderColor3 = S.ESP_Color; fr.Parent = bb
        local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1,0,0,16); nl.Position = UDim2.new(0,0,0,-18); nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.new(1,1,1); nl.TextStrokeTransparency = 0; nl.TextSize = 14; nl.Font = Enum.Font.GothamBold; nl.Parent = fr
        local dl = Instance.new("TextLabel"); dl.Size = UDim2.new(1,0,0,14); dl.Position = UDim2.new(0,0,1,2); dl.BackgroundTransparency = 1; dl.TextColor3 = Color3.fromRGB(200,200,200); dl.TextStrokeTransparency = 0; dl.TextSize = 12; dl.Font = Enum.Font.Gotham; dl.Parent = fr
        local hb = Instance.new("Frame"); hb.Size = UDim2.new(0.05,0,1,0); hb.Position = UDim2.new(0,-6,0,0); hb.BackgroundColor3 = Color3.fromRGB(0,255,0); hb.BorderSizePixel = 0; hb.Parent = fr
        esp.Billboard = bb; esp.Frame = fr; esp.NameLabel = nl; esp.DistLabel = dl; esp.HPBar = hb; esp.UseDrawing = false
    end
    
    ESP_Objects[player] = esp
end

local function removeESP(player)
    local esp = ESP_Objects[player]
    if esp then
        if esp.UseDrawing then
            for _, obj in pairs(esp) do if type(obj) ~= "boolean" then pcall(function() obj:Remove() end) end end
        else
            pcall(function() esp.Billboard:Destroy() end)
        end
        ESP_Objects[player] = nil
    end
end

local function updateESP()
    for player, esp in pairs(ESP_Objects) do
        local hide = function()
            if esp.UseDrawing then
                for _, obj in pairs(esp) do if type(obj) ~= "boolean" then pcall(function() obj.Visible = false end) end end
            else pcall(function() esp.Billboard.Enabled = false end) end
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
                local bh2 = bh*hp
                esp.HPOutline.From = Vector2.new(bx-5,by); esp.HPOutline.To = Vector2.new(bx-5,by+bh); esp.HPOutline.Visible = true
                esp.HP.From = Vector2.new(bx-5,by+bh-bh2); esp.HP.To = Vector2.new(bx-5,by+bh); esp.HP.Color = Color3.fromRGB(255*(1-hp),255*hp,0); esp.HP.Visible = true
            else esp.HPOutline.Visible = false; esp.HP.Visible = false end
            
            if S.ESP_Distance then
                local mr = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if mr then esp.Dist.Text = string.format("[%dm]", math.floor((mr.Position-root.Position).Magnitude)); esp.Dist.Position = Vector2.new(pos.X,by+bh+4); esp.Dist.Visible = true end
            else esp.Dist.Visible = false end
        else
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
-- SPEED HACK
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
if DrawingNew then
    FOVCircle = DrawingNew("Circle")
    FOVCircle.Visible = false; FOVCircle.Radius = S.AimbotFOV; FOVCircle.Color = Color3.fromRGB(255,255,255)
    FOVCircle.Thickness = 1; FOVCircle.Filled = false; FOVCircle.NumSides = 64; FOVCircle.Transparency = 0.7
end

local KeyMap = {
    RMB = Enum.UserInputType.MouseButton2,
    LMB = Enum.UserInputType.MouseButton1,
    LShift = Enum.KeyCode.LeftShift,
    LAlt = Enum.KeyCode.LeftAlt,
    E = Enum.KeyCode.E,
    Q = Enum.KeyCode.Q,
}

local function getAimKey()
    return KeyMap[S.AimbotKey] or Enum.UserInputType.MouseButton2
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
    if not MouseMoveRel then return end
    local bp = target.Character:FindFirstChild(S.AimbotBone)
    if not bp then return end
    local sp = Camera:WorldToViewportPoint(bp.Position)
    local sc = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local d = (Vector2.new(sp.X,sp.Y) - sc) / S.AimbotSmooth
    MouseMoveRel(d.X, d.Y)
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

-- ══════════════════════════════════════════
-- INPUT
-- ══════════════════════════════════════════
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == getAimKey() or input.KeyCode == getAimKey() then
        S.AimbotHeld = true
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == getAimKey() or input.KeyCode == getAimKey() then
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

-- Close button
CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
    -- Cleanup ESP
    for _, esp in pairs(ESP_Objects) do
        pcall(function()
            if esp.UseDrawing then
                for _, obj in pairs(esp) do if type(obj) ~= "boolean" then pcall(function() obj:Remove() end) end end
            else esp.Billboard:Destroy() end
        end)
    end
    if FOVCircle then pcall(function() FOVCircle:Remove() end) end
end)

print("═══════════════════════════════════════")
print("  ⚡ NERO SCRIPT v2.0 LOADED")
print("  Executor: " .. getexecutorname())
print("  RightShift = Toggle Panel")
print("═══════════════════════════════════════")
