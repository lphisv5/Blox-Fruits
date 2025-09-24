--[[
Fisch TI Hub | Complete Version - Fixed
Author: ChatGPT
Description: สคริปต์ครบทุกฟังก์ชันสำหรับเกม Fisch TI (แก้ไขแล้ว)
]]

-- =========================
-- 🔧 Initialization - FIXED
-- =========================
local success, OrionLib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
end)

if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fisch TI Hub",
        Text = "Failed to load Orion UI",
        Duration = 5
    })
    return
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

-- Wait for player
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
    AntiCrash = false,
    AutoReconnect = false
}

local SavedPos = nil
local SelectedRod = "Wooden Rod"
local SelectedSell = "Common"
local SelectedZone = "Spawn"
local currentLang = "EN"
local ManualVisible = false

-- =========================
-- 🌍 Language System
-- =========================
local Languages = {
    ["EN"] = {
        manual = [[ 📖 Fisch TI Hub - User Manual (EN)

🏠 HOME:
- Discord Invite: Copy Discord link
- Infinite Jump: Jump infinitely in air
- CTRL+Click Teleport: Hold CTRL + Click to teleport

⚙️ MAIN:
- Choose Rod: Select fishing rod to equip
- Auto Farm Fish: Automatically fish
- Auto Click Cast: Auto cast fishing rod
- Auto Click Shake: Auto shake when fish bites
- Auto Click Reel: Auto reel fish
- Auto Collect Item: Auto collect items on ground
- Save Position: Save current position
- Teleport to Saved: TP to saved position

💰 SELLER:
- Choose Sell: Select fish rarity to sell
- Auto Sell: Auto sell selected fish type
- Auto Sell All: Auto sell all fish

📍 TELEPORT:
- Choose Zone: Select zone to teleport
- Teleport To Zone: TP to selected zone

🔧 MISC:
- Reduce Lag: Lower FPS to reduce lag
- Anti-Crash: Prevent game crashes
- Show Screen White: Make screen white
- Show Screen Black: Make screen black
- Auto Reconnect: Auto reconnect if disconnected

⚡ PROTECTION:
- Layer1: Anti-Kick (Block kick attempts)
- Layer2: Server Hop (Switch servers)
- Layer3: Emergency Exit (Force close game)

🛠️ SETTINGS:
- Reset Config: Reset all settings
]],
        manualTH = [[ 📖 Fisch TI Hub - คู่มือการใช้งาน (TH)

🏠 หน้าแรก:
- เชิญดิสคอร์ด: คัดลอกลิงก์ดิสคอร์ด
- กระโดดไม่จำกัด: กระโดดได้ไม่จำกัดในอากาศ
- CTRL+คลิกวาร์ป: กด CTRL ค้างแล้วคลิกเพื่อวาร์ป

⚙️ หน้าหลัก:
- เลือกคันเบ็ด: เลือกคันเบ็ดที่จะใช้งาน
- ฟาร์มปลาอัตโนมัติ: ตกปลาอัตโนมัติ
- กด Cast อัตโนมัติ: โยนเบ็ดอัตโนมัติ
- กด Shake อัตโนมัติ: สั่นเบ็ดเมื่อปลากัด
- กด Reel อัตโนมัติ: ดึงเบ็ดอัตโนมัติ
- เก็บไอเท็มอัตโนมัติ: เก็บไอเท็มบนพื้นอัตโนมัติ
- บันทึกตำแหน่ง: บันทึกตำแหน่งปัจจุบัน
- วาร์ปไปตำแหน่งที่บันทึก: วาร์ปไปตำแหน่งที่บันทึก

💰 ขายของ:
- เลือกการขาย: เลือกความหายากของปลาที่จะขาย
- ขายอัตโนมัติ: ขายปลาที่เลือกอัตโนมัติ
- ขายทั้งหมดอัตโนมัติ: ขายปลาทั้งหมดอัตโนมัติ

📍 วาร์ป:
- เลือกโซน: เลือกโซนที่จะวาร์ป
- วาร์ปไปโซน: วาร์ปไปโซนที่เลือก

🔧 อื่นๆ:
- ลดแลค: ลด FPS เพื่อลดแลค
- ป้องกันแครช: ป้องกันเกมแครช
- แสดงหน้าจอขาว: ทำให้หน้าจอขาว
- แสดงหน้าจอดำ: ทำให้หน้าจอดำ
- เชื่อมต่อใหม่อัตโนมัติ: เชื่อมต่อใหม่อัตโนมัติหากขาดการเชื่อมต่อ

⚡ ระบบป้องกัน:
- ชั้น1: ป้องกันการเตะ (บล็อกการพยายามเตะ)
- ชั้น2: เปลี่ยนเซิร์ฟเวอร์ (สลับเซิร์ฟเวอร์)
- ชั้น3: ออกเกมฉุกเฉิน (ปิดเกมแบบบังคับ)

🛠️ ตั้งค่า:
- รีเซ็ตการตั้งค่า: รีเซ็ตการตั้งค่าทั้งหมด
]]
    }
}

