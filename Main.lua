--// REDZ HUB - Auto Click With Saved Position
--// Free Version | 2025

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- ========== บันทึกตำแหน่ง ==========
local saveFile = "autoClickPos.json"
local clickPos = nil

-- โหลดค่าที่บันทึกไว้
if isfile and isfile(saveFile) then
    local ok, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(saveFile))
    end)
    if ok and data.X and data.Y then
        clickPos = Vector2.new(data.X, data.Y)
        print("📂 Loaded saved click position:", clickPos)
    end
end

-- ฟังก์ชันบันทึกตำแหน่ง
local function savePosition(vec2)
    local data = {
        X = math.floor(vec2.X),
        Y = math.floor(vec2.Y)
    }
    writefile(saveFile, game:GetService("HttpService"):JSONEncode(data))
    print("💾 Saved position:", data.X, data.Y)
end

-- ฟังก์ชันคลิก
local function doClick()
    if clickPos then
        pcall(function() setcursorpos(clickPos.X, clickPos.Y) end)
        pcall(function() mouse1click() end)
    else
        -- ถ้าไม่มีตำแหน่ง → คลิกกลางจอ
        local cam = workspace.CurrentCamera
        local v = cam.ViewportSize
        pcall(function() setcursorpos(v.X/2, v.Y/2) end)
        pcall(function() mouse1click() end)
    end
end

-- ========== GUI ==========
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 180)
Frame.Position = UDim2.new(0.35, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Text = "🔴 REDZ HUB"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,70,70)
Title.Size = UDim2.new(1, -20, 0, 35)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- ปุ่ม Start Loop
local ToggleButton = Instance.new("TextButton", Frame)
ToggleButton.Size = UDim2.new(0.7, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.15, 0, 0.3, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
ToggleButton.Text = "▶ Start Loop"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.TextColor3 = Color3.new(1,1,1)

local UICorner2 = Instance.new("UICorner", ToggleButton)
UICorner2.CornerRadius = UDim.new(0, 10)

-- ปุ่ม Set Position
local SetPosBtn = Instance.new("TextButton", Frame)
SetPosBtn.Size = UDim2.new(0.7, 0, 0, 35)
SetPosBtn.Position = UDim2.new(0.15, 0, 0.65, 0)
SetPosBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
SetPosBtn.Text = "📍 Set Position"
SetPosBtn.Font = Enum.Font.GothamBold
SetPosBtn.TextSize = 14
SetPosBtn.TextColor3 = Color3.new(1,1,1)

local UICorner3 = Instance.new("UICorner", SetPosBtn)
UICorner3.CornerRadius = UDim.new(0, 10)

-- ========== ระบบ ==========
_G.clickDelay = 0.2
local loopRunning = false

-- Auto Click Loop
ToggleButton.MouseButton1Click:Connect(function()
    loopRunning = not loopRunning
    if loopRunning then
        ToggleButton.Text = "⏹ Stop Loop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
        spawn(function()
            while loopRunning do
                doClick()
                wait(_G.clickDelay)
            end
        end)
    else
        ToggleButton.Text = "▶ Start Loop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
    end
end)

-- Set Position
SetPosBtn.MouseButton1Click:Connect(function()
    -- ใช้เมาส์จริง
    local pos = UserInputService:GetMouseLocation()
    clickPos = Vector2.new(pos.X, pos.Y)
    savePosition(clickPos)
    print("📍 New AutoClick Position:", pos.X, pos.Y)
end)
