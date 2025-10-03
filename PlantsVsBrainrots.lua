local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()

-- สร้างหน้าต่างหลัก
local Window = Library:CreateWindow({
    Title = "YANZ HUB | V1.2.0",
    Description = "By lphisv5 | Game : Plants vs Brainrots",
    Keybind = Enum.KeyCode.RightShift,
    Size = UDim2.new(0.15, 500, 0.25, 400)
})

-- // Services and Game Variables //
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage.Remotes
local Tycoon = Workspace.Tycoon

-- // Main Automation Tab //
local automationTab = Window:AddTab({Title = "Automation"})

-- Kill Aura
automationTab:AddToggle({
    Title = "Kill Aura",
    Default = false,
    Callback = function(bool)
        _G.KillAura = bool
    end
})

-- Auto Collect Cash
automationTab:AddToggle({
    Title = "Auto Collect Cash",
    Default = false,
    Callback = function(bool)
        _G.AutoCollect = bool
    end
})

-- Auto Equip Best Brainrots
automationTab:AddToggle({
    Title = "Auto Equip Best Brainrots",
    Default = false,
    Callback = function(bool)
        _G.AutoEquipBest = bool
    end
})

-- Auto Buy Gears
automationTab:AddToggle({
    Title = "Auto Buy Gears",
    Default = false,
    Callback = function(bool)
        _G.AutoBuyGears = bool
    end
})

-- // Player Modifications Tab //
local playerTab = Window:AddTab({Title = "Player"})

-- WalkSpeed Slider
local WalkSpeedValue = 16
playerTab:AddSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(val)
        WalkSpeedValue = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

-- JumpPower Slider
local JumpPowerValue = 50
playerTab:AddSlider({
    Title = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(val)
        JumpPowerValue = val
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end
})

-- Function to apply properties
local function applyProperties()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
        LocalPlayer.Character.Humanoid.JumpPower = JumpPowerValue
    end
end

-- Apply on character added
LocalPlayer.CharacterAdded:Connect(applyProperties)
if LocalPlayer.Character then
    applyProperties()
end

-- // Core Logic Loops //

-- Kill Aura
task.spawn(function()
    while true do
        if _G.KillAura and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, brainrot in pairs(Workspace.Brainrots:GetChildren()) do
                if brainrot:FindFirstChild("Humanoid") and brainrot.Humanoid.Health > 0 and brainrot:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - brainrot.HumanoidRootPart.Position).Magnitude
                    if distance < 50 then -- Attack range
                        pcall(function()
                            Remotes.Damage:FireServer(brainrot, "Basic")
                        end)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

-- Auto Collect Cash
task.spawn(function()
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
task.spawn(function()
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
task.spawn(function()
    while true do
        if _G.AutoBuyGears then
            pcall(function()
                -- Assuming Shop is in Workspace, adjust if needed (e.g., to PlayerGui)
                for _, gear in pairs(Workspace.Shop.Gears:GetChildren()) do
                    if gear:IsA("TextButton") and gear:FindFirstChild("Price") then
                        local playerCash = LocalPlayer.leaderstats.Cash.Value
                        if gear.Price.Value <= playerCash then
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
        if LocalPlayer.Character.Humanoid.WalkSpeed < WalkSpeedValue then
            LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
        end
        if LocalPlayer.Character.Humanoid.JumpPower < JumpPowerValue then
            LocalPlayer.Character.Humanoid.JumpPower = JumpPowerValue
        end
    end
end)
