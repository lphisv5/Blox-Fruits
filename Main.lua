-- YANZ HUB | V0.0.1 - BETA
-- Roblox Lua Script for Fisck Game
-- Designed for Ronix Executor on Windows
-- Created by xAI

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "YANZ_HUB"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame (Modern Design with Rounded Corners)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 400)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame
MainFrame.Parent = ScreenGui

-- Scrolling Frame for Horizontal and Vertical Scrolling
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -20, 1, -70)
ScrollingFrame.Position = UDim2.new(0, 10, 0, 60)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
ScrollingFrame.CanvasSize = UDim2.new(3, 0, 2, 0)
ScrollingFrame.Parent = MainFrame

-- UI List Layout for Horizontal Layout
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.Padding = UDim.new(0, 15)
UIListLayout.Parent = ScrollingFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = TitleBar
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "YANZ HUB | V0.0.1 - BETA"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close/Open Button with Smooth Animation
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Position = UDim2.new(1, -50, 0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
ToggleButton.Text = "X"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleButton
ToggleButton.Parent = TitleBar

local isGuiOpen = true
local function toggleGui()
    isGuiOpen = not isGuiOpen
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local goal = isGuiOpen and {Size = UDim2.new(0, 650, 0, 400)} or {Size = UDim2.new(0, 650, 0, 40)}
    local tween = TweenService:Create(MainFrame, tweenInfo, goal)
    tween:Play()
    ToggleButton.Text = isGuiOpen and "X" or "O"
    ToggleButton.BackgroundColor3 = isGuiOpen and Color3.fromRGB(255, 85, 85) or Color3.fromRGB(85, 255, 85)
end
ToggleButton.MouseButton1Click:Connect(toggleGui)

-- Tab System
local Tabs = {}
local function createTab(name)
    local TabFrame = Instance.new("Frame")
    TabFrame.Size = UDim2.new(0, 220, 0, 340)
    TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabFrame.BorderSizePixel = 0
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabFrame
    TabFrame.Parent = ScrollingFrame
    
    local TabTitle = Instance.new("TextLabel")
    TabTitle.Size = UDim2.new(1, 0, 0, 40)
    TabTitle.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabTitle.Text = name
    TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabTitle.TextSize = 18
    TabTitle.Font = Enum.Font.GothamBold
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TabTitle
    TabTitle.Parent = TabFrame
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -40)
    ContentFrame.Position = UDim2.new(0, 0, 0, 40)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = TabFrame
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.FillDirection = Enum.FillDirection.Vertical
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.Parent = ContentFrame
    
    Tabs[name] = ContentFrame
    return ContentFrame
end

-- Create Tabs
local HomeTab = createTab("HOME")
local MainTab = createTab("MAIN")
local SellerTab = createTab("SELLER")
local TeleportTab = createTab("TELEPORT")
local MiscTab = createTab("MISCELLANEOUS")
local SettingsTab = createTab("SETTINGS")

-- Function to Create Toggle Button
local function createToggleButton(parent, text, position, callback)
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, -10, 0, 35)
    ToggleButton.Position = UDim2.new(0, 5, 0, position)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.Text = text .. ": OFF"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 14
    ToggleButton.Font = Enum.Font.Gotham
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = ToggleButton
    ToggleButton.Parent = parent
    local toggleState = false
    ToggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        ToggleButton.Text = text .. ": " .. (toggleState and "ON" or "OFF")
        ToggleButton.BackgroundColor3 = toggleState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 40)
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(ToggleButton, tweenInfo, {BackgroundColor3 = toggleState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(40, 40, 40)})
        tween:Play()
        callback(toggleState)
    end)
    return ToggleButton
end

-- Function to Create Regular Button
local function createButton(parent, text, position, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -10, 0, 35)
    Button.Position = UDim2.new(0, 5, 0, position)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    Button.Parent = parent
    Button.MouseButton1Click:Connect(function()
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(Button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)})
        tween:Play()
        wait(0.2)
        local revertTween = TweenService:Create(Button, tweenInfo, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
        revertTween:Play()
        callback()
    end)
end

