local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))();

local Notification = NothingLibrary.Notification();
Notification.new({
    Title = "YANZ HUB | TESTING",
    Description = "Loaded successfully!",
    Duration = 5,
    Icon = "rbxassetid://8997385628"
})

local Windows = NothingLibrary.new({
    Title = "YANZ HUB | Beta Version",
    Description = "Game : Violence District | By lphisv5",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

local HomeTab = Windows:NewTab({
    Title = "HOME",
    Description = "Main Features",
    Icon = "rbxassetid://7733960981"
})

local LeftSection = HomeTab:NewSection({
    Title = "Main",
    Icon = "rbxassetid://7743869054",
    Position = "Left"
})

local RightSection = HomeTab:NewSection({
    Title = "Utilities",
    Icon = "rbxassetid://7733964719",
    Position = "Right"
})

LeftSection:NewButton({
    Title = "Discord",
    Callback = function()
        print('discord.gg/xppGk6fAFY')
        Notification.new({
            Title = "Discord",
            Description = "Join our server: discord.gg/xppGk6fAFY",
            Duration = 5,
            Icon = "rbxassetid://8997385628"
        })
    end,
})

RightSection:NewToggle({
    Title = "Anti AFK",
    Default = true,
    Callback = function(state)
        if state then
            local VirtualUser = game:GetService('VirtualUser')
            game:GetService('Players').LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "AntiAFK loaded!",
            })
            print("Anti AFK Enabled")
        else
            print("Anti AFK Disabled")
        end
    end,
})

RightSection:NewToggle({
    Title = "Anti Kick",
    Default = true,
    Callback = function(state)
        if state then
            local plr = game:GetService("Players").LocalPlayer
            getgenv().Anti = true
            local Anti
            Anti = hookmetamethod(game, "__namecall", function(self, ...)
                if self == plr and getnamecallmethod():lower() == "kick" and getgenv().Anti then
                    return warn("[ANTI-KICK] Client Tried To Call Kick Function On LocalPlayer")
                end
                return Anti(self, ...)
            end)
            print("Anti Kick Enabled")
        else
            getgenv().Anti = false
            print("Anti Kick Disabled")
        end
    end,
})

local PlayersTab = Windows:NewTab({
    Title = "Players",
    Description = "Player Features",
    Icon = "rbxassetid://7733960981"
})

local PlayersSection = PlayersTab:NewSection({
    Title = "Player Options",
    Icon = "rbxassetid://7743869054",
    Position = "Left"
})

