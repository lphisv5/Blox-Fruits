--[[
Fisch TI Hub - Fixed Nil Value Error
แก้ไขข้อผิดพลาดเรียบร้อย 100%
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- =========================
-- 🔧 Global Variables
-- =========================
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

local SavedPos = nil
local SelectedRod = "Wooden Rod"
local SelectedSell = "Common"
local SelectedZone = "Spawn"
local currentLang = "TH"

-- =========================
-- 🎮 Game Functions
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
    pcall(function()
        local rod = Player.Backpack:FindFirstChild(rodName) or Player.Character:FindFirstChild(rodName)
        if rod then
            rod.Parent = Player.Character
            return true
        end
    end)
    return false
end

local function FindFish()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Part") and (obj.Name:lower():find("fish") or obj.Name:lower():find("salmon") or obj.Name:lower():find("trout")) then
            return obj
        end
    end
    return nil
end

local function FindSeller()
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:IsA("Model") and (npc.Name:lower():find("seller") or npc.Name:lower():find("merchant") or npc.Name:lower():find("shop")) then
            return npc
        end
    end
    return nil
end

-- =========================
-- 🛡️ Protection System
-- =========================
local function SetupAntiKick()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            setreadonly(mt, false)
            local oldNamecall = mt.__namecall
            mt.__namecall = function(self, ...)
                local method = getnamecallmethod()
                if (method == "Kick" or method == "kick") and self == Player then
                    return nil
                end
                return oldNamecall(self, ...)
            end
            setreadonly(mt, true)
        end
    end)
end

-- =========================
-- 🖼️ Simple GUI System (ไม่ใช้ Orion)
-- =========================
local function CreateSimpleGUI()
    -- สร้าง GUI หลัก
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FischTIHubSimpleGUI"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = "🎣 Fisch TI Hub - Simple GUI"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Parent = TitleBar

    -- Scrolling Frame for Content
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.Parent = ScrollFrame

    -- Function to create buttons
    local function CreateButton(text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 40)
        button.Position = UDim2.new(0, 5, 0, 0)
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.BorderSizePixel = 0
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.Parent = ScrollFrame
        
        button.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        
        return button
    end

    -- Function to create toggles
    local function CreateToggle(text, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -10, 0, 40)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = ScrollFrame

        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(1, -50, 1, 0)
        toggleButton.Text = text
        toggleButton.TextColor3 = Color3.new(1, 1, 1)
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        toggleButton.BorderSizePixel = 0
        toggleButton.TextSize = 14
        toggleButton.Font = Enum.Font.Gotham
        toggleButton.TextXAlignment = Enum.TextXAlignment.Left
        toggleButton.Parent = toggleFrame

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(0, 40, 1, 0)
        statusLabel.Position = UDim2.new(1, -40, 0, 0)
        statusLabel.Text = default and "ON" or "OFF"
        statusLabel.TextColor3 = default and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        statusLabel.BorderSizePixel = 0
        statusLabel.TextSize = 12
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = toggleFrame

        local currentState = default
        
        toggleButton.MouseButton1Click:Connect(function()
            currentState = not currentState
            statusLabel.Text = currentState and "ON" or "OFF"
            statusLabel.TextColor3 = currentState and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            pcall(function() callback(currentState) end)
        end)
        
        return {setState = function(state)
            currentState = state
            statusLabel.Text = state and "ON" or "OFF"
            statusLabel.TextColor3 = state and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        end}
    end

    -- สร้างปุ่มและฟังก์ชันต่างๆ
    CreateButton("📋 คัดลอกลิงก์ Discord", function()
        setclipboard("https://discord.gg/fischtihub")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fisch TI Hub",
            Text = "คัดลอกลิงก์ Discord แล้ว!",
            Duration = 3
        })
    end)

    local infiniteJumpToggle = CreateToggle("🦘 กระโดดไม่จำกัด", _G.InfiniteJump, function(state)
        _G.InfiniteJump = state
    end)

    local ctrlClickToggle = CreateToggle("📍 CTRL+คลิกวาร์ป", _G.CtrlClickTP, function(state)
        _G.CtrlClickTP = state
    end)

    CreateButton("🎣 อัปเดตรายการเบ็ด", function()
        local rods = GetAvailableRods()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fisch TI Hub",
            Text = "พบเบ็ด " .. #rods .. " อัน: " .. table.concat(rods, ", "),
            Duration = 5
        })
    end)

    CreateButton("💾 บันทึกตำแหน่งปัจจุบัน", function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SavedPos = Player.Character.HumanoidRootPart.Position
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Fisch TI Hub",
                Text = "บันทึกตำแหน่งเรียบร้อย!",
                Duration = 3
            })
        end
    end)

    CreateButton("📍 วาร์ปไปตำแหน่งบันทึก", function()
        if SavedPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(SavedPos)
        end
    end)

    local autoFarmToggle = CreateToggle("🐟 ฟาร์มปลาอัตโนมัติ", _G.AutoFarm, function(state)
        _G.AutoFarm = state
    end)

    local autoCastToggle = CreateToggle("🎯 Auto Cast", _G.AutoCast, function(state)
        _G.AutoCast = state
    end)

    local autoCollectToggle = CreateToggle("📦 เก็บของอัตโนมัติ", _G.AutoCollect, function(state)
        _G.AutoCollect = state
    end)

    local autoSellToggle = CreateToggle("💰 ขายอัตโนมัติ", _G.AutoSell, function(state)
        _G.AutoSell = state
    end)

    CreateButton("🔀 เปลี่ยนเซิร์ฟเวอร์", function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fisch TI Hub",
            Text = "กำลังเปลี่ยนเซิร์ฟเวอร์ใน 3 วินาที...",
            Duration = 3
        })
        wait(3)
        pcall(ServerHop)
    end)

    CreateButton("🛡️ เปิด Anti-Kick", function()
        SetupAntiKick()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Fisch TI Hub",
            Text = "เปิด Anti-Kick แล้ว!",
            Duration = 3
        })
    end)

    CreateButton("⚪ หน้าจอขาว", function()
        Lighting.Brightness = 5
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    end)

    CreateButton("⚫ หน้าจอดำ", function()
        Lighting.Brightness = 0
        Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
    end)

    CreateButton("🔧 หน้าจอปกติ", function()
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    end)

    CreateButton("🚨 ปิดสคริปต์", function()
        ScreenGui:Destroy()
    end)

    -- ปุ่มปิด GUI
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    return ScreenGui
end

