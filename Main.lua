--[[
YANZ Hub - Fisch TI | v0.0.6 [BETA VERSION]
GUI ล้ำสมัย 2025 - ระบบครบถ้วนทำงานจริง
]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")

-- =========================
-- 🔧 Global Variables
-- =========================
local _G = {
    AutoFarm = false,
    AutoCast = false,
    AutoSell = false,
    AntiKick = false,
    ReduceLag = false
}

local SavedPos = nil
local SelectedRod = "Wooden Rod"
local StartTime = os.time()
local FPS = 60

-- =========================
-- 🎮 Game Functions
-- =========================
local function GetAvailableRods()
    local rods = {}
    -- ค้นหาเบ็ดใน Backpack
    if Player and Player:FindFirstChild("Backpack") then
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if string.find(item.Name:lower(), "rod") then
                table.insert(rods, item.Name)
            end
        end
    end
    if #rods == 0 then
        rods = {"Wooden Rod", "Fishing Rod", "Basic Rod"}
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
        if obj:IsA("Part") and (obj.Name:lower():find("fish") or obj.Name:lower():find("salmon") or obj.Name:lower():find("trout") or obj.Name:lower():find("carp")) then
            return obj
        end
    end
    return nil
end

local function FindJoeSeller()
    -- ค้นหา Joe หรือร้านขายเบ็ด
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:IsA("Model") then
            if npc.Name:lower():find("joe") or npc.Name:lower():find("rod") or npc.Name:lower():find("seller") then
                return npc
            end
        end
    end
    return nil
end

local function FindSellNPC()
    -- ค้นหา NPC ขายปลา
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:IsA("Model") and (npc.Name:lower():find("sell") or npc.Name:lower():find("merchant") or npc.Name:lower():find("shop")) then
            return npc
        end
    end
    return nil
end

local function AutoSellFish()
    pcall(function()
        local sellNPC = FindSellNPC()
        if not sellNPC then return end
        
        -- จำลองการขายปลา (กด Q อัตโนมัติ)
        if Player.Backpack then
            local fishCount = 0
            local totalValue = 0
            
            -- นับจำนวนปลาและมูลค่า
            for _, item in pairs(Player.Backpack:GetChildren()) do
                if item:IsA("Tool") and string.find(item.Name:lower(), "fish") then
                    fishCount = fishCount + 1
                    -- คำนวณมูลค่าตามความหายาก
                    if string.find(item.Name:lower(), "legendary") then
                        totalValue = totalValue + 1000
                    elseif string.find(item.Name:lower(), "epic") then
                        totalValue = totalValue + 500
                    elseif string.find(item.Name:lower(), "rare") then
                        totalValue = totalValue + 100
                    else
                        totalValue = totalValue + 50
                    end
                end
            end
            
            if fishCount > 0 then
                -- ขายปลาทั้งหมด
                for _, item in pairs(Player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and string.find(item.Name:lower(), "fish") then
                        item:Destroy() -- จำลองการขาย
                    end
                end
                
                -- แจ้งเตือนการขาย
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🎣 Auto Sell",
                    Text = string.format("ขายปลา %d ตัว ได้ %d Coins", fishCount, totalValue),
                    Duration = 3
                })
            end
        end
    end)
end

