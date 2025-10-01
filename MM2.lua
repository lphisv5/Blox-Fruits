local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local highlightEnabled = false
local autoCollectEnabled = false
local gunDropESPEnabled = false
local playerSpeed = 16
local defaultGravity = Workspace.Gravity
local attackEnabled = false
local teleportYOffset = 5 -- Y-axis offset to prevent falling through the map

local function createHighlight(instance)
    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.5
    highlight.Parent = instance
    return highlight
end

local function createBillboardGui(player)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.AlwaysOnTop = true
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Name = "UsernameDisplay"

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.Parent = billboardGui

    return billboardGui
end

local function highlightPlayer(player, color)
    local character = player.Character or Workspace:FindFirstChild(player.Name)
    if character then
        local highlight = character:FindFirstChildOfClass("Highlight") or createHighlight(character)
        highlight.FillColor = color
        highlight.OutlineColor = color

        local head = character:FindFirstChild("Head")
        if head then
            local existingGui = head:FindFirstChild("UsernameDisplay")
            if not existingGui then
                local billboardGui = createBillboardGui(player)
                billboardGui.Parent = head
            end
        end
    end
end

local function removeHighlight(player)
    local character = player.Character or Workspace:FindFirstChild(player.Name)
    if character then
        local highlight = character:FindFirstChildOfClass("Highlight")
        if highlight then
            highlight:Destroy()
        end

        local head = character:FindFirstChild("Head")
        if head then
            local usernameDisplay = head:FindFirstChild("UsernameDisplay")
            if usernameDisplay then
                usernameDisplay:Destroy()
            end
        end
    end
end

local function hasTool(player, toolName)
    local character = player.Character or Workspace:FindFirstChild(player.Name)
    if character and character:FindFirstChild(toolName) then
        return true
    end
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack and backpack:FindFirstChild(toolName) then
        return true
    end

    return false
end

local function checkPlayers()
    local murdererFound = false
    local sheriffFound = false
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player and player.Character then
            local hasKnife = hasTool(player, "Knife")
            local hasGun = hasTool(player, "Gun")
            
            if hasKnife then
                highlightPlayer(player, Color3.new(1, 0, 0)) -- Red for murderer
                murdererFound = true
            elseif hasGun then
                highlightPlayer(player, Color3.new(0, 0, 1)) -- Blue for sheriff
                sheriffFound = true
            else
                highlightPlayer(player, Color3.new(0, 1, 0)) -- Green for others
            end
        end
    end
    
    if not murdererFound then
        for _, player in ipairs(Players:GetPlayers()) do
            if player and player.Character and not hasTool(player, "Gun") then
                highlightPlayer(player, Color3.new(0, 1, 0)) -- Green for others if no murderer
            end
        end
    end
end

local function loopCheckPlayers()
    while highlightEnabled do
        checkPlayers()
        wait(1) -- Adjust the delay as needed
    end
    if not highlightEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            removeHighlight(player)
        end
    end
end

local function teleportToCoin(player, coinPosition)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(coinPosition + Vector3.new(0, teleportYOffset, 0))
    end
end

local function isPlayerInRange(player)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local position = character.HumanoidRootPart.Position
        return (position.X > -110.301956 and position.X < -9.69793701) and
               (position.Y > 310.059998 and position.Y < 311.059998) and
               (position.Z > -10.69793701 and position.Z < 10.302063)
    end
    return false
end

local function collectCoins()
    autoCollectEnabled = true
    while autoCollectEnabled do
        if not Players.LocalPlayer.Character or not Players.LocalPlayer.Character:FindFirstChild("Humanoid") or Players.LocalPlayer.Character.Humanoid.Health <= 0 then
            autoCollectEnabled = false
            break
        end
        local player = Players.LocalPlayer
        if not isPlayerInRange(player) then
            local coinContainer = Workspace:FindFirstChild("Normal"):FindFirstChild("CoinContainer")
            if coinContainer then
                for _, coin in ipairs(coinContainer:GetChildren()) do
                    if coin:IsA("Part") then
                        teleportToCoin(player, coin.Position)
                        wait(2) -- Delay of 2 seconds between teleports
                    end
                end
            end
        end
        wait(1) -- Adjust delay between checks if necessary
    end
end

local function highlightGunDrop()
    while gunDropESPEnabled do
        local gunDrop = Workspace:FindFirstChild("GunDrop")
        if gunDrop then
            local highlight = gunDrop:FindFirstChildOfClass("Highlight") or createHighlight(gunDrop)
            highlight.FillColor = Color3.new(0, 0, 0) -- Black color

            local existingGui = gunDrop:FindFirstChild("GunDropDisplay")
            if not existingGui then
                local billboardGui = Instance.new("BillboardGui")
                billboardGui.Size = UDim2.new(0, 100, 0, 50)
                billboardGui.AlwaysOnTop = true
                billboardGui.StudsOffset = Vector3.new(0, 2, 0)
                billboardGui.Name = "GunDropDisplay"

                local textLabel = Instance.new("TextLabel")
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundTransparency = 1
                textLabel.Text = "Gun Drop"
                textLabel.TextColor3 = Color3.new(0, 0, 0)
                textLabel.TextStrokeTransparency = 0
                textLabel.Parent = billboardGui

                billboardGui.Parent = gunDrop
            end
        end
        wait(1) -- Adjust delay as needed
    end

    if not gunDropESPEnabled then
        local gunDrop = Workspace:FindFirstChild("GunDrop")
        if gunDrop then
            local highlight = gunDrop:FindFirstChildOfClass("Highlight")
            if highlight then
                highlight:Destroy()
            end

            local gunDropDisplay = gunDrop:FindFirstChild("GunDropDisplay")
            if gunDropDisplay then
                gunDropDisplay:Destroy()
            end
        end
    end
