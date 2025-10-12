--===[ Services ]===--
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local StarterGui = game:GetService("StarterGui")

local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local NothingLibrary = loadstring(game:HttpGet(libURL))()

local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.7.7",
    Description = "By lphisv5 | Game : ⚡Race Clicker",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

--===[ Tabs ]===--
local HomeTab = Window:NewTab({
    Title = "HOME",
    Description = "Home Features",
    Icon = "rbxassetid://7733960981"
})

local HomeSection = HomeTab:NewSection({
    Title = "Home",
    Position = "Left"
})

--===[ Home Buttons ]===--
HomeSection:NewButton({
    Title = "Join Discord",
    Callback = function()
        local success, err = pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
        end)

        if success then
            NothingLibrary:Notify({
                Title = "Copied!",
                Content = "Discord link copied to clipboard",
                Duration = 5
            })
        else
            NothingLibrary:Notify({
                Title = "Error",
                Content = "Failed to copy link: " .. tostring(err),
                Duration = 5
            })
        end
    end
})

--===[ Anti AFK Toggle ]===--
local antiAFKState = true

HomeSection:NewToggle({
    Title = "Anti AFK",
    Default = true,
    Callback = function(v)
        antiAFKState = v
    end
})

task.spawn(function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if antiAFKState then
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
            StarterGui:SetCore("SendNotification", {
                Title = "YANZ HUB | Anti-AFK",
                Text = "You were about to be AFK kicked — Protected!",
                Duration = 2.5
            })
        end
    end)
end)

StarterGui:SetCore("SendNotification", {
    Title = "Anti AFK loaded!",
    Text = "You are now protected from being kicked for inactivity.",
    Duration = 3
})

--===[ Main Tab ]===--
local MainTab = Window:NewTab({Title="Main", Description="Auto System", Icon="rbxassetid://7733960981"})
local AutoClickSection = MainTab:NewSection({Title="Auto Click", Icon="rbxassetid://7733916988", Position="Left"})
local AutoWinsSection = MainTab:NewSection({Title="Auto Wins", Icon="rbxassetid://7733916988", Position="Right"})

--===[ States ]===--
local state = {
    autoClick = false,
    autoWins = false
}

--===[ Safe Notify Wrapper ]===--
local function SafeNotify(info)
    local success, err = pcall(function()
        if NothingLibrary.Notify then
            NothingLibrary:Notify(info)
        elseif NothingLibrary.Notification then
            NothingLibrary:Notification(info)
        else
            StarterGui:SetCore("SendNotification", {
                Title = info.Title or "YANZ HUB",
                Text = info.Content or "Notification",
                Duration = info.Duration or 3
            })
        end
    end)
    if not success then
        warn("Notify Error:", err)
    end
end

--===[ Safe Remote Finder ]===--
local function findRemoteEvent(eventName)
    local eventsFolder = ReplicatedStorage:FindFirstChild("Events")
    if not eventsFolder then return nil end
    for _, v in ipairs(eventsFolder:GetChildren()) do
        if v.Name == eventName and v:IsA("RemoteEvent") then
            return v
        end
    end
    return nil
end

--===[ Auto Click ]===--
local function doClick()
    local remoteEventName = "Click!"
    local remote = findRemoteEvent(remoteEventName)
    if remote then
        pcall(function() remote:FireServer() end)
    else
        SafeNotify({
            Title = "Error",
            Content = "RemoteEvent '" .. remoteEventName .. "' not found!",
            Duration = 5
        })
    end
end

AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = false,
    Callback = function(v)
        state.autoClick = v
        if v then
            if not autoClickConnection then
                autoClickConnection = RunService.Heartbeat:Connect(doClick)
                NothingLibrary:Notify({
                    Title = "Auto Click",
                    Content = "Auto Click is now active!",
                    Duration = 3
                })
            end
        else
            if autoClickConnection then
                autoClickConnection:Disconnect()
                autoClickConnection = nil
                NothingLibrary:Notify({
                    Title = "Auto Click",
                    Content = "Auto Click is now inactive.",
                    Duration = 3
                })
            end
        end
    end
})


