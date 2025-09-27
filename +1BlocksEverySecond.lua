-- Tower Builder with FluentUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TOWER_BASE = workspace:WaitForChild("TowerBase")
local BLOCK_SIZE = Vector3.new(4,4,4)

-- ===============================
-- LOAD FLUENT UI (ModuleScript recommended)
-- ===============================
-- ModuleScript: ReplicatedStorage -> FluentUI
local Fluent = require(ReplicatedStorage:WaitForChild("FluentUI"))
local SaveManager = require(ReplicatedStorage:WaitForChild("FluentUI_SaveManager"))
local InterfaceManager = require(ReplicatedStorage:WaitForChild("FluentUI_InterfaceManager"))

-- ===============================
-- CONFIG
-- ===============================
local MATERIAL_STAGES = {
	{threshold=0, material=Enum.Material.Wood},
	{threshold=100, material=Enum.Material.Concrete},
	{threshold=500, material=Enum.Material.Metal},
	{threshold=2000, material=Enum.Material.Neon}
}

local CLICK_VALUE = 5
local PASSIVE_RATE = 1 -- blocks per second

local totalBlocks = 0
local towerHeight = 1
local currentMaterial = MATERIAL_STAGES[1].material
local autoBuildEnabled = false
local buildSpeed = 1

-- ===============================
-- FUNCTIONS
-- ===============================
local function getMaterial(blocks)
	local chosen = MATERIAL_STAGES[1].material
	for _, stage in ipairs(MATERIAL_STAGES) do
		if blocks >= stage.threshold then
			chosen = stage.material
		end
	end
	return chosen
end

local function addBlocks(amount)
	for i = 1, amount do
		local block = Instance.new("Part")
		block.Size = BLOCK_SIZE
		block.Anchored = true
		block.Material = currentMaterial
		block.BrickColor = BrickColor.new("Bright green")
		block.Position = TOWER_BASE.Position + Vector3.new(0, towerHeight * BLOCK_SIZE.Y, 0)
		block.Parent = workspace

		towerHeight += 1
		totalBlocks += 1
		currentMaterial = getMaterial(totalBlocks)
	end
	updateStatsUI()
end

-- ===============================
-- GUI SETUP
-- ===============================
local Window = Fluent:CreateWindow({
	Title = "Tower Builder",
	SubTitle = "by You",
	Size = UDim2.fromOffset(580,460),
	Acrylic = true,
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
	Main = Window:AddTab({Title="Main", Icon=""}),
	Settings = Window:AddTab({Title="Settings", Icon="settings"})
}

-- Stats Paragraph
local StatsParagraph = Tabs.Main:AddParagraph({Title="Tower Stats", Content="Blocks: 0 | Material: Wood"})
function updateStatsUI()
	StatsParagraph.Content = string.format("Blocks: %d | Material: %s", totalBlocks, tostring(currentMaterial))
end

-- Button to manually add blocks
Tabs.Main:AddButton({
	Title = "Add Block",
	Description = "Click to add blocks",
	Callback = function()
		addBlocks(CLICK_VALUE)
	end
})

-- Toggle for auto-build
local AutoToggle = Tabs.Main:AddToggle("Auto Build", {Title="Enable Auto Build", Default=false})
AutoToggle:OnChanged(function(value)
	autoBuildEnabled = value
end)

-- Slider for build speed
local BuildSpeedSlider = Tabs.Main:AddSlider("Build Speed", {
	Title="Build Speed",
	Description="Adjust auto build speed",
	Default=1,
	Min=0.1,
	Max=5,
	Rounding=1,
	Callback=function(value)
		buildSpeed = value
	end
})

-- ===============================
-- CLICK DETECTOR
-- ===============================
local clickDetector = TOWER_BASE:FindFirstChild("ClickDetector") or Instance.new("ClickDetector")
clickDetector.Parent = TOWER_BASE

clickDetector.MouseClick:Connect(function()
	addBlocks(CLICK_VALUE)
end)

-- ===============================
-- PASSIVE + AUTO BUILD LOOP
-- ===============================
task.spawn(function()
	while true do
		task.wait(1 / PASSIVE_RATE)
		addBlocks(1)

		if autoBuildEnabled then
			addBlocks(buildSpeed)
		end
	end
end)

-- ===============================
-- SaveManager + InterfaceManager setup
-- ===============================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("TowerBuilderHub")
SaveManager:SetFolder("TowerBuilderHub/Config")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({Title="Tower Builder", Content="GUI Loaded Successfully!", Duration=5})

print("Tower Builder + Fluent UI Loaded!")
