local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "YANZ HUB",
    HidePremium = false,
    IntroEnabled = false,
    SaveConfig = true,
    ConfigFolder = "Doors"
})

local V = "Version: 0.0.8"

-- Configuration variables
local EspMonster = false
local EspItems = false
local NoFigureHearing = false
local LibraryCodeFinder = false
local espEnabled = false

-- Name tables
local NameMonsterTable = {
    "AmbushMoving", "FigureRig", "Eyes", "RushMoving", 
    "SeekMovingNewClone", "Screech", "Halt"
}
local NameItemsTable = {
    "Crucifix", "LeverForGate", "KeyHitbox", "Gold", "Candle", 
    "Lockpick", "LockPick", "Flashlight", "BigFlashlight"
}

-- ESP management
local espObjects = {}
local connections = {}

-- Create BillboardGui with Highlight
local function createBillboard(part, name)
    if not part or part.Parent == nil then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPBillboard"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = name
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.Parent = part

    -- Color configuration
    local color = Color3.new(1, 1, 1) -- Default white
    if table.find(NameMonsterTable, name) then
        color = Color3.new(1, 0, 0) -- Red for monsters
    elseif name == "Gold" then
        color = Color3.new(1, 1, 0) -- Yellow for gold
    elseif name == "LeverForGate" then
        color = Color3.new(0, 1, 0) -- Green for lever
    elseif name == "KeyHitbox" then
        color = Color3.new(1, 1, 0) -- Yellow for key
    end

    textLabel.TextColor3 = color
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.Always
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0

    -- Store references for cleanup
    local id = part:GetDebugId()
    espObjects[id] = {
        billboard = billboard,
        highlight = highlight,
        part = part
    }
end

-- Remove ESP elements
local function removeBillboard(part)
    local id = part:GetDebugId()
    local obj = espObjects[id]
    if obj then
        if obj.billboard then
            obj.billboard:Destroy()
        end
        if obj.highlight then
            obj.highlight:Destroy()
        end
        espObjects[id] = nil
    end
end

-- Scan workspace for ESP targets
local function scanWorkspace()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("Model") or descendant:IsA("BasePart") then
            local part = descendant:IsA("Model") and descendant.PrimaryPart or descendant
            
            if part and part.Parent ~= nil then
                local id = part:GetDebugId()
                
                -- Check if ESP object already exists
                if espObjects[id] then continue end
                
                -- Monster ESP
                if EspMonster then
                    for _, name in ipairs(NameMonsterTable) do
                        if descendant.Name == name then
                            createBillboard(part, name)
                            break
                        end
                    end
                end
                
                -- Item ESP
                if EspItems then
                    for _, name in ipairs(NameItemsTable) do
                        if descendant.Name == name then
                            createBillboard(part, name)
                            break
                        end
                    end
                end
            end
        end
    end
end

-- Clear all ESP elements
local function clearESP()
    for id, obj in pairs(espObjects) do
        if obj.billboard then
            obj.billboard:Destroy()
        end
        if obj.highlight then
            obj.highlight:Destroy()
        end
    end
    espObjects = {}
end

-- Toggle ESP functionality
local function updateESP()
    clearESP()
    if EspMonster or EspItems then
        scanWorkspace()
    end
end

-- Handle new objects added to workspace
local function onChildAdded(child)
    if not espEnabled then return end
    
    if child:IsA("Model") or child:IsA("BasePart") then
        local part = child:IsA("Model") and child.PrimaryPart or child
        
        if part and part.Parent ~= nil then
            local id = part:GetDebugId()
            
            -- Check if ESP object already exists
            if espObjects[id] then return end
            
            -- Monster ESP
            if EspMonster then
                for _, name in ipairs(NameMonsterTable) do
                    if child.Name == name then
                        createBillboard(part, name)
                        return
                    end
                end
            end
            
            -- Item ESP
            if EspItems then
                for _, name in ipairs(NameItemsTable) do
                    if child.Name == name then
                        createBillboard(part, name)
                        return
                    end
                end
            end
        end
    end
end

-- Cleanup function
local function cleanupESP()
    clearESP()
    for _, conn in pairs(connections) do
        conn:Disconnect()
    end
    connections = {}
end

-- Setup ESP connections
local function setupESP()
    cleanupESP()
    espEnabled = EspMonster or EspItems
    
    if espEnabled then
        -- Scan existing objects
        scanWorkspace()
        
        -- Connect to workspace changes
        connections.childAdded = workspace.DescendantAdded:Connect(onChildAdded)
    else
        clearESP()
    end
end

-- Main tabs
local HubMainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local HubAutoFarmTab = Window:MakeTab({
    Name = "AutoFarm(Coming)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local HubEspTab = Window:MakeTab({
    Name = "Esp",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local HubMiscTab = Window:MakeTab({
    Name = "Misc(Coming)",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local HubVersionTab = Window:MakeTab({
    Name = V,
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- ESP Toggles
HubEspTab:AddToggle({
    Name = "Esp Monsters",
    Default = false,
    Callback = function(Value)
        EspMonster = Value
        setupESP()
    end
})

HubEspTab:AddToggle({
    Name = "Esp Items",
    Default = false,
    Callback = function(Value)
        EspItems = Value
        setupESP()
    end
})

-- Main Toggles
HubMainTab:AddToggle({
    Name = "No Figure Hearing",
    Default = false,
    Callback = function(Value)
        NoFigureHearing = Value
        if Value then
            spawn(function()
                while NoFigureHearing do
                    game:GetService("RunService").Heartbeat:Wait()
                    game:GetService("ReplicatedStorage").RemotesFolder.Crouch:FireServer(true)
                end
            end)
        end
    end
})

HubMainTab:AddToggle({
    Name = "Auto Library Code (Code Finder)",
    Default = false,
    Callback = function(Value)
        LibraryCodeFinder = Value
        if Value then
            spawn(function()
                while LibraryCodeFinder do
                    local code = tostring(math.random(100000, 999999))
                    game:GetService("ReplicatedStorage").RemotesFolder.PL:FireServer(code)
                    game:GetService("RunService").Heartbeat:Wait()
                end
            end)
        end
    end
})

-- Cleanup on window close
Window:OnOpen(function()
    -- Window opened
end)

Window:OnClose(function()
    cleanupESP()
end)

OrionLib:Init()