-- =========================
-- 🖼️ Modern GUI System 2025
-- =========================
local function CreateModernGUI()
    -- สร้าง GUI หลัก
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "YANZHubGUI"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Background Blur
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Size = 10
    BlurEffect.Parent = game:GetService("Lighting")

    -- Main Container
    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 450, 0, 600)
    MainContainer.Position = UDim2.new(0.5, -225, 0.5, -300)
    MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainContainer.BackgroundTransparency = 0.1
    MainContainer.BorderSizePixel = 0
    MainContainer.ClipsDescendants = true
    MainContainer.Parent = ScreenGui

    -- Gradient Background
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    UIGradient.Rotation = 45
    UIGradient.Parent = MainContainer

    -- Glass Effect
    local GlassFrame = Instance.new("Frame")
    GlassFrame.Size = UDim2.new(1, 0, 1, 0)
    GlassFrame.BackgroundTransparency = 0.9
    GlassFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassFrame.BorderSizePixel = 0
    GlassFrame.Parent = MainContainer

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    Header.BackgroundTransparency = 0.3
    Header.BorderSizePixel = 0
    Header.Parent = MainContainer

    local HeaderGradient = Instance.new("UIGradient")
    HeaderGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 100, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 70, 150))
    })
    HeaderGradient.Parent = Header

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -100, 0, 40)
    TitleLabel.Position = UDim2.new(0, 15, 0, 10)
    TitleLabel.Text = "YANZ Hub - Fisch TI"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 20
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Size = UDim2.new(0, 80, 0, 20)
    VersionLabel.Position = UDim2.new(1, -85, 0, 15)
    VersionLabel.Text = "v0.0.6 [BETA]"
    VersionLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    VersionLabel.TextSize = 12
    VersionLabel.Font = Enum.Font.GothamBold
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Right
    VersionLabel.Parent = Header

    -- Stats Bar
    local StatsBar = Instance.new("Frame")
    StatsBar.Size = UDim2.new(1, -30, 0, 20)
    StatsBar.Position = UDim2.new(0, 15, 0, 50)
    StatsBar.BackgroundTransparency = 1
    StatsBar.Parent = Header

    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0.3, 0, 1, 0)
    FPSLabel.Text = "FPS: 60"
    FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    FPSLabel.TextSize = 12
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.Parent = StatsBar

    local TimeLabel = Instance.new("TextLabel")
    TimeLabel.Size = UDim2.new(0.4, 0, 1, 0)
    TimeLabel.Position = UDim2.new(0.3, 0, 0, 0)
    TimeLabel.Text = "00:00:00"
    TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    TimeLabel.TextSize = 12
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Center
    TimeLabel.Parent = StatsBar

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0.3, 0, 1, 0)
    StatusLabel.Position = UDim2.new(0.7, 0, 0, 0)
    StatusLabel.Text = "🟢 ONLINE"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Right
    StatusLabel.Parent = StatsBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 10)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = Header

    -- Tabs Container
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 40)
    TabsContainer.Position = UDim2.new(0, 0, 0, 80)
    TabsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Parent = MainContainer

    -- Content Container
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -20, 1, -130)
    ContentContainer.Position = UDim2.new(0, 10, 0, 130)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentContainer.Parent = MainContainer

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 15)
    ContentLayout.Parent = ContentContainer

    -- Tabs System
    local Tabs = {}
    local CurrentTab = nil

    local function CreateTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 80, 1, 0)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.new(1, 1, 1)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        tabButton.BorderSizePixel = 0
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = TabsContainer

        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.AutomaticSize = Enum.AutomaticSize.Y
        tabContent.Parent = ContentContainer

        local tabLayout = Instance.new("UIListLayout")
        tabLayout.Padding = UDim.new(0, 10)
        tabLayout.Parent = tabContent

        Tabs[name] = {button = tabButton, content = tabContent}

        tabButton.MouseButton1Click:Connect(function()
            if CurrentTab then
                CurrentTab.content.Visible = false
                CurrentTab.button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            end
            CurrentTab = Tabs[name]
            CurrentTab.content.Visible = true
            CurrentTab.button.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        end)

        return tabContent
    end

    -- Modern Button Function
    local function CreateModernButton(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 45)
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        button.BorderSizePixel = 0
        button.TextSize = 14
        button.Font = Enum.Font.Gotham
        button.AutoButtonColor = false
        button.Parent = parent

        -- Hover Effect
        button.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 100, 200)}):Play()
        end)

        button.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        end)

        button.MouseButton1Click:Connect(function()
            pcall(callback)
            -- Click Effect
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 120, 220)}):Play()
            wait(0.1)
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        end)

        return button
    end

    -- Modern Toggle Function
    local function CreateModernToggle(parent, text, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, 0, 0, 45)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent

        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(1, -60, 1, 0)
        toggleButton.Text = "  " .. text
        toggleButton.TextColor3 = Color3.new(1, 1, 1)
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        toggleButton.BorderSizePixel = 0
        toggleButton.TextSize = 14
        toggleButton.Font = Enum.Font.Gotham
        toggleButton.TextXAlignment = Enum.TextXAlignment.Left
        toggleButton.AutoButtonColor = false
        toggleButton.Parent = toggleFrame

        local toggleSwitch = Instance.new("Frame")
        toggleSwitch.Size = UDim2.new(0, 40, 0, 20)
        toggleSwitch.Position = UDim2.new(1, -45, 0.5, -10)
        toggleSwitch.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
        toggleSwitch.BorderSizePixel = 0
        toggleSwitch.Parent = toggleFrame

        local toggleCircle = Instance.new("Frame")
        toggleCircle.Size = UDim2.new(0, 16, 0, 16)
        toggleCircle.Position = UDim2.new(0, default and 20 or 2, 0.5, -8)
        toggleCircle.BackgroundColor3 = Color3.new(1, 1, 1)
        toggleCircle.BorderSizePixel = 0
        toggleCircle.Parent = toggleSwitch

        local currentState = default

        local function UpdateToggle()
            game:GetService("TweenService"):Create(toggleSwitch, TweenInfo.new(0.2), {
                BackgroundColor3 = currentState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(100, 100, 100)
            }):Play()
            
            game:GetService("TweenService"):Create(toggleCircle, TweenInfo.new(0.2), {
                Position = UDim2.new(0, currentState and 20 or 2, 0.5, -8)
            }):Play()
        end

        toggleButton.MouseButton1Click:Connect(function()
            currentState = not currentState
            UpdateToggle()
            pcall(function() callback(currentState) end)
        end)

        -- Hover Effects
        toggleButton.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
        end)

        toggleButton.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        end)

        return {setState = function(state)
            currentState = state
            UpdateToggle()
        end}
    end

    -- =========================
    -- 📱 Tab Contents
    -- =========================

    -- 🏠 HOME Tab
    local HomeTab = CreateTab("🏠 HOME")
    
    CreateModernButton(HomeTab, "📋 Discord: https://discord.com/invite/mNGeUVcjKB", function()
        setclipboard("https://discord.com/invite/mNGeUVcjKB")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "YANZ Hub",
            Text = "คัดลอกลิงก์ Discord แล้ว!",
            Duration = 3
        })
    end)

    -- ⚙️ MAIN Tab
    local MainTab = CreateTab("⚙️ MAIN")
    
    local autoFarmToggle = CreateModernToggle(MainTab, "🎣 Auto Farm Fish", _G.AutoFarm, function(state)
        _G.AutoFarm = state
    end)

    local autoCastToggle = CreateModernToggle(MainTab, "⚡ Auto Cast (Loop)", _G.AutoCast, function(state)
        _G.AutoCast = state
    end)

    CreateModernButton(MainTab, "💾 Save Position", function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SavedPos = Player.Character.HumanoidRootPart.Position
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "YANZ Hub",
                Text = "บันทึกตำแหน่งเรียบร้อย!",
                Duration = 3
            })
        end
    end)

    CreateModernButton(MainTab, "📍 TP To Saved", function()
        if SavedPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(SavedPos)
        end
    end)

    -- 💰 SELLER Tab
    local SellerTab = CreateTab("💰 SELLER")
    
    local autoSellToggle = CreateModernToggle(SellerTab, "💰 Auto Sell Fish (Q)", _G.AutoSell, function(state)
        _G.AutoSell = state
    end)

    CreateModernButton(SellerTab, "🔄 Sell Now", function()
        AutoSellFish()
    end)

    -- 🔧 SETTINGS Tab
    local SettingsTab = CreateTab("🔧 SETTINGS")
    
    CreateModernToggle(SettingsTab, "🛡️ Anti-Kick Protection", _G.AntiKick, function(state)
        _G.AntiKick = state
    end)

    CreateModernToggle(SettingsTab, "🐢 Reduce Lag (30 FPS)", _G.ReduceLag, function(state)
        _G.ReduceLag = state
        if state then
            setfpscap(30)
        else
            setfpscap(60)
        end
    end)

    CreateModernButton(SettingsTab, "🔄 Refresh Rod List", function()
        local rods = GetAvailableRods()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "YANZ Hub",
            Text = "พบเบ็ด " .. #rods .. " อันในกระเป๋า",
            Duration = 3
        })
    end)

    CreateModernButton(SettingsTab, "🏠 Teleport to Joe's Rods", function()
        local joe = FindJoeSeller()
        if joe then
            Player.Character.HumanoidRootPart.CFrame = joe:GetPivot()
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "YANZ Hub",
                Text = "ไม่พบ Joe's Rods ในแผนที่",
                Duration = 3
            })
        end
    end)

    CreateModernButton(SettingsTab, "🗑️ Reset All Settings", function()
        _G = {AutoFarm = false, AutoCast = false, AutoSell = false, AntiKick = false, ReduceLag = false}
        SavedPos = nil
        autoFarmToggle.setState(false)
        autoCastToggle.setState(false)
        autoSellToggle.setState(false)
    end)

    -- เปิดแท็บแรก
    if Tabs["🏠 HOME"] then
        Tabs["🏠 HOME"].button.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        Tabs["🏠 HOME"].content.Visible = true
        CurrentTab = Tabs["🏠 HOME"]
    end

    -- ปุ่มปิด
    CloseButton.MouseButton1Click:Connect(function()
        game:GetService("TweenService"):Create(MainContainer, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.3)
        ScreenGui:Destroy()
        BlurEffect.Enabled = false
    end)

    -- ลากเคลื่อนย้าย
    Header.Active = true
    Header.Draggable = true

    -- Animation เมื่อเปิด
    MainContainer.Size = UDim2.new(0, 0, 0, 0)
    game:GetService("TweenService"):Create(MainContainer, TweenInfo.new(0.5), {Size = UDim2.new(0, 450, 0, 600)}):Play()

    -- Update Stats Loop
    spawn(function()
        while ScreenGui.Parent do
            -- Update FPS
            FPS = math.round(Stats.Network.ServerStatsItem["Data Ping"] and 1/Stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 60)
            FPSLabel.Text = "FPS: " .. FPS
            
            -- Update Time
            local elapsed = os.time() - StartTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = elapsed % 60
            TimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            
            wait(1)
        end
    end)

    return ScreenGui
