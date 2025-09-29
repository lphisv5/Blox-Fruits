-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Player
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Virtual Input
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

-- Load Nothing Library
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local ok_lib, NothingLibrary = pcall(function()
    local code = game:HttpGetAsync(libURL)
    if code then
        local func, err = loadstring(code)
        if not func then warn("Loadstring error:", err) return nil end
        return func()
    end
end)
if not ok_lib or not NothingLibrary then
    warn("YANZ HUB: Failed to load Nothing UI Library")
    return
end

-- Window
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.2.1",
    Description = "By lphisv5 | Game : +1 Blocks Every Second",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

-- HOME Tab (โปรโมท Discord)
local HomeTab = Window:NewTab({Title = "HOME", Description = "Home Features", Icon = "rbxassetid://7733960981"})
local HomeSection = HomeTab:NewSection({Title = "Home", Icon = "rbxassetid://7733916988", Position = "Left"})

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

-- MAIN Tab (Auto Farm Block)
local MainTab = Window:NewTab({Title = "MAIN", Description = "Auto Farm Features", Icon = "rbxassetid://7733960981"})
local MainControlsSection = MainTab:NewSection({Title = "Controls", Icon = "rbxassetid://7733916988", Position = "Left"})

-- Status Label
local StatusLabel = MainControlsSection:NewTitle("Status: Sleeping")

-- Globals
local isLoopRunning = false
local lastRun = false
local loopThread = nil
local connections = {}

local function addConn(conn) if conn then table.insert(connections, conn) end return conn end

-- Helpers
local function updateLabel(lbl, text)
    if not lbl then return end
    pcall(function()
        if typeof(lbl) == "Instance" and lbl.Text ~= nil then lbl.Text = tostring(text) end
        if lbl.Set then lbl:Set(tostring(text)) end
        if lbl.SetText then lbl:SetText(tostring(text)) end
        if lbl.SetTitle then lbl:SetTitle(tostring(text)) end
    end)
end

local function updateStatus()
    if isLoopRunning then
        lastRun = true
        updateLabel(StatusLabel, "Status: Working")
    elseif not isLoopRunning and lastRun then
        updateLabel(StatusLabel, "Status: Not Working")
    else
        updateLabel(StatusLabel, "Status: Sleeping")
    end
end

-- Safe Click (background click Windows)
local function SafeClick()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local pos = {X = viewport.X/2, Y = viewport.Y/2}

    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, cam, 1)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, cam, 1)
        end)
    end
end

-- Auto Farm Loop
local function startAutoFarm()
    if loopThread then return end
    loopThread = task.spawn(function()
        while isLoopRunning do
            SafeClick()
            -- Delay 0.5 – 2 วินาที แบบสุ่ม
            task.wait(0.5 + math.random() * 1.5)
        end
        loopThread = nil
    end)
end

-- Auto Farm Toggle
MainControlsSection:NewToggle({
    Title = "Auto Farm Block",
    Default = false,
    Callback = function(value)
        isLoopRunning = value
        updateStatus()
        if isLoopRunning then startAutoFarm() end
    end
})

-- Emergency Stop F6/F7
addConn(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        isLoopRunning = not isLoopRunning
        updateStatus()
        if isLoopRunning then startAutoFarm() end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        isLoopRunning = false
        updateStatus()
    end
end))

-- Cleanup
local function cleanup()
    isLoopRunning = false
    for _, c in ipairs(connections) do
        pcall(function() if c and c.Disconnect then c:Disconnect() end end)
    end
    connections = {}
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
        if Window and Window.Close then Window:Close() end
    end)
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))

-- Initial Status
updateStatus()
print("YANZ HUB - Auto Farm Block Script Loaded Successfully")
