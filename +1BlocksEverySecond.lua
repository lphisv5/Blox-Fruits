-- =========================================
-- YANZ HUB | Auto Click Only | Fixed Version 5
-- Now compatible with the MODIFIED NOTHING UI Library and has larger GUI
-- =========================================

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local ok_lib, NothingLibrary = pcall(function()
    local code = game:HttpGetAsync(libURL)
    if code then
        -- print("Loaded Nothing Library code (first 1000 chars):", code:sub(1, 1000))
        local func, err = loadstring(code)
        if not func then
            warn("Loadstring error:", err)
            return nil
        end
        return func()
    else
        warn("Failed to fetch Nothing Library from URL:", libURL)
        return nil
    end
end)
if not ok_lib or not NothingLibrary then
    warn("YANZ HUB: Failed to load Nothing UI Library. Error or code issue:", NothingLibrary)
    return
end

-- Create Window with LARGER Size
local Window
local ok_window, res_window = pcall(function()
    return NothingLibrary.new({
        Title = "YANZ HUB | Auto Click Only",
        Description = "By lphisv5",
        Keybind = Enum.KeyCode.RightShift,
        -- Logo = 'http://www.roblox.com/asset/?id=125456335927282' -- ถ้าต้องการ Logo
        -- ปรับ Size ให้ใหญ่ขึ้น
        Size = UDim2.new(0.3, 0, 0.4, 0), -- ขนาด 30% ของความกว้างหน้าจอ และ 40% ของความสูงหน้าจอ
        -- หรือใช้ขนาดคงที่ (แนะนำสำหรับการทดสอบ)
        -- Size = UDim2.new(0, 500, 0, 400), -- ความกว้าง 500 พิกเซล, ความสูง 400 พิกเซล
        -- ค่าจำลองเพื่อข้ามระบบ Auth
        GetKey = function() return 'https://example.com' end,
        Auth = function(key) if key == 'any_key' then return true else return false end; end,
        Freeze = false,
    })
end)
if ok_window then Window = res_window else
    warn("YANZ HUB: Cannot create window from NothingLibrary. Error:", res_window)
    return
end

-- Tabs & Sections
local AutoClickTab = Window:NewTab({
    Title = "Auto Clicker",
    Description = "Auto Click Features",
    Icon = nil -- หลีกเลี่ยง asset errors หากมี
})
local AutoClickSection = AutoClickTab:NewSection({
    Title = "Controls",
    Icon = nil,
})
local SettingsSection = AutoClickTab:NewSection({
    Title = "Speed Settings",
    Icon = nil,
})

-- Helper: updateLabel (เหมือนในโค้ดตัวอย่าง)
local function updateLabel(lbl, text)
    if not lbl then return end
    pcall(function()
        if typeof(lbl) == "Instance" and lbl.Text ~= nil then lbl.Text = tostring(text) end
        if lbl.Set then lbl:Set(tostring(text)) end
        if lbl.SetText then lbl:SetText(tostring(text)) end
        if lbl.SetTitle then lbl:SetTitle(tostring(text)) end
    end)
end

-- Status Label
local StatusLabel = AutoClickSection:NewTitle("Status: Ready")

-- Position Label
local PosLabel = AutoClickSection:NewTitle("Player Pos: Waiting...")

-- Global Variables
_G.clickDelay = _G.clickDelay or 0.1
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
_G.isLoopRunning = _G.isLoopRunning or false

-- Connections manager
local connections = {}
local function addConn(conn) if conn then table.insert(connections, conn) end return conn end

-- Safe Click
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    if pos.X < 0 or pos.Y < 0 or pos.X > viewport.X or pos.Y > viewport.Y then
        warn("⚠️ Invalid click position", pos.X, pos.Y, "Viewport:", viewport)
        return
    end
    if not VirtualInputManager then
        warn("⚠️ VirtualInputManager not available")
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
    if _G.autoClickPos and _G.autoClickPos.X and _G.autoClickPos.Y then
        SafeClick(_G.autoClickPos)
    else
        local cam = workspace.CurrentCamera
        if not cam then return end
        local viewportSize = cam.ViewportSize
        SafeClick({X = viewportSize.X/2, Y = viewportSize.Y/2})
    end
