local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))();
local Notification = NothingLibrary.Notification();
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Windows = NothingLibrary.new({
    Title = "YANZ HUB | Beta Version",
    Description = "Game: Violence District | By lphisv5",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
})

local Connections = {}
local TogglesState = {}
local ScreenGui = nil

local function resetScript()
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
    Connections = {}

    for toggle, state in pairs(TogglesState) do
        if state then
            toggle.Callback(false)
            TogglesState[toggle] = false
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if highlight then
                highlight:Destroy()
            end
        end
    end

    if ScreenGui and not ScreenGui.Parent then
        Notification.new({
            Title = "YANZ HUB",
            Description = "UI was reset, reloading...",
            Duration = 3,
            Icon = "rbxassetid://8997385628"
        })
        loadUI()
    end
end

local function setupMapChangeDetection()
    table.insert(Connections, workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") and child.Name == "CurrentMap" then
            resetScript()
            Notification.new({
                Title = "Map Changed",
                Description = "Resetting script for new map",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end))

    -- ตรวจจับ RemoteEvent ที่อาจใช้ใน Violence District
    local mapChangedEvent = ReplicatedStorage:FindFirstChild("MapChanged")
    if mapChangedEvent then
        table.insert(Connections, mapChangedEvent.OnClientEvent:Connect(function()
            resetScript()
            Notification.new({
                Title = "Map Changed",
                Description = "Resetting script for new map",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end))
    end
end

-- ฟังก์ชันสร้าง UI
local function loadUI()
    Notification.new({
        Title = "YANZ HUB | Beta Version",
        Description = "Loaded successfully!",
        Duration = 5.5,
        Icon = "rbxassetid://8997385628"
    })

    -- แท็บ HOME
    local HomeTab = Windows:NewTab({
        Title = "HOME",
        Description = "Main Features",
        Icon = "rbxassetid://7733960981"
    })

    -- Section ด้านซ้ายใน HOME
    local LeftSection = HomeTab:NewSection({
        Title = "Main",
        Icon = "rbxassetid://7743869054",
        Position = "Left"
    })

    -- Section ด้านขวาใน HOME
    local RightSection = HomeTab:NewSection({
        Title = "Utilities",
        Icon = "rbxassetid://7733964719",
        Position = "Right"
    })

    -- Discord Button (Left)
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

    -- Anti AFK Toggle (Right)
    RightSection:NewToggle({
        Title = "Anti AFK",
        Default = true,
        Callback = function(state)
            TogglesState[RightSection] = state
            if state then
                local VirtualUser = game:GetService('VirtualUser')
                local conn = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
                table.insert(Connections, conn)
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "AntiAFK loaded!",
                })
                print("Anti AFK Enabled")
            else
                print("Anti AFK Disabled")
            end
        end,
    })

    -- Anti Kick Toggle (Right)
    RightSection:NewToggle({
        Title = "Anti Kick",
        Default = true,
        Callback = function(state)
            TogglesState[RightSection] = state
            if state then
                getgenv().Anti = true
                local Anti
                Anti = hookmetamethod(game, "__namecall", function(self, ...)
                    if self == LocalPlayer and getnamecallmethod():lower() == "kick" and getgenv().Anti then
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

    -- Anti Ban Bypasser Toggle (Right)
    local antiBanConnection
    RightSection:NewToggle({
        Title = "Anti Ban Bypasser",
        Default = true,
        Callback = function(state)
            TogglesState[RightSection] = state
            if state then
                local TextChatService = game:GetService("TextChatService")
                cloneref = cloneref or function(o) return o end
                local COREGUI = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
                local Notifbro = {}

                local function Notify(titletxt, text, time)
                    coroutine.wrap(function()
                        local GUI = Instance.new("ScreenGui")
                        local Main = Instance.new("Frame", GUI)
                        local title = Instance.new("TextLabel", Main)
                        local message = Instance.new("TextLabel", Main)

                        GUI.Name = "BackgroundNotif"
                        GUI.Parent = COREGUI

                        local sw = workspace.CurrentCamera.ViewportSize.X
                        local sh = workspace.CurrentCamera.ViewportSize.Y
                        local nh = sh / 7
                        local nw = sw / 5

                        Main.Name = "MainFrame"
                        Main.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
                        Main.BackgroundTransparency = 0.2
                        Main.BorderSizePixel = 0
                        Main.Size = UDim2.new(0, nw, 0, nh)

                        title.BackgroundColor3 = Color3.new(0, 0, 0)
                        title.BackgroundTransparency = 0.9
                        title.Size = UDim2.new(1, 0, 0, nh / 2)
                        title.Font = Enum.Font.GothamBold
                        title.Text = titletxt
                        title.TextColor3 = Color3.new(1, 1, 1)
                        title.TextScaled = true

                        message.BackgroundColor3 = Color3.new(0, 0, 0)
                        message.BackgroundTransparency = 1
                        message.Position = UDim2.new(0, 0, 0, nh / 2)
                        message.Size = UDim2.new(1, 0, 1, -nh / 2)
                        message.Font = Enum.Font.Gotham
                        message.Text = text
                        message.TextColor3 = Color3.new(1, 1, 1)
                        message.TextScaled = true

                        local offset = 50
                        for _, notif in ipairs(Notifbro) do
                            offset = offset + notif.Size.Y.Offset + 10
                        end

                        Main.Position = UDim2.new(1, 5, 0, offset)
                        table.insert(Notifbro, Main)

                        task.wait(0.1)
                        Main:TweenPosition(UDim2.new(1, -nw, 0, offset), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, 0.5, true)
                        Main:TweenSize(UDim2.new(0, nw * 1.06, 0, nh * 1.06), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 0.5, true)
                        task.wait(0.5)
                        Main:TweenSize(UDim2.new(0, nw, 0, nh), Enum.EasingDirection.Out, Enum.EasingStyle.Elastic, 0.2, true)

                        task.wait(time)

                        Main:TweenSize(UDim2.new(0, nw * 1.06, 0, nh * 1.06), Enum.EasingDirection.In, Enum.EasingStyle.Elastic, 0.2, true)
                        task.wait(0.2)
                        Main:TweenSize(UDim2.new(0, nw, 0, nh), Enum.EasingDirection.In, Enum.EasingStyle.Elastic, 0.2, true)
                        task.wait(0.2)
                        Main:TweenPosition(UDim2.new(1, 5, 0, offset), Enum.EasingDirection.In, Enum.EasingStyle.Bounce, 0.5, true)
                        task.wait(0.5)

                        GUI:Destroy()
                        for i, notif in ipairs(Notifbro) do
                            if notif == Main then
                                table.remove(Notifbro, i)
                                break
                            end
                        end

                        for i, notif in ipairs(Notifbro) do
                            local newOffset = 50 + (nh + 10) * (i - 1)
                            notif:TweenPosition(UDim2.new(1, -nw, 0, newOffset), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, 0.5, true)
                        end
                    end)()
                end

                local guiName = "NOT BETTER"
                if COREGUI:FindFirstChild(guiName) then
                    Notify("Error", "Script Already Executed", 1)
                    return
                end

                local screenGui = Instance.new("ScreenGui")
                screenGui.Name = guiName
                screenGui.Parent = COREGUI

                local function bypassEncode(str)
                    local INV = {"\u{FE2D}", "\u{FE2B}", "\u{FE2D}"}
                    local map = {["0"]="０", ["1"]="１", ["2"]="２", ["3"]="３", ["4"]="４", ["5"]="５", ["6"]="６", ["7"]="７", ["8"]="８", ["9"]="９", [" "]="\b"}
                    local function r() return INV[math.random(#INV)] end
                    return str:gsub(".", function(c)
                        if c:match("%a") then return r()..c..r()
                        elseif map[c] then return map[c]
                        else return c end
                    end)
                end

                local function splitByDelimiter(str, delim)
                    local result = {}
                    for word in string.gmatch(str, "([^"..delim.."]+)") do
                        table.insert(result, word)
                    end
                    return result
                end

                local function splitByBypassedChunks(bypassed, maxLen)
                    local parts, current = {}, ""
                    local words = splitByDelimiter(bypassed, "\b")
                    for _, word in ipairs(words) do
                        local next = current ~= "" and current.."\b"..word or word
                        if #next > maxLen then
                            if current ~= "" then table.insert(parts, current) end
                            current = word
                        else
                            current = next
                        end
                    end
                    if current ~= "" then table.insert(parts, current) end
                    return parts
                end

                local CachedChannels = {}

                local function sendBypassedMessage(message, recipient)
                    local firstChar = message:sub(1, 1)
                    local skipEncoding = firstChar == "/" or firstChar == "-" or firstChar == ";" or firstChar == ":" or firstChar == "!"

                    local finalMessages = {}

                    if skipEncoding then
                        table.insert(finalMessages, message)
                    else
                        local prefix, suffix = "\u{05BE}>ˑ\u{0008}", "ˑ\u{0008}"
                        local bypassed = bypassEncode(message):gsub(" ", "\b")
                        local chunks = splitByBypassedChunks(bypassed, 140)
                        for _, chunk in ipairs(chunks) do
                            table.insert(finalMessages, prefix .. chunk .. suffix)
                        end
                    end

                    for _, final in ipairs(finalMessages) do
                        local channel = nil

                        if recipient and recipient ~= "All" then
                            channel = CachedChannels[recipient]
                            if not channel or not channel:IsDescendantOf(TextChatService)
                                or not channel:FindFirstChild(recipient)
                                or not channel:FindFirstChild(LocalPlayer.Name) then
                                CachedChannels[recipient] = nil
                                channel = nil
                            end
                            if not channel then
                                for _, ch in pairs(TextChatService.TextChannels:GetChildren()) do
                                    if ch.Name:find("RBXWhisper:") and ch:FindFirstChild(recipient) then
                                        channel = ch
                                        CachedChannels[recipient] = ch
                                        break
                                    end
                                end
                            end
                        end

                        if not channel then
                            channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                                or TextChatService.TextChannels:FindFirstChild("General")
                        end

                        if channel then
                            channel:SendAsync(final)
                        else
                            local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                            if ev then
                                local say = ev:FindFirstChild("SayMessageRequest")
                                if say then say:FireServer(final, "All") end
                            end
                        end

                        task.wait(0.3)
                    end
                end

                local function Match(str, pattern)
                    return string.match(str, pattern)
                end

                local function getTargetName(targetChip)
                    if targetChip and targetChip:IsA("TextButton") then
                        local displayName = Match(targetChip.Text or "", "^%[To%s+(.-)%]$")
                        if displayName and displayName ~= "" then
                            for _, plr in ipairs(Players:GetPlayers()) do
                                if plr.DisplayName:lower() == displayName:lower() then
                                    return plr.Name
                                end
                            end
                        end
                    end
                    return "All"
                end

                task.spawn(function()
                    repeat task.wait() until COREGUI:FindFirstChild("ExperienceChat")
                    local experienceChat = COREGUI:WaitForChild("ExperienceChat")
                    local appLayout = experienceChat:FindFirstChild("appLayout")
                    if not appLayout then return end

                    local chatInputBar = appLayout:FindFirstChild("chatInputBar")
                    if not chatInputBar then return end

                    local background = chatInputBar:FindFirstChild("Background")
                    if not background then return end

                    local container = background:FindFirstChild("Container")
                    if not container then return end

                    local textContainer = container:FindFirstChild("TextContainer")
                    local textBoxContainer = textContainer and textContainer:FindFirstChild("TextBoxContainer")
                    local chatBox = textBoxContainer and textBoxContainer:FindFirstChild("TextBox")
                    local sendButton = container:FindFirstChild("SendButton")
                    local targetChip = textContainer and textContainer:FindFirstChild("TargetChannelChip")

                    if chatBox then
                        antiBanConnection = chatBox.FocusLost:Connect(function(enterPressed)
                            if enterPressed and chatBox.Text ~= "" then
                                local msg = chatBox.Text
                                local recipient = getTargetName(targetChip)
                                chatBox.Text = ""
                                local lowered = msg:lower()
                                task.defer(function()
                                    sendBypassedMessage(lowered, recipient)
                                end)
                            end
                        end)
                        table.insert(Connections, antiBanConnection)
                    end

                    if sendButton then
                        sendButton:Destroy()
                    end
                end)

                Notify("Better? Bypass", "Bypass active", 5)
                Notify("watch tutorial", "youtube.com/shorts/z1yCdkbXTi4", 60)
                print("Anti Ban Bypasser Enabled")
            else
                if antiBanConnection then
                    antiBanConnection:Disconnect()
                    antiBanConnection = nil
                end
                if COREGUI:FindFirstChild("NOT BETTER") then
                    COREGUI:FindFirstChild("NOT BETTER"):Destroy()
                end
                Notification.new({
                    Title = "Anti Ban Bypasser",
                    Description = "Disabled",
                    Duration = 3,
                    Icon = "rbxassetid://8997385628"
                })
                print("Anti Ban Bypasser Disabled")
            end
        end,
    })

    -- แท็บ Players
    local PlayersTab = Windows:NewTab({
        Title = "Players",
        Description = "Player Features",
        Icon = "rbxassetid://7733960981"
    })

    -- Section ด้านซ้ายใน Players
    local PlayersSectionLeft = PlayersTab:NewSection({
        Title = "Player Options",
        Icon = "rbxassetid://7743869054",
        Position = "Left"
    })

    -- Section ด้านขวาใน Players
    local PlayersSectionRight = PlayersTab:NewSection({
        Title = "Combat Options",
        Icon = "rbxassetid://7733964719",
        Position = "Right"
    })

    -- Player ESP Toggle (Left)
    local Highlights = {}
    local DistanceLabels = {}
    PlayersSectionLeft:NewToggle({
        Title = "Player ESP",
        Default = false,
        Callback = function(state)
            TogglesState[PlayersSectionLeft] = state
            if state then
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

-- Speed Toggle (Left)
local speedConnections = {}
local speedConnection

PlayersSectionLeft:NewToggle({
    Title = "Speed",
    Default = false,
    Callback = function(state)
        TogglesState["Speed"] = state

        local defaultSpeed = 16       -- ความเร็วเริ่มต้นของ Roblox
        local desiredSpeed = 50       -- ความเร็วที่ต้องการ

        local function applySpeed()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if Humanoid and Humanoid.WalkSpeed ~= desiredSpeed then
                    Humanoid.WalkSpeed = desiredSpeed
                end
            end
        end

        if state then
            for _, conn in ipairs(speedConnections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
            speedConnections = {}

            speedConnection = RunService.RenderStepped:Connect(applySpeed)
            table.insert(speedConnections, speedConnection)

            local charConn = LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                applySpeed()
            end)
            table.insert(speedConnections, charConn)

            Notification.new({
                Title = "Speed",
                Description = "Speed Enabled: " .. tostring(desiredSpeed),
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        else
            for _, conn in ipairs(speedConnections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
            speedConnections = {}

            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
            end

            Notification.new({
                Title = "Speed",
                Description = "Speed Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

-- No Clip Toggle (Left)
local noclipConnections = {}
local loopConnection

PlayersSectionLeft:NewToggle({
    Title = "No Clip",
    Default = false,
    Callback = function(state)
        TogglesState["NoClip"] = state
        local Player = game.Players.LocalPlayer
        local RunService = game:GetService("RunService")

        local Character = Player.Character or Player.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

        local IsActive = false

        local function EnableNoclip()
            IsActive = true

            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end

            loopConnection = RunService.Stepped:Connect(function()
                if not IsActive then return end
                local char = Player.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
            table.insert(noclipConnections, loopConnection)

            print("Noclip Enabled")
        end

        local function DisableNoclip()
            IsActive = false

            for _, conn in ipairs(noclipConnections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
            noclipConnections = {}
            loopConnection = nil

            local char = Player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end

            print("Noclip Disabled")
        end

        local charConn = Player.CharacterAdded:Connect(function(char)
            Character = char
            HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
            if state then
                task.wait(0.5)
                EnableNoclip()
            end
        end)
        table.insert(noclipConnections, charConn)

        if state then
            EnableNoclip()
        else
            DisableNoclip()
        end
    end,
})

    -- God Mode Toggle (Left)
PlayersSectionLeft:NewToggle({
    Title = "God Mode",
    Default = false,
    Callback = function(state)
        TogglesState["GodMode"] = state

        local Player = game.Players.LocalPlayer
        local RunService = game:GetService("RunService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")
        local Root = Character:WaitForChild("HumanoidRootPart")

        local Connections = {}
        local GodModeEnabled = false

        local function enableGodMode()
            GodModeEnabled = true

            Humanoid.Health = math.huge
            Humanoid.MaxHealth = math.huge
            Humanoid.BreakJointsOnDeath = false

            if getconnections then
                for _, conn in ipairs(getconnections(Humanoid.Died)) do
                    conn:Disable()
                end
            end

            for _, s in ipairs(Enum.HumanoidStateType:GetEnumItems()) do
                Humanoid:SetStateEnabled(s, true)
            end

            local protectConn = RunService.Heartbeat:Connect(function()
                if not GodModeEnabled or not Humanoid or not Humanoid.Parent then return end

                if Humanoid.Health < Humanoid.MaxHealth then
                    Humanoid.Health = Humanoid.MaxHealth
                end
                if Humanoid.Health <= 0 then
                    Humanoid.Health = math.huge
                end

                if Root and Root.Position.Y < -200 then
                    Root.CFrame = CFrame.new(0, 50, 0)
                end

                for _, v in ipairs(Character:GetDescendants()) do
                    if v:IsA("BodyVelocity") or v:IsA("BodyGyro") or v:IsA("BodyThrust") or v:IsA("VectorForce") then
                        v:Destroy()
                    end
                end
            end)
            table.insert(Connections, protectConn)

            local antiFallConn = RunService.RenderStepped:Connect(function()
                if Humanoid.PlatformStand then
                    Humanoid.PlatformStand = false
                end
            end)
            table.insert(Connections, antiFallConn)

            local function autoRecoverHealth(remote)
                if not remote:IsA("RemoteEvent") and not remote:IsA("RemoteFunction") then return end
                local conn
                if remote:IsA("RemoteEvent") then
                    conn = remote.OnClientEvent:Connect(function(...)
                        if GodModeEnabled and Humanoid and Humanoid.Parent then
                            Humanoid.Health = Humanoid.MaxHealth
                        end
                    end)
                elseif remote:IsA("RemoteFunction") then
                    local oldCall = remote.OnClientInvoke
                    remote.OnClientInvoke = function(...)
                        if GodModeEnabled and Humanoid and Humanoid.Parent then
                            Humanoid.Health = Humanoid.MaxHealth
                        end
                        if oldCall then
                            return oldCall(...)
                        end
                    end
                    conn = remote
                end
                table.insert(Connections, conn)
            end

            for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                autoRecoverHealth(obj)
            end
            for _, obj in ipairs(Character:GetDescendants()) do
                autoRecoverHealth(obj)
            end

            print("God Mode Enabled")
        end

        local function disableGodMode()
            GodModeEnabled = false

            for _, conn in ipairs(Connections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                elseif typeof(conn) == "Instance" then
                    if conn:IsA("RemoteFunction") then
                        conn.OnClientInvoke = nil
                    end
                end
            end
            Connections = {}

            if Humanoid then
                Humanoid.MaxHealth = 100
                Humanoid.Health = 100
                Humanoid.BreakJointsOnDeath = true
            end

            print("God Mode Disabled")
        end

        if state then
            enableGodMode()

            local respawnConn = Player.CharacterAdded:Connect(function(char)
                Character = char
                Humanoid = char:WaitForChild("Humanoid")
                Root = char:WaitForChild("HumanoidRootPart")
                task.wait(0.5)
                if GodModeEnabled then
                    enableGodMode()
                end
            end)
            table.insert(Connections, respawnConn)
        else
            disableGodMode()
        end
    end,
})
    
-- Damage ×2 Toggle (Right)
local damageConnection
PlayersSectionRight:NewToggle({
    Title = "Damage ×2",
    Default = false,
    Callback = function(state)
        TogglesState["Damagex2"] = state

        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local Debris = game:GetService("Debris")
        local LocalPlayer = Players.LocalPlayer

        local Connections = {}

        local function isFriendly(attacker, target)
            if attacker.Team and target.Team then
                return attacker.Team == target.Team
            end
            return false
        end

        local function GetEquippedTool(player)
            if not player.Character then return nil end
            for _, child in ipairs(player.Character:GetChildren()) do
                if child:IsA("Tool") then
                    return child
                end
            end
            return nil
        end

        local function SpawnFloatingDamage(targetCharacter, damageAmount)
            local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = hrp
            billboard.Size = UDim2.new(0,100,0,40)
            billboard.StudsOffset = Vector3.new(0,3,0)
            billboard.AlwaysOnTop = true

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1,0,1,0)
            text.BackgroundTransparency = 1
            text.TextScaled = true
            text.Font = Enum.Font.SourceSansBold
            text.TextStrokeTransparency = 0.5
            text.TextColor3 = Color3.new(1,0,0)
            text.Text = tostring(math.floor(damageAmount))
            text.Parent = billboard

            billboard.Parent = workspace
            Debris:AddItem(billboard, 1)
            spawn(function()
                local t0 = tick()
                local duration = 0.8
                while tick() - t0 < duration do
                    local alpha = (tick()-t0)/duration
                    billboard.StudsOffset = Vector3.new(0, 3 + 2*alpha, 0)
                    RunService.Heartbeat:Wait()
                end
            end)
        end

        local function PlayAttackSound(character)
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://12222005"
            s.Volume = 1.5
            s.PlayOnRemove = true
            s.Parent = hrp
            s:Destroy()
        end

        local function DealDamage(attackerPlayer, baseDamage, radius, cooldown, options)
            options = options or {}
            cooldown = cooldown or 0.5
            if not attackerPlayer or not attackerPlayer.Character then return false, "no_character" end

            local now = tick()
            attackerPlayer._lastAttackTick = attackerPlayer._lastAttackTick or 0
            if now - attackerPlayer._lastAttackTick < cooldown then
                return false, "cooldown"
            end
            attackerPlayer._lastAttackTick = now

            local multiplier = options.multiplier or 2
            local finalDamage = baseDamage * multiplier

            local hrp = attackerPlayer.Character:FindFirstChild("HumanoidRootPart") or attackerPlayer.Character:FindFirstChild("Torso")
            if not hrp then return false, "no_hrp" end

            local equippedTool = GetEquippedTool(attackerPlayer)
            if not equippedTool then return false, "no_tool" end

            local hitCount = 0
            local maxTargets = options.maxTargets or math.huge

            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if hitCount >= maxTargets then break end
                if targetPlayer ~= attackerPlayer and targetPlayer.Character then
                    local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
                    if targetHum and targetHRP and targetHum.Health > 0 then
                        if options.ignoreDead and targetHum.Health <= 0 then
                            continue
                        end
                        local distance = (hrp.Position - targetHRP.Position).Magnitude
                        if distance <= radius then
                            if options.respectTeam and isFriendly(attackerPlayer, targetPlayer) then
                                continue
                             end
                            local ok, err = pcall(function()
                                if options.useTakeDamage == false then
                                    targetHum.Health = math.max(0, targetHum.Health - finalDamage)
                                else
                                    targetHum:TakeDamage(finalDamage)
                                end
                                if options.playSound then
                                    PlayAttackSound(targetPlayer.Character)
                                end
                                if options.floatingDamage then
                                    SpawnFloatingDamage(targetPlayer.Character, finalDamage)
                                end
                            end)
                            if ok then
                                hitCount = hitCount + 1
                            else
                                warn("[Damage ×2] Failed to apply damage:", err)
                            end
                        end
                    end
                end
            end
            return true, hitCount
        end

        -- เปิด toggle
        if state then
            damageConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local ok, info = DealDamage(LocalPlayer, 20, 5, 0.9, {
                            multiplier = 2,
                            ignoreDead = true,
                            respectTeam = true,
                            useTakeDamage = true,
                            maxTargets = 5,
                            playSound = true,
                            floatingDamage = true
                        })
                        if ok then
                            Notification.new({
                                Title = "Damage ×2",
                                Description = string.format("Dealt damage to %d targets", info),
                                Duration = 3,
                                Icon = "rbxassetid://8997385628"
                            })
                        else
                            Notification.new({
                                Title = "Damage ×2",
                                Description = "Failed: " .. tostring(info),
                                Duration = 3,
                                Icon = "rbxassetid://8997385628"
                            })
                        end
                    end
                end
            end)
            table.insert(Connections, damageConnection)
            Notification.new({
                Title = "Damage ×2",
                Description = "Enabled: Click to deal double damage!",
                Duration = 5,
                Icon = "rbxassetid://8997385628"
            })
        else
            -- ปิด toggle
            for _, conn in ipairs(Connections) do
                if typeof(conn) == "RBXScriptConnection" then
                    conn:Disconnect()
                end
            end
            Connections = {}
            Notification.new({
                Title = "Damage ×2",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

    -- แท็บ Server
    local ServerTab = Windows:NewTab({
        Title = "Server",
        Description = "Server Management",
        Icon = "rbxassetid://7733960981"
    })

    -- Section ด้านขวาใน Server
    local ServerSectionRight = ServerTab:NewSection({
        Title = "Server Options",
        Icon = "rbxassetid://7733964719",
        Position = "Right"
    })

    -- ServerTeleportUtils
    local ServerTeleportUtils = {}
    ServerTeleportUtils.__index = ServerTeleportUtils

    function ServerTeleportUtils.Rejoin(player)
        if not player or not player.UserId then return end

        local TeleportService = game:GetService("TeleportService")
        local success, result = pcall(function()
            TeleportService:Teleport(game.PlaceId, player)
        end)

        if success then
            Notification.new({
                Title = "Rejoin",
                Description = string.format("%s is rejoining the server", player.Name),
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
            print(("[Rejoin] %s Returned to the original server"):format(player.Name))
        else
            Notification.new({
                Title = "Rejoin",
                Description = "Failed: " .. tostring(result),
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
            warn(("[Rejoin] fail: %s"):format(result))
        end
    end

    function ServerTeleportUtils.ServerHop(player)
        if not player or not player.UserId then return end

        local TeleportService = game:GetService("TeleportService")
        local HttpService = game:GetService("HttpService")
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        local servers = {}

        local function GetServers(cursor)
            local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor then
                url = url .. "&cursor=" .. cursor
            end

            local response = game:HttpGet(url)
            local data = HttpService:JSONDecode(response)
            return data
        end

        local success, data = pcall(function()
            return GetServers()
        end)

        if success and data and data.data then
            for _, server in ipairs(data.data) do
                if type(server) == "table" and server.id ~= currentJobId and server.playing < server.maxPlayers then
                    table.insert(servers, server.id)
                end
            end
        else
            Notification.new({
                Title = "Server Hop",
                Description = "Failed to retrieve server list: " .. tostring(data),
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
            warn("[ServerHop] Unable to retrieve server information:", data)
            return
        end

        if #servers > 0 then
            local newServerId = servers[math.random(1, #servers)]
            local ok, err = pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, newServerId, player)
            end)

            if ok then
                Notification.new({
                    Title = "Server Hop",
                    Description = string.format("%s is hopping to a new server", player.Name),
                    Duration = 3,
                    Icon = "rbxassetid://8997385628"
                })
                print(("[ServerHop] %s has been successfully moved to the new server."):format(player.Name))
            else
                Notification.new({
                    Title = "Server Hop",
                    Description = "Failed: " .. tostring(err),
                    Duration = 3,
                    Icon = "rbxassetid://8997385628"
                })
                warn(("[ServerHop] fail: %s"):format(err))
            end
        else
            Notification.new({
                Title = "Server Hop",
                Description = "No other servers available",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
            warn("[ServerHop] There are no other servers to move to.")
        end
    end

    ServerSectionRight:NewButton({
        Title = "Rejoin",
        Callback = function()
            ServerTeleportUtils.Rejoin(LocalPlayer)
        end,
    })

    ServerSectionRight:NewButton({
        Title = "Server Hop",
        Callback = function()
            ServerTeleportUtils.ServerHop(LocalPlayer)
        end,
    })

    ScreenGui = LocalPlayer.PlayerGui:FindFirstChild("NothingUI") or LocalPlayer.PlayerGui:WaitForChild("NothingUI", 5)
end

loadUI()
setupMapChangeDetection()

table.insert(Connections, LocalPlayer.PlayerGui:GetPropertyChangedSignal("Reset"):Connect(function()
    resetScript()
    loadUI()
    Notification.new({
        Title = "PlayerGui Reset",
        Description = "Reloading YANZ HUB UI",
        Duration = 3,
        Icon = "rbxassetid://8997385628"
    })
end))
