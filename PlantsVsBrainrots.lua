local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/refs/heads/main/source.lua"))()

-- สร้างหน้าต่างหลัก
local main = library.new({
    Title = "PvB Advanced GUI",
    Description = "Plants vs Brainrots Script",
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
local automationTab = main:CreateTab("Automation")

-- Kill Aura
automationTab:NewToggle({
    Title = "Kill Aura",
    Default = false,
    Callback = function(bool)
        _G.KillAura = bool
    end
})

-- Auto Collect Cash
automationTab:NewToggle({
    Title = "Auto Collect Cash",
    Default = false,
    Callback = function(bool)
        _G.AutoCollect = bool
    end
})

-- Auto Equip Best Brainrots
automationTab:NewToggle({
    Title = "Auto Equip Best Brainrots",
    Default = false,
    Callback = function(bool)
        _G.AutoEquipBest = bool
    end
})

-- Auto Buy Gears
automationTab:NewToggle({
    Title = "Auto Buy Gears",
    Default = false,
    Callback = function(bool)
        _G.AutoBuyGears = bool
    end
})

-- // Player Modifications Tab //
local playerTab = main:CreateTab("Player")

-- WalkSpeed Slider
playerTab:NewSlider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

-- JumpPower Slider
playerTab:NewSlider({
    Title = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(val)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = val
        end
    end
})

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
