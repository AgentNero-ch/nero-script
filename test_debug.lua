-- NERO SCRIPT v7.3 — Debug version
-- Paste di executor, cek CONSOLE untuk output

print("[Nero] Step 1: Script loaded")

local ok1, err1 = pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    print("[Nero] Step 2: Game loaded")
end)
if not ok1 then warn("[Nero] Step 2 FAILED: " .. tostring(err1)) return end

local ok2, err2 = pcall(function()
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
    print("[Nero] Step 3: Player found: " .. LP.Name)
end)
if not ok2 then warn("[Nero] Step 3 FAILED: " .. tostring(err2)) return end

local ok3, err3 = pcall(function()
    print("[Nero] Step 4: Waiting for character...")
    local LP = game:GetService("Players").LocalPlayer
    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") do
        task.wait(0.1)
    end
    print("[Nero] Step 5: Character ready")
end)
if not ok3 then warn("[Nero] Step 4-5 FAILED: " .. tostring(err3)) return end

local ok4, err4 = pcall(function()
    print("[Nero] Step 6: Loading Rayfield...")
    local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/sirius-menu/rayfield/main/source.lua'))()
    print("[Nero] Step 7: Rayfield loaded: " .. tostring(Rayfield))
end)
if not ok4 then warn("[Nero] Step 6-7 FAILED: " .. tostring(err4)) return end

print("[Nero] All steps passed!")
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Nero Script",
    Text = "Debug passed! Check console.",
    Duration = 5
})