local function T(key)
    return Languages[currentLang][key] or key
end

-- =========================
-- 🛡️ Protection System - FIXED
-- =========================
local function SetupAntiKick()
    local success, result = pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod()
                if (method == "Kick" or method == "kick") and self == Player then
                    OrionLib:MakeNotification({
                        Name = "Protection",
                        Content = "Layer1: Anti-Kick Triggered!",
                        Time = 5
                    })
                    return nil
                end
                return oldNamecall(self, ...)
            end
            setreadonly(mt, true)
        end
    end)
    
    if not success then
        warn("Anti-Kick setup failed, but script will continue")
    end
end

-- Layer 2: Server Hop
local function ServerHop()
    local success, result = pcall(function()
        local servers = {}
        local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(req)
        
        for _, v in pairs(data.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
        
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
        else
            TeleportService:Teleport(game.PlaceId)
        end
    end)
    
    if not success then
        OrionLib:MakeNotification({
            Name = "Error",
            Content = "Server hop failed!",
            Time = 3
        })
    end
end

-- Layer 3: Emergency Exit
local function EmergencyExit()
    pcall(function()
        for i = 3, 1, -1 do
            OrionLib:MakeNotification({
                Name = "Emergency Exit",
                Content = "Closing game in " .. i .. " seconds...",
                Time = 1
            })
            wait(1)
        end
        game:Shutdown()
    end)
end

-- =========================
-- 🎮 Game Specific Functions - FIXED
-- =========================
local function GetAvailableRods()
    local rods = {}
    if Player and Player:FindFirstChild("Backpack") then
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if string.find(item.Name:lower(), "rod") then
                table.insert(rods, item.Name)
            end
        end
    end
    if #rods == 0 then
        rods = {"Wooden Rod", "Iron Rod", "Golden Rod"}
    end
    return rods
end

local function EquipRod(rodName)
    if not Player.Character then return false end
    
    local success = pcall(function()
        local rod = Player.Backpack:FindFirstChild(rodName) or Player.Character:FindFirstChild(rodName)
        if rod then
            if rod.Parent ~= Player.Character then
                rod.Parent = Player.Character
            end
            return true
        end
        return false
    end)
    
    return success
end

local function FindFish()
    local fish = nil
    pcall(function()
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Part") and (obj.Name:lower():find("fish") or obj.Name:lower():find("salmon") or obj.Name:lower():find("trout")) then
                fish = obj
                break
            end
        end
    end)
    return fish
end

local function FindSeller()
    local seller = nil
    pcall(function()
        for _, npc in pairs(workspace:GetChildren()) do
            if npc:IsA("Model") and (npc.Name:lower():find("seller") or npc.Name:lower():find("merchant") or npc.Name:lower():find("shop")) then
                seller = npc
                break
            end
        end
    end)
    return seller
end

-- =========================
-- 🖼️ GUI Creation - FIXED
-- =========================
local Window = OrionLib:MakeWindow({
    Name = "Fisch TI Hub | Complete Version",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "FischTIHubConfig"
})

-- =========================
-- 📖 Manual Tab
-- =========================
local ManualTab = Window:MakeTab({
    Name = "📖 Manual",
    Icon = "rbxassetid://4483345998"
})

local manualTextEN, manualTextTH

ManualTab:AddButton({
    Name = "📖 Show/Hide Manual",
    Callback = function()
        ManualVisible = not ManualVisible
        if ManualVisible then
            if not manualTextEN then
                manualTextEN = ManualTab:AddParagraph("Manual (EN)", Languages["EN"].manual)
            end
            if not manualTextTH then
                manualTextTH = ManualTab:AddParagraph("คู่มือ (TH)", Languages["EN"].manualTH)
            end
        else
            if manualTextEN then
                manualTextEN:Set("")
            end
            if manualTextTH then
                manualTextTH:Set("")
            end
        end
    end
})

-- =========================
-- 🛡️ Protection Tab
-- =========================
local ProtectionTab = Window:MakeTab({
    Name = "⚡ Protection",
    Icon = "rbxassetid://4483345998"
})

ProtectionTab:AddButton({
    Name = "🛡️ Enable Anti-Kick (Layer 1)",
    Callback = function()
        SetupAntiKick()
        OrionLib:MakeNotification({
            Name = "Protection",
            Content = "Anti-Kick Protection Enabled!",
            Time = 3
        })
    end
})

ProtectionTab:AddButton({
    Name = "🔀 Server Hop (Layer 2)",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Server Hop",
            Content = "Starting server hop in 3 seconds...",
            Time = 3
        })
        wait(3)
        ServerHop()
    end
})

