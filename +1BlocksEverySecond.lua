-- Simple Tower Builder Script (LocalScript in StarterPlayerScripts)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Settings
local TOWER_BASE = workspace:WaitForChild("TowerBase")
local CLICK_VALUE = 5
local PASSIVE_RATE = 1
local BLOCK_SIZE = Vector3.new(4, 4, 4)

-- Material stages with thresholds
local MATERIAL_STAGES = {
    {threshold = 0, material = Enum.Material.Wood},
    {threshold = 100, material = Enum.Material.Concrete},
    {threshold = 500, material = Enum.Material.Metal},
    {threshold = 2000, material = Enum.Material.Neon},
}

-- Variables
local totalBlocks = 0
local currentTowerHeight = 1
local currentMaterial = MATERIAL_STAGES[1].material

-- Utility: get material for current totalBlocks
local function getMaterial()
    local chosen = MATERIAL_STAGES[1].material
    for _, stage in ipairs(MATERIAL_STAGES) do
        if totalBlocks >= stage.threshold then
            chosen = stage.material
        end
    end
    return chosen
end

-- Spawn a block
local function spawnBlock()
    local newBlock = Instance.new("Part")
    newBlock.Name = "TowerBlock"
    newBlock.Size = BLOCK_SIZE
    newBlock.Material = currentMaterial
    newBlock.BrickColor = BrickColor.new("Bright green")
    newBlock.Anchored = true
    newBlock.Position = TOWER_BASE.Position + Vector3.new(0, currentTowerHeight * BLOCK_SIZE.Y, 0)
    newBlock.Parent = workspace

    currentTowerHeight += 1
    totalBlocks += 1
    currentMaterial = getMaterial()
end

-- Clicking
local clickDetector = TOWER_BASE:FindFirstChild("ClickDetector") or Instance.new("ClickDetector")
clickDetector.Parent = TOWER_BASE

clickDetector.MouseClick:Connect(function()
    for i = 1, CLICK_VALUE do
        spawnBlock()
    end
    print("Clicked! Added " .. CLICK_VALUE .. " blocks. Total: " .. totalBlocks)
end)

-- Passive growth
task.spawn(function()
    while true do
        task.wait(1 / PASSIVE_RATE)
        spawnBlock()
        print("Passive tick! Total blocks: " .. totalBlocks)
    end
end)

-- UI
local screenGui = Instance.new("ScreenGui", playerGui)
local statsLabel = Instance.new("TextLabel", screenGui)
statsLabel.Size = UDim2.new(0, 220, 0, 50)
statsLabel.Position = UDim2.new(0, 10, 0, 10)
statsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
statsLabel.TextColor3 = Color3.new(1, 1, 1)

RunService.RenderStepped:Connect(function()
    statsLabel.Text = string.format("Blocks: %d | Material: %s", totalBlocks, tostring(currentMaterial))
end)