end

local function teleportToGunDrop()
    local gunDrop = Workspace:FindFirstChild("GunDrop")
    if gunDrop then
        local player = Players.LocalPlayer
        teleportToCoin(player, gunDrop.Position)
    end
end

local function getClosestPlayers(range)
    local localPlayer = Players.LocalPlayer
    local localCharacter = localPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return {} end
    
    local closestPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (localCharacter.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance <= range then
                table.insert(closestPlayers, player)
            end
        end
    end
    return closestPlayers
end

local function attackClosestPlayers()
    attackEnabled = true
    while attackEnabled do
        local closestPlayers = getClosestPlayers(300)
        for _, player in ipairs(closestPlayers) do
            local localPlayer = Players.LocalPlayer
            local localCharacter = localPlayer.Character
            if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") and localCharacter:FindFirstChildOfClass("Tool") then
                local tool = localCharacter:FindFirstChildOfClass("Tool")
                local humanoidRootPart = localCharacter.HumanoidRootPart
                local targetHumanoidRootPart = player.Character.HumanoidRootPart
                
                humanoidRootPart.CFrame = targetHumanoidRootPart.CFrame
                tool:Activate()
                wait(0.1) -- Adjust the delay as needed
            end
        end
        wait(1) -- Adjust delay between checks if necessary
    end
end

local function stopAttacking()
    attackEnabled = false
end

local function setSpeed(speed)
    playerSpeed = speed
    local character = Players.LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        character:FindFirstChildOfClass("Humanoid").WalkSpeed = playerSpeed
    end
end

local function setGravity(newGravity)
    Workspace.Gravity = newGravity
end

local function resetGravity()
    Workspace.Gravity = defaultGravity
end

local function teleportToModelCenter(model)
    local localPlayer = Players.LocalPlayer
    local localCharacter = localPlayer.Character
    if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
        if model.PrimaryPart then
            localCharacter.HumanoidRootPart.CFrame = model.PrimaryPart.CFrame + Vector3.new(0, teleportYOffset, 0)
        else
            local totalPosition = Vector3.new(0, 0, 0)
            local numParts = 0

            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("BasePart") then
                    totalPosition = totalPosition + part.Position
                    numParts = numParts + 1
                end
            end

            if numParts > 0 then
                local averagePosition = totalPosition / numParts
                localCharacter.HumanoidRootPart.CFrame = CFrame.new(averagePosition + Vector3.new(0, teleportYOffset, 0))
            else
                print("No parts found in the model.")
            end
        end
    end
end

local function teleportToLobby()
    teleportToModelCenter(Workspace.Lobby)
end

local function teleportToMap()
    teleportToModelCenter(Workspace.Normal.Map)
end

local Window = OrionLib:MakeWindow({Name = "Player Highlighter", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Enable Highlighting",
    Default = false,
    Callback = function(value)
        highlightEnabled = value
        if highlightEnabled then
            loopCheckPlayers()
        else
            for _, player in ipairs(Players:GetPlayers()) do
                removeHighlight(player)
            end
        end
    end    
})

MainTab:AddButton({
    Name = "Start Auto Collect Coins",
    Callback = function()
        collectCoins()
    end    
})

MainTab:AddToggle({
    Name = "Gun Drop ESP",
    Default = false,
    Callback = function(value)
        gunDropESPEnabled = value
        if gunDropESPEnabled then
            highlightGunDrop()
        end
    end
})

MainTab:AddButton({
    Name = "Teleport to Gun Drop",
    Callback = function()
        teleportToGunDrop()
    end    
})

MainTab:AddButton({
    Name = "Start Attacking Closest Players",
    Callback = function()
        attackClosestPlayers()
    end    
})

MainTab:AddButton({
    Name = "Stop Attacking",
    Callback = function()
        stopAttacking()
    end    
})

MainTab:AddSlider({
    Name = "Set Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        setSpeed(value)
    end    
})

MainTab:AddSlider({
    Name = "Set Gravity",
    Min = 0,
    Max = 196.2,
    Default = 196.2,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    ValueName = "Gravity",
    Callback = function(value)
        setGravity(value)
    end    
})

MainTab:AddButton({
    Name = "Reset Gravity",
    Callback = function()
        resetGravity()
    end    
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

TeleportTab:AddButton({
    Name = "Teleport to Lobby",
    Callback = function()
        teleportToLobby()
    end    
})

TeleportTab:AddButton({
    Name = "Teleport to Map",
    Callback = function()
        teleportToMap()
    end    
})

OrionLib:Init()