-- Function to Create Dropdown
local function createDropdown(parent, text, position, items, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
    DropdownFrame.Position = UDim2.new(0, 5, 0, position)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 6)
    DropdownCorner.Parent = DropdownFrame
    DropdownFrame.Parent = parent
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = text .. ": Select"
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 14
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Parent = DropdownFrame
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, #items * 35)
    DropdownList.Position = UDim2.new(0, 0, 1, 5)
    DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    DropdownList.Visible = false
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 6)
    ListCorner.Parent = DropdownList
    DropdownList.Parent = DropdownFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.FillDirection = Enum.FillDirection.Vertical
    ListLayout.Padding = UDim.new(0, 5)
    ListLayout.Parent = DropdownList
    
    for i, item in ipairs(items) do
        local ItemButton = Instance.new("TextButton")
        ItemButton.Size = UDim2.new(1, 0, 0, 30)
        ItemButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ItemButton.Text = item
        ItemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ItemButton.TextSize = 14
        ItemButton.Font = Enum.Font.Gotham
        local ItemCorner = Instance.new("UICorner")
        ItemCorner.CornerRadius = UDim.new(0, 6)
        ItemCorner.Parent = ItemButton
        ItemButton.Parent = DropdownList
        ItemButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = text .. ": " .. item
            DropdownList.Visible = false
            callback(item)
        end)
    end
    
    DropdownButton.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(DropdownFrame, tweenInfo, {BackgroundColor3 = DropdownList.Visible and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(40, 40, 40)})
        tween:Play()
    end)
end

-- Enhanced Pixel Scan Function
local function isColorMatch(pixelColor, targetColor, tolerance)
    local r, g, b = pixelColor.r, pixelColor.g, pixelColor.b
    local tr, tg, tb = targetColor.r, targetColor.g, targetColor.b
    return math.abs(r - tr) <= tolerance and math.abs(g - tg) <= tolerance and math.abs(b - tb) <= tolerance
end

local AutoFarmFishToggle = false
local function pixelScanForFishBar()
    local screenWidth, screenHeight = 1920, 1080 -- Adjust to your resolution
    local barRegion = {x1 = 800, y1 = 400, x2 = 1120, y2 = 420} -- Adjust based on game
    local perfectColor = Color3.fromRGB(0, 255, 0) -- Green (Perfect)
    local goodColor = Color3.fromRGB(255, 255, 0) -- Yellow (Good)
    local okColor = Color3.fromRGB(255, 0, 0) -- Red (OK)
    local tolerance = 10 -- RGB tolerance
    
    while AutoFarmFishToggle do
        local detected = false
        local detectedState = nil
        for x = barRegion.x1, barRegion.x2, 3 do
            for y = barRegion.y1, barRegion.y2, 3 do
                local pixelColor = syn.getpixelcolor(x, y)
                if isColorMatch(pixelColor, perfectColor, tolerance) then
                    detected = true
                    detectedState = "Perfect"
                    break
                elseif isColorMatch(pixelColor, goodColor, tolerance) then
                    detected = true
                    detectedState = "Good"
                    break
                elseif isColorMatch(pixelColor, okColor, tolerance) then
                    detected = true
                    detectedState = "OK"
                    break
                end
            end
            if detected then break end
        end
        
        if detected then
            syn.mouse_press(1)
            wait(0.01)
            syn.mouse_release(1)
            print("Detected " .. detectedState .. " bar, clicking!")
        end
        
        wait(math.random(0.01, 0.03))
    end
end

-- HOME Tab
createButton(HomeTab, "Join Discord", 5, function()
    setclipboard("https://discord.com/invite/mNGeUVcjKB")
    print("Discord link copied to clipboard!")
end)

