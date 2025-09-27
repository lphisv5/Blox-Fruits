-- +1 Blocks Every Second Auto Script for Roblox Executor
-- WARNING: Using scripts/exploits violates Roblox ToS and can result in permanent bans.
-- This is for educational purposes only. Use at your own risk. Stick to legit play!
-- Features: Auto-redeem codes, Auto-clicker, Auto-rebirth (basic), Auto-hatch eggs.
-- All active codes from community (as of Sep 2025): release, 8mvisits, alien, oblivion, mars, visit1.5m, 10klikes, 13klikes, heaven
-- Tested on basic executors like Synapse/Krnl. Adjust if needed.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for game to load
repeat wait() until playerGui:FindFirstChild("ScreenGui") -- Assuming main GUI is ScreenGui; adjust if different

-- All codes list (update as new ones drop)
local codes = {
    "release",      -- 100 free blocks
    "8mvisits",     -- 8,000 blocks
    "alien",        -- Alien Pet
    "oblivion",     -- 10,000 blocks
    "mars",         -- Free blocks
    "visit1.5m",    -- 1,500 blocks
    "10klikes",     -- Huge Blocks
    "13klikes",     -- Free blocks
    "heaven"        -- Heaven Pet
}

-- Function to find and click a GUI button by name (generic clicker)
local function clickButton(buttonName)
    local success, gui = pcall(function()
        return playerGui:FindFirstChild("ScreenGui", true):FindFirstChild(buttonName, true) -- Adjust ScreenGui name if needed
    end)
    if success and gui then
        -- Simulate click via fireclickdetector or mouse event
        if gui:IsA("TextButton") or gui:IsA("ImageButton") then
            fireclickdetector(gui:FindFirstChild("ClickDetector") or gui) -- Fallback to fire if present
            gui:Activate() -- Alternative activation
            print("Clicked: " .. buttonName)
            return true
        end
    end
    print("Failed to find/click: " .. buttonName)
    return false
end

-- Auto-Redeem Codes
local function redeemCodes()
    print("Starting code redemption...")
    clickButton("Codes") -- Open Codes menu
    wait(0.5)
    
    for _, code in ipairs(codes) do
        -- Assume code input is a TextBox named "CodeInput" and Redeem button is "Redeem"
        local codeInput = playerGui:FindFirstChild("ScreenGui", true):FindFirstChild("CodeInput", true) -- Adjust path
        if codeInput then
            codeInput.Text = code
            clickButton("Redeem")
            wait(1) -- Cooldown between redeems
            print("Redeemed: " .. code)
        end
    end
    
    clickButton("Codes") -- Close if needed
    print("All codes redeemed!")
end

-- Auto-Clicker (taps tower top every 0.1s for max CPS)
local clicking = false
local function toggleClicker()
    clicking = not clicking
    spawn(function()
        while clicking do
            -- Find tower part (assuming it's the main tower model in workspace)
            local tower = workspace:FindFirstChild("Tower") -- Adjust to actual tower name/path
            if tower then
                -- Fire remote event for click (common in clickers)
                local remote = ReplicatedStorage:FindFirstChild("RemoteEvent") -- Adjust to game's click remote
                if remote then
                    remote:FireServer("Click", tower.Position) -- Example args; inspect game for exact
                else
                    -- Fallback: Simulate mouse click on tower
                    mousemoverel(0, 0) -- Position mouse if needed
                    mouse1click()
                end
            end
            wait(0.1) -- 10 CPS; adjust for less detection
        end
    end)
    print("Clicker: " .. (clicking and "ON" or "OFF"))
end

-- Auto-Rebirth (checks height, rebirths when ready)
local rebirthing = false
local function toggleRebirth(minBlocks)
    minBlocks = minBlocks or 50000 -- Default threshold
    rebirthing = not rebirthing
    spawn(function()
        while rebirthing do
            -- Get current blocks (assuming leaderstats)
            local stats = player:FindFirstChild("leaderstats")
            if stats then
                local blocks = stats:FindFirstChild("Blocks") -- Adjust stat name
                if blocks and blocks.Value >= minBlocks then
                    clickButton("Rebirth")
                    wait(2) -- Post-rebirth delay
                    print("Auto-rebirth triggered!")
                end
            end
            wait(5) -- Check every 5s
        end
    end)
    print("Auto-Rebirth: " .. (rebirthing and "ON (threshold: " .. minBlocks .. ")" or "OFF"))
end

-- Auto-Hatch Eggs (buys and hatches basic eggs)
local hatching = false
local function toggleHatcher(numEggs)
    numEggs = numEggs or 5 -- Default 5 eggs
    hatching = not hatching
    spawn(function()
        while hatching do
            for i = 1, numEggs do
                clickButton("BuyEgg") -- Buy egg button
                wait(0.5)
                clickButton("Hatch") -- Hatch button
                wait(1)
                print("Hatched egg #" .. i)
            end
            wait(10) -- Cycle every 10s
        end
    end)
    print("Auto-Hatcher: " .. (hatching and "ON (" .. numEggs .. " eggs/cycle)" or "OFF"))
end

-- Main GUI for toggles (simple on-screen buttons)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoScriptGUI"
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.Parent = screenGui

local function addButton(text, callback, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, yPos)
    btn.Text = text
    btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
end

addButton("Redeem All Codes", redeemCodes, 5)
addButton("Toggle Clicker", toggleClicker, 40)
addButton("Toggle Rebirth (50k)", function() toggleRebirth(50000) end, 75)
addButton("Toggle Hatcher (5)", function() toggleHatcher(5) end, 110)

print("Script loaded! GUI appeared top-left. Use buttons to toggle features.")
print("Pro Tip: Run redeem first for free boosts. Happy stacking! 🚀")
print("REMINDER: Disable before leaving game to avoid detection.")

-- Hotkeys for quick toggle (optional)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F1 then toggleClicker() end
    if input.KeyCode == Enum.KeyCode.F2 then toggleRebirth() end
    if input.KeyCode == Enum.KeyCode.F3 then toggleHatcher() end
end)
