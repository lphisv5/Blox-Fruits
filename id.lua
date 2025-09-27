--// Game Info GUI with Copy Buttons
local TweenService = game:GetService("TweenService")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

-- สร้าง ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameInfoUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.4, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BackgroundTransparency = 0.1
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = Frame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Image = "rbxassetid://5028857084"
Shadow.ImageColor3 = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency = 0.5
Shadow.ZIndex = -1

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "📌 Game Information"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Info Text
local Info = Instance.new("TextLabel")
Info.Parent = Frame
Info.Size = UDim2.new(1, -20, 0, 80)
Info.Position = UDim2.new(0, 10, 0, 40)
Info.BackgroundTransparency = 1
Info.Font = Enum.Font.Gotham
Info.TextSize = 14
Info.TextColor3 = Color3.fromRGB(220, 220, 220)
Info.TextXAlignment = Enum.TextXAlignment.Left
Info.TextYAlignment = Enum.TextYAlignment.Top
Info.TextWrapped = true
Info.Text = "PlaceId: " .. game.PlaceId .. "\nGameId: " .. game.GameId .. "\nUniverseId: " .. game.GameId

-- ปุ่ม Copy สร้างฟังก์ชัน
local function createCopyBtn(name, yPos, value)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Font = Enum.Font.GothamBold
    btn.Text = "📋 Copy " .. name
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1,1,1)

    local UIC = Instance.new("UICorner", btn)
    UIC.CornerRadius = UDim.new(0, 6)

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
    end)

    -- Copy action
    btn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(tostring(value))
        elseif toclipboard then
            toclipboard(tostring(value))
        end
        btn.Text = "✅ Copied " .. name
        wait(1.2)
        btn.Text = "📋 Copy " .. name
    end)
end

-- เรียกปุ่ม Copy
createCopyBtn("PlaceId", 130, game.PlaceId)
createCopyBtn("GameId", 165, game.GameId)
createCopyBtn("UniverseId", 200, game.GameId)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Frame
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,1,1)

local UICorner2 = Instance.new("UICorner", CloseBtn)
UICorner2.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 60, 60)}):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    wait(0.3)
    ScreenGui:Destroy()
end)
