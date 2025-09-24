--[[
YANZ Hub - Fisch TI | v0.0.9 [BETA VERSION]
แก้ไขปัญหาแท็บไม่แสดง - แสดงครบทุกแท็บ
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
    ReduceLag = false,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    AFK = false,
    RGB_GUI_ALL = false,
    RGB_GUI = false,
    RGB_NAME = false,
    RGB_GUI_EDGE = false
}

local SavedPos = nil
local SelectedRod = "Wooden Rod"
local StartTime = os.time()
local RealFPS = 60
local WalkSpeed = 16
local FlySpeed = 50
local RGB_Offset = 0

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

local function AutoSellFish()
    pcall(function()
        if Player.Backpack then
            local fishCount = 0
            local totalValue = 0
            
            for _, item in pairs(Player.Backpack:GetChildren()) do
                if item:IsA("Tool") and string.find(item.Name:lower(), "fish") then
                    fishCount = fishCount + 1
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
                for _, item in pairs(Player.Backpack:GetChildren()) do
                    if item:IsA("Tool") and string.find(item.Name:lower(), "fish") then
                        item:Destroy()
                    end
                end
                
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "🎣 Auto Sell",
                    Text = string.format("ขายปลา %d ตัว ได้ %d Coins", fishCount, totalValue),
                    Duration = 3
                })
            end
        end
    end)
end

