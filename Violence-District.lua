-- โหลด NothingLibrary
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))();
local Notification = NothingLibrary.Notification();
Notification.new({
    Title = "YANZ HUB | Beta Version",
    Description = "Loaded successfully!",
    Duration = 5.5,
    Icon = "rbxassetid://8997385628"
})

-- สร้าง Window
local Windows = NothingLibrary.new({
    Title = "YANZ HUB | Beta Version",
    Description = "Game: Violence District | By lphisv5",
    Keybind = Enum.KeyCode.LeftControl,
    Logo = 'http://www.roblox.com/asset/?id=18898582662'
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

-- Anti Kick Toggle (Right)
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

-- Anti Ban Bypasser Toggle (Right)
local antiBanConnection
RightSection:NewToggle({
    Title = "Anti Ban Bypasser",
    Default = true,
    Callback = function(state)
        if state then
            local Players = game:GetService("Players")
            local TextChatService = game:GetService("TextChatService")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            cloneref = cloneref or function(o) return o end
            local COREGUI = cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")
            local LocalPlayer = Players.LocalPlayer

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
PlayersSectionLeft:NewToggle({
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

-- Speed Toggle (Left)
local speedConnection
PlayersSectionLeft:NewToggle({
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

-- No Clip Toggle (Left)
PlayersSectionLeft:NewToggle({
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

-- God Mode Toggle (Left)
PlayersSectionLeft:NewToggle({
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

-- Damage ×2 Toggle (Right)
local damageConnection
PlayersSectionRight:NewToggle({
    Title = "Damage ×2",
    Default = false,
    Callback = function(state)
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local UserInputService = game:GetService("UserInputService")
        local LocalPlayer = Players.LocalPlayer

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
            if not attackerPlayer or not attackerPlayer.Character then return end

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
                            -- ข้ามถ้าตายแล้ว
                        else
                            local distance = (hrp.Position - targetHRP.Position).Magnitude
                            if distance <= radius then
                                if options.respectTeam and isFriendly(attackerPlayer, targetPlayer) then
                                    -- ข้าม
                                else
                                    if targetHum.Health > 0 then
                                        local ok, err = pcall(function()
                                            if options.useTakeDamage == false then
                                                targetHum.Health = math.max(0, targetHum.Health - finalDamage)
                                            else
                                                targetHum:TakeDamage(finalDamage)
                                            end
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
            damageConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local ok, info = DamageUtils.DealDamageAdvanced(LocalPlayer, 20, 5, 0.9, {
                            multiplier = 2,
                            ignoreDead = true,
                            respectTeam = true,
                            useTakeDamage = true,
                            maxTargets = 5
                        })
                        if not ok then
                            Notification.new({
                                Title = "Damage ×2",
                                Description = "Failed: " .. tostring(info),
                                Duration = 3,
                                Icon = "rbxassetid://8997385628"
                            })
                        else
                            Notification.new({
                                Title = "Damage ×2",
                                Description = string.format("Dealt damage to %d targets", info),
                                Duration = 3,
                                Icon = "rbxassetid://8997385628"
                            })
                        end
                    end
                end
            end)
            Notification.new({
                Title = "Damage ×2",
                Description = "Enabled: Click to deal double damage!",
                Duration = 5,
                Icon = "rbxassetid://8997385628"
            })
        else
            if damageConnection then
                damageConnection:Disconnect()
                damageConnection = nil
            end
            Notification.new({
                Title = "Damage ×2",
                Description = "Disabled",
                Duration = 3,
                Icon = "rbxassetid://8997385628"
            })
        end
    end,
})
