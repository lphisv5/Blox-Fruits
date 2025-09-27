-- =========================================
-- YANZ HUB | Auto Click Only | Fixed Version 2
-- Now compatible with the specific NOTHING UI Library
-- =========================================

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Character
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Load VirtualInputManager
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

-- Load NOTHING UI Library
local ok_lib, NothingLibrary = pcall(function()
    -- โหลดโค้ด Library จาก GitHub
    local lib_source = game:HttpGet('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua')
    -- รันโค้ด Library แล้วรับค่าที่คืนกลับมา
    return loadstring(lib_source)()
end)

if not ok_lib or not NothingLibrary then
    warn("YANZ HUB: Failed to load NOTHING UI Library!")
    return
end

-- Debug library methods (Optional)
print("NothingLibrary methods:")
for k, v in pairs(NothingLibrary) do
    print(k, type(v))
end

-- Create GUI Window using the correct function name
local Window
local ok_window, res_window = pcall(function()
    -- ใช้ Library.New แทน CreateWindow หรือ new
    -- โครงสร้างของ Library.New (หรือ NewAuth ในโค้ดต้นฉบับ) ต้องการ config ที่มี Title, Description, Keybind
    return NothingLibrary.New({
        Title = "YANZ HUB | Auto Click Only",
        Description = "By lphisv5",
        Keybind = Enum.KeyCode.RightShift,
        Size = UDim2.new(0.15, 0, 0.25, 0), -- เพิ่มขนาด (Optional)
    })
end)

if not ok_window or not res_window then
    warn("YANZ HUB: NewWindow failed! Error:", res_window)
    return
end
Window = res_window -- ตอนนี้ Window คือ WindowTable ที่ได้จาก Library.New

-- Tabs & Sections
-- ใช้เมธอดของ Window ที่ได้จาก Library.New
local AutoClickTab = Window:NewTab({
    Title = "Auto Clicker",
    Description = "Auto Click Features",
    Icon = nil -- หลีกเลี่ยง asset errors หากมี
})
local AutoClickSection = AutoClickTab:NewSection({
    Title = "Controls",
    Position = "Left", -- Library นี้อาจไม่ใช้ Position แบบ Left/Right ตรงๆ แต่จะจัดเรียงใน Tab
    Icon = nil
})
local SettingsSection = AutoClickTab:NewSection({
    Title = "Speed Settings",
    Position = "Right",
    Icon = nil
})
local PositionSection = AutoClickTab:NewSection({
    Title = "Player Position",
    Position = "Right",
    Icon = nil
})

-- Labels (ใช้ NewTitle หรือ NewLabel ถ้ามี, ถ้าไม่มี ใช้ Label หรือ TextLabel ธรรมดาก็ได้)
-- Library นี้ใช้ NewToggle, NewButton, NewDropdown ได้ตามปกติ
-- เราจะใช้ Title ของ Section หรือ Toggle/Button สำหรับแสดงสถานะแทน Label
local StatusTitle = AutoClickSection:NewToggle({
    Title = "Status: Ready", -- ใช้ Title แสดงสถานะ
    Default = false,
    Callback = function(value) -- ไม่ต้องทำอะไรกับ toggle นี้จริงๆ
        -- เปลี่ยน Title ตอนเปิด/ปิด
        -- แต่เราจะใช้ Callback ของ Auto Click Toggle หลักแทน
    end
})

-- เราจะใช้ Title ของ StatusTitle นี้ในการเปลี่ยนข้อความ
-- ต้องเก็บ reference ไว้ แต่ Library นี้ไม่ได้คืนค่า Object ที่มี SetTitle ให้โดยตรง
-- วิธีแก้: ใช้ Title ของ Toggle/Button หรือสร้าง Toggle/Button ว่างๆ ไว้แสดงสถานะ
-- หรือใช้ TextLabel ที่สร้างเอง แล้วอัปเดตผ่าน script ของเรา
-- วิธีที่ง่ายที่สุดคือใช้ Title ของ Toggle/Button ที่มี Callback ไม่ทำอะไร

-- ใช้ Toggle ว่างๆ สำหรับแสดงสถานะ
local statusToggle = AutoClickSection:NewToggle({
    Title = "Status: Ready",
    Default = false,
    Callback = function(value) -- ไม่ต้องทำอะไร
    end
})

-- ใช้ Button ว่างๆ สำหรับแสดงตำแหน่ง
local posButton = PositionSection:NewButton({
    Title = "Player Pos: Waiting...",
    Callback = function() -- ไม่ต้องทำอะไร
    end
})

-- Global Variables
_G.clickDelay = 0.1
_G.autoClickPos = {X = nil, Y = nil}
_G.isLoopRunning = false

-- Connections manager
local connections = {}
local function addConn(conn) if conn then table.insert(connections, conn) end return conn end

-- SafeClick function
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    if not VirtualInputManager then
        warn("⚠️ VirtualInputManager not available")
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    if pos.X < 0 or pos.Y < 0 or pos.X > viewport.X or pos.Y > viewport.Y then
        warn("⚠️ Invalid click position", pos.X, pos.Y, "Viewport:", viewport)
        return
    end
    local tried = {}
    local function trySig(target)
        local ok, err = pcall(function()
            if target == "workspace" then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, workspace, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, workspace, 1)
            elseif target == "game" then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
            else
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, cam, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, cam, 1)
            end
        end)
        if not ok then table.insert(tried, err) end
        return ok
    end
    if trySig("workspace") then return end
    if trySig("game") then return end
    if trySig("camera") then return end
    warn("❌ SafeClick: all attempts failed. Errors:", tried)