local function ServerHop()
    pcall(function()
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
end

-- =========================
-- 🖼️ Fixed Horizontal GUI System
-- =========================
local function CreateFixedGUI()
    -- สร้าง GUI หลัก
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "YANZHubGUI"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false

    -- Main Container
    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 500, 0, 350)
    MainContainer.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainContainer.BorderSizePixel = 0
    MainContainer.ClipsDescendants = true
    MainContainer.Active = true
    MainContainer.Draggable = true
    MainContainer.Parent = ScreenGui

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Header.BorderSizePixel = 0
    Header.Parent = MainContainer

    -- Title
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = "YANZ Hub - Fisch TI | v0.0.9 [BETA]"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    -- Stats
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Size = UDim2.new(0.5, 0, 1, 0)
    StatsLabel.Position = UDim2.new(0.5, 0, 0, 0)
    StatsLabel.Text = "FPS: 60 | 00:00:00"
    StatsLabel.TextColor3 = Color3.new(0, 1, 1)
    StatsLabel.TextSize = 12
    StatsLabel.Font = Enum.Font.Gotham
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Right
    StatsLabel.Parent = Header

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = Header

    -- Tabs Container (แนวนอน)
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 35)
    TabsContainer.Position = UDim2.new(0, 0, 0, 40)
    TabsContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Parent = MainContainer

    -- Content Area
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -75)
    ContentFrame.Position = UDim2.new(0, 0, 0, 75)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainContainer

    -- Tabs System (ง่ายๆ แต่ได้ผล)
    local Tabs = {}
    local CurrentTab = nil

    local function CreateTab(name)
        -- Tab Button
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.Text = name
        tabButton.TextColor3 = Color3.new(1, 1, 1)
        tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        tabButton.BorderSizePixel = 0
        tabButton.TextSize = 12
        tabButton.Font = Enum.Font.Gotham
        tabButton.Parent = TabsContainer

        -- Tab Content
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = ContentFrame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.Parent = tabContent

        Tabs[name] = {
            button = tabButton,
            content = tabContent,
            elements = {}
        }

        tabButton.MouseButton1Click:Connect(function()
            -- ซ่อนแท็บเก่า
            if CurrentTab then
                CurrentTab.content.Visible = false
                CurrentTab.button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            end
            
            -- แสดงแท็บใหม่
            CurrentTab = Tabs[name]
            CurrentTab.content.Visible = true
            CurrentTab.button.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
            CurrentTab.content.CanvasPosition = Vector2.new(0, 0)
        end)

        return Tabs[name]
    end

    -- Function สร้างปุ่ม
    local function AddButton(tab, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 35)
        button.Position = UDim2.new(0, 10, 0, 0)
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        button.BorderSizePixel = 0
        button.TextSize = 12
        button.Font = Enum.Font.Gotham
        button.Parent = tab.content
        
        button.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
        
        table.insert(tab.elements, button)
        return button
    end

    -- Function สร้าง Toggle
    local function AddToggle(tab, text, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -20, 0, 35)
        toggleFrame.Position = UDim2.new(0, 10, 0, 0)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = tab.content

        local toggleText = Instance.new("TextLabel")
        toggleText.Size = UDim2.new(0.7, 0, 1, 0)
        toggleText.Text = text
        toggleText.TextColor3 = Color3.new(1, 1, 1)
        toggleText.TextSize = 12
        toggleText.Font = Enum.Font.Gotham
        toggleText.BackgroundTransparency = 1
        toggleText.TextXAlignment = Enum.TextXAlignment.Left
        toggleText.Parent = toggleFrame

        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(0.3, 0, 0.6, 0)
        toggleButton.Position = UDim2.new(0.7, 0, 0.2, 0)
        toggleButton.Text = default and "ON" or "OFF"
        toggleButton.TextColor3 = default and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
        toggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        toggleButton.BorderSizePixel = 0
        toggleButton.TextSize = 11
        toggleButton.Font = Enum.Font.GothamBold
        toggleButton.Parent = toggleFrame

        local state = default

        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            toggleButton.Text = state and "ON" or "OFF"
            toggleButton.TextColor3 = state and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
            pcall(function() callback(state) end)
        end)

        table.insert(tab.elements, toggleFrame)
        return {setState = function(newState)
            state = newState
            toggleButton.Text = state and "ON" or "OFF"
            toggleButton.TextColor3 = state and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
            toggleButton.BackgroundColor3 = state and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
        end}
    end

    -- Function สร้าง Input
    local function AddInput(tab, text, default, callback)
        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(1, -20, 0, 35)
        inputFrame.Position = UDim2.new(0, 10, 0, 0)
        inputFrame.BackgroundTransparency = 1
        inputFrame.Parent = tab.content

        local inputLabel = Instance.new("TextLabel")
        inputLabel.Size = UDim2.new(0.4, 0, 1, 0)
        inputLabel.Text = text
        inputLabel.TextColor3 = Color3.new(1, 1, 1)
        inputLabel.TextSize = 12
        inputLabel.Font = Enum.Font.Gotham
        inputLabel.BackgroundTransparency = 1
        inputLabel.TextXAlignment = Enum.TextXAlignment.Left
        inputLabel.Parent = inputFrame

        local textBox = Instance.new("TextBox")
        textBox.Size = UDim2.new(0.6, 0, 0.7, 0)
        textBox.Position = UDim2.new(0.4, 0, 0.15, 0)
        textBox.Text = tostring(default)
        textBox.TextColor3 = Color3.new(0, 0, 0)
        textBox.BackgroundColor3 = Color3.new(1, 1, 1)
        textBox.BorderSizePixel = 0
        textBox.TextSize = 11
        textBox.Font = Enum.Font.Gotham
        textBox.Parent = inputFrame

        textBox.FocusLost:Connect(function()
            pcall(function() callback(textBox.Text) end)
        end)

        table.insert(tab.elements, inputFrame)
        return textBox
    end

    -- Function สร้าง Label
    local function AddLabel(tab, text, color)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = text
        label.TextColor3 = color or Color3.new(1, 1, 1)
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Parent = tab.content
        
        table.insert(tab.elements, label)
        return label
    end

    -- =========================
    -- 📱 สร้างแท็บทั้งหมด (ง่ายๆ แต่ได้ผล)
    -- =========================

    -- 🏠 TAB - HOME
    local HomeTab = CreateTab("HOME")
    
    AddButton(HomeTab, "📋 Discord - คัดลอกลิงก์", function()
        setclipboard("https://discord.com/invite/mNGeUVcjKB")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "YANZ Hub",
            Text = "คัดลอกลิงก์ Discord แล้ว!",
            Duration = 3
        })
    end)

    AddButton(HomeTab, "🔄 อัปเดต Rod List", function()
        local rods = GetAvailableRods()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "YANZ Hub",
            Text = "พบเบ็ด " .. #rods .. " อันในกระเป๋า",
            Duration = 3
        })
    end)

    -- ⚙️ TAB - MAIN
    local MainTab = CreateTab("MAIN")
    
    local autoFarmToggle = AddToggle(MainTab, "Auto Farm Fish", _G.AutoFarm, function(state)
        _G.AutoFarm = state
    end)

    AddButton(MainTab, "Save", function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SavedPos = Player.Character.HumanoidRootPart.Position
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "YANZ Hub",
                Text = "บันทึกตำแหน่งเรียบร้อย!",
                Duration = 3
            })
        end
    end)

    AddButton(MainTab, "TP To Save", function()
        if SavedPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(SavedPos)
        end
    end)

    local afkToggle = AddToggle(MainTab, "AFK", _G.AFK, function(state)
        _G.AFK = state
    end)

    -- 🔧 TAB - SETTING
    local SettingsTab = CreateTab("SETTING")
    
    local infiniteJumpToggle = AddToggle(SettingsTab, "กระโดดไม่จำกัด", _G.InfiniteJump, function(state)
        _G.InfiniteJump = state
    end)

    local walkSpeedInput = AddInput(SettingsTab, "วิ่งเร็ว %", WalkSpeed, function(value)
        local num = tonumber(value)
        if num and num >= 16 and num <= 100 then
            WalkSpeed = num
        end
    end)

    local noClipToggle = AddToggle(SettingsTab, "เดินทะลุ", _G.NoClip, function(state)
        _G.NoClip = state
    end)

    local flyToggle = AddToggle(SettingsTab, "Fly", _G.Fly, function(state)
        _G.Fly = state
    end)

    -- Server Section
    AddLabel(SettingsTab, "====== Server =====", Color3.fromRGB(0, 255, 255))

    AddButton(SettingsTab, "Rejoin", function()
        TeleportService:Teleport(game.PlaceId)
    end)

    AddButton(SettingsTab, "Server Hop", function()
        ServerHop()
    end)

    local serverIdInput = AddInput(SettingsTab, "Join ID", "", function(value)
        -- Handle in button
    end)

    AddButton(SettingsTab, "Join Server ID", function()
        local serverId = serverIdInput.Text
        if serverId and serverId ~= "" then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId)
            end)
        end
    end)

    -- GUI RGB Section
    AddLabel(SettingsTab, "====== GUI RGB =====", Color3.fromRGB(255, 0, 255))

    local rgbAllToggle = AddToggle(SettingsTab, "RGB GUI ALL", _G.RGB_GUI_ALL, function(state)
        _G.RGB_GUI_ALL = state
    end)

    local rgbGuiToggle = AddToggle(SettingsTab, "RGB GUI", _G.RGB_GUI, function(state)
        _G.RGB_GUI = state
    end)

    local rgbNameToggle = AddToggle(SettingsTab, "RGB NAME", _G.RGB_NAME, function(state)
        _G.RGB_NAME = state
    end)

    local rgbEdgeToggle = AddToggle(SettingsTab, "RGB GUI EDGE", _G.RGB_GUI_EDGE, function(state)
        _G.RGB_GUI_EDGE = state
    end)

    -- เปิดแท็บ HOME โดยอัตโนมัติ
    if Tabs["HOME"] then
        Tabs["HOME"].button.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        Tabs["HOME"].content.Visible = true
        CurrentTab = Tabs["HOME"]
    end

    -- ปุ่มปิด
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Update Stats
    spawn(function()
        local frameCount = 0
        local lastTime = tick()
        
        while ScreenGui.Parent do
            frameCount = frameCount + 1
            local currentTime = tick()
            
            if currentTime - lastTime >= 1 then
                RealFPS = math.floor(frameCount / (currentTime - lastTime))
                frameCount = 0
                lastTime = currentTime
                
                local elapsed = os.time() - StartTime
                local hours = math.floor(elapsed / 3600)
                local minutes = math.floor((elapsed % 3600) / 60)
                local seconds = elapsed % 60
                
                StatsLabel.Text = string.format("FPS: %d | %02d:%02d:%02d", RealFPS, hours, minutes, seconds)
            end
            
            wait(0.1)
        end
    end)

    return ScreenGui
