-- YANZ HUB | Race Clicker
-- By: lphisv5
-- Version: V0.7.6

--===[ Services ]===--
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInput = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

--===[ Load UI Lib ]===--
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local NothingLibrary = loadstring(game:HttpGet(libURL))()

local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.7.6",
    Description = "By lphisv5 | Game : ⚡ Race Clicker",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

--===[ Tabs ]===--
local HomeTab = Window:NewTab({ Title = "HOME", Description = "Home Features", Icon = "rbxassetid://7733960981" })
local MainTab = Window:NewTab({Title="Main", Description="Auto System", Icon="rbxassetid://7733960981"})
local AutoClickSection = MainTab:NewSection({Title="Auto Click", Icon="rbxassetid://7733916988", Position="Left"})
local AutoWinsSection = MainTab:NewSection({Title="Auto Wins", Icon="rbxassetid://7733916988", Position="Right"})

--===[ States ]===--
local state = {
    autoClick = false,
    autoWins = false
}


--===[ Auto Click ]===--
local autoClickConnection = nil

local function doClick()
    local remote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Click3")
    if remote and remote.FireServer then
        remote:FireServer()
    end
end

AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = false,
    Callback = function(v)
        state.autoClick = v
        if v then
            if autoClickConnection then autoClickConnection:Disconnect() end
            autoClickConnection = RunService.Heartbeat:Connect(function()
                doClick()
            end)
        else
            if autoClickConnection then autoClickConnection:Disconnect() end
            autoClickConnection = nil
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
    print("Undetected fly mode setup with BodyVelocity.")
end

local function moveToPosition(hrp, targetPos)
    if not flyVelocity then return end
    local direction = (targetPos - hrp.Position).Unit
    local distance = (targetPos - hrp.Position).Magnitude
    local speed = math.min(distance * 50, 999999999999)
    flyVelocity.Velocity = direction * speed
    task.wait(0.003 * (distance / 1000))
    flyVelocity.Velocity = Vector3.new(0, -9.81, 0)
    task.wait(0.002)
    flyVelocity.Velocity = Vector3.new(0, 0, 0)
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
            print("Moved to " .. stages[stageNum].name)
            currentStage = stageNum
        end)
    end
    if flyVelocity then flyVelocity:Destroy() end
    if not success then
        print("Failed to move to " .. stages[stageNum].name)
    end
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

AutoWinsSection:NewToggle({
    Title = "Auto Farm Wins",
    Default = false,
    Callback = function(v)
        state.autoWins = v
        if v then
            task.spawn(function()
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and hrp then
                    setupUndetectedFly(hrp)
                    humanoid.JumpPower = 0
                    print("Undetected fly mode activated for Auto Wins.")
                end
                while state.autoWins do
                    local txt = findTimer()
                    print("Timer Status: " .. txt)
                    if txt:find("Waiting") then
                        print("Waiting for race to start...")
                        task.wait(0.05)
                    elseif txt:find("Click to build") then
                        print("Spamming clicks...")
                        for i = 1, 30 do
                            doClick()
                            task.wait(0.03)
                        end
                    elseif txt:match("%d%d:%d%d") then
                        print("Race in progress, starting ultra fast TP loop...")
                        local lastTimerUpdate = tick()
                        while txt:match("%d%d:%d%d") and state.autoWins do
                            for i = 1, #stages do
                                tpToStage(i)
                            end
                            if tick() - lastTimerUpdate > 0.05 then
                                txt = findTimer()
                                lastTimerUpdate = tick()
                            end
                            RunService.Heartbeat:Wait()
                        end
                    elseif txt:find("00:00") then
                        print("Race ended, resetting Auto Wins...")
                        state.autoWins = false
                        break
                    else
                        print("Unknown timer state: " .. txt)
                        task.wait(0.05)
                    end
                end
                if flyVelocity then flyVelocity:Destroy() end
                if humanoid then
                    humanoid.JumpPower = 50
                    print("Undetected fly mode deactivated.")
                end
            end)
        end
    end
})


--===[ HOME ]===--
HomeSection:NewButton({
    Title = "Join Discord",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/DfVuhsZb") end)
        NothingLibrary:Notify({ Title = "Copied!", Content = "Link copied to clipboard", Duration = 5 })
    end
})


--===[ Anti-Jump and Anti-Follow Fix ]===--
RunService.Heartbeat:Connect(function()
    pcall(function()
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Jump = false
            humanoid.JumpPower = 0
        end
        if Workspace.CurrentCamera then
            Workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character.Humanoid
        end
    end)
end)

--===[ Disable Spectate/Leaderboard Tracking ]===--
local function disableSpectate()
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("ScreenGui") or obj:IsA("BillboardGui") then
                if obj.Name:find("Leaderboard") or obj.Name:find("Spectate") or obj.Name:find("Track") then
                    obj.Enabled = false
                    print("Disabled GUI: " .. obj.Name)
                end
            end
        end
    end
end
disableSpectate()
