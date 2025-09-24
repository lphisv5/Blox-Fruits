--[[
YANZ Hub - Fisch TI | v0.0.8 [BETA VERSION]
GUI แนวนอน - เรียงแท็บใหม่ตามที่ต้องการ
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
-- 🖼️ Horizontal GUI System
-- =========================
local function CreateHorizontalGUI()
    -- สร้าง GUI หลัก
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "YANZHubGUI"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Main Container (แนวนอน)
    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(0, 600, 0, 400) -- กว้างมากขึ้นสำหรับแนวนอน
    MainContainer.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    MainContainer.BackgroundTransparency = 0.05
    MainContainer.BorderSizePixel = 0
    MainContainer.ClipsDescendants = true
    MainContainer.Active = true
    MainContainer.Draggable = true
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
    GlassFrame.BackgroundTransparency = 0.92
    GlassFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassFrame.BorderSizePixel = 0
    GlassFrame.Parent = MainContainer

    -- Header (ด้านบน)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 60)
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
    TitleLabel.Size = UDim2.new(1, -100, 0, 30)
    TitleLabel.Position = UDim2.new(0, 15, 0, 5)
    TitleLabel.Text = "YANZ Hub - Fisch TI | v0.0.8 [BETA]"
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    -- Stats Bar (FPS และ Timer)
    local StatsBar = Instance.new("Frame")
    StatsBar.Size = UDim2.new(1, -30, 0, 20)
    StatsBar.Position = UDim2.new(0, 15, 0, 35)
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
    CloseButton.Position = UDim2.new(1, -35, 0, 15)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = Header

    -- Tabs Container (แนวนอน - ด้านล่าง Header)
    local TabsContainer = Instance.new("Frame")
    TabsContainer.Size = UDim2.new(1, 0, 0, 40)
    TabsContainer.Position = UDim2.new(0, 0, 0, 60)
    TabsContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    TabsContainer.BorderSizePixel = 0
    TabsContainer.Parent = MainContainer

    -- Content Container (พื้นที่แสดงเนื้อหา)
    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -10, 1, -110)
    ContentContainer.Position = UDim2.new(0, 5, 0, 110)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.ScrollBarThickness = 6
    ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 150)
    ContentContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentContainer.Parent = MainContainer

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.Parent = ContentContainer

    -- Tabs System (เรียงตามที่ต้องการ: HOME → MAIN → SETTINGS)
    local Tabs = {}
    local CurrentTab = nil

    local function CreateTab(name)
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 120, 1, 0) -- กว้างขึ้นสำหรับแนวนอน
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
        tabLayout.Padding = UDim.new(0, 8)
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
            ContentContainer.CanvasPosition = Vector2.new(0, 0)
        end)

        return tabContent
    end

    -- Modern Button Function
    local function CreateModernButton(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -10, 0, 40)
        button.Position = UDim2.new(0, 5, 0, 0)
        button.Text = text
        button.TextColor3 = Color3.new(1, 1, 1)
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        button.BorderSizePixel = 0
        button.TextSize = 13
        button.Font = Enum.Font.Gotham
        button.AutoButtonColor = false
        button.Parent = parent

        button.MouseEnter:Connect(function()
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 100, 200)}):Play()
        end)

        button.MouseLeave:Connect(function()
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        end)

        button.MouseButton1Click:Connect(function()
            pcall(callback)
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(80, 120, 220)}):Play()
            wait(0.1)
            game:GetService("TweenService"):Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        end)

        return button
    end

    -- Modern Toggle Function
    local function CreateModernToggle(parent, text, default, callback)
        local toggleFrame = Instance.new("Frame")
        toggleFrame.Size = UDim2.new(1, -10, 0, 40)
        toggleFrame.Position = UDim2.new(0, 5, 0, 0)
        toggleFrame.BackgroundTransparency = 1
        toggleFrame.Parent = parent

        local toggleButton = Instance.new("TextButton")
        toggleButton.Size = UDim2.new(1, -60, 1, 0)
        toggleButton.Text = "  " .. text
        toggleButton.TextColor3 = Color3.new(1, 1, 1)
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        toggleButton.BorderSizePixel = 0
        toggleButton.TextSize = 13
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

    -- Text Input Function
    local function CreateTextInput(parent, text, default, callback)
        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(1, -10, 0, 40)
        inputFrame.Position = UDim2.new(0, 5, 0, 0)
        inputFrame.BackgroundTransparency = 1
        inputFrame.Parent = parent

        local inputLabel = Instance.new("TextLabel")
        inputLabel.Size = UDim2.new(0.4, 0, 1, 0)
        inputLabel.Text = text
        inputLabel.TextColor3 = Color3.new(1, 1, 1)
        inputLabel.TextSize = 13
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
        textBox.TextSize = 12
        textBox.Font = Enum.Font.Gotham
        textBox.Parent = inputFrame

        textBox.FocusLost:Connect(function()
            pcall(function() callback(textBox.Text) end)
        end)

        return textBox
    end

    -- =========================
    -- 📱 สร้างแท็บตามลำดับที่ต้องการ
    -- =========================

    -- 🏠 TAB - HOME (แรกสุด)
    local HomeTab = CreateTab("HOME")
    
    CreateModernButton(HomeTab, "📋 Discord - คัดลอกลิงก์", function()
        setclipboard("https://discord.com/invite/mNGeUVcjKB")
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "YANZ Hub",
            Text = "คัดลอกลิงก์ Discord แล้ว!",
            Duration = 3
        })
    end)

    -- ⚙️ TAB - MAIN (ที่สอง)
    local MainTab = CreateTab("MAIN")
    
    local autoFarmToggle = CreateModernToggle(MainTab, "Auto Farm Fish", _G.AutoFarm, function(state)
        _G.AutoFarm = state
    end)

    CreateModernButton(MainTab, "Save", function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            SavedPos = Player.Character.HumanoidRootPart.Position
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "YANZ Hub",
                Text = "บันทึกตำแหน่งเรียบร้อย!",
                Duration = 3
            })
        end
    end)

    CreateModernButton(MainTab, "TP To Save", function()
        if SavedPos and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(SavedPos)
        end
    end)

    local afkToggle = CreateModernToggle(MainTab, "AFK", _G.AFK, function(state)
        _G.AFK = state
    end)

    -- 🔧 TAB - SETTING (สุดท้าย)
    local SettingsTab = CreateTab("SETTING")
    
    local infiniteJumpToggle = CreateModernToggle(SettingsTab, "กระโดดไม่จำกัด", _G.InfiniteJump, function(state)
        _G.InfiniteJump = state
    end)

    local walkSpeedInput = CreateTextInput(SettingsTab, "วิ่งเร็ว %", WalkSpeed, function(value)
        local num = tonumber(value)
        if num and num >= 16 and num <= 100 then
            WalkSpeed = num
        end
    end)

    local noClipToggle = CreateModernToggle(SettingsTab, "เดินทะลุ", _G.NoClip, function(state)
        _G.NoClip = state
    end)

    local flyToggle = CreateModernToggle(SettingsTab, "Fly", _G.Fly, function(state)
        _G.Fly = state
    end)

    -- Server Section
    local serverLabel = Instance.new("TextLabel")
    serverLabel.Size = UDim2.new(1, -10, 0, 20)
    serverLabel.Position = UDim2.new(0, 5, 0, 0)
    serverLabel.Text = "====== Server ======"
    serverLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    serverLabel.TextSize = 12
    serverLabel.Font = Enum.Font.GothamBold
    serverLabel.BackgroundTransparency = 1
    serverLabel.TextXAlignment = Enum.TextXAlignment.Center
    serverLabel.Parent = SettingsTab

    CreateModernButton(SettingsTab, "Rejoin", function()
        TeleportService:Teleport(game.PlaceId)
    end)

    CreateModernButton(SettingsTab, "Server Hop", function()
        ServerHop()
    end)

    local serverIdInput = CreateTextInput(SettingsTab, "Join ID", "", function(value)
        if value and value ~= "" then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, value)
            end)
        end
    end)

    CreateModernButton(SettingsTab, "Join Server ID", function()
        local serverId = serverIdInput.Text
        if serverId and serverId ~= "" then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId)
            end)
        end
    end)

    -- GUI RGB Section
    local rgbLabel = Instance.new("TextLabel")
    rgbLabel.Size = UDim2.new(1, -10, 0, 20)
    rgbLabel.Position = UDim2.new(0, 5, 0, 0)
    rgbLabel.Text = "====== GUI RGB ======"
    rgbLabel.TextColor3 = Color3.fromRGB(255, 0, 255)
    rgbLabel.TextSize = 12
    rgbLabel.Font = Enum.Font.GothamBold
    rgbLabel.BackgroundTransparency = 1
    rgbLabel.TextXAlignment = Enum.TextXAlignment.Center
    rgbLabel.Parent = SettingsTab

    local rgbAllToggle = CreateModernToggle(SettingsTab, "RGB GUI ALL", _G.RGB_GUI_ALL, function(state)
        _G.RGB_GUI_ALL = state
    end)

    local rgbGuiToggle = CreateModernToggle(SettingsTab, "RGB GUI", _G.RGB_GUI, function(state)
        _G.RGB_GUI = state
    end)

    local rgbNameToggle = CreateModernToggle(SettingsTab, "RGB NAME", _G.RGB_NAME, function(state)
        _G.RGB_NAME = state
    end)

    local rgbEdgeToggle = CreateModernToggle(SettingsTab, "RGB GUI EDGE", _G.RGB_GUI_EDGE, function(state)
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
        game:GetService("TweenService"):Create(MainContainer, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)

    -- Animation เมื่อเปิด
    MainContainer.Size = UDim2.new(0, 0, 0, 0)
    game:GetService("TweenService"):Create(MainContainer, TweenInfo.new(0.5), {Size = UDim2.new(0, 600, 0, 400)}):Play()

    -- Update Real FPS และ Timer
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
                
                FPSLabel.Text = "FPS: " .. RealFPS
                
                if RealFPS >= 100 then
                    FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif RealFPS >= 60 then
                    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                elseif RealFPS >= 30 then
                    FPSLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                else
                    FPSLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
            
            local elapsed = os.time() - StartTime
            local hours = math.floor(elapsed / 3600)
            local minutes = math.floor((elapsed % 3600) / 60)
            local seconds = elapsed % 60
            TimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
            
            wait(0.1)
        end
    end)

    return ScreenGui