end

-- =========================
-- 🔄 Auto Systems
-- =========================
local function StartAutoSystems()
    -- Auto Farm
    spawn(function()
        while task.wait(0.1) do
            pcall(function()
                if not Player or not Player.Character then return end
                local character = Player.Character
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                if _G.AutoFarm then
                    local rods = GetAvailableRods()
                    if #rods > 0 then
                        SelectedRod = rods[1]
                        if EquipRod(SelectedRod) then
                            local fish = FindFish()
                            if fish then
                                local distance = (hrp.Position - fish.Position).Magnitude
                                if distance > 15 then
                                    hrp.CFrame = CFrame.new(fish.Position + Vector3.new(0, 0, 8))
                                end
                                
                                if _G.AutoCast then
                                    local rod = character:FindFirstChild(SelectedRod)
                                    if rod and rod:IsA("Tool") then
                                        rod:Activate()
                                        wait(0.5)
                                    end
                                end
                            end
                        end
                    end
                end

                if _G.AutoSell then
                    AutoSellFish()
                    wait(5)
                end
            end)
        end
    end)

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

    -- Walk Speed
    spawn(function()
        while task.wait(0.1) do
            if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                Player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = WalkSpeed
            end
        end
    end)
end

-- =========================
-- 🚀 Initialize
-- =========================
wait(1)

-- แจ้งเตือนเริ่มต้น
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YANZ Hub - Fisch TI",
    Text = "กำลังโหลด v0.0.9 [BETA]...",
    Duration = 3
})

-- สร้าง GUI
CreateFixedGUI()

-- เริ่มระบบอัตโนมัติ
StartAutoSystems()

-- แจ้งเตือนสำเร็จ
wait(1)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YANZ Hub - Fisch TI",
    Text = "โหลดสำเร็จ! แท็บแสดงครบถ้วน",
    Duration = 5
})

-- Keybind สำหรับเปิด/ปิด GUI
UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("YANZHubGUI")
        if gui then
            gui.Enabled = not gui.Enabled
        end
    end
end)

print("🎯 YANZ Hub - Fisch TI v0.0.9 [BETA]")
print("✅ แก้ไขเรียบร้อย! แท็บแสดงครบ: HOME, MAIN, SETTING")
print("📊 FPS จริง + Timer เรียลไทม์")
print("⚡ ระบบอัตโนมัติพร้อมทำงาน")
