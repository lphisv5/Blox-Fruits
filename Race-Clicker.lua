-- YANZ HUB | Race Clicker - PROFESSIONAL FIXED VERSION
-- By: assistant (for lphisv5 request)

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
    Title = "YANZ HUB | V0.6.5 [TESTING]",
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

AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = false,
    Callback = function(v)
        state.autoClick = v
        if v then
            task.spawn(function()
                while state.autoClick do
                    doClick()
                    task.wait(0.1)
                end
            end)
        end
    end
})

--===[ Auto Wins ]===--
local checkpoints = {1, 3, 4, 5, 10, 25, 50, 100, 500, 1000, 5000, 10000, 25000, 50000, 100000}

local function tpTo(num)
    local success = false
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    
    if hrp and humanoid then
        humanoid.Jump = false -- ป้องกันการกระโดด
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and tostring(obj.Name) == tostring(num) then
                hrp.Anchored = true -- ยึดตัวละครชั่วคราว
                hrp.CFrame = obj.CFrame + Vector3.new(0, 1, 0) -- ลดความสูงจาก 5 เป็น 2 เพื่อความสมูท
                task.wait(000000000000000.0000000000000001) -- หน่วงสั้นมากเพื่อให้ CFrame เซ็ต
                hrp.Anchored = false
                success = true
                print("Teleported to checkpoint: " .. num)
                break
            end
        end
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
                    task.wait(000000000000000.0000000000000001) -- ลดหน่วงจาก 0.1 เป็น 0.05 เพื่อให้เร็วสุดๆ
                    local txt = findTimer()
                    print("Timer Status: " .. txt)
                    if txt:find("Waiting") then
                        print("Waiting for race to start...")
                    elseif txt:find("Click to build") then
                        print("Spamming clicks...")
                        for i = 1, 30 do -- เพิ่มจำนวน click เพื่อความเร็ว
                            doClick()
                            task.wait(0.03) -- ลดหน่วง click จาก 0.05 เป็น 0.03
                        end
                    elseif txt:match("%d%d:%d%d") then
                        print("Race in progress, teleporting to checkpoints...")
                        for _, num in ipairs(checkpoints) do
                            if not state.autoWins then break end
                            local success = tpTo(num)
                            task.wait(000000000000000.0000000000000001) -- ลดหน่วงจาก 0.1 เป็น 000.001 เพื่อ TP รั่วๆ
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
                    task.wait(0.1)
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum then
                                hum.WalkSpeed = 999999999
                                hum.JumpPower = 0 -- ปิดการกระโดดเพื่อความสมูท
                                hum.Jump = false -- ป้องกันการกระโดดอัตโนมัติ
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

print("✅ YANZ HUB Race Clicker Loaded Successfully")
