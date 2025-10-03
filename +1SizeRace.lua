local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "YANZ HUB",
    SubTitle = "Game : +1 Size Race",
    TabWidth = 160,
    Size = UDim2.fromOffset(520, 400),
    Acrylic = true,
    Theme = "Dark",
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main" }),
    Player = Window:AddTab({ Title = "Player" }),
    Settings = Window:AddTab({ Title = "Settings" }),
}

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("SizeRaceExecutor")
SaveManager:SetFolder("SizeRaceExecutor/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)

Fluent:Notify({ Title = "Executor Loaded", Content = "GUI for +1 Size Race Ready!", Duration = 5 })

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local function HRP()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

-- ===========================
-- Variables
-- ===========================
-- Auto Farm
local autoFarm = false
local farmPoints = {
    Vector3.new(-13.23, 55.95, 37.52),
    Vector3.new(-25.43, 44.25, -9542.87),
}
local farmIndex = 1
local tweenDuration = 2
local moving = false

local speedHack = false
local speedValue = 5

-- ===========================
-- Main Tab Features
-- ===========================

-- Auto Farm Toggle
local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm Size",
    Default = false,
})
FarmToggle:OnChanged(function(state)
    autoFarm = state
    if autoFarm then
        local char = LocalPlayer.Character
        if char and HRP() then
            if not char:FindFirstChild("FarmBox") then
                local box = Instance.new("Part")
                box.Name = "FarmBox"
                box.Size = Vector3.new(6, 1, 6)
                box.Anchored = true
                box.CanCollide = true
                box.Transparency = 0.5
                box.Color = Color3.fromRGB(0, 200, 255)
                box.Parent = char
            end
        end
    end
end)

-- Auto Speed Button
Tabs.Main:AddButton({
    Title = "Auto Farm Speed",
    Description = "Teleport to the Speed Machine",
    Callback = function()
        if HRP() then
            HRP().CFrame = CFrame.new(-76.65, 15.26, -21.41) -- จุดเครื่อง Speed
        end
    end,
})

-- ===========================
-- Player Tab Features
-- ===========================

-- Anti AFK
Tabs.Player:AddButton({
    Title = "Anti-AFK",
    Description = "Prevent being kicked out of the game",
    Callback = function()
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        Fluent:Notify({ Title = "Anti-AFK", Content = "successfully", Duration = 3 })
    end,
})

-- Speed Hack Toggle
local SpeedToggle = Tabs.Player:AddToggle("SpeedHack", {
    Title = "CFrame Speed Hack",
    Default = false,
})
SpeedToggle:OnChanged(function(state)
    speedHack = state
end)

-- ===========================
-- Functions
-- ===========================

-- Smooth Tween Movement
local function TweenToPosition(targetPos)
    if not HRP() then return end
    moving = true
    local tweenInfo = TweenInfo.new(
        tweenDuration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut
    )
    local tweenGoal = {CFrame = CFrame.new(targetPos + Vector3.new(0,5,0))} -- ลอยตัว +5
    local tween = TweenService:Create(HRP(), tweenInfo, tweenGoal)
    
    tween:Play()
    tween.Completed:Wait()
    moving = false
end

-- ===========================
-- Loops
-- ===========================

-- Auto Farm Smooth Loop
task.spawn(function()
    while RunService.RenderStepped:Wait() do
        if autoFarm and HRP() and not moving then
            local target = farmPoints[farmIndex]
            TweenToPosition(target)

            -- Box ตามตัว
            local box = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FarmBox")
            if box then
                box.CFrame = HRP().CFrame * CFrame.new(0, -4, 0)
            end

            -- สลับพิกัด
            farmIndex = farmIndex == 1 and 2 or 1
        end
    end
end)

-- Speed Hack Loop
task.spawn(function()
    while RunService.RenderStepped:Wait() do
        if speedHack and HRP() then
            HRP().CFrame = HRP().CFrame * CFrame.new(0, 0, -speedValue)
        end
    end
end)

-- ===========================
-- Keybind: เปิด/ปิด Speed Hack (ตัวอย่าง P)
-- ===========================
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.P then
        speedHack = not speedHack
        SpeedToggle:SetValue(speedHack)
        Fluent:Notify({ Title = "Speed Hack", Content = speedHack and "Enabled" or "Disabled", Duration = 2 })
    end
end)