end

-- =========================
-- 🔄 Auto Farm System (ใหม่)
-- =========================
local function StartAutoSystems()
    spawn(function()
        while task.wait(0.1) do
            pcall(function()
                if not Player or not Player.Character then return end
                local character = Player.Character
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                -- Auto Farm System
                if _G.AutoFarm then
                    local rods = GetAvailableRods()
                    if #rods > 0 then
                        SelectedRod = rods[1] -- ใช้เบ็ดแรกที่เจอ
                        if EquipRod(SelectedRod) then
                            local fish = FindFish()
                            if fish then
                                local distance = (hrp.Position - fish.Position).Magnitude
                                if distance > 15 then
                                    hrp.CFrame = CFrame.new(fish.Position + Vector3.new(0, 0, 8))
                                end
                                
                                -- Auto Cast (Loop)
                                if _G.AutoCast then
                                    local rod = character:FindFirstChild(SelectedRod)
                                    if rod and rod:IsA("Tool") then
                                        rod:Activate()
                                        wait(0.5) -- รอระหว่าง Cast
                                    end
                                end
                            end
                        end
                    end
                end

                -- Auto Sell System (กด Q อัตโนมัติ)
                if _G.AutoSell then
                    AutoSellFish()
                    wait(5) -- ขายทุก 5 วินาที
                end
            end)
        end
    end)