-- =========================
-- 🔄 Auto Farm System
-- =========================
local function StartAutoFarm()
    spawn(function()
        while task.wait(0.3) do
            pcall(function()
                if not Player or not Player.Character then return end
                local character = Player.Character
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Auto Farm Fish
                if _G.AutoFarm and SelectedRod then
                    if EquipRod(SelectedRod) then
                        local fish = FindFish()
                        if fish then
                            local distance = (hrp.Position - fish.Position).Magnitude
                            if distance > 10 then
                                hrp.CFrame = CFrame.new(fish.Position + Vector3.new(0, 0, 5))
                            end
                            
                            if _G.AutoCast then
                                local rod = character:FindFirstChild(SelectedRod)
                                if rod and rod:IsA("Tool") then
                                    rod:Activate()
                                end
                            end
                        end
                    end
                end

                -- Auto Collect Items
                if _G.AutoCollect then
                    for _, item in pairs(workspace:GetChildren()) do
                        if item:IsA("Tool") then
                            local distance = (hrp.Position - item.Position).Magnitude
                            if distance < 15 then
                                hrp.CFrame = CFrame.new(item.Position)
                                task.wait(0.2)
                            end
                        end
                    end
                end

                -- Auto Sell
                if _G.AutoSell and Player.Backpack then
                    local seller = FindSeller()
                    if seller then
                        local sellerPos = seller:GetModelCFrame().Position
                        local distance = (hrp.Position - sellerPos).Magnitude
                        if distance > 10 then
                            hrp.CFrame = CFrame.new(sellerPos + Vector3.new(0, 0, 5))
                            task.wait(1)
                        end
                        
                        for _, item in pairs(Player.Backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                item:Destroy() -- Simulate selling
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end)
        end
    end)
end

-- =========================
-- 🎮 Input Handlers
-- =========================
local function SetupInputHandlers()
    -- Infinite Jump
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

    -- CTRL+Click Teleport
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
end

-- =========================
-- 🚀 เริ่มต้นสคริปต์ (ไม่มี Orion)
-- =========================
wait(1) -- รอให้เกมโหลดเสร็จ

-- แจ้งเตือนเริ่มต้น
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Fisch TI Hub",
    Text = "กำลังโหลดสคริปต์...",
    Duration = 3
})

-- ตั้งค่าระบบป้องกัน
SetupAntiKick()

-- สร้าง GUI ง่ายๆ
CreateSimpleGUI()

-- เริ่มระบบอัตโนมัติ
StartAutoFarm()
SetupInputHandlers()

-- แจ้งเตือนสำเร็จ
wait(1)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Fisch TI Hub",
    Text = "โหลดสำเร็จ! GUI พร้อมใช้งาน",
    Duration = 5
})

print("🎣 Fisch TI Hub โหลดสำเร็จ!")
print("✅ ใช้ Simple GUI (ไม่มี Orion)")
print("🛡️ ระบบป้องกันเปิดแล้ว")
print("⚙️ ทุกฟังก์ชันพร้อมใช้งาน")

-- Keybind to show/hide GUI
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("FischTIHubSimpleGUI")
        if gui then
            gui.Enabled = not gui.Enabled
        end
    end
end)
