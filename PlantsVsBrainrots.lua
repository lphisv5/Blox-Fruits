local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/gumanba/UI-Libraries/main/Gumanba-UI-Library-V1.lua"))()
local main = library:AddWindow("PvB Advanced GUI", "Community Script", Enum.KeyCode.RightShift)

-- // Services and Game Variables //
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage.Remotes
local Tycoon = Workspace.Tycoon

-- // Main Automation Tab //
local mainTab = main:AddTab("Automation")

mainTab:AddToggle("Kill Aura", false, function(bool)
    _G.KillAura = bool
end)

mainTab:AddToggle("Auto Collect Cash", false, function(bool)
    _G.AutoCollect = bool
end)

mainTab:AddToggle("Auto Equip Best Brainrots", false, function(bool)
    _G.AutoEquipBest = bool
end)

mainTab:AddToggle("Auto Buy Gears", false, function(bool)
    _G.AutoBuyGears = bool
end)

-- // Player Modifications Tab //
local playerTab = main:AddTab("Player")

playerTab:AddSlider("WalkSpeed", 16, 16, 200, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
end)

playerTab:AddSlider("JumpPower", 50, 50, 300, function(val)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = val
    end
end)

-- // Core Logic Loops //

-- Kill Aura
spawn(function()
    while true do
        if _G.KillAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, brainrot in pairs(Workspace.Brainrots:GetChildren()) do
                if brainrot:FindFirstChild("Humanoid") and brainrot.Humanoid.Health > 0 then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - brainrot.HumanoidRootPart.Position).Magnitude
                    if distance < 50 then -- Attack range
                        pcall(function()
                            Remotes.Damage:FireServer(brainrot, "Basic")
                        end)
                    end
                end
            end
        end
        task.wait(0.1) -- ใช้ task.wait แทน wait สำหรับความเสถียร
    end
end)

-- Auto Collect Cash
spawn(function()
    while true do
        if _G.AutoCollect then
            for _, cashPart in pairs(Tycoon.Cash:GetChildren()) do
                if cashPart:IsA("Part") then
                    pcall(function()
                        cashPart:Destroy()
                    end)
                end
            end
        end
        task.wait(0.5)
    end
end)

-- Auto Equip Best Brainrots
spawn(function()
    while true do
        if _G.AutoEquipBest then
            pcall(function()
                Remotes.EquipBest:FireServer()
            end)
        end
        task.wait(5) -- Runs every 5 seconds to avoid spamming the server
    end
end)

-- Auto Buy Gears
spawn(function()
    while true do
        if _G.AutoBuyGears then
            pcall(function()
                for _, gear in pairs(Workspace.Shop.Gears:GetChildren()) do
                    if gear:IsA("TextButton") and gear:FindFirstChild("Price") then
                        if gear.Price.Value <= LocalPlayer.leaderstats.Cash.Value then
                            Remotes.BuyGear:FireServer(gear.Name)
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

-- // Additional Safety Features //
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if LocalPlayer.Character.Humanoid.WalkSpeed < 16 then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
        if LocalPlayer.Character.Humanoid.JumpPower < 50 then
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
end)