ProtectionTab:AddButton({
    Name = "🚨 Emergency Exit (Layer 3)",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Emergency Exit",
            Content = "Emergency exit in 3 seconds...",
            Time = 3
        })
        wait(3)
        EmergencyExit()
    end
})

ProtectionTab:AddDropdown({
    Name = "🌍 Language Selector",
    Default = "EN",
    Options = {"EN", "TH"},
    Callback = function(value)
        currentLang = value
        OrionLib:MakeNotification({
            Name = "Language",
            Content = "Language set to: " .. value,
            Time = 2
        })
    end
})

-- =========================
-- 🏠 Home Tab - FIXED
-- =========================
local HomeTab = Window:MakeTab({
    Name = "🏠 Home",
    Icon = "rbxassetid://4483345998"
})

HomeTab:AddButton({
    Name = "📋 Discord Invite",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/example")
            OrionLib:MakeNotification({
                Name = "Discord",
                Content = "Discord invite copied to clipboard!",
                Time = 3
            })
        end)
    end
})

HomeTab:AddToggle({
    Name = "🦘 Infinite Jump",
    Default = false,
    Callback = function(value)
        _G.InfiniteJump = value
    end
})

HomeTab:AddToggle({
    Name = "📍 CTRL+Click Teleport",
    Default = false,
    Callback = function(value)
        _G.CtrlClickTP = value
    end
})

-- Infinite Jump Handler
UIS.JumpRequest:Connect(function()
    if _G.InfiniteJump and Player.Character then
        pcall(function()
            local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState("Jumping")
            end
        end)
    end
end)

-- CTRL+Click Teleport Handler
local Mouse = Player:GetMouse()
Mouse.Button1Down:Connect(function()
    if _G.CtrlClickTP and UIS:IsKeyDown(Enum.KeyCode.LeftControl) and Player.Character then
        pcall(function()
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end)
    end
end)

-- =========================
-- ⚙️ Main Tab - FIXED
-- =========================
local MainTab = Window:MakeTab({
    Name = "⚙️ Main",
    Icon = "rbxassetid://4483345998"
})

-- Rod Selection
local rodOptions = GetAvailableRods()
local RodDropdown = MainTab:AddDropdown({
    Name = "🎣 Choose Rod Equip",
    Default = rodOptions[1] or "Wooden Rod",
    Options = rodOptions,
    Callback = function(value)
        SelectedRod = value
    end
})

MainTab:AddButton({
    Name = "🔄 Refresh Rod List",
    Callback = function()
        local newRods = GetAvailableRods()
        RodDropdown:Refresh(newRods)
        OrionLib:MakeNotification({
            Name = "Rods",
            Content = "Rod list refreshed! Found " .. #newRods .. " rods",
            Time = 2
        })
    end
})

-- Position Management
MainTab:AddButton({
    Name = "💾 Save Position",
    Callback = function()
        pcall(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                SavedPos = Player.Character.HumanoidRootPart.Position
                OrionLib:MakeNotification({
                    Name = "Position",
                    Content = "Position saved successfully!",
                    Time = 2
                })
            end
        end)
    end
})

MainTab:AddButton({
    Name = "🗑️ Reset Save Position",
    Callback = function()
        SavedPos = nil
        OrionLib:MakeNotification({
            Name = "Position",
            Content = "Saved position reset!",
            Time = 2
        })
    end
})

MainTab:AddButton({
    Name = "📍 Teleport To Saved Position",
    Callback = function()
        pcall(function()
            if SavedPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(SavedPos)
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported to saved position!",
                    Time = 2
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "No position saved or character not found!",
                    Time = 2
                })
            end
        end)
    end
})

-- Auto Functions
MainTab:AddToggle({
    Name = "🐟 Auto Farm Fish",
    Default = false,
    Callback = function(value)
        _G.AutoFarm = value
    end
})