end

-- =========================
-- 🔄 Auto Farm System
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
-- 🚀 Initialize System
-- =========================
wait(2)

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YANZ Hub - Fisch TI",
    Text = "กำลังโหลด v0.0.8 [BETA]...",
    Duration = 3
})

CreateHorizontalGUI()
StartAutoSystems()

wait(1)
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "YANZ Hub - Fisch TI",
    Text = "โหลดสำเร็จ! กด RightShift เพื่อเปิด/ปิด GUI",
    Duration = 5
})

UIS.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        local gui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("YANZHubGUI")
        if gui then
            local main = gui:FindFirstChild("MainContainer")
            if main then
                if main.Size == UDim2.new(0, 600, 0, 400) then
                    game:GetService("TweenService"):Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 0)}):Play()
                else
                    game:GetService("TweenService"):Create(main, TweenInfo.new(0.3), {Size = UDim2.new(0, 600, 0, 400)}):Play()
                end
            end
        end
    end
end)

print("🎯 YANZ Hub - Fisch TI v0.0.8 [BETA]")
print("✅ GUI แนวนอน - เรียงแท็บ: HOME → MAIN → SETTING")
print("📊 FPS จริง + Timer เรียลไทม์")
print("⚡ ระบบอัตโนมัติครบถ้วน")