--===[ Auto Wins ]===--
local stages = {
    {name = "Stage1", cframe = CFrame.new(-4569.67, 5.38, 0.08)},
    {name = "Stage2", cframe = CFrame.new(-9352.16, 3.13, 0.08)},
    {name = "Stage3", cframe = CFrame.new(-21810.46, 3.22, 0.08)},
    {name = "Stage4", cframe = CFrame.new(-39570.17, 3.22, 0.08)},
    {name = "Stage5", cframe = CFrame.new(-63559.04, 3.22, 0.08)},
    {name = "Stage6", cframe = CFrame.new(-93380.27, 3.22, 0.08)},
    {name = "Stage7", cframe = CFrame.new(-129828.51, 3.22, 0.08)},
    {name = "Stage8", cframe = CFrame.new(-171708.46, 3.22, 0.08)},
    {name = "Stage9", cframe = CFrame.new(-219552.24, 3.22, 0.08)},
    {name = "Stage10", cframe = CFrame.new(-273359.94, 3.22, 0.08)},
    {name = "Stage11", cframe = CFrame.new(-345854.54, 3.22, 0.08)},
    {name = "Stage12", cframe = CFrame.new(-441807.16, 3.22, 0.08)}
}

local currentStage = 1
local flyVelocity = nil

local function setupUndetectedFly(hrp)
    if flyVelocity then flyVelocity:Destroy() end
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyVelocity.Parent = hrp
end

local function moveToPosition(hrp, targetPos)
    if not flyVelocity then return end
    local direction = (targetPos - hrp.Position).Unit
    local distance = (targetPos - hrp.Position).Magnitude
    local speed = math.min(distance * 10, 999999999999999)
    flyVelocity.Velocity = direction * speed
    task.wait(0.001 * (distance / 1000))
    flyVelocity.Velocity = Vector3.new(0, -9.81, 0)
    task.wait(0.001)
    flyVelocity.Velocity = Vector3.new(0, 1, 0)
    hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 1, 0))
end

local function tpToStage(stageNum)
    local success = false
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hrp and humanoid and stageNum <= #stages then
        humanoid.Jump = false
        humanoid.JumpPower = 0
        setupUndetectedFly(hrp)
        pcall(function()
            moveToPosition(hrp, stages[stageNum].cframe.Position)
            success = true
            currentStage = stageNum
        end)
    end
    if flyVelocity then flyVelocity:Destroy() end
    return success
end

local function findTimer()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return "" end
    for _, c in ipairs(gui:GetDescendants()) do
        if c:IsA("TextLabel") and c.Text then
            if c.Text:match("%d%d:%d%d") or c.Text:find("Waiting") or c.Text:find("Click to build") or c.Text:find("00:00") then
                return c.Text
            end
        end
    end
    return ""
end

--===[ Auto Farm Wins ]===--
AutoWinsSection:NewToggle({
    Title = "Auto Farm Wins",
    Default = false,
    Callback = function(v)
        state.autoWins = v
        if v then
            SafeNotify({
                Title = "Auto Farm Wins",
                Content = "Started!",
                Duration = 3
            })

            task.spawn(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and hrp then humanoid.JumpPower = 0 end
                currentStage = 1

                while state.autoWins do
                    local txt = findTimer()

                    if txt:find("Waiting") then
                        task.wait(0.00001)

                    elseif txt:find("Click to build") then
                        for i = 1, 300 do
                            task.spawn(doClick)
                            task.wait(0.00001)
                        end

                    elseif txt:match("%d%d:%d%d") then
                        while txt:match("%d%d:%d%d") and state.autoWins do
                            if not tpToStage(currentStage) then break end

                            if currentStage < #stages then
                                currentStage += 1
                            else
                                SafeNotify({
                                    Title = "Auto Farm Wins",
                                    Content = "Reached Final Stage — Restarting!",
                                    Duration = 2
                                })
                                currentStage = 1
                            end

                            task.wait(0.00001)
                            txt = findTimer()
                        end

                    else
                        task.wait(0.00001)
                    end
                end

                if humanoid then humanoid.JumpPower = 16 end
                SafeNotify({
                    Title = "Auto Farm Wins",
                    Content = "Stopped or Completed Cycle",
                    Duration = 3
                })
            end)

        else
            SafeNotify({
                Title = "Auto Farm Wins",
                Content = "Stopped!",
                Duration = 3
            })
        end
    end
})

RunService.Heartbeat:Connect(function()
    pcall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Jump = false
            humanoid.JumpPower = 0
        end
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        end
    end)
end)

local function disableSpectate()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("ScreenGui") or obj:IsA("BillboardGui") then
                if obj.Name:find("Leaderboard") or obj.Name:find("Spectate") or obj.Name:find("Track") then
                    obj.Enabled = false
                end
            end
        end
    end
end

disableSpectate()
