local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "YANZ HUB | V1.4",
    SubTitle = "By lphisv5 | +1 Size Race",
    TabWidth = 120,
    Size = UDim2.fromOffset(500, 400),
    Acrylic = true,
    Theme = "Dark",
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Player = Window:AddTab({ Title = "Player", Icon = "player" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
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

-- Auto Respawn Feature
local autoRespawn = true
local respawnConnections = {}

local function setupRespawnHandling()
    for _, conn in pairs(respawnConnections) do
        if conn then conn:Disconnect() end
    end
    respawnConnections = {}
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = HRP()
    
    if humanoid then
        local diedConn = humanoid.Died:Connect(function()
            if autoRespawn then
                task.wait(0.1)
                LocalPlayer:LoadCharacter()
                Fluent:Notify({ Title = "Auto-Respawn", Content = "Character died - Respawning!", Duration = 2 })
            end
        end)
        table.insert(respawnConnections, diedConn)
    end
    
    -- Detect HRP removal
    if hrp then
        local hrpAncestryConn = hrp.AncestryChanged:Connect(function()
            if not hrp.Parent then
                if autoRespawn then
                    task.wait(0.1)
                    LocalPlayer:LoadCharacter()
                    Fluent:Notify({ Title = "Auto-Respawn", Content = "HRP lost - Respawning!", Duration = 2 })
                end
            end
        end)
        table.insert(respawnConnections, hrpAncestryConn)
    end
   
    local charRemovingConn = LocalPlayer.CharacterRemoving:Connect(function()
        if autoRespawn then
            task.wait(0.1)
            LocalPlayer:LoadCharacter()
            Fluent:Notify({ Title = "Auto-Respawn", Content = "Character removing - Respawning!", Duration = 2 })
        end
    end)
    table.insert(respawnConnections, charRemovingConn)
end

setupRespawnHandling()
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    setupRespawnHandling()
end)

-- Auto Farm
local autoFarm = false
local farmPoints = {
    Vector3.new(-214.79, 18.83, -928.51),
    Vector3.new(-217.22, 18.39, -9525.09),
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
local winSpeed = 400
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
        farmIndex = 1
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
        moving = false
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
        winActive = false
    end
    Fluent:Notify({
        Title = "Auto Win",
        Content = autoWin and "Enabled" or "Disabled",
        Duration = 1
    })
end)

-- Auto Speed Button
Tabs.Main:AddButton({
    Title = "Auto Farm Speed",
    Description = "Teleport to the Speed Machine",
    Callback = function()
        if HRP() then
            HRP().CFrame = CFrame.new(-87.06, 21.19, -9387.45)
        end
    end,
})

-- ===========================
-- Player Tab Features
-- ===========================
-- Anti AFK
local antiAFKConnection = nil
Tabs.Player:AddButton({
    Title = "Anti-AFK",
    Description = "Prevent being kicked out of the game",
    Callback = function()
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
            Fluent:Notify({ Title = "Anti-AFK", Content = "Disabled", Duration = 2 })
        else
            local VirtualUser = game:GetService("VirtualUser")
            antiAFKConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            Fluent:Notify({ Title = "Anti-AFK", Content = "Enabled", Duration = 2 })
        end
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
    local hrp = HRP()
    if not hrp then return false end
    moving = true
    local offset = height or 65
    local distance = (hrp.Position - targetPos).Magnitude
    local duration = distance / 200
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tweenGoal = {CFrame = CFrame.new(targetPos + Vector3.new(0, offset, 0))}
    local tween = TweenService:Create(hrp, tweenInfo, tweenGoal)
    tween:Play()
    tween.Completed:Wait()
    moving = false
    return true
end

-- Auto Farm Smooth Loop
task.spawn(function()
    while true do
        task.wait()
        if not autoFarm or not LocalPlayer.Character or not HRP() or moving then continue end
        
        local success, err = pcall(function()
            local target = farmPoints[farmIndex]
            if not TweenToPosition(target, 1) then return end
            
            local box = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FarmBox")
            if box then
                box.CFrame = HRP().CFrame * CFrame.new(0, -4, 0)
            end
            
            farmIndex = farmIndex == 1 and 2 or 1
        end)
        
        if not success then
            warn("[YANZ HUB] Auto Farm error:", err)
            task.wait(1)
        end
    end
end)

-- Speed Hack Loop
task.spawn(function()
    while true do
        task.wait()
        if not speedHack or not HRP() then continue end
        
        local success, err = pcall(function()
            HRP().CFrame = HRP().CFrame * CFrame.new(0, 0, -speedValue)
        end)
        
        if not success then
            warn("[YANZ HUB] Speed Hack error:", err)
        end
    end
end)

-- Auto Win Loop
task.spawn(function()
    while true do
        task.wait()
        if not autoWin or not HRP() or not winActive then continue end
        
        local success, err = pcall(function()
            local distance = (HRP().Position - winGoal).Magnitude
            local duration = distance / winSpeed
            local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(HRP(), tweenInfo, {CFrame = CFrame.new(winGoal)})
            tween:Play()
            tween.Completed:Wait()
            
            if not autoWin then return end
            
            task.wait(1)
            HRP().CFrame = CFrame.new(winStart)
            task.wait(1)
        end)
        
        if not success then
            warn("[YANZ HUB] Auto Win error:", err)
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

local function applyStealthOnCharacter(char)
    local hum = char:WaitForChild("Humanoid")
    StealthHumanoid(hum)
end

if LocalPlayer.Character then
    applyStealthOnCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(applyStealthOnCharacter)

warn("[YANZ HUB] Advanced Anti-Kick & Auto-Respawn Loaded!")
