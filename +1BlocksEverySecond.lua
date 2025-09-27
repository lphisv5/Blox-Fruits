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

local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua '
local ok_lib, NothingLibrary = pcall(function()
    local code = game:HttpGetAsync(libURL)
    if code then
        print("Loaded Nothing Library code (first 1000 chars):", code:sub(1, 1000))
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

-- Create Window
local Window
local ok_window, res_window = pcall(function()
    return NothingLibrary.new({
        Title = "YANZ HUB | V0.2.1",
        Description = "By lphisv5 | Game : +1 Blocks Every Second",
        Keybind = Enum.KeyCode.RightShift,
        Logo = 'http://www.roblox.com/asset/?id=125456335927282'
    })
end)
if ok_window then Window = res_window else
    warn("YANZ HUB: Cannot create window from NothingLibrary. Error:", res_window)
    return
end

-- Tabs & Sections
local HomeTab = Window:NewTab({
    Title = "HOME",
    Description = "Home Features",
    Icon = "rbxassetid://7733960981"
})
local MainTab = Window:NewTab({
    Title = "MAIN", -- Renamed from "Auto Clicker"
    Description = "Auto Click Features",
    Icon = "rbxassetid://7733960981"
})
local HomeSection = HomeTab:NewSection({Title = "Home", Icon = "rbxassetid://7733916988", Position = "Left"})
local MainControlsSection = MainTab:NewSection({Title = "Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local MainSettingsSection = MainTab:NewSection({Title = "Speed Settings", Icon = "rbxassetid://7743869054", Position = "Right"})

-- Position Label in UI (Moved to Main Tab)
local posLabel = MainControlsSection:NewTitle("Player Pos: Waiting...")

-- Height Label in UI (Added to Home Tab)
local heightLabel = HomeSection:NewTitle("Height: Waiting...")

-- Globals
_G.clickDelay = _G.clickDelay or 0.1
_G.humanizeClicks = _G.humanizeClicks or false
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
_G.lastClickPos = _G.lastClickPos or nil
_G.isLoopRunning = _G.isLoopRunning or false

-- Helper: updateLabel
local function updateLabel(lbl, text)
    if not lbl then return end
    pcall(function()
        if typeof(lbl) == "Instance" and lbl.Text ~= nil then lbl.Text = tostring(text) end
        if lbl.Set then lbl:Set(tostring(text)) end
        if lbl.SetText then lbl:SetText(tostring(text)) end
        if lbl.SetTitle then lbl:SetTitle(tostring(text)) end
    end)
end

-- Counters
local clickCount = 0

-- Status Label (Rich Information) (Moved to Main Tab)
local StatusLabel = MainControlsSection:NewTitle("Status: Initializing...")

-- Update the main status label with all relevant info
local function updateStatusLabel()
    local statusText = "Status: " .. (_G.isLoopRunning and "Running" or "Ready")
    statusText = statusText .. " | Delay: " .. string.format("%.2f", _G.clickDelay) .. "s"
    statusText = statusText .. " | Humanization: " .. (_G.humanizeClicks and "ON" or "OFF")
    statusText = statusText .. " | Clicks: " .. clickCount
    statusText = statusText .. " | Last Pos: " .. (_G.lastClickPos and string.format("(%.0f, %.0f)", _G.lastClickPos.X, _G.lastClickPos.Y) or "N/A")
    updateLabel(StatusLabel, statusText)
end

-- Connections manager
local connections = {}
local function addConn(conn) if conn then table.insert(connections, conn) end return conn end

-- Home Tab Functions
HomeSection:NewButton({
    Title = "Join Discord",
    Icon = "rbxassetid://7733960981",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
            
            NothingLibrary:Notify({
                Title = "Copied!",
                Content = "Successfully copied the link",
                Duration = 5
            })
        end)
    end
})

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
    local posToClick
    if _G.autoClickPos and _G.autoClickPos.X and _G.autoClickPos.Y then
        posToClick = _G.autoClickPos
    else
        local cam = workspace.CurrentCamera
        if not cam then return end
        local viewportSize = cam.ViewportSize
        posToClick = {X = viewportSize.X/2, Y = viewportSize.Y/2}
    end
    SafeClick(posToClick)
    clickCount = clickCount + 1
    _G.lastClickPos = posToClick -- Update last click position
    updateStatusLabel() -- Update status immediately after a click
end

-- Auto Click Toggle
MainControlsSection:NewToggle({
    Title = "Auto Click",
    Default = _G.isLoopRunning or false,
    Callback = function(value)
        _G.isLoopRunning = value
        updateStatusLabel()
        if value then
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    local delay = _G.clickDelay
                    if _G.humanizeClicks then
                        delay = delay * (0.8 + (math.random() * 0.4))
                    end
                    task.wait(delay)
                end
            end)
        end
    end
})

-- Set Click Position Button
MainControlsSection:NewButton({
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
                task.wait(1)
                updateStatusLabel()
            end
        end))
        task.delay(10, function()
            if settingPosition then
                settingPosition = false
                if conn then conn:Disconnect() end
                updateLabel(StatusLabel, "❌ Position set cancelled")
                task.wait(2)
                if not _G.isLoopRunning then
                    updateStatusLabel()
                else
                     updateStatusLabel()
                end
            end
        end)
    end
})

-- Speed
MainSettingsSection:NewSlider({
    Title = "Click Delay (seconds)",
    Min = 00.01,
    Max = 2,
    Default = _G.clickDelay or 0.1,
    Callback = function(value)
        _G.clickDelay = value
        updateStatusLabel()
        -- Notify
        pcall(function()
            if NothingLibrary.Notify then
                NothingLibrary:Notify({
                    Title = "Speed Updated",
                    Content = "Click delay set to " .. string.format("%.2f", value) .. "s",
                    Duration = 2
                })
            end
        end)
    end
})

-- Humanization Toggle
MainSettingsSection:NewToggle({
    Title = "Enable Humanization",
    Default = _G.humanizeClicks,
    Callback = function(value)
        _G.humanizeClicks = value
        updateStatusLabel()
        pcall(function()
            if NothingLibrary.Notify then
                NothingLibrary:Notify({
                    Title = "Humanization " .. (value and "Enabled" or "Disabled"),
                    Content = "Click timing will " .. (value and "be randomized slightly" or "be consistent"),
                    Duration = 2
                })
            end
        end)
    end
})

-- Position Updater (Updated for Main Tab)
local function startPositionUpdater(character)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local renderConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                updateLabel(posLabel, string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
                -- Update height label in Home Tab
                updateLabel(heightLabel, string.format("Height: Y=%.2f", pos.Y))
            else
                updateLabel(posLabel, "Player Pos: Waiting...")
                updateLabel(heightLabel, "Height: Waiting...")
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

-- Emergency Stop (F6) - Toggle
addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        updateStatusLabel()
        if _G.isLoopRunning then
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    local delay = _G.clickDelay
                    if _G.humanizeClicks then
                        delay = delay * (0.8 + (math.random() * 0.4))
                    end
                    task.wait(delay)
                end
            end)
        end
    end
end))

-- Emergency Stop (F7) - Force Stop
addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F7 then
        _G.isLoopRunning = false
        updateStatusLabel()
        -- Notify
        pcall(function()
            if NothingLibrary.Notify then
                NothingLibrary:Notify({
                    Title = "FORCE STOPPED",
                    Content = "Auto Clicker stopped by F7",
                    Duration = 2
                })
            end
        end)
    end
end))

-- Initial Status Update
updateStatusLabel()

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

print("YANZ HUB - Loaded Successfully")