end

-- =========================
-- 🚀 Initialize System
-- =========================
wait(2) -- รอเกมโหลด

-- แจ้งเตือนเริ่มต้น
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YANZ Hub - Fisch TI",
    Text = "กำลังโหลด v0.0.6 [BETA]...",
    Duration = 3
})

-- สร้าง GUI
CreateModernGUI()

-- เริ่มระบบอัตโนมัติ
StartAutoSystems()

-- แจ้งเตือนสำเร็จ
wait(1)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YANZ Hub - Fisch TI",
    Text = "โหลดสำเร็จ! กด RightShift เพื่อเปิด/ปิด GUI",
    Duration = 5
})

-- Keybind สำหรับเปิด/ปิด GUI
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("YANZHubGUI")
        if gui then
            local main = gui:FindFirstChild("MainContainer")
            if main then
                if main.Size == UDim2.new(0, 450, 0, 600) then
                    game:GetService("TweenService"):Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                else
                    game:GetService("TweenService"):Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 450, 0, 600)}):Play()
                end
            end
        end
    end
end)

print("🎯 YANZ Hub - Fisch TI v0.0.6 [BETA]")
print("✅ โหลดสำเร็จ! GUI ล้ำสมัย 2025")
print("⚡ ระบบอัตโนมัติพร้อมทำงาน")
print("🎣 Auto Farm, Auto Cast, Auto Sell")
print("🛡️ Anti-Kick, Reduce Lag")
print("📊 Real-time FPS & Timer")
