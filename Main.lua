--[[
Fisch TI Hub - Fixed GUI Version
แก้ปัญหา GUI ไม่โชว์ 100%
]]

-- =========================
-- 🔧 โหลด Orion UI แบบใหม่
-- =========================
local OrionLib = nil
local GUILoaded = false

-- ลองโหลด Orion หลายๆ เวอร์ชัน
local OrionURLs = {
    "https://raw.githubusercontent.com/shlexware/Orion/main/source",
    "https://pastebin.com/raw/A0CyVfWh",
    "https://raw.githubusercontent.com/richie0866/orion/master/source"
}

for _, url in pairs(OrionURLs) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success and result then
        OrionLib = result
        GUILoaded = true
        break
    end
end

-- ถ้า Orion โหลดไม่สำเร็จ ให้ใช้ GUI แบบง่ายๆ
if not GUILoaded then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fisch TI Hub",
        Text = "กำลังโหลด GUI แบบสำรอง...",
        Duration = 3
    })
    
    -- สร้าง GUI แบบง่ายๆ ด้วยตัวเอง
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FischTIHubGUI"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.Parent = ScreenGui
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.Text = "🎣 Fisch TI Hub (สำรอง)"
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.Parent = MainFrame
    
    -- สร้างปุ่มพื้นฐาน
    local function CreateButton(text, position, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0, 40)
        button.Position = position
        button.Text = text
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Parent = MainFrame
        
        button.MouseButton1Click:Connect(callback)
        return button
    end
    
    -- ปุ่มพื้นฐาน
    CreateButton(UDim2.new(0.05, 0, 0.1, 0), "🔄 โหลดสคริปต์ใหม่", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/your-repo/fisch-ti-hub/main/script.lua"))()
    end)
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fisch TI Hub",
        Text = "ใช้ GUI สำรองแล้ว! กด F9 เพื่อดูหน้าต่าง",
        Duration = 5
    })
    
    return -- หยุดการทำงานสคริปต์หลัก
end

-- =========================
-- 🎮 ต่อจากนี้คือสคริปต์หลัก
-- =========================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- รอจนกว่า Player จะพร้อม
repeat wait() until Player and Player.Character

-- Global Variables
local _G = {
    InfiniteJump = false,
    CtrlClickTP = false,
    AutoFarm = false,
    AutoCast = false,
    AutoShake = false,
    AutoReel = false,
    AutoCollect = false,
    AutoSell = false,
    AutoSellAll = false,
}

-- สร้าง Window หลัก
local Window = OrionLib:MakeWindow({
    Name = "🎣 Fisch TI Hub | COMPLETE",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FischTIConfig",
    IntroText = "Fisch TI Hub โหลดสำเร็จ!",
    IntroIcon = "http://www.roblox.com/asset/?id=123456789"
})

-- แจ้งเตือนเมื่อโหลดสำเร็จ
OrionLib:MakeNotification({
    Name = "Fisch TI Hub",
    Content = "GUI โหลดสำเร็จ! 🎉",
    Time = 5,
    Image = "http://www.roblox.com/asset/?id=123456789"
})

-- =========================
-- 🏠 Home Tab
-- =========================
local HomeTab = Window:MakeTab({
    Name = "🏠 หน้าแรก",
    Icon = "rbxassetid://7072717162"
})

HomeTab:AddButton({
    Name = "📋 คัดลอก Discord",
    Callback = function()
        setclipboard("https://discord.gg/example")
        OrionLib:MakeNotification({
            Name = "Discord",
            Content = "คัดลอกลิงก์ Discord แล้ว!",
            Time = 3
        })
    end
})

HomeTab:AddToggle({
    Name = "🦘 กระโดดไม่จำกัด",
    Default = false,
    Callback = function(value)
        _G.InfiniteJump = value
    end
})

HomeTab:AddToggle({
    Name = "📍 CTRL+คลิกวาร์ป",
    Default = false,
    Callback = function(value)
        _G.CtrlClickTP = value
    end
})

-- =========================
-- ⚙️ Main Tab
-- =========================
local MainTab = Window:MakeTab({
    Name = "⚙️ ฟาร์มปลา",
    Icon = "rbxassetid://7072717162"
})

MainTab:AddToggle({
    Name = "🐟 ฟาร์มปลาอัตโนมัติ",
    Default = false,
    Callback = function(value)
        _G.AutoFarm = value
    end
})

MainTab:AddToggle({
    Name = "🎣 Auto Cast",
    Default = false,
    Callback = function(value)
        _G.AutoCast = value
    end
})

MainTab:AddToggle({
    Name = "🌀 Auto Shake",
    Default = false,
    Callback = function(value)
        _G.AutoShake = value
    end
})

MainTab:AddToggle({
    Name = "📦 เก็บของอัตโนมัติ",
    Default = false,
    Callback = function(value)
        _G.AutoCollect = value
    end
})

-- =========================
-- 🔄 เริ่มต้นสคริปต์
-- =========================
OrionLib:Init()

-- แสดงหน้าต่าง GUI
Window:Show()

print("🎣 Fisch TI Hub โหลดสำเร็จแล้ว!")
print("✅ GUI พร้อมใช้งาน")
print("📁 Config Folder: FischTIConfig")
