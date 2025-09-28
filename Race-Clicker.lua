-- โหลด Library GUI หลัก
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/refs/heads/main/source.lua"))()

-- ตั้งค่าหน้าต่างหลัก
local Main = Library.new({
    Title = "YANZ HUB",
    Logo = "rbxassetid://1234567890", -- โลโก้ใส่อะไรก็ได้
    Description = "By lphisv5 | Game : 🏆 Race Clicker"
})

-------------------------------------------------------
-- 🔥 Auto Click
-------------------------------------------------------
local autoClick = false
Main:CreateToggle("Auto Click (0.1s)", function(state)
    autoClick = state
    spawn(function()
        while autoClick do
            task.wait(0.1)
            -- ระบบคลิกในเกม
            game:GetService("ReplicatedStorage").Events.Click3:FireServer()
            -- แสดงคำว่า CLICK ที่มุมขวาจอ
            game.StarterGui:SetCore("SendNotification", {
                Title = "YANZ HUB",
                Text = "CLICK",
                Duration = 0.1
            })
        end
    end)
end)

-------------------------------------------------------
-- 🏆 Auto Wins
-------------------------------------------------------
local autoWin = false
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ตำแหน่งตามสีและตัวเลข
local checkpoints = {
    {"ส้มอ่อน", 1},
    {"แดงอ่อน", 3},
    {"ฟ้าอ่อน", 4},
    {"ม่วง", 5},
    {"เขียว", 10},
    {"ฟ้าใส", 25},
    {"ชมพู่อ่อน", 50},
    {"ดำ", 100},
    {"ส้ม", 500},
    {"เขียว", 1000},
    {"ชมพู่เข้ม", 5000},
    {"เหลือง", 10000},
    {"น้ำเงิน", 25000},
    {"แดงเข้ม", 50000},
    {"ม่วงออกชมพู", 100000}
}

-- ฟังก์ชัน Teleport
local function tpTo(part)
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,3,0)
    end
end

-- เปิดใช้งาน Auto Wins
Main:CreateToggle("Auto Wins", function(state)
    autoWin = state
    spawn(function()
        while autoWin do
            task.wait(0.5)

            -- ตรวจสอบสถานะเกมจาก UI ด้านบน
            local topUI = game:GetService("Players").LocalPlayer.PlayerGui.Main.Timer.Text

            if string.find(topUI, "Waiting to start") then
                -- ยังไม่เริ่ม
            elseif string.find(topUI, "Click to build up Speed") then
                -- จะ Auto Click ตรงนี้ถ้าเปิด Auto Wins
                game:GetService("ReplicatedStorage").Events.Click3:FireServer()
            else
                -- เริ่มวิ่งแล้ว → Teleport ตาม Checkpoint
                for _,v in ipairs(checkpoints) do
                    local part = workspace:FindFirstChild(tostring(v[2]))
                    if part then
                        tpTo(part)
                        task.wait(1)
                    end
                end
            end
        end
    end)
end)

-------------------------------------------------------
-- 🚀 Speed Booster
-------------------------------------------------------
local autoSpeed = false
Main:CreateToggle("Speed Booster (เพิ่ม Speed ไม่จำกัด)", function(state)
    autoSpeed = state
    spawn(function()
        while autoSpeed do
            task.wait(0.2)
            local stats = lp:FindFirstChild("leaderstats")
            if stats and stats:FindFirstChild("Speed") then
                stats.Speed.Value = stats.Speed.Value + 100 -- เพิ่มทีละ 100
            end
        end
    end)
end)

-------------------------------------------------------
-- เปิด GUI
Main:Init()
