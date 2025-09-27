-- Simple Tower Builder Script (LocalScript in StarterPlayerScripts)
-- Inspired by idle/clicker games like +1 Blocks Every Second
-- Handles clicking, passive growth, and material changes

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Game settings
local TOWER_BASE = workspace:WaitForChild("TowerBase")  -- Your base part
local CLICK_VALUE = 5  -- Blocks added per click
local PASSIVE_RATE = 1  -- Blocks per second (passive)
local BLOCK_SIZE = Vector3.new(4, 4, 4)  -- Size of each block
local MATERIALS = {  -- Tower material progression
    Enum.Material.Wood,      -- Stage 1: 0-100 blocks
    Enum.Material.Concrete,  -- Stage 2: 101-500
    Enum.Material.Metal,     -- Stage 3: 501-2000
    Enum.Material.Neon,      -- Stage 4: 2001+
}

-- Variables
local totalBlocks = 0
local lastPassiveTime = tick()
local currentTowerHeight = 1  -- Starting height (base is height 1)
local currentMaterialIndex = 1

-- Function to spawn a new block on top of the tower
local function spawnBlock()
    local newBlock = Instance.new("Part")
    newBlock.Name = "TowerBlock"
    newBlock.Size = BLOCK_SIZE
    newBlock.Material = MATERIALS[currentMaterialIndex]
    newBlock.BrickColor = BrickColor.new("Bright green")  -- Customize color
    newBlock.Anchored = true
    newBlock.Position = TOWER_BASE.Position + Vector3.new(0, currentTowerHeight * 4, 0)
    newBlock.Parent = workspace
    
    currentTowerHeight = currentTowerHeight + 1
    totalBlocks = totalBlocks + 1
    
    -- Update material based on total blocks
    for i, threshold in ipairs({0, 100, 500, 2000}) do
        if totalBlocks > threshold then
            currentMaterialIndex = i + 1
        end
    end
end

-- Click event (attach ClickDetector to TowerBase)
local clickDetector = TOWER_BASE:FindFirstChild("ClickDetector") or Instance.new("ClickDetector")
clickDetector.Parent = TOWER_BASE

clickDetector.MouseClick:Connect(function()
    for i = 1, CLICK_VALUE do
        spawnBlock()
    end
    print("Clicked! Added " .. CLICK_VALUE .. " blocks. Total: " .. totalBlocks)
end)

-- Passive growth loop (runs every second)
local passiveConnection
passiveConnection = RunService.Heartbeat:Connect(function()
    if tick() - lastPassiveTime >= 1 then
        spawnBlock()
        lastPassiveTime = tick()
        print("Passive tick! Total blocks: " .. totalBlocks)
    end
end)

-- Optional: Simple GUI to show stats
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(0, 200, 0, 50)
statsLabel.Position = UDim2.new(0, 10, 0, 10)
statsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statsLabel.TextColor3 = Color3.new(1, 1, 1)
statsLabel.Text = "Blocks: 0"
statsLabel.Parent = screenGui

-- Update GUI loop
local guiConnection
guiConnection = RunService.Heartbeat:Connect(function()
    statsLabel.Text = "Blocks: " .. totalBlocks .. " (Material: " .. tostring(MATERIALS[currentMaterialIndex]) .. ")"
end)

-- Cleanup on player leaving (optional)
player.CharacterRemoving:Connect(function()
    if passiveConnection then passiveConnection:Disconnect() end
    if guiConnection then guiConnection:Disconnect() end
end)

print("Tower Builder loaded! Click the base to build, or wait for passive growth.")
