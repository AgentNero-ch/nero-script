-- TEST 1: Paling sederhana - cek Ronix bisa execute
-- Kalau ini gak jalan, berarti masalah di executor

local p = game:GetService("Players").LocalPlayer
local g = Instance.new("ScreenGui")
g.Name = "NeroTest"
g.ResetOnSpawn = false
g.Parent = p:WaitForChild("PlayerGui")

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 300, 0, 150)
f.Position = UDim2.new(0.5, -150, 0.5, -75)
f.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
f.BorderSizePixel = 0
f.Parent = g
Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

local t = Instance.new("TextLabel")
t.Size = UDim2.new(1, 0, 0.5, 0)
t.BackgroundTransparency = 1
t.Text = "NERO SCRIPT TEST"
t.TextColor3 = Color3.new(1, 1, 1)
t.TextSize = 24
t.Font = Enum.Font.GothamBold
t.Parent = f

local s = Instance.new("TextLabel")
s.Size = UDim2.new(1, 0, 0.5, 0)
s.Position = UDim2.new(0, 0, 0.5, 0)
s.BackgroundTransparency = 1
s.Text = "Kalau lo liat ini, Ronix works!"
s.TextColor3 = Color3.fromRGB(220, 220, 220)
s.TextSize = 14
s.Font = Enum.Font.Gotham
s.Parent = f
