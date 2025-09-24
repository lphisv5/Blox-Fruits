--// REDZ HUB - Auto Click Center Loop + Close + Drag + Minimize + Settings
--// Free Version | 2025

-- GUI สร้างเอง
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local UICorner2 = Instance.new("UICorner")
local CloseButton = Instance.new("TextButton")
local MinButton = Instance.new("TextButton")
local SettingsButton = Instance.new("TextButton")
local SettingsFrame = Instance.new("Frame")
local UICorner3 = Instance.new("UICorner")

-- ใส่ GUI ให้ผู้เล่น
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame หลัก
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Position = UDim2.new(0.35, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Active = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- Title
Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -90, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "REDZ HUB | Free 2025"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่ม Close (X)
CloseButton.Parent = Frame
CloseButton.BackgroundTransparency = 1
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.TextSize = 18

-- ปุ่ม Minimize (–)
MinButton.Parent = Frame
MinButton.BackgroundTransparency = 1
MinButton.Position = UDim2.new(1, -60, 0, 0)
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Font = Enum.Font.GothamBold
MinButton.Text = "-"
MinButton.TextColor3 = Color3.fromRGB(255, 200, 100)
MinButton.TextSize = 18

-- ปุ่ม Settings (⚙️)
SettingsButton.Parent = Frame
SettingsButton.BackgroundTransparency = 1
SettingsButton.Position = UDim2.new(1, -90, 0, 0)
SettingsButton.Size = UDim2.new(0, 30, 0, 30)
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.Text = "⚙️"
SettingsButton.TextColor3 = Color3.fromRGB(100, 200, 255)
SettingsButton.TextSize = 18

-- ปุ่ม Toggle Loop
ToggleButton.Parent = Frame
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleButton.Position = UDim2.new(0.2, 0, 0.5, 0)
ToggleButton.Size = UDim2.new(0.6, 0, 0.3, 0)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "Start Loop"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14

UICorner2.CornerRadius = UDim.new(0, 8)
UICorner2.Parent = ToggleButton

-- Settings Frame (ซ่อนอยู่ก่อน)
SettingsFrame.Parent = Frame
SettingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsFrame.Position = UDim2.new(0.1, 0, 1, 5)
SettingsFrame.Size = UDim2.new(0, 200, 0, 100)
SettingsFrame.Visible = false
UICorner3.CornerRadius = UDim.new(0, 8)
UICorner3.Parent = SettingsFrame

-- ปุ่มเลือกความเร็ว
local speeds = {0.1, 0.2, 0.5}
for i, v in ipairs(speeds) do
    local btn = Instance.new("TextButton")
    btn.Parent = SettingsFrame
    btn.Size = UDim2.new(1, -10, 0, 25)
    btn.Position = UDim2.new(0, 5, 0, (i - 1) * 30 + 5)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = tostring(v) .. "s"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.MouseButton1Click:Connect(function()
        _G.clickDelay = v
        print("⏱️ ตั้งค่า Click Delay =", v, "วินาที")
        SettingsFrame.Visible = false
    end)
end

-- ตัวแปรควบคุม Loop
local loopRunning = false
local minimized = false
local fullSize = Frame.Size
_G.clickDelay = 0.2

-- ฟังก์ชันคลิกตรงกลางจอ
local function clickCenter()
    local camera = workspace.CurrentCamera
    local viewport = camera.ViewportSize
    local centerX, centerY = viewport.X / 2, viewport.Y / 2
    
    pcall(function()
        setcursorpos(centerX, centerY)
    end)

    pcall(function()
        mouse1click()
    end)
end

-- Toggle Loop
ToggleButton.MouseButton1Click:Connect(function()
    loopRunning = not loopRunning
    if loopRunning then
        ToggleButton.Text = "Stop Loop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        spawn(function()
            while loopRunning do
                clickCenter()
                wait(_G.clickDelay)
            end
        end)
    else
        ToggleButton.Text = "Start Loop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- ปุ่ม Close
CloseButton.MouseButton1Click:Connect(function()
    loopRunning = false
    ScreenGui:Destroy()
    print("❌ REDZ HUB ถูกปิดแล้ว")
end)

-- ปุ่ม Minimize
MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        fullSize = Frame.Size
        Frame.Size = UDim2.new(0, 250, 0, 35)
        ToggleButton.Visible = false
        SettingsFrame.Visible = false
    else
        Frame.Size = fullSize
        ToggleButton.Visible = true
    end
end)

-- ปุ่ม Settings
SettingsButton.MouseButton1Click:Connect(function()
    SettingsFrame.Visible = not SettingsFrame.Visible
end)

-- Drag GUI
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
