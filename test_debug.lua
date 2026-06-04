-- DEBUG v2 — semua output via notification

local function N(t, msg)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = t,
            Text = tostring(msg),
            Duration = 8
        })
    end)
end

N("Step 1", "Script loaded OK")

local ok2, err2 = pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
end)
N("Step 2", ok2 and "Game loaded OK" or "FAIL: " .. tostring(err2))
if not ok2 then return end

local ok3, err3 = pcall(function()
    return game:GetService("Players").LocalPlayer.Name
end)
N("Step 3", ok3 and "Player: " .. tostring(err3) or "FAIL: " .. tostring(err3))
if not ok3 then return end

local ok4, err4 = pcall(function()
    local LP = game:GetService("Players").LocalPlayer
    local i = 0
    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") do
        task.wait(0.5)
        i = i + 1
        if i > 20 then error("Character wait timeout (10s)") end
    end
end)
N("Step 4", ok4 and "Character OK" or "FAIL: " .. tostring(err4))
if not ok4 then return end

N("Step 5", "Loading Rayfield...")

local ok5, err5 = pcall(function()
    local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/sirius-menu/rayfield/main/source.lua'))()
    N("Step 5a", "Rayfield type: " .. typeof(Rayfield))
    
    local Window = Rayfield:CreateWindow({
        Name = "Nero Script",
        LoadingTitle = "Nero Script",
        LoadingSubtitle = "v7.3",
        ConfigurationSaving = { Enabled = false },
        Discord = { Enabled = false },
        KeySystem = false,
    })
    N("Step 5b", "Window type: " .. typeof(Window))
    
    local Tab = Window:CreateTab("Test", 4483362458)
    N("Step 5c", "Tab type: " .. typeof(Tab))
    
    Tab:CreateToggle({
        Name = "Test Toggle",
        CurrentValue = false,
        Flag = "Test",
        Callback = function(v)
            N("Toggle", "Value: " .. tostring(v))
        end,
    })
    
    Rayfield:Notify({Title = "Success", Content = "Rayfield UI loaded!", Duration = 5})
end)

if not ok5 then
    N("Step 5 FAILED", tostring(err5))
end