end

-- Click Loop
local function ClickLoop()
    if _G.autoClickPos.X and _G.autoClickPos.Y then
        SafeClick(_G.autoClickPos)
    else
        local cam = workspace.CurrentCamera
        if not cam then return end
        local viewport = cam.ViewportSize
        SafeClick({X = viewport.X / 2, Y = viewport.Y / 2})
    end
end

-- Auto Click Toggle
AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = _G.isLoopRunning,
    Callback = function(value)
        _G.isLoopRunning = value
        -- เปลี่ยน Title ของ statusToggle ที่เราสร้างไว้
        statusToggle.Callback("Status: " .. (value and "Auto Clicking Active" or "Ready"))
        if value then
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    task.wait(_G.clickDelay)
                end
            end)
        end
    end
})

-- Set Click Position Button
AutoClickSection:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        -- อัปเดตสถานะ
        statusToggle.Callback("Status: 🖱️ Click anywhere to set position...")
        local setting = true
        local conn
        conn = addConn(UserInputService.InputBegan:Connect(function(input, processed)
            if processed or not setting then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                _G.autoClickPos = {X = mousePos.X, Y = mousePos.Y}
                statusToggle.Callback("Status: ✅ Position set: " .. math.floor(mousePos.X) .. ", " .. math.floor(mousePos.Y))
                pcall(function()
                    NothingLibrary.Notification({
                        Title = "Position Set",
                        Content = "Click position set to X: " .. math.floor(mousePos.X) .. ", Y: " .. math.floor(mousePos.Y),
                        Duration = 3
                    })
                end)
                setting = false
                if conn then conn:Disconnect() end
            end
        end))
        task.delay(10, function()
            if setting then
                setting = false
                if conn then conn:Disconnect() end
                statusToggle.Callback("Status: ❌ Position set cancelled")
                pcall(function()
                    NothingLibrary.Notification({
                        Title = "Position Set Cancelled",
                        Content = "Click position setting was cancelled",
                        Duration = 3
                    })
                end)
            end
        end)
    end
})

-- Speed Settings Dropdown
local speedOptions = {0.01, 0.5, 1, 1.5}
SettingsSection:NewDropdown({
    Title = "Click Speed",
    Default = tostring(_G.clickDelay),
    Options = speedOptions,
    Callback = function(value)
        _G.clickDelay = tonumber(value)
        statusToggle.Callback("Status: Delay: " .. value .. "s")
        pcall(function()
            NothingLibrary.Notification({
                Title = "Speed Updated",
                Content = "Click delay set to " .. value .. "s",
                Duration = 2
            })
        end)
    end
})

-- Player Position Updater
local function startPositionUpdater(character)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local renderConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                posButton.Callback(string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
            else
                posButton.Callback("Player Pos: Waiting...")
            end
        end)
    end)
    addConn(renderConn)
end

if LocalPlayer.Character then
    startPositionUpdater(LocalPlayer.Character)
end
addConn(LocalPlayer.CharacterAdded:Connect(function(char)
    startPositionUpdater(char)
end))

-- Emergency Stop (F6)
addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        -- อัปเดต Toggle หลัก (ถ้า Library ให้เราอัปเดตค่า Toggle ได้)
        -- โค้ดเดิมพยายามหา Toggle แล้ว Set ค่า ซึ่ง Library นี้อาจไม่รองรับ
        -- เราจะใช้ Callback ของ Toggle หลักอีกครั้งเพื่ออัปเดตสถานะ
        -- เรียก Callback ของ Auto Click Toggle ด้วยค่าใหม่
        -- เนื่องจากเราไม่สามารถเรียก Callback ของ Toggle อื่นได้โดยตรง
        -- วิธีแก้คือ ให้ Toggle หลักอัปเดตสถานะเองทุกครั้งที่ถูกเรียก
        -- ดัดแปลง Toggle หลักเล็กน้อย
        -- หรือใช้ _G.isLoopRunning ตรงๆ
        -- ให้ statusToggle แสดงสถานะ
        statusToggle.Callback("Status: " .. (_G.isLoopRunning and "Auto Clicking Active (F6)" or "Emergency Stopped (F6)"))
        pcall(function()
            NothingLibrary.Notification({
                Title = _G.isLoopRunning and "Auto Click Resumed" or "Emergency Stop",
                Content = _G.isLoopRunning and "Auto clicking resumed via F6" or "Auto clicking stopped via F6",
                Duration = 3
            })
        end)
        if _G.isLoopRunning then
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    task.wait(_G.clickDelay)
                end
            end)
        end
    end
end))

-- Cleanup
local function cleanup()
    _G.isLoopRunning = false
    for _, c in ipairs(connections) do
        pcall(function() if c and c.Disconnect then c:Disconnect() end end)
    end
    -- ไม่มีฟังก์ชัน Destroy Window ที่ชัดเจนใน Library นี้
    -- ปล่อยให้ Roblox จัดการเมื่อสคริปต์หยุด
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))

print("YANZ HUB | Auto Click Only (Fixed Version 2) loaded successfully!")
