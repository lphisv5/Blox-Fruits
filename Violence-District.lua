local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
local Notification = NothingLibrary.Notification()
Notification.new({
    Title = "YANZ HUB | Beta Version",
    Description = "Loaded successfully!",
    Duration = 5.5,
    Icon = "rbxassetid://8997385628"
})

local Windows = NothingLibrary.new({
    Title = "YANZ HUB | Beta Version",
    Description = "Game: Violence District | By lphisv5",
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
    Default = false,
    Callback = function(state)
        local VirtualUser = game:GetService('VirtualUser')
        local Connections = {}
        if state then
            table.insert(Connections, game:GetService('Players').LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end))
            Notification.new({
                Title = "Anti AFK",
                Description = "Enabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        else
            for _, conn in pairs(Connections) do
                conn:Disconnect()
            end
            Connections = {}
            Notification.new({
                Title = "Anti AFK",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

RightSection:NewToggle({
    Title = "Anti Kick",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Connections = {}
        if state then
            table.insert(Connections, Players.PlayerRemoving:Connect(function(player)
                if player == LocalPlayer then
                    warn("[ANTI-KICK] Attempt to kick detected!")
                    Notification.new({
                        Title = "Anti Kick",
                        Description = "Kick attempt detected!",
                        Duration = 3,
                        Icon = "rbxassetid://8997385628"
                    })
                end
            end))
            Notification.new({
                Title = "Anti Kick",
                Description = "Enabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        else
            for _, conn in pairs(Connections) do
                conn:Disconnect()
            end
            Connections = {}
            Notification.new({
                Title = "Anti Kick",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

local antiBanConnection
RightSection:NewToggle({
    Title = "Anti Ban Bypasser",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local TextChatService = game:GetService("TextChatService")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local COREGUI = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
        local LocalPlayer = Players.LocalPlayer
        local Connections = {}

        local function Notify(titletxt, text, time)
            task.spawn(function()
                local GUI = Instance.new("ScreenGui")
                GUI.Name = "BackgroundNotif"
                GUI.Parent = COREGUI
                local sw = workspace.CurrentCamera.ViewportSize.X
                local sh = workspace.CurrentCamera.ViewportSize.Y
                local nh = sh / 7
                local nw = sw / 5

                local Main = Instance.new("Frame", GUI)
                Main.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
                Main.BackgroundTransparency = 0.2
                Main.BorderSizePixel = 0
                Main.Size = UDim2.new(0, nw, 0, nh)

                local title = Instance.new("TextLabel", Main)
                title.BackgroundColor3 = Color3.new(0, 0, 0)
                title.BackgroundTransparency = 0.9
                title.Size = UDim2.new(1, 0, 0, nh / 2)
                title.Font = Enum.Font.GothamBold
                title.Text = titletxt
                title.TextColor3 = Color3.new(1, 1, 1)
                title.TextScaled = true

                local message = Instance.new("TextLabel", Main)
                message.BackgroundColor3 = Color3.new(0, 0, 0)
                message.BackgroundTransparency = 1
                message.Position = UDim2.new(0, 0, 0, nh / 2)
                message.Size = UDim2.new(1, 0, 1, -nh / 2)
                message.Font = Enum.Font.Gotham
                message.Text = text
                message.TextColor3 = Color3.new(1, 1, 1)
                message.TextScaled = true

                Main.Position = UDim2.new(1, 5, 0, 50)
                task.wait(0.1)
                Main:TweenPosition(UDim2.new(1, -nw, 0, 50), Enum.EasingDirection.Out, Enum.EasingStyle.Bounce, 0.5, true)
                task.wait(time)
                Main:TweenPosition(UDim2.new(1, 5, 0, 50), Enum.EasingDirection.In, Enum.EasingStyle.Bounce, 0.5, true)
                task.wait(0.5)
                GUI:Destroy()
            end)
        end

        if state then
            local guiName = "NOT_BETTER"
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
                        if not channel or not channel:IsDescendantOf(TextChatService) or not channel:FindFirstChild(recipient) or not channel:FindFirstChild(LocalPlayer.Name) then
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
                        channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral") or TextChatService.TextChannels:FindFirstChild("General")
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
                            task.defer(function()
                                sendBypassedMessage(msg:lower(), recipient)
                            end)
                        end
                    end)
                    table.insert(Connections, antiBanConnection)
                end

                if sendButton then
                    sendButton:Destroy()
                end
            end)

            Notify("Anti Ban Bypasser", "Enabled", 5)
            Notify("Tutorial", "youtube.com/shorts/z1yCdkbXTi4", 60)
        else
            for _, conn in pairs(Connections) do
                conn:Disconnect()
            end
            Connections = {}
            if antiBanConnection then
                antiBanConnection:Disconnect()
                antiBanConnection = nil
            end
            if COREGUI:FindFirstChild("NOT_BETTER") then
                COREGUI:FindFirstChild("NOT_BETTER"):Destroy()
            end
            for _, gui in pairs(COREGUI:GetChildren()) do
                if gui.Name == "BackgroundNotif" then
                    gui:Destroy()
                end
            end
            Notification.new({
                Title = "Anti Ban Bypasser",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

-- Players Tab
local PlayersTab = Windows:NewTab({
    Title = "Players",
    Description = "Player Features",
    Icon = "rbxassetid://7733960981"
})

local PlayersSectionLeft = PlayersTab:NewSection({
    Title = "Player Options",
    Icon = "rbxassetid://7743869054",
    Position = "Left"
})

local PlayersSectionRight = PlayersTab:NewSection({
    Title = "Combat Options",
    Icon = "rbxassetid://7733964719",
    Position = "Right"
})

PlayersSectionLeft:NewToggle({
    Title = "Player ESP",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Connections = {}
        local Highlights = {}
        local DistanceLabels = {}

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
            if not player.Character then return end
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
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if not Highlights[player] then
                    local highlight, distanceLabel = createHighlight(player)
                    Highlights[player] = highlight
                    DistanceLabels[player] = distanceLabel
                end
                Highlights[player].Adornee = player.Character
            end
        end

        local function updateDistances()
            task.spawn(function()
                while state do
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
                    task.wait(0.2)
                end
            end)
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
            updateDistances()
            for _, player in ipairs(Players:GetPlayers()) do
                onPlayerAdded(player)
            end
            Notification.new({
                Title = "Player ESP",
                Description = "Enabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
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
            Notification.new({
                Title = "Player ESP",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

PlayersSectionLeft:NewToggle({
    Title = "Speed",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local Connections = {}
        local defaultSpeed = 16
        local desiredSpeed = 100

        local function applySpeed(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.WalkSpeed = state and desiredSpeed or defaultSpeed
            end
        end

        if state then
            if LocalPlayer.Character then
                applySpeed(LocalPlayer.Character)
            end
            table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                applySpeed(char)
            end))
            Notification.new({
                Title = "Speed",
                Description = "Enabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        else
            for _, conn in pairs(Connections) do
                conn:Disconnect()
            end
            Connections = {}
            if LocalPlayer.Character then
                applySpeed(LocalPlayer.Character)
            end
            Notification.new({
                Title = "Speed",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

PlayersSectionLeft:NewToggle({
    Title = "No Clip",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        local RunService = game:GetService("RunService")
        local Connections = {}
        local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        local function applyNoClip(character)
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not state
                end
            end
        end

        if state then
            if Character then
                applyNoClip(Character)
            end
            table.insert(Connections, RunService.Stepped:Connect(function()
                if Character then
                    applyNoClip(Character)
                end
            end))
            table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
                Character = char
                task.wait(0.1)
                applyNoClip(char)
            end))
            Notification.new({
                Title = "No Clip",
                Description = "Enabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        else
            for _, conn in pairs(Connections) do
                conn:Disconnect()
            end
            Connections = {}
            if Character then
                applyNoClip(Character)
            end
            Notification.new({
                Title = "No Clip",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

PlayersSectionLeft:NewToggle({
    Title = "God Mode",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local LocalPlayer = Players.LocalPlayer
        local Connections = {}

        local function protectHealth(character)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if humanoid then
                humanoid.MaxHealth = state and math.huge or 100
                humanoid.Health = state and math.huge or 100
                if state then
                    table.insert(Connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                        if humanoid.Health < math.huge then
                            humanoid.Health = math.huge
                        end
                    end))
                end
            end
        end

        local function antiVoid(character)
            if state then
                table.insert(Connections, RunService.Heartbeat:Connect(function()
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root and root.Position.Y < -20 then
                        root.CFrame = CFrame.new(0, 50, 0)
                    end
                end))
            end
        end

        if state then
            if LocalPlayer.Character then
                protectHealth(LocalPlayer.Character)
                antiVoid(LocalPlayer.Character)
            end
            table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.1)
                protectHealth(char)
                antiVoid(char)
            end))
            Notification.new({
                Title = "God Mode",
                Description = "Enabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        else
            for _, conn in pairs(Connections) do
                conn:Disconnect()
            end
            Connections = {}
            if LocalPlayer.Character then
                protectHealth(LocalPlayer.Character)
            end
            Notification.new({
                Title = "God Mode",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})

PlayersSectionRight:NewToggle({
    Title = "Damage ×2",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local UserInputService = game:GetService("UserInputService")
        local LocalPlayer = Players.LocalPlayer
        local Connections = {}

        local DamageUtils = {}
        DamageUtils.__index = DamageUtils
        local _lastAttackTick = {}

        local function isFriendly(attacker, target)
            if attacker.Team and target.Team then
                return attacker.Team == target.Team
            end
            return false
        end

        function DamageUtils.DealDamageAdvanced(attackerPlayer, baseDamage, radius, cooldown, options)
            options = options or {}
            cooldown = cooldown or 0.5
            if not attackerPlayer or not attackerPlayer.Character then return false, "no_character" end

            local now = tick()
            local last = _lastAttackTick[attackerPlayer] or 0
            if now - last < cooldown then
                return false, "cooldown"
            end
            _lastAttackTick[attackerPlayer] = now

            local multiplier = options.multiplier or 2
            local finalDamage = baseDamage * multiplier
            local attackerChar = attackerPlayer.Character
            local hrp = attackerChar:FindFirstChild("HumanoidRootPart") or attackerChar:FindFirstChild("Torso")
            if not hrp then return false, "no_hrp" end

            local hitCount = 0
            local maxTargets = options.maxTargets or math.huge

            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if hitCount >= maxTargets then break end
                if targetPlayer ~= attackerPlayer and targetPlayer.Character then
                    local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
                    if targetHum and targetHRP then
                        if options.ignoreDead and targetHum.Health <= 0 then
                            -- Skip dead players
                        else
                            local distance = (hrp.Position - targetHRP.Position).Magnitude
                            if distance <= radius then
                                if options.respectTeam and isFriendly(attackerPlayer, targetPlayer) then
                                    -- Skip friendly players
                                else
                                    if targetHum.Health > 0 then
                                        local ok, err = pcall(function()
                                            targetHum:TakeDamage(finalDamage)
                                        end)
                                        if ok then
                                            hitCount = hitCount + 1
                                        else
                                            warn("[DamageUtils] Failed to apply damage:", err)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            return true, hitCount
        end

        if state then
            table.insert(Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local ok, info = DamageUtils.DealDamageAdvanced(LocalPlayer, 20, 5, 0.9, {
                            multiplier = 2,
                            ignoreDead = true,
                            respectTeam = true,
                            maxTargets = 5
                        })
                        Notification.new({
                            Title = "Damage ×2",
                            Description = ok and string.format("Dealt damage to %d targets", info) or "Failed: " .. tostring(info),
                            Duration = 3,
                            Icon = "rbxassetid://8997385628"
                        })
                    end
                end
            end))
            Notification.new({
                Title = "Damage ×2",
                Description = "Enabled: Click to deal double damage!",
                Duration = 5,
                Icon = "rbxassetid://8997385628"
            })
        else
            for _, conn in pairs(Connections) do
                conn:Disconnect()
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

-- Server Tab
local ServerTab = Windows:NewTab({
    Title = "Server",
    Description = "Server Management",
    Icon = "rbxassetid://7733960981"
})

local ServerSectionRight = ServerTab:NewSection({
    Title = "Server Options",
    Icon = "rbxassetid://7733964719",
    Position = "Right"
})

local ServerTeleportUtils = {}
ServerTeleportUtils.__index = ServerTeleportUtils

function ServerTeleportUtils.Rejoin(player)
    if not player or not player.UserId then return end
    local TeleportService = game:GetService("TeleportService")
    local success, result = pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
    Notification.new({
        Title = "Rejoin",
        Description = success and string.format("%s is rejoining the server", player.Name) or "Failed: " .. tostring(result),
        Duration = 3,
        Icon = "rbxassetid://8997385628"
    })
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
        return HttpService:JSONDecode(response)
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
        return
    end

    if #servers > 0 then
        local newServerId = servers[math.random(1, #servers)]
        local ok, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, newServerId, player)
        end)
        Notification.new({
            Title = "Server Hop",
            Description = ok and string.format("%s is hopping to a new server", player.Name) or "Failed: " .. tostring(err),
            Duration = 3,
            Icon = "rbxassetid://8997385628"
        })
    else
        Notification.new({
            Title = "Server Hop",
            Description = "No other servers available",
            Duration = 3,
            Icon = "rbxassetid://8997385628"
        })
    end
end

ServerSectionRight:NewButton({
    Title = "Rejoin",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        ServerTeleportUtils.Rejoin(LocalPlayer)
    end,
})

ServerSectionRight:NewButton({
    Title = "Server Hop",
    Callback = function()
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        ServerTeleportUtils.ServerHop(LocalPlayer)
    end,
})
