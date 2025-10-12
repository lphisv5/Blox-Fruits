--===[ Services ]===--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--===[ Library ]===--
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local NothingLibrary = loadstring(game:HttpGet(libURL))()

local Window = NothingLibrary.new({
    Title = "YANZ HUB | Blox Fruits",
    Description = "By lphisv5",
    Keybind = Enum.KeyCode.RightShift
})

--===[ Tab ]===--
local MainTab = Window:NewTab({
    Title = "Main",
    Description = "ESP & Lock Target",
    Icon = "rbxassetid://7733916988"
})

local MainSection = MainTab:NewSection({
    Title = "Blox Fruits ESP & Lock",
    Position = "Left"
})

--===[ Variables ]===--
local ESP_ENABLED = false
local LOCK_ENABLED = false
local TARGET_PLAYER = nil
local ESP_OBJECTS = {}
local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNameCall = mt.__namecall

--===[ Helper Functions ]===--
local function getPlayers()
    local plrs = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(plrs, plr)
        end
    end
    return plrs
end

-- Create ESP for a player
local function createESP(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then return end
    if ESP_OBJECTS[player] then return end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "YANZ_ESP"
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(0,255,255)
    highlight.Parent = player.Character

    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "YANZ_ESP_BILL"
    billboard.Size = UDim2.new(0,150,0,40)
    billboard.StudsOffset = Vector3.new(0,3,0)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character:FindFirstChild("Head")

    -- Name and Distance Label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1,0,0,20)
    nameLabel.Position = UDim2.new(0,0,0,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(0,255,255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard

    -- HP Label
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1,0,0,20)
    hpLabel.Position = UDim2.new(0,0,0,20)
    hpLabel.BackgroundTransparency = 1
    hpLabel.TextColor3 = Color3.fromRGB(255,100,100)
    hpLabel.TextScaled = true
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.Parent = billboard

    -- Health Bar
    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(1,0,0,5)
    barFrame.Position = UDim2.new(0,0,1,-5)
    barFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    barFrame.Parent = billboard

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(hum.Health/hum.MaxHealth,0,1,0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0,255*(hum.Health/hum.MaxHealth),255*(1-(hum.Health/hum.MaxHealth)))
    healthBar.Parent = barFrame

    ESP_OBJECTS[player] = {highlight=highlight, billboard=billboard, nameLabel=nameLabel, hpLabel=hpLabel, healthBar=healthBar, barFrame=barFrame}

    -- Update ESP every frame
    RunService.Heartbeat:Connect(function()
        if ESP_ENABLED and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                nameLabel.Text = player.Name.." ["..math.floor(dist).."m]"
                hpLabel.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
                healthBar.Size = UDim2.new(hum.Health/hum.MaxHealth,0,1,0)
                healthBar.BackgroundColor3 = Color3.fromRGB(0,255*(hum.Health/hum.MaxHealth),255*(1-(hum.Health/hum.MaxHealth)))
            end
        else
            nameLabel.Text = ""
            hpLabel.Text = ""
        end
    end)
end

local function removeESP(player)
    if ESP_OBJECTS[player] then
        if ESP_OBJECTS[player].highlight then ESP_OBJECTS[player].highlight:Destroy() end
        if ESP_OBJECTS[player].billboard then ESP_OBJECTS[player].billboard:Destroy() end
        ESP_OBJECTS[player] = nil
    end
end

local function updateESP()
    for _, plr in pairs(getPlayers()) do
        if ESP_ENABLED then
            createESP(plr)
        else
            removeESP(plr)
        end
    end
end

local function getNearestPlayer()
    local closest, dist = nil, math.huge
    for _, plr in pairs(getPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local mag = (LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
            if mag < dist then
                dist = mag
                closest = plr
            end
        end
    end
    return closest
end

local function isTargetAlive()
    return TARGET_PLAYER and TARGET_PLAYER.Character and TARGET_PLAYER.Character:FindFirstChild("Humanoid") and TARGET_PLAYER.Character.Humanoid.Health > 0
end

--===[ ESP Toggle ]===--
MainSection:NewToggle({
    Title = "Player ESP",
    Default = false,
    Callback = function(v)
        ESP_ENABLED = v
        updateESP()
        NothingLibrary:Notify({
            Title = "ESP",
            Content = v and "Enabled" or "Disabled",
            Duration = 3
        })
    end
})

--===[ Lock Target Toggle ]===--
MainSection:NewToggle({
    Title = "Lock Target",
    Default = false,
    Callback = function(v)
        LOCK_ENABLED = v
        if v then
            TARGET_PLAYER = getNearestPlayer()
            if TARGET_PLAYER then
                NothingLibrary:Notify({
                    Title = "Lock Target",
                    Content = "Locked onto: " .. TARGET_PLAYER.Name,
                    Duration = 3
                })
            else
                NothingLibrary:Notify({
                    Title = "Lock Target",
                    Content = "No player found!",
                    Duration = 3
                })
            end
        else
            TARGET_PLAYER = nil
            NothingLibrary:Notify({
                Title = "Lock Target",
                Content = "Unlocked",
                Duration = 3
            })
        end
    end
})

--===[ Keybind to Lock ]===--
MainSection:NewKeybind({
    Title = "Lock Keybind",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        if not LOCK_ENABLED then
            LOCK_ENABLED = true
            TARGET_PLAYER = getNearestPlayer()
            if TARGET_PLAYER then
                NothingLibrary:Notify({
                    Title = "Lock Target",
                    Content = "Locked onto: " .. TARGET_PLAYER.Name,
                    Duration = 3
                })
            else
                NothingLibrary:Notify({
                    Title = "Lock Target",
                    Content = "No player found!",
                    Duration = 3
                })
            end
        else
            TARGET_PLAYER = nil
            LOCK_ENABLED = false
            NothingLibrary:Notify({
                Title = "Lock Target",
                Content = "Unlocked",
                Duration = 3
            })
        end
    end
})

--===[ Camera & Aim Assist ]===--
RunService.RenderStepped:Connect(function()
    if LOCK_ENABLED and isTargetAlive() and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local targetPos = TARGET_PLAYER.Character.HumanoidRootPart.Position
        root.CFrame = CFrame.new(root.Position, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
    end
end)

--===[ Skill Lock / Aim Assist ]===--
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if LOCK_ENABLED and isTargetAlive() then
        if method == "InvokeServer" and self.Name == "CommF_" then
            local index = args[1]
            if index == "1" or index == "2" or index == "3" or index == "4" then
                args[2] = TARGET_PLAYER.Character.HumanoidRootPart.Position
                args[3] = TARGET_PLAYER.Character.HumanoidRootPart
            end
        end
    end

    return oldNameCall(self, ...)
end)

--===[ Player Connect/Disconnect Handling ]===--
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if ESP_ENABLED then createESP(plr) end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

NothingLibrary:Notify({
    Title = "YANZ HUB",
    Content = "Loaded ESP + Lock Target Pro (Distance + HP + Auto Skills)",
    Duration = 5
})