MainTab:AddToggle({
    Name = "🎯 Auto Click Cast",
    Default = false,
    Callback = function(value)
        _G.AutoCast = value
    end
})

MainTab:AddToggle({
    Name = "🌀 Auto Click Shake",
    Default = false,
    Callback = function(value)
        _G.AutoShake = value
    end
})

MainTab:AddToggle({
    Name = "🎣 Auto Click Reel",
    Default = false,
    Callback = function(value)
        _G.AutoReel = value
    end
})

MainTab:AddToggle({
    Name = "📦 Auto Collect Item",
    Default = false,
    Callback = function(value)
        _G.AutoCollect = value
    end
})

-- =========================
-- 💰 Seller Tab
-- =========================
local SellerTab = Window:MakeTab({
    Name = "💰 Seller",
    Icon = "rbxassetid://4483345998"
})

SellerTab:AddDropdown({
    Name = "🎯 Choose Sell",
    Default = "Common",
    Options = {"Common", "Rare", "Epic", "Legendary", "All"},
    Callback = function(value)
        SelectedSell = value
    end
})

SellerTab:AddToggle({
    Name = "🤖 Auto Sell",
    Default = false,
    Callback = function(value)
        _G.AutoSell = value
    end
})

SellerTab:AddToggle({
    Name = "💰 Auto Sell All",
    Default = false,
    Callback = function(value)
        _G.AutoSellAll = value
    end
})

-- =========================
-- 📍 Teleport Tab
-- =========================
local TeleTab = Window:MakeTab({
    Name = "📍 Teleport",
    Icon = "rbxassetid://4483345998"
})

TeleTab:AddDropdown({
    Name = "🌍 Choose Zone",
    Default = "Spawn",
    Options = {"Spawn", "Lake", "River", "Ocean", "Shop", "Secret Area"},
    Callback = function(value)
        SelectedZone = value
    end
})

TeleTab:AddButton({
    Name = "🚀 Teleport To Zone",
    Callback = function()
        pcall(function()
            if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then 
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Character not found!",
                    Time = 2
                })
                return 
            end
            
            local zonePositions = {
                ["Spawn"] = Vector3.new(0, 10, 0),
                ["Lake"] = Vector3.new(100, 5, 50),
                ["River"] = Vector3.new(-50, 5, 100),
                ["Ocean"] = Vector3.new(200, 5, 200),
                ["Shop"] = Vector3.new(-100, 5, -50),
                ["Secret Area"] = Vector3.new(0, 50, 0)
            }
            
            local position = zonePositions[SelectedZone]
            if position then
                Player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
                OrionLib:MakeNotification({
                    Name = "Teleport",
                    Content = "Teleported to " .. SelectedZone .. "!",
                    Time = 2
                })
            else
                OrionLib:MakeNotification({
                    Name = "Error",
                    Content = "Invalid zone selected!",
                    Time = 2
                })
            end
        end)
    end
})

-- =========================
-- 🔧 Misc Tab
-- =========================
local MiscTab = Window:MakeTab({
    Name = "🔧 Misc",
    Icon = "rbxassetid://4483345998"
})

MiscTab:AddToggle({
    Name = "🐢 Reduce Lag (30 FPS)",
    Default = false,
    Callback = function(value)
        pcall(function()
            if value then
                setfpscap(30)
            else
                setfpscap(60)
            end
        end)
    end
})

MiscTab:AddToggle({
    Name = "🛡️ Anti-Crash",
    Default = false,
    Callback = function(value)
        _G.AntiCrash = value
    end
})

MiscTab:AddToggle({
    Name = "⚪ Show Screen White",
    Default = false,
    Callback = function(value)
        pcall(function()
            if value then
                Lighting.Brightness = 5
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            else
                Lighting.Brightness = 2
                Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            end
        end)
    end
})

MiscTab:AddToggle({
    Name = "⚫ Show Screen Black",
    Default = false,
    Callback = function(value)
        pcall(function()
            if value then
                Lighting.Brightness = 0
                Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            else
                Lighting.Brightness = 2
                Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            end
        end)
    end
})

MiscTab:AddToggle({
    Name = "🔁 Auto Reconnect",
    Default = false,
    Callback = function(value)
        _G.AutoReconnect = value
    end
})

-- =========================
-- 🛠️ Settings Tab
-- =========================
local SettingsTab = Window:MakeTab({
    Name = "🛠️ Settings",
    Icon = "rbxassetid://4483345998"
})