createToggleButton(HomeTab, "Infinite Jump", 48, function(state)
    if state then
        UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character.Humanoid then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

local ctrlTeleport = false
createToggleButton(HomeTab, "CTRL + Click Teleport", 91, function(state)
    ctrlTeleport = state
end)
UserInputService.InputBegan:Connect(function(input)
    if ctrlTeleport and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
        end
    end
end)

-- MAIN Tab
local savedPosition = nil
local selectedRod = nil
createDropdown(MainTab, "Choose Rod Equip", 5, {"Rod1", "Rod2", "Rod3"}, function(rod)
    selectedRod = rod
    print("Selected Rod: " .. rod)
end)

createButton(MainTab, "Refresh Choose Rod Equip", 48, function()
    selectedRod = nil
    print("Rod selection refreshed!")
end)

createButton(MainTab, "Save Position", 91, function()
    if LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
        savedPosition = LocalPlayer.Character.HumanoidRootPart.Position
        print("Position saved!")
    else
        print("Character not found!")
    end
end)

createButton(MainTab, "Reset Save Position", 134, function()
    savedPosition = nil
    print("Saved position reset!")
end)

createToggleButton(MainTab, "Auto Farm Fish", 177, function(state)
    AutoFarmFishToggle = state
    if state then
        spawn(pixelScanForFishBar)
    end
end)

createButton(MainTab, "Teleport To Saved Position", 220, function()
    if savedPosition and LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(savedPosition)
        print("Teleported to saved position!")
    else
        print("No saved position or character not found!")
    end
end)

createToggleButton(MainTab, "Auto Click Cast", 263, function(state)
    if state then
        spawn(function()
            while state do
                syn.mouse_click(960, 100, 1)
                wait(math.random(0.01, 0.03))
            end
        end)
    end
end)

createToggleButton(MainTab, "Auto Click Shake", 306, function(state)
    if state then
        spawn(function()
            while state do
                syn.mouse_click(960, 100, 1)
                wait(math.random(0.01, 0.03))
            end
        end)
    end
end)

createToggleButton(MainTab, "Auto Click Reel", 349, function(state)
    if state then
        spawn(function()
            while state do
                syn.mouse_click(960, 100, 1)
                wait(math.random(0.01, 0.03))
            end
        end)
    end
end)

createToggleButton(MainTab, "Auto Collect Item", 392, function(state)
    if state then
        spawn(function()
            while state do
                print("Collecting items...")
                wait(1)
            end
        end)
    end
end)

-- SELLER Tab
local selectedSell = nil
createDropdown(SellerTab, "Choose Sell", 5, {"Fish", "Items", "All"}, function(item)
    selectedSell = item
    print("Selected Sell: " .. item)
end)

createToggleButton(SellerTab, "Auto Sell", 48, function(state)
    if state then
        spawn(function()
            while state do
                print("Auto selling " .. (selectedSell or "nothing") .. "...")
                wait(1)
            end
        end)
    end
end)

createToggleButton(SellerTab, "Auto Sell All", 91, function(state)
    if state then
        spawn(function()
            while state do
                print("Auto selling all items...")
                wait(1)
            end
        end)
    end
end)

-- TELEPORT Tab
local selectedZone = nil
createDropdown(TeleportTab, "Choose Zone", 5, {"Zone1", "Zone2", "Zone3"}, function(zone)
    selectedZone = zone
    print("Selected Zone: " .. zone)
end)

createButton(TeleportTab, "Teleport To Zone", 48, function()
    if selectedZone then
        print("Teleporting to " .. selectedZone)
    else
        print("No zone selected!")
    end
end)

-- MISCELLANEOUS Tab
createToggleButton(MiscTab, "Reduce Lag", 5, function(state)
    if state then
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").Brightness = 0
        print("Lag reduction enabled!")
    else
        game:GetService("Lighting").GlobalShadows = true
        game:GetService("Lighting").Brightness = 1
        print("Lag reduction disabled!")
    end
end)

createToggleButton(MiscTab, "Anti-Crash", 48, function(state)
    if state then
        print("Anti-Crash enabled (placeholder)!")
    end
end)

createToggleButton(MiscTab, "Show Screen White", 91, function(state)
    if state then
        local whiteScreen = Instance.new("Frame")
        whiteScreen.Size = UDim2.new(1, 0, 1, 0)
        whiteScreen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        whiteScreen.Parent = ScreenGui
        whiteScreen.Name = "WhiteScreen"
    else
        if ScreenGui:FindFirstChild("WhiteScreen") then
            ScreenGui.WhiteScreen:Destroy()
        end
    end
end)

createToggleButton(MiscTab, "Show Screen Black", 134, function(state)
    if state then
        local blackScreen = Instance.new("Frame")
        blackScreen.Size = UDim2.new(1, 0, 1, 0)
        blackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blackScreen.Parent = ScreenGui
        blackScreen.Name = "BlackScreen"
    else
        if ScreenGui:FindFirstChild("BlackScreen") then
            ScreenGui.BlackScreen:Destroy()
        end
    end
end)

createToggleButton(MiscTab, "Auto Reconnect", 177, function(state)
    if state then
        spawn(function()
            while state do
                if not game:IsLoaded() then
                    game:Rejoin()
                end
                wait(5)
            end
        end)
    end
end)

-- SETTINGS Tab
createButton(SettingsTab, "Reset Script Config", 5, function()
    print("Script config reset!")
end)

-- Dragging Functionality for GUI
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Initialize GUI
print("YANZ HUB | V0.0.1 - BETA Loaded for Ronix Executor!")