end

-- Auto Click Toggle
local autoToggle = AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = _G.isLoopRunning or false,
    Callback = function(value)
        _G.isLoopRunning = value
        if value then
            updateLabel(StatusLabel, "Auto Clicking Active")
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    task.wait(_G.clickDelay or 0.2)
                end
            end)
        else
            updateLabel(StatusLabel, "Status: Ready")
        end
    end
})

-- Set Click Position Button
AutoClickSection:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        local settingPosition = true
        updateLabel(StatusLabel, "🖱️ Click anywhere to set position...")
        local conn
        conn = addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not settingPosition then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                _G.autoClickPos = { X = mousePos.X, Y = mousePos.Y }
                updateLabel(StatusLabel, "✅ Position set: " .. math.floor(mousePos.X) .. ", " .. math.floor(mousePos.Y))
                settingPosition = false
                if conn then conn:Disconnect() end
            end
        end))
        task.delay(10, function()
            if settingPosition then
                settingPosition = false
                if conn then conn:Disconnect() end
                updateLabel(StatusLabel, "❌ Position set cancelled")
                task.wait(2)
                if not _G.isLoopRunning then
                    updateLabel(StatusLabel, "Status: Ready")
                end
            end
        end)
    end
})

-- Speed Buttons
local speeds = {
    {label = "ULTRA FAST", value = 0.01},
    {label = "FAST", value = 0.5},
    {label = "NORMAL", value = 1},
    {label = "SLOW", value = 1.5}
}
for _, speedData in ipairs(speeds) do
    SettingsSection:NewButton({
        Title = speedData.label .. " (" .. speedData.value .. "s)",
        Callback = function()
            _G.clickDelay = speedData.value
            updateLabel(StatusLabel, "Delay: " .. speedData.value .. "s")
            pcall(function()
                if NothingLibrary.Notify then
                    NothingLibrary:Notify({
                        Title = "Speed Updated",
                        Content = "Click delay set to " .. speedData.value .. "s",
                        Duration = 2
                    })
                end
            end)
        end
    })
end

-- Position Updater
local function startPositionUpdater(character)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local renderConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                updateLabel(PosLabel, string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
            else
                updateLabel(PosLabel, "Player Pos: Waiting...")
            end
        end)
    end)
    addConn(renderConn)
end

-- Start updating for the current character
if LocalPlayer.Character then
    startPositionUpdater(LocalPlayer.Character)
end

-- Update on character respawn
addConn(LocalPlayer.CharacterAdded:Connect(function(char)
    startPositionUpdater(char)
end))

-- Emergency Stop (F6)
addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        if autoToggle and autoToggle.Set then
            autoToggle:Set(_G.isLoopRunning)
        elseif autoToggle and autoToggle.SetValue then
            autoToggle:SetValue(_G.isLoopRunning)
        end
        if _G.isLoopRunning then
            updateLabel(StatusLabel, "Auto Clicking Active (F6)")
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    task.wait(_G.clickDelay or 0.2)
                end
            end)
        else
            updateLabel(StatusLabel, "Emergency Stopped (F6)")
            task.wait(2)
            if not _G.isLoopRunning then
                updateLabel(StatusLabel, "Status: Ready")
            end
        end
    end
end))

-- Cleanup
local function cleanup()
    _G.isLoopRunning = false
    for _, c in ipairs(connections) do
        pcall(function() if c and c.Disconnect then c:Disconnect() end end)
    end
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
        if Window and Window.Close then Window:Close() end
    end)
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))

print("YANZ HUB | Auto Click Only (Fixed Version 5) loaded successfully!")
