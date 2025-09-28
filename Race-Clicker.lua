--===[ Services ]===--
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--===[ Load NothingLibrary ]===--
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local ok_lib, NothingLibrary = pcall(function()
    local code = game:HttpGetAsync(libURL)
    local func, err = loadstring(code)
    if not func then
        warn("Loadstring error:", err)
        return nil
    end
    return func()
end)
if not ok_lib or not NothingLibrary then
    warn("YANZ HUB: Failed to load Nothing UI Library.")
    return
end

--===[ Create Window ]===--
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.5.0",
    Description = "By lphisv5 | Game : 🏆 Race Clicker",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

--===[ Tabs & Sections ]===--
local MainTab = Window:NewTab({
    Title = "Main",
    Description = "Core Features",
    Icon = "rbxassetid://7733960981"
})
local SpeedTab = Window:NewTab({
    Title = "Speed Booster",
    Description = "Unlimited Speed Settings",
    Icon = "rbxassetid://7743869054"
})

local MainSection = MainTab:NewSection({Title = "Auto Features", Icon = "rbxassetid://7733916988", Position = "Left"})
local SpeedSection = SpeedTab:NewSection({Title = "Speed Control", Icon = "rbxassetid://7733916988", Position = "Left"})

--===[ Globals ]===--
_G.autoClick = false
_G.autoWin = false
_G.autoSpeed = false

--===[ Auto Click ]===--
MainSection:NewToggle({
    Title = "Auto Click (0.1s)",
    Default = false,
    Callback = function(state)
        _G.autoClick = state
        if state then
            task.spawn(function()
                while _G.autoClick do
                    task.wait(0.1)
                    -- ส่งคลิก
                    pcall(function()
                        game:GetService("ReplicatedStorage").Events.Click3:FireServer()
                    end)
                end
            end)
        end
    end
})

--===[ Auto Wins ]===--
local checkpoints = {
    [1] = "ส้มอ่อน", [3] = "แดงอ่อน", [4] = "ฟ้าอ่อน", [5] = "ม่วง",
    [10] = "เขียว", [25] = "ฟ้าใส", [50] = "ชมพู่อ่อน", [100] = "ดำ",
    [500] = "ส้ม", [1000] = "เขียวเข้ม", [5000] = "ชมพู่เข้ม",
    [10000] = "เหลือง", [25000] = "น้ำเงิน", [50000] = "แดงเข้ม", [100000] = "ม่วงออกชมพู"
}

local function tpToPart(part)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,3,0)
    end
end

MainSection:NewToggle({
    Title = "Auto Wins",
    Default = false,
    Callback = function(state)
        _G.autoWin = state
        if state then
            task.spawn(function()
                while _G.autoWin do
                    task.wait(1)

                    -- ตรวจสอบ UI ด้านบน
                    local gui = LocalPlayer:WaitForChild("PlayerGui")
                    local timer = gui:FindFirstChild("Main") and gui.Main:FindFirstChild("Timer")
                    local text = timer and timer.Text or ""

                    if text:find("Click to build up Speed") then
                        -- ถ้าอยู่ช่วง Click → Auto Click
                        game:GetService("ReplicatedStorage").Events.Click3:FireServer()
                    elseif text:find(":") then
                        -- ถ้ามีเวลา → วิ่งอยู่ → Teleport ตาม checkpoint
                        for num, name in pairs(checkpoints) do
                            local part = workspace:FindFirstChild(tostring(num))
                            if part then
                                tpToPart(part)
                                task.wait(0.5)
                            end
                        end
                    else
                        -- ถ้าเวลา = 00:00 หยุด
                        if text == "00:00.00" then
                            _G.autoWin = false
                        end
                    end
                end
            end)
        end
    end
})

--===[ Speed Booster ]===--
SpeedSection:NewToggle({
    Title = "Enable Speed Booster",
    Default = false,
    Callback = function(state)
        _G.autoSpeed = state
        if state then
            task.spawn(function()
                while _G.autoSpeed do
                    task.wait(0.2)
                    local stats = LocalPlayer:FindFirstChild("leaderstats")
                    if stats and stats:FindFirstChild("Speed") then
                        stats.Speed.Value = stats.Speed.Value + 100 -- เพิ่ม Speed ทีละ 100
                    end
                end
            end)
        end
    end
})

print("✅ YANZ HUB Race Clicker Loaded Successfully")
