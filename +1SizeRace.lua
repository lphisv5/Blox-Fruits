-- โหลด GUI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "YANZ HUB",
    SubTitle = "Game : +1 Size Race",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 400),
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

-- ===========================
-- Services & Utils
-- ===========================
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
local moving = false

-- Speed Hack
local speedHack = false
local speedValue = 5

-- Auto Win
local autoWin = false
local winStart = Vector3.new(2.24, 21.02, -223.43)
local winGoal  = Vector3.new(1.00, 17.59, -9402.92)
local winSpeed = 500
local winActive = false

-- ===========================
-- Main Tab Features
-- ===========================
-- Auto Farm Toggle
local FarmToggle = Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
})
FarmToggle:OnChanged(function(state)
    autoFarm = state
    if autoFarm then
        farmIndex = 1 -- เริ่มจากจุดใกล้สุด
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
    else
        moving = false -- หยุดทันที
    end
end)

-- Auto Win Toggle
local AutoWinToggle = Tabs.Main:AddToggle("AutoWin", {
    Title = "Auto Win",
    Default = false,
})
AutoWinToggle:OnChanged(function(state)
    autoWin = state
    if autoWin then
        winActive = true
    else
        winActive = false -- หยุดทันที
    end
    Fluent:Notify({
        Title = "Auto Win",
        Content = autoWin and "Enabled" or "Disabled",
        Duration = 2
    })
end)

-- Auto Speed Button
Tabs.Main:AddButton({
    Title = "Auto Farm Speed",
    Description = "Teleport to the Speed Machine",
    Callback = function()
        if HRP() then
            HRP().CFrame = CFrame.new(-87.06, 21.19, -9387.45) -- จุดเครื่อง Speed (ใหม่)
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
    Title = "Speed Hack",
    Default = false,
})
SpeedToggle:OnChanged(function(state)
    speedHack = state
end)

-- ===========================
-- Functions
-- ===========================
-- Smooth Tween Movement
local function TweenToPosition(targetPos, height)
    if not HRP() then return end
    moving = true
    local offset = height or 65
    local distance = (HRP().Position - targetPos).Magnitude
    local duration = distance / 200
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tweenGoal = {CFrame = CFrame.new(targetPos + Vector3.new(0, offset, 0))}
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
            
            -- Tween ตัวละครไปยังตำแหน่ง + ลอยตัว
            moving = true
            local distance = (HRP().Position - target).Magnitude
            local duration = distance / 500 -- ความเร็ว Tween
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
            local tweenGoal = {CFrame = CFrame.new(target + Vector3.new(0, 25, 0))}
            local tween = TweenService:Create(HRP(), tweenInfo, tweenGoal)
            tween:Play()
            tween.Completed:Wait()
            moving = false

            -- อัปเดต Box หลัง Tween เสร็จ
            local box = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FarmBox")
            if box then
                box.CFrame = HRP().CFrame * CFrame.new(0, -2, 0)
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

-- Auto Win Loop
task.spawn(function()
    while RunService.RenderStepped:Wait() do
        if autoWin and HRP() and winActive then
            local distance = (HRP().Position - winGoal).Magnitude
            local duration = distance / winSpeed
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(HRP(), tweenInfo, {CFrame = CFrame.new(winGoal)})
            tween:Play()
            tween.Completed:Wait()

            if not autoWin then break end -- ถ้าปิด Toggle หยุดทันที

            task.wait(1)
            HRP().CFrame = CFrame.new(winStart)
            task.wait(1)
        end
    end
end)

-- ===========================
-- Keybind
-- ===========================
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.P then
        speedHack = not speedHack
        SpeedToggle:SetValue(speedHack)
        Fluent:Notify({
            Title = "Speed Hack",
            Content = speedHack and "Enabled" or "Disabled",
            Duration = 2
        })
    end
end)

-- ===========================
-- Advanced Anti Kick / Anti Cheat
-- ===========================
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if tostring(method) == "Kick" or tostring(method) == "kick" then
        return warn("[YANZ HUB] Kick attempt blocked!")
    end
    return oldNamecall(self, ...)
end)

for _, v in ipairs(game:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        if string.match(string.lower(v.Name), "kick") or string.match(string.lower(v.Name), "ban") or string.match(string.lower(v.Name), "report") then
            v:Destroy()
            warn("[YANZ HUB] Removed suspicious Remote:", v.Name)
        end
    end
end

game:GetService("ScriptContext").Error:Connect(function(message, stack)
    if string.find(message:lower(), "crash") or string.find(message:lower(), "kick") then
        warn("[YANZ HUB] Crash attempt blocked:", message)
    end
end)

local function StealthHumanoid(hum)
    hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed > 16 then
            hum.WalkSpeed = 16
            warn("[YANZ HUB] WalkSpeed reset to safe value")
        end
    end)
    hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if hum.JumpPower > 50 then
            hum.JumpPower = 50
            warn("[YANZ HUB] JumpPower reset to safe value")
        end
    end)
end

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    StealthHumanoid(LocalPlayer.Character:FindFirstChildOfClass("Humanoid"))
end
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    StealthHumanoid(char:FindFirstChildOfClass("Humanoid"))
end)

warn("[YANZ HUB] Advanced Anti-Kick Loaded!")