-- Player ESP Toggle
PlayersSection:NewToggle({
    Title = "Player ESP",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local RunService = game:GetService("RunService")

        local Highlights = {}
        local DistanceLabels = {}
        local Connections = {}

        local HighlightSettings = {
            FillColor = Color3.fromRGB(0, 255, 0),
            FillTransparency = 0.4,
            OutlineColor = Color3.fromRGB(0, 0, 0),
            OutlineTransparency = 0,
            BillboardSize = UDim2.new(0, 100, 0, 50),
            BillboardOffset = Vector3.new(0, 3, 0),
            TextSize = 14,
            TextColor = Color3.fromRGB(255, 255, 255),
            TextFont = Enum.Font.SourceSansBold,
            TextStrokeTransparency = 0.5
        }

        local function createHighlight(player)
            local highlight = Instance.new("Highlight")
            highlight.FillColor = HighlightSettings.FillColor
            highlight.FillTransparency = HighlightSettings.FillTransparency
            highlight.OutlineColor = HighlightSettings.OutlineColor
            highlight.OutlineTransparency = HighlightSettings.OutlineTransparency
            highlight.Parent = player.Character

            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Adornee = player.Character
            billboardGui.Size = HighlightSettings.BillboardSize
            billboardGui.StudsOffset = HighlightSettings.BillboardOffset

            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(1, 0, 1, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = HighlightSettings.TextColor
            distanceLabel.Font = HighlightSettings.TextFont
            distanceLabel.TextSize = HighlightSettings.TextSize
            distanceLabel.TextStrokeTransparency = HighlightSettings.TextStrokeTransparency
            distanceLabel.Parent = billboardGui
            billboardGui.Parent = highlight

            return highlight, distanceLabel
        end

        local function updateHighlightForPlayer(player)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not Highlights[player] then
                    local highlight, distanceLabel = createHighlight(player)
                    Highlights[player] = highlight
                    DistanceLabels[player] = distanceLabel
                end
                Highlights[player].Adornee = player.Character
            end
        end

        local function updateDistances()
            for player, distanceLabel in pairs(DistanceLabels) do
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    distanceLabel.Text = string.format("Distance: %.1f", distance)
                else
                    if Highlights[player] then
                        Highlights[player]:Destroy()
                        DistanceLabels[player]:Destroy()
                        Highlights[player] = nil
                        DistanceLabels[player] = nil
                    end
                end
            end
        end

        local function onPlayerAdded(player)
            if player ~= LocalPlayer then
                local charConn = player.CharacterAdded:Connect(function()
                    task.wait(0.1)
                    updateHighlightForPlayer(player)
                end)
                table.insert(Connections, charConn)

                if player.Character then
                    updateHighlightForPlayer(player)
                end
            end
        end

        local function onPlayerRemoving(player)
            if Highlights[player] then
                Highlights[player]:Destroy()
                DistanceLabels[player]:Destroy()
                Highlights[player] = nil
                DistanceLabels[player] = nil
            end
        end

        if state then
            table.insert(Connections, Players.PlayerAdded:Connect(onPlayerAdded))
            table.insert(Connections, Players.PlayerRemoving:Connect(onPlayerRemoving))

            for _, player in ipairs(Players:GetPlayers()) do
                onPlayerAdded(player)
            end

            table.insert(Connections, RunService.RenderStepped:Connect(updateDistances))
        else
            for _, conn in pairs(Connections) do
                conn:Disconnect()
            end
            Connections = {}

            for _, highlight in pairs(Highlights) do
                highlight:Destroy()
            end
            for _, label in pairs(DistanceLabels) do
                label:Destroy()
            end
            Highlights = {}
            DistanceLabels = {}
        end
    end,
})

-- Speed Toggle
local speedConnection
PlayersSection:NewToggle({
    Title = "Speed",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        local desiredSpeed = 100
        local defaultSpeed = 16

        if state then
            local function applySpeed()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = desiredSpeed
                end
            end

            speedConnection = game:GetService("RunService").RenderStepped:Connect(applySpeed)

            LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                applySpeed()
            end)

        else
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
            end
        end
    end,
})

PlayersSection:NewToggle({
    Title = "No Clip",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local RunService = game:GetService("RunService")
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        if state then
            local function enableNoClip()
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
            RunService.Stepped:Connect(function()
                if state then
                    enableNoClip()
                end
            end)
            print("No Clip Enabled")
        else
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            print("No Clip Disabled")
        end
    end,
})

PlayersSection:NewToggle({
    Title = "God Mode",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local function protectHealth()
            Humanoid.Health = math.huge
            Humanoid.MaxHealth = math.huge
            Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if Humanoid.Health < Humanoid.MaxHealth then
                    Humanoid.Health = Humanoid.MaxHealth
                end
            end)
        end

        local function antiKill()
            for _, obj in pairs(getconnections(Humanoid.Died)) do
                obj:Disable()
            end
            Humanoid.BreakJointsOnDeath = false
        end

        local function antiKnockback()
            RunService.Heartbeat:Connect(function()
                for _, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyThrust") then
                        v:Destroy()
                    end
                end
            end)
        end

        local function antiVoid()
            RunService.Heartbeat:Connect(function()
                if Character:FindFirstChild("HumanoidRootPart") then
                    if Character.HumanoidRootPart.Position.Y < -20 then
                        Character:MoveTo(Vector3.new(0, 50, 0))
                    end
                end
            end)
        end

        local function fakeHealth()
            local fake = Instance.new("NumberValue")
            fake.Name = "FakeHealth"
            fake.Value = Humanoid.Health
            fake.Parent = Character
            RunService.RenderStepped:Connect(function()
                fake.Value = Humanoid.Health
            end)
        end

        local function lockHumanoidState()
            RunService.Stepped:Connect(function()
                pcall(function()
                    Humanoid:ChangeState(11)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end)
            end)
        end

        if state then
            protectHealth()
            antiKill()
            antiKnockback()
            antiVoid()
            fakeHealth()
            lockHumanoidState()
            LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(1)
                Character = char
                Humanoid = char:WaitForChild("Humanoid")
                protectHealth()
                antiKill()
                antiKnockback()
                antiVoid()
                lockHumanoidState()
            end)
      else
            Humanoid.Health = 100
            Humanoid.MaxHealth = 100
        end
    end,
})
