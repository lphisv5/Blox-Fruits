-- YANZ HUB | Race Clicker - PROFESSIONAL FIXED VERSION
-- By: assistant (for lphisv5 request)
-- Version: V0.6.6 [UPDATED: Super Fast TP Loop, Anti-Jump Fix, Advanced Auto Click]

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
    Title = "YANZ HUB | V0.6.6 [TESTING]",
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
        if c:IsA("TextLabel") and c.Text == "Click to build" then -- ตรวจสอบแบบเข้มงวด: Text ต้องตรงเป๊ะ "Click to build"
            -- เพิ่มการตรวจสอบเพิ่มเติมถ้าต้องการ เช่น ชื่อ parent หรือ position ถ้าทราบ path ใน GUI
            -- ตัวอย่าง: if c.Parent.Name == "SpecificFrame" then return true end
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
                    if isClickToBuildActive() then -- คลิกเฉพาะเมื่อ "Click to build" แสดงเท่านั้น
                        print("Click to build detected! Starting super spam clicks...")
                        local startTime = tick()
                        while (tick() - startTime) < 20 and isClickToBuildActive() and state.autoClick do -- สแปม 20 วินาที หรือจนกว่า "Click to build" หาย
                            for i = 1, 100 do -- สแปมเหมือน 100 คนคลิกพร้อมกัน (loop 100 ครั้งรวดเดียว)
                                task.spawn(doClick) -- ใช้ task.spawn เพื่อคลิกพร้อมกันหลายครั้ง (เหมือนหลายนิ้วคลิกกลางหน้าจอ)
                            end
                            task.wait(0.005) -- หน่วง 0.005 วินาที (5 ซิ = 0.005s) เพื่อป้องกัน FPS ตกเยอะ
                        end
                        print("Spam clicks ended after 20s or state changed.")
                    end
                    task.wait(0000000000000000000000.0000000000000000000001) -- ตรวจสอบสถานะทุก 0.1 วินาที
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
        humanoid.Jump = false -- บังคับไม่ให้กระโดด
        humanoid.JumpPower = 0 -- ตั้ง JumpPower เป็น 0 เพื่อป้องกันกระโดด
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and tostring(obj.Name) == tostring(num) then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 1, 0) -- ไม่ใช้ Anchored เพื่อความสมูท
                    success = true
                    print("Teleported to checkpoint: " .. num)
                    break
                end
            end
        end)
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
                    RunService.RenderStepped:Wait() -- ใช้ RenderStepped เพื่อความเร็วสูงสุดและสมูท
                    local txt = findTimer()
                    print("Timer Status: " .. txt)
                    if txt:find("Waiting") then
                        print("Waiting for race to start...")
                    elseif txt:find("Click to build") then
                        print("Spamming clicks...")
                        for i = 1, 30 do
                            doClick()
                            task.wait(0000000000000000000000.0000000000000000000001)
                        end
                    elseif txt:match("%d%d:%d%d") then
                        print("Race in progress, starting super fast TP loop...")
                        while txt:match("%d%d:%d%d") and state.autoWins do -- วนลูป TP จนกว่าจะจบการแข่ง
                            tpTo(endCheckpoint) -- TP ไป 100K รวดเดียว
                            RunService.RenderStepped:Wait() -- หน่วงสั้นสุด (เหมือน 0.000...1)
                            tpTo(startCheckpoint) -- TP กลับ 1
                            RunService.RenderStepped:Wait() -- วนซ้ำรวดเร็วมาก
                            txt = findTimer() -- อัปเดตสถานะ
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
                    RunService.RenderStepped:Wait() -- อัปเดตบ่อยขึ้นเพื่อป้องกันกระโดด
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum.WalkSpeed = 999999999
                                hum.JumpPower = 0 -- บังคับ JumpPower = 0
                                hum.Jump = false -- บังคับไม่ให้กระโดดทุก frame
                            end
                        end
                    end)
                end
            end)
        else
            -- รีเซ็ตเมื่อปิด Speed Booster
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = 16 -- ค่าเริ่มต้น
                        hum.JumpPower = 50 -- ค่าเริ่มต้น
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
        end
    end)
end)

print("YANZ HUB Loaded Successfully")