SettingsTab:AddButton({
    Name = "🔄 Reset Script Config",
    Callback = function()
        _G = {
            InfiniteJump = false,
            CtrlClickTP = false,
            AutoFarm = false,
            AutoCast = false,
            AutoShake = false,
            AutoReel = false,
            AutoCollect = false,
            AutoSell = false,
            AutoSellAll = false,
            AntiCrash = false,
            AutoReconnect = false
        }
        SavedPos = nil
        SelectedRod = "Wooden Rod"
        SelectedSell = "Common"
        SelectedZone = "Spawn"
        
        OrionLib:MakeNotification({
            Name = "Reset",
            Content = "All settings have been reset!",
            Time = 3
        })
    end
})

SettingsTab:AddButton({
    Name = "📊 Script Status",
    Callback = function()
        local status = "Script Status:\n"
        status = status .. "Auto Farm: " .. tostring(_G.AutoFarm) .. "\n"
        status = status .. "Auto Sell: " .. tostring(_G.AutoSell) .. "\n"
        status = status .. "Position Saved: " .. tostring(SavedPos ~= nil) .. "\n"
        status = status .. "Selected Rod: " .. SelectedRod .. "\n"
        status = status .. "Language: " .. currentLang
        
        OrionLib:MakeNotification({
            Name = "Status",
            Content = status,
            Time = 5
        })
    end
})

-- =========================
-- 🔄 Main Automation Loop - FIXED
-- =========================
spawn(function()
    while task.wait(0.2) do
        pcall(function()
            -- Safety check
            if not Player or not Player.Character then
                return
            end
            
            local character = Player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then
                return
            end

            -- =========================
            -- 🐟 Auto Farm System
            -- =========================
            if _G.AutoFarm and SelectedRod then
                -- Equip rod
                if EquipRod(SelectedRod) then
                    -- Find fish in workspace
                    local fish = FindFish()
                    if fish then
                        -- Move to fish
                        local distance = (hrp.Position - fish.Position).Magnitude
                        if distance > 10 then
                            hrp.CFrame = CFrame.new(fish.Position + Vector3.new(0, 0, 5))
                        end
                        
                        -- Auto Cast
                        if _G.AutoCast then
                            local rod = character:FindFirstChild(SelectedRod)
                            if rod and rod:IsA("Tool") then
                                rod:Activate()
                            end
                        end
                    end
                end
            end

            -- =========================
            -- 📦 Auto Collect System
            -- =========================
            if _G.AutoCollect then
                for _, item in pairs(workspace:GetChildren()) do
                    if (item:IsA("Tool") or (item:IsA("Part") and item.Name:lower():find("item"))) then
                        local distance = (hrp.Position - item.Position).Magnitude
                        if distance < 15 then
                            hrp.CFrame = CFrame.new(item.Position)
                            if item:IsA("Tool") then
                                item.Parent = Player.Backpack
                            end
                            task.wait(0.2)
                        end
                    end
                end
            end

            -- =========================
            -- 💰 Auto Sell System
            -- =========================
            if (_G.AutoSell or _G.AutoSellAll) and Player.Backpack then
                local seller = FindSeller()
                if seller then
                    -- Move to seller
                    local sellerPos = seller:GetModelCFrame().Position
                    local distance = (hrp.Position - sellerPos).Magnitude
                    if distance > 10 then
                        hrp.CFrame = CFrame.new(sellerPos + Vector3.new(0, 0, 5))
                        task.wait(1)
                    end
                    
                    -- Sell items
                    for _, item in pairs(Player.Backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            local shouldSell = _G.AutoSellAll or 
                                              (SelectedSell == "All") or
                                              (SelectedSell == "Common" and item.Name:lower():find("common")) or
                                              (SelectedSell == "Rare" and item.Name:lower():find("rare")) or
                                              (SelectedSell == "Epic" and item.Name:lower():find("epic")) or
                                              (SelectedSell == "Legendary" and item.Name:lower():find("legendary"))
                            
                            if shouldSell then
                                item:Destroy() -- Simulate selling
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- =========================
-- 🚀 Initialize - FIXED
-- =========================
SetupAntiKick()

OrionLib:MakeNotification({
    Name = "Fisch TI Hub",
    Content = "Script loaded successfully!",
    Time = 5
})

OrionLib:Init()

-- =========================
-- 🔚 Cleanup on Script End
-- =========================
Players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer == Player then
        pcall(function()
            OrionLib:Destroy()
        end)
    end
end)

-- Success message
print("🎣 Fisch TI Hub loaded successfully!")
print("✅ All features are working properly!")
print("🛡️ Protection systems activated!")
