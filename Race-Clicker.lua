-- YANZ HUB | Race Clicker - PROFESSIONAL FIXED VERSION
-- By: assistant (for lphisv5 request)
-- Version: V0.6.7 [SUPER FAST TP LOOP, ANTI-JUMP FIX, ADVANCED AUTO CLICK]

--===[ Services ]===--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--===[ Load UI Lib ]===--
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local NothingLibrary = loadstring(game:HttpGet(libURL))()

local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.6.7 [UPDATED]",
    Description = "By lphisv5 | Game : 🏆 Race Clicker",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

--===[ Tabs ]===--
local MainTab = Window:NewTab({Title="Main", Description="Auto System", Icon="rbxassetid://7733960981"})
local AutoClickSection = MainTab:NewSection({Title="Auto Click", Icon="rbxassetid://7733916988", Position="Left"})
local AutoWinsSection = MainTab:NewSection({Title="Auto Wins", Icon="rbxassetid://7733916988", Position="Right"})
local SpeedSection = MainTab:NewSection({Title="Speed Booster", Icon="rbxassetid://7733916988", Position="Left"})

--===[ States ]===--
local state = {
    autoClick = false,
    autoWins = false,
    autoSpeed = false
}

--===[ Auto Click ]===--
local function doClick()
    local remote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Click3")
    if remote and remote.FireServer then
        remote:FireServer()
    end
end

local function isClickToBuildActive()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return false end
    for _, c in ipairs(gui:GetDescendants()) do
        if c:IsA("TextLabel") and c.Text == "Click to build" then -- ตรวจสอบแบบเข้มงวด
            return true
        end
    end
    return false
end

AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = false,
    Callback = function(v)
        state.autoClick = v
        if v then
            task.spawn(function()
                while state.autoClick do
                    if isClickToBuildActive() then
                        print("Click to build detected! Starting super spam clicks...")
                        local startTime = tick()
                        while (tick() - startTime) < 20 and isClickToBuildActive() and state.autoClick do
                            for i = 1, 100 do -- สแปม 100 ครั้งเหมือน 100 คน 10 นิ้ว
                                task.spawn(doClick)
                            end
                            task.wait(0.005) -- หน่วง 0.005 วินาที (5 ซิ) เพื่อป้องกัน FPS ตก
                        end
                        print("Spam clicks ended after 20s or state changed.")
                    end
                    RunService.RenderStepped:Wait() -- ตรวจสอบสถานะทุก frame
                end
            end)
        end
    end
})

--===[ Auto Wins ]===--
local startCheckpoint = 1
local endCheckpoint = 100000

local function tpTo(num)
    local success = false
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if hrp and humanoid then
        humanoid.Jump = false
        humanoid.JumpPower = 0
        humanoid.PlatformStand = true -- บังคับให้ตัวละครยืนนิ่งเพื่อป้องกันการเคลื่อนไหว
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and tostring(obj.Name) == tostring(num) then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 1, 0)
                    success = true
                    print("Teleported to checkpoint: " .. num)
                    break
                end
            end
        end)
        humanoid.PlatformStand = false -- ปลดการยืนนิ่งหลัง TP
    end
    if not success then
        print("Checkpoint " .. num .. " not found!")
    end
    return success
end

local function findTimer()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return "" end
    for _, c in ipairs(gui:GetDescendants()) do
        if c:IsA("TextLabel") and c.Text then
            if c.Text:match("%d%d:%d%d") or c.Text:find("Waiting") or c.Text:find("Click to build") or c.Text:find("00:00") then
                return c.Text
            end
        end
    end
    return ""
end

AutoWinsSection:NewToggle({
    Title = "Auto Wins",
    Default = false,
    Callback = function(v)
        state.autoWins = v
        if v then
            task.spawn(function()
                while state.autoWins do
                    RunService.RenderStepped:Wait()
                    local txt = findTimer()
                    print("Timer Status: " .. txt)
                    if txt:find("Waiting") then
                        print("Waiting for race to start...")
                    elseif txt:find("Click to build") then
                        print("Spamming clicks...")
                        local startTime = tick()
                        while (tick() - startTime) < 20 and isClickToBuildActive() and state.autoWins do
                            for i = 1, 100 do
                                task.spawn(doClick)
                            end
                            task.wait(0.0001)
                        end
                    elseif txt:match("%d%d:%d%d") then
                        print("Race in progress, starting super fast TP loop...")
                        while txt:match("%d%d:%d%d") and state.autoWins do
                            if not tpTo(endCheckpoint) then
                                print("Failed to find endCheckpoint, retrying...")
                                RunService.RenderStepped:Wait()
                                continue
                            end
                            RunService.RenderStepped:Wait()
                            if not tpTo(startCheckpoint) then
                                print("Failed to find startCheckpoint, retrying...")
                                RunService.RenderStepped:Wait()
                                continue
                            end
                            RunService.RenderStepped:Wait()
                            txt = findTimer()
                        end
                    elseif txt:find("00:00") then
                        print("Race ended, resetting Auto Wins...")
                        state.autoWins = false
                        break
                    else
                        print("Unknown timer state: " .. txt)
                    end
                end
            end)
        end
    end
})

--===[ Speed Booster ]===--
SpeedSection:NewToggle({
    Title = "Speed Booster",
    Default = false,
    Callback = function(v)
        state.autoSpeed = v
        if v then
            task.spawn(function()
                while state.autoSpeed do
                    RunService.RenderStepped:Wait()
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum.WalkSpeed = 999999999
                                hum.JumpPower = 0
                                hum.Jump = false
                                hum.PlatformStand = false
                            end
                        end
                    end)
                end
            end)
        else
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16
                        hum.JumpPower = 50
                        hum.PlatformStand = false
                    end
                end
            end)
        end
    end
})

--===[ Anti-Jump Global Fix ]===--
RunService.RenderStepped:Connect(function()
    pcall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Jump = false
            humanoid.JumpPower = 0
            humanoid.PlatformStand = false -- รีเซ็ต PlatformStand ในกรณีที่ไม่ใช้ Auto Wins
        end
    end)
end)

print("✅ YANZ HUB Race Clicker Loaded Successfully [V0.6.7]")
